# Math Reference

## Trigonometric Functions

```txt
       *--
      **
     * *
  l *  *
   *   * h
  *    *
 * θ   *
********--
|   a  |
```

$$
\sin \theta = \frac{h}{l} \quad \cos \theta = \frac{a}{l} \quad \tan \theta = \frac{h}{a}
$$

## Vector

### Dot Product

向量的「点积」，又称「内积」，其结果是一个标量。公式如下：

$$
\vec{a} \cdot \vec{b} = |\vec{a}| |\vec{b}| \cos \theta
$$

数值上等于 $\vec{b}$ 在 $\vec{a}$ 上的投影长度（同方向为正，反方向为负）与 $\vec{a}$ 模的乘积。

### Cross Product

向量的「叉乘」，又称「外积」，其结果仍然是一个向量。

结果向量的大小是两个向量所围成的平行四边形的面积，公式如下：

$$
|\vec{a} \times \vec{b}| = |\vec{a}| |\vec{b}| \sin \theta
$$

结果向量垂直与两个向量所构成的平面，方向由「右手定则」规定。因此向量外积不适用于二维向量。

右手定则具体是：

1. 伸平右手， 保持大拇指与另外四指**垂直**
2. 四指指向 $ \vec{a} $ 方向，掌心朝向 $ \vec{b} $
3. 大拇指所指方向即是结果向量的方向

使用单位向量表示时，向量外积可用矩阵表达：

$$
\vec{a} = a_x\vec{i} + a_y\vec{j} + a_z\vec{k} \\
\vec{b} = b_x\vec{i} + b_y\vec{j} + b_z\vec{k} \\
\vec{a} \times \vec{b} = 
\begin{vmatrix}
  \vec{i} & \vec{j} & \vec{k} \\
  a_x & a_y & a_z \\
  b_x & b_y & b_z
\end{vmatrix}
$$

## Matrix

$$
\begin{vmatrix}
   a & b \\
   c & d
\end{vmatrix}
$$

## Matrix Multiply

两个矩阵的乘法只有当第一个矩阵的列数与第二个矩阵的行数相等时才能定义。

如 $ \bm{A} $ 是 $ m \times n $ 矩阵，$ \bm{A} $ 是 $ n \times p $ 矩阵，二者的乘积 $ \bm{AB} $ 是一个 $ m \times p $ 矩阵。$ \bm{AB} $ 的一个元素可由公式计算：

$$
[\bm{AB}]_{ij} = \bm{A}_{i1}\bm{B}_{1j} + \bm{A}_{i2}\bm{B}_{2j} + \dots + \bm{A}_{in}\bm{B}_{nj} = \sum_{r=1}^n \bm{A}_{ir} \bm{B}_{rj}
$$

## Eigen Vector and Eigen Value

对于任意方阵 $ \bm{A} $，如果存在非零向量 $ \vec{v} $ 和标量 $ \lambda $ ，使得 $ \bm{A} \vec{v} = \vec{v} \lambda $，那么称 $ \lambda $ 为 $ \bm{A} $ 的一个特征值，$ \vec{v} $ 是对应的特征向量。

