# 反向传播

模型定义：

$$
Z = W_1X + b_1 \\
A = \sigma(Z) \\
\hat{y} = W_2A + b_2 \\
y = 1 \\
Loss = (y - \hat{y})^2
$$

其中 $ W_1 $，$ W_2 $，$ b_1 $，$ b_2 $，$ X $ 定义如下：

$$
W_1 = \begin{bmatrix}
  1.0 & 2.0 \\
  3.0 & 4.0
\end{bmatrix}
\quad
W_2 = \begin{bmatrix}
  3.0 & 4.0
\end{bmatrix}
$$

$$
b_1 = \begin{bmatrix}
  0.0 \\
  0.0
\end{bmatrix}
\quad
b_2 = \begin{bmatrix}
  0.0 \\
\end{bmatrix}
$$

$$
X = \begin{bmatrix}
  1.0 \\
  2.0
\end{bmatrix}
$$

## 前向传播

### 隐藏层

$$
\begin{equation}
\begin{split}
  z_1 &= w_1X + b_{11} \\
      &= w_{11}x_1 + w_{12}x_2 + b_{11} \\
      &= 1.0 \times 1.0 + 2.0 \times 2.0 + 0.0 \\
      &= 5.0
\end{split}
\end{equation}
$$

$$
\begin{equation}
\begin{split}
  z_2 &= w_2X + b_{12} \\
      &= w_{21}x_1 + w_{22}x_2 + b_{12} \\
      &= 3.0 \times 1.0 + 4.0 \times 2.0 + 0.0 \\
      &= 11.0
\end{split}
\end{equation}
$$

$$
Z =
\begin{bmatrix}
  z_1 \\ z_2
\end{bmatrix} =
\begin{bmatrix}
  5 \\ 11
\end{bmatrix}
$$

$$
A = \sigma(Z) = \frac{1}{1+e^{-z}} = \begin{bmatrix} 0.993307 \\ 0.999983 \end{bmatrix}
$$

### 输出层

$$
\begin{equation}
\begin{split}
  \hat{y} &= W_2A + b_{2} \\
          &= w_{1}a_1 + w_{2}a_2 + b_{2} \\
          &= 3.0 \times 0.993307 + 4.0 \times 0.999983 + 0.0 \\
          &= 6.979855
\end{split}
\end{equation}
$$

## 反向传播

$$
Loss = (y - \hat{y})^2 = (1 - 6.979855)^2 = 35.758659
$$

### 输出层

根据链式法则，$ L $ 对 $ W_2 $ 求偏导：

$$
\frac{\partial{L}}{\partial{W_2}} = \frac{\partial{L}}{\partial{\hat{y}}} \cdot \frac{\partial{\hat{y}}}{\partial{W_2}} =
\frac{\partial{L}}{\partial{\hat{y}}} \cdot
\begin{bmatrix}
  \frac{\partial{L}}{\partial{w_1}} \\ \frac{\partial{L}}{\partial{w_2}}
\end{bmatrix}
$$

计算 $ L $ 对 $ \hat{y} $ 的偏导：

$$
\frac{\partial{L}}{\partial{\hat{y}}} = 2(y - \hat{y}) = 2 \times (1 - 6.979855) = 11.959709
$$

分别计算 $ \hat{y} $ 对 $ w_1 $ 和 $ w_2 $ 的偏导：

$$
\frac{\partial{\hat{y}}}{\partial{w_1}} = (w_{1}a_1 + w_{2}a_2 + b_{2})' = a_1 = 0.993307
$$

$$
\frac{\partial{\hat{y}}}{\partial{w_2}} = (w_{1}a_1 + w_{2}a_2 + b_{2})' = a_2 = 0.999983
$$

整理得到：

$$
\frac{\partial{L}}{\partial{W_2}} =
\begin{bmatrix}
  11.879665 \\ 11.959510
\end{bmatrix}
$$

### 隐藏层

根据链式法则，$ L $ 对 $ W_1 $ 求偏导：

$$
\frac{\partial{L}}{\partial{W_1}} =
\frac{\partial{L}}{\partial{\hat{y}}} \cdot \frac{\partial{\hat{y}}}{\partial{W_1}} =
\frac{\partial{L}}{\partial{\hat{y}}} \cdot
\frac{\partial{\hat{y}}}{\partial{A}} \cdot
\frac{\partial{A}}{\partial{Z}} \cdot
\frac{\partial{Z}}{\partial{W_1}}
$$

计算 $ L $ 对 $ A $ 的偏导：

$$
\frac{\partial{\hat{y}}}{\partial{A}} = (\hat{y} = W_2A + b_2)' = W_2 = \begin{bmatrix} 3.0 \\ 4.0 \end{bmatrix}
$$

计算 $ A $ 对 $ Z $ 的偏导：

$$
\sigma'(z) = \sigma(z) \cdot (1 - \sigma(z))
$$

$$
\frac{\partial{A}}{\partial{Z}} = \begin{bmatrix} \sigma'(z_1) \\ \sigma'(z_2) \end{bmatrix} =
\begin{bmatrix}
\sigma(5.0) \cdot (1-\sigma(5.0)) \\ \sigma(11.0) \cdot (1-\sigma(11.0))
\end{bmatrix} =
\begin{bmatrix}
  0.006648 \\ 0.000017
\end{bmatrix}
$$

计算 $ Z $ 对 $ W_1 $ 的偏导：

$$
\frac{\partial{Z}}{\partial{W_1}} = (W_1X + b_1)' = X = \begin{bmatrix} 1.0 \\ 2.0 \end{bmatrix}
$$

分别计算 $ L $ 对 $ w_{11} $ 和 $ w_{12} $ 的偏导：

$$
\begin{equation}
\begin{split}
  \frac{\partial{L}}{\partial{w_{11}}} &=
  \frac{\partial{L}}{\partial{\hat{y}}} \cdot
  \frac{\partial{\hat{y}}}{\partial{a_1}} \cdot
  \frac{\partial{a_1}}{\partial{z_1}} \cdot
  \frac{\partial{z_1}}{\partial{w_{11}}} \\
  &=
  \frac{\partial{L}}{\partial{\hat{y}}} \cdot
  w_1 \cdot
  \sigma'(z_1) \cdot
  x_1 \\
  &=
  11.959709 \times 3.0 \times 0.006648 \times 1.0 \\
  &= 0.238526
\end{split}
\end{equation}
$$

$$
\begin{equation}
\begin{split}
  \frac{\partial{L}}{\partial{w_{12}}} &=
  \frac{\partial{L}}{\partial{\hat{y}}} \cdot
  w_1 \cdot
  \sigma'(z_1) \cdot
  x_2 \\
  &=
  11.959709 \times 3.0 \times 0.006648 \times 2.0 \\
  &= 0.477051
\end{split}
\end{equation}
$$

分别计算 $ L $ 对 $ w_{21} $ 和 $ w_{22} $ 的偏导：

$$
\begin{equation}
\begin{split}
  \frac{\partial{L}}{\partial{w_{21}}} &=
  \frac{\partial{L}}{\partial{\hat{y}}} \cdot
  w_2 \cdot
  \sigma'(z_2) \cdot
  x_1 \\
  &=
  11.959709 \times 4.0 \times 0.000017 \times 1.0 \\
  &= 0.000798
\end{split}
\end{equation}
$$

$$
\begin{equation}
\begin{split}
  \frac{\partial{L}}{\partial{w_{21}}} &=
  \frac{\partial{L}}{\partial{\hat{y}}} \cdot
  w_2 \cdot
  \sigma'(z_2) \cdot
  x_2 \\
  &=
  11.959709 \times 4.0 \times 0.000017 \times 2.0 \\
  &= 0.001597
\end{split}
\end{equation}
$$

整理得到：

$$
\frac{\partial{L}}{\partial{W_1}} = \begin{bmatrix}
  0.238526 & 0.477051 \\
  0.000798 & 0.001597
\end{bmatrix}
$$

## 更新参数

设学习率 $ \eta = 0.1$，参数更新公式如下：

$$
W \leftarrow W - \eta \cdot \nabla
$$

对 $ W_2 $ 有：

$$
W_{2} \leftarrow W_{2} - \eta \cdot \frac{\partial{L}}{\partial{W_2}}
$$

对 $ W_1 $ 有：

$$
W_{1} \leftarrow W_{1} - \eta \cdot \frac{\partial{L}}{\partial{W_1}}
$$

