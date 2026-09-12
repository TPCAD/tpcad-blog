# DeepSeek 架构理解

## DeepSeek-V2

### MLA

传统 MHA 中，每个 Transformer 块需要为每个 Token 缓存 $ 2d_h n_h $ 个元素，如果有 $ l $ 层，那么就需要为每个元素缓存 $ 2d_h n_hl $ 个元素。

MLA 的核心是对 K，V 进行「低秩联合压缩」。

$$
\overrightarrow{c}^{KV}_t = W^{DKV} \overrightarrow{h}_t
\\
\overrightarrow{k}^C_t = W^{UK} \overrightarrow{c}^{KV}_t
\\
\overrightarrow{v}^C_t = W^{UV} \overrightarrow{c}^{KV}_t
$$

$ \overrightarrow{c}^KV \in \R^{d_c} $ 是 K，V 的压缩潜在向量，$ d_c \ll d_h n_h $ 是压缩后的维度。$ W^{DKV} \in \R^{d_c \times d} $ 是下投影矩阵，$ W^{UK} \in \R^{d_h n_h \times d_c} $，$ W^{UV} \in \R^{d_h n_h \times d_c} $ 分别是 K，V 的上投影矩阵。在推理过程中，MLA 仅需缓存 $ \overrightarrow{c}^KV $，因此其 KV 缓存仅包含 $ d_cl $ 个元素。

为了减少**训练**时的激活内存，MLA 还对 Q 进行了低秩压缩，尽管这无法减少 KV 缓存。

$$
\overrightarrow{c}^{Q}_t = W^{DQ} \overrightarrow{h}_t
\\
\overrightarrow{q}^C_t = W^{UQ} \overrightarrow{c}^{Q}_t
\\
$$

按照正常思路，需要先恢复 Q，K，V，再进行后续计算。但实际计算中并不需要恢复 K，V，可以直接使用压缩潜在向量计算。

$$
a = q^T k
\\
a = (W^{UQ} \overrightarrow{c}^{Q}_t)^T (W^{UK} \overrightarrow{c}^{KV}_t)
\\
a = (\overrightarrow{c}^{Q}_t)^T (W^{UQ})^T (W^{UK} \overrightarrow{c}^{KV}_t)
$$

注意到，在推理过程中，$ (W^{UQ})^T (W^{UK} $ 是已知参数，可以提前计算。这也是论文中提到的 $ W^UK $ 可以被 $ W^UQ $ 吸收。这样一来计算过程就不再需要恢复 Q，K，V，而是直接使用压缩潜在向量。

#### 解耦旋转位置编码

RoPE 与低秩 KV 压缩不兼容。具体而言，如果直接对 $ \overrightarrow{q}^C_t $，$ \overrightarrow{k}^C_t $ 应用 RoPE，旋转矩阵将与 $ W^UK $ 耦合，导致无法直接使用压缩潜在向量计算。

$$
a = \text{RoPE}(q^T k)
\\
a = (R_m W^{UQ} \overrightarrow{c}^{Q}_t)^T (R_n W^{UK} \overrightarrow{c}^{KV}_t)
\\
a = (\overrightarrow{c}^{Q}_t)^T (W^{UQ})^T R_m^T (R_n W^{UK} \overrightarrow{c}^{KV}_t)
$$

因为矩阵乘法没有交换律，$ W^{UQ} $ 和 $ W^{UK} $ 无法融合，必须计算 $ R_n W^{UK} \overrightarrow{c}^{KV}_t $，也就是恢复 K 的过程。这与 MLA 的思路相悖。

为此 DeepSeek-V2 提出「解耦旋转位置编码」策略，该策略使用额外的多头查询 $ \overrightarrow{q}^R_i \in \R^{d^R_h} $ 和共享键 $ \overrightarrow{k}^R \in \R^{d^R_h} $ 来承载 RoPE。

$$
[\bm{q}^R_{t,1};\bm{q}^R_{t,2};\dots;\bm{q}^R_{t,n_h}] = \bm{q}^R_t = RoPE(W^{QR} \bm{c}^Q_t)
\\
\bm{k}^R_t = RoPE(W^{KR}\bm{h}_t)
\\
\bm{q}_{t,i} = [\bm{q}^C_{t,i};\bm{q}^R_{t,i}]
\\
\bm{k}_{t,i} = [\bm{k}^C_{t,i};\bm{k}^R_{t,i}]
$$

拼接位置编码后计算过程如下：

$$
a = [\bm{q}^C_{t,i},\bm{q}^R_{t,i}]^T [\bm{k}^C_{t,i},\bm{k}^R_{t,i}]
\\
a= \bm{q}^C_{t,i}\bm{k}^C_{t,i} + \bm{q}^R_{t,i}\bm{k}^R_{t,i}
$$

可见，内容部分已经于位置部分解耦，内容部分计算时可以直接使用压缩潜在向量直接计算。

## DeepSeek-V4

### 流形约束超连接

#### 残差连接

残差连接让模型学习「输入与输出的差异如何变换」。

设模型为 $ y = H(x) $。没有残差连接时，模型学习如何让输入 $ x $ 变成 $ y $，也就是 $ H(x) $ 。而残差网络 $ y = x + F(x) $，模型学习如何让 $ x + F(x) $ 变成 $ y $，因为输入 $ x $ 已知，模型只需学习 $ F(x) $，也就是 $ y - x $，输入与输出之间的差异如何变换。

$ y - x $ 称为残差，表示输入与输出的差值。$ F(x) $ 称为残差函数。

#### 超连接

HC 将输入向量 $ x_l \in \R^C $ 扩展成 $ n $ 条残差流 $ x_l \in \R^{n \times C} $（复制 n 次），并引入三个可学习映射（矩阵），$ \mathcal{H}^{res}_l \in \R^{n \times n} $，$ \mathcal{H}^{pre}_l \in \R^{1 \times n} $，$ \mathcal{H}^{post}_l \in \R^{1 \times n} $。

因为 Attention 只接受 $ (1 \times C) $，所以使用 $ \mathcal{H}^{pre}_l $ 将扩展后的残差流映射回 $ (1 \times C) $，计算完后再使用 $ \mathcal{H}^{post}_l $ 映射到 $ (n \times C) $。这里并没有使用原始向量作为 Attention 的输入，而是使用 $ \mathcal{H}^{pre}_l x_l $。这一操作将 $ n $ 条残差流加权求和作为 Attention 的输入。

$ \mathcal{H}^{res}_l \in \R^{n \times n} $ 将 $ n $ 条残差流的信息混合。

$$
\tilde{x_l} = RMSNorm(x_l)
\\
\mathcal{H}^{pre}_l = \alpha_l^{pre} \cdot tanh(\theta_l^{pre} \cdot \widetilde{x_l}^T) + \bm{b}_l^{pre}
\\
\mathcal{H}^{post}_l = \alpha_l^{post} \cdot tanh(\theta_l^{post} \cdot \widetilde{x_l}^T) + \bm{b}_l^{post}
\\
\mathcal{H}^{res}_l = \alpha_l^{res} \cdot tanh(\theta_l^{res} \cdot \widetilde{x_l}^T) + \bm{b}_l^{res}
\\
x_{l+1} = \mathcal{H}^{res}_l \cdot x_l + (\mathcal{H}^{post}_l)^{T} \cdot \mathcal{F}(\mathcal{H}^{pre}_l \cdot x_l, W_l)
$$

根据计算公式，HC 在跨越多层后出现 $ \mathcal{H}^{res}_l $ 连乘，而 $ \mathcal{H}^{res}_l $ 是任意可学习矩阵，没有任何约束。在深层网络中，连乘会将任何微小波动放大。因此 HC 破坏了残差连接的恒等映射。

#### 流形约束超连接

mHC 针对 HC 会破坏恒等映射的问题，将 $ \mathcal{H}^{res}_l $ 换成「双随机矩阵」，并对 $ \mathcal{H}^{pre}_l $ 和 $ \mathcal{H}^{post}_l $ 进行约束。

双随机矩阵满足如下性质：

$$
\mathcal{P}_{\mathcal{M}^{\text{res}}}(\mathcal{H}^{res}_l) :=
\left\{
\mathcal{H}^{res}_l \in \R^{n \times n}
\; \middle| \;
\mathcal{H}^{res}_l \mathbf{1}_n = \mathbf{1}_n, \;
\mathbf{1}_n^T \mathcal{H}^{res}_l = \mathbf{1}_n^T, \;
\mathcal{H}^{res}_l \geqslant 0
\right\}
$$

双随机矩阵的行和、列和都为 1，元素都大于 0。同时，双随机矩阵相乘仍为双随机矩阵。这一特性使得 mHC 在跨越多层后的连乘项 $ \mathcal{H}^{res}_l $ 仍是双随机矩阵，从而**保持恒等映射属性**。这里的保持恒等映射属性是指恒等映射能够**稳定信号通路**的性质。

mHC 通过与 HC 类似的方式得到原始矩阵。

$$
x_l \in \R^{n \times C}
\\
\overrightarrow{x_l} = vec(x_l) \in \R^{1 \times nC}
\\
\overrightarrow{x_l^\prime} = RMSNorm(\overrightarrow{x_l})
\\
\widetilde{\mathcal{H}}^{pre}_l = \alpha_l^{pre} \cdot (\overrightarrow{x_l^\prime} \varphi^{pre}_l) + \bm{b}_l^{pre}
\\
\widetilde{\mathcal{H}}^{post}_l = \alpha_l^{post} \cdot (\overrightarrow{x_l^\prime} \varphi^{post}_l) + \bm{b}_l^{post}
\\
\widetilde{\mathcal{H}}^{res}_l = \alpha_l^{res} \cdot mat(\overrightarrow{x_l^\prime} \varphi^{res}_l) + \bm{b}_l^{res}
$$

其中 $ \varphi^{pre}_l $、$ \varphi^{post}_l \in \R^{nC \times n} $ 和 $ \varphi^{res}_l \in \R^{nC \times n^2} $ 用于动态映射，$ mat(\cdot) $ 是一个从 $ \R^{1 \times n^2} $ 到 $ \R^{n \times n} $ 的重塑函数。

随后通过以下方式获得最终的约束映射：

$$
\mathcal{H}^{pre}_l = \sigma(\widetilde{\mathcal{H}}^{pre}_l)
\\
\mathcal{H}^{post}_l = 2\sigma(\widetilde{\mathcal{H}}^{post}_l)
\\
\mathcal{H}^{res}_l = \text{Sinkhorn-Knopp}(\widetilde{\mathcal{H}}^{res}_l)
$$

Sinkhorn-Knopp 算法是对 $ H^{res}_l $ 进行约束的核心。它首先对矩阵所有元素取指数，保证所有元素为正数，随后交替执行列归一化和行归一化，直到矩阵收敛到一个双随机矩阵。

$$
x_{l+1} = \mathcal{H}^{res}_l \cdot x_l + (\mathcal{H}^{post}_l)^{T} \cdot \mathcal{F}(\mathcal{H}^{pre}_l \cdot x_l, W_l)
$$

