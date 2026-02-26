+++
title = 'NumPy Reference'
date = 2024-11-22T08:24:44+08:00
tags = ['Python', 'NumPy']
+++

# NumPy CheatSheet

## Ndarray

### Create Array

#### array()

```python
import numpy as np
a = np.array([1, 2, 3])
```

#### zeros()

```python
np.zeros(2)
# array([0., 0.])
```

#### ones()

```python
np.ones(2)
# array([1., 1.])
```

#### empty()

元素的值是随即的，由内存当前存储的数据决定。`empty()` 比 `zeros()` 要快，但在使用前一定要初始化。

```python
np.empty(2)
```

#### arange()

```python
np.arange(4)
# array([0, 1, 2, 3])
np.arange(4, 10, 2)
# array([4, 6, 8])
```

#### linspace()

```python
# [4, 10] 之间线性分布的 10 个数
np.linspace(4, 10, num=10)
# array([ 4.          4.66666667  5.33333333  6.          6.66666667  7.33333333
#         8.          8.66666667  9.33333333 10.        ])
```

#### Specify Data Type

默认的数据类型是 `np.float64`。

以上创建数组的函数均可以通过参数 `dtype` 来指定数据类型。

```python
np.ones(2, dtype=np.int64)
np.zeros(2, dtype=np.int64)
```

## Sorting Elements

### sort()

`sort()` 会返回一个新的数组。

```python
a = np.array([2, 4, 12, 1, 22, 11, 5, 3])
print(np.sort(a))
```

## Array's Property

```python
arr = np.array([[1, 2, 3], [4, 5, 6]])

print(arr.ndim) # 2，数组的维数
print(arr.size) # 6，数组的元素个数
print(arr.shape) # (2,3)，数组的形状
```

## Reshape Array

### reshape()

```python
array_example = np.array([[[0, 1, 2, 3],
                           [4, 5, 6, 7]],

                          [[0, 1, 2, 3],
                           [4, 5, 6, 7]],

                          [[0 ,1 ,2, 3],
                           [4, 5, 6, 7]]])

print(np.reshape(array_example, (2, 3, 4)))
# [[[0 1 2 3]
#   [4 5 6 7]
#   [0 1 2 3]]
#
#  [[4 5 6 7]
#   [0 1 2 3]
#   [4 5 6 7]]]
```

## Add New Axis

### newaxis

```python
arr = np.array([[1, 2, 3], [4, 5, 6]])
arr = arr[np.newaxis,:,:] # the same as arr[np.newaxis]

print(arr.shape) # (1, 2, 3)
```

```python
arr = arr[:,np.newaxis,:] # (2, 1, 3)
```

### expand_dims()

```python
arr = np.expand_dims(arr, axis=0) # (1, 2, 3)
arr = np.expand_dims(arr, axis=1) # (2, 1, 3)
arr = np.expand_dims(arr, axis=2) # (2, 3, 1)
arr = np.expand_dims(arr, axis=3) # error!
```

## Slicing of NumPy

**所有由切片产生的新数组都是通过浅拷贝得到的，它们与原数组共享数据（数据指的是数组元素，不包括维度，大小，形状）。**

NumPy 支持 Python 的切片方式，还提供了许多更方便的切片方式。

### Integer Array Indexing

`array[rowIndexArray, columnIndexArray]`。将两个数组的对应元素组合起来得到一个索引从而得到原数组中的元素。高维数组同理。

```python
# 获得索引为 (0,0), (1,1), (2,0) 的元素。
x = np.array([[1, 2], [3, 4], [5, 6]])
y = x[[0,1,2], [0,1,0]]
print(y) # [1,3,5]
```

### Slicing Indexing

`array[columnSlicing, rowSlicing]`。

```python
x = np.array([[1,2,3], [4,5,6],[7,8,9]])
y = x[1:3,:]
print (y)
# [[4 5 6]
#  [7 8 9]]
y = x[...,:] # 整个数组
```

切片索引可以和整数数组索引配合使用。

```python
x[1:2, [1,2]]
```

### Boolean Indexing

NumPy 支持通过逻辑表达式的方式进行切片。

```python
a = np.array([[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12]])

print(a[a > 5]) # [6, 7, 8, 9, 10, 11, 12]
print(a[a%5==0]) # [5, 10]
print(a[(a>2)&(a<10)]) # [3, 4, 5, 6, 7, 8, 9]
# 不能使用 and 和 or，而应使用 & 和 |
```

### Fancy Indexing

```python
x=np.arange(32).reshape((8,4))
print(x)
# 二维数组读取指定下标对应的行
print("-------读取下标对应的行-------")
print (x[[4,2,1,7]])

# [[16 17 18 19] 第 4 行
#  [ 8  9 10 11] 第 2 行
#  [ 4  5  6  7] 第 1 行
#  [28 29 30 31]] 第 7 行
```

### nonzero()

`nonzero()` 会返回一个数组元组，其代表元素的索引。

```python
b = np.nonzero((a>2)&(a<10))

# (array([0, 0, 1, 1, 1, 1, 2]),
#  array([2, 3, 0, 1, 2, 3, 0]))
# 两个数组对应的元素组合起来就是原数组中符合条件的元素的索引

print(a[b]) # [3, 4, 5, 6, 7, 8, 9]
c = list(zip(b[0], b[1])) # [(0, 2), (0, 3), (1, 0), (1, 1), (1, 2), (1, 3), (2, 0)]
```

## Create Array From Existing Data

### vstack()

```python
a1 = np.array([[1, 1],
               [2, 2]])

a2 = np.array([[3, 3],
               [4, 4]])

print(np.vstack((a1, a2)))

# [[1 1]
#  [2 2]
#  [3 3]
#  [4 4]]
```

### hstack()

```python
print(np.hstack((a1, a2)))
# [[1 1 3 3]
#  [2 2 4 4]]
```

### hsplit()

```python
x = np.arange(1, 25).reshape(3, 8)
print(np.hsplit(x,3))
# [array([[ 1,  2,  3,  4],[13, 14, 15, 16]]),
#  array([[ 5,  6,  7,  8],[17, 18, 19, 20]]),
#  array([[ 9, 10, 11, 12],[21, 22, 23, 24]])]
```

## Basic Array Operations

### Arithmetic

只有形状相同的数组才能进行四则运算。

```python
a = np.array(([1,3,4],[2,5,6]))
b = np.ones((2,3))

print(a+b)
# [[2. 4. 5.]
#  [3. 6. 7.]]
print(a-b)
# [[0. 2. 3.]
#  [1. 4. 5.]]
print(a*b)
# [[1. 3. 4.]
#  [2. 5. 6.]]
print(a/b)
# [[1. 3. 4.]
#  [2. 5. 6.]]

print(a.sum())
# 21
print(a.sum(axis=0))
# [ 3  8 10]
print(a.sum(axis=1))
# [ 8 13]
```

### unique()

`unique()` 可以去除数组中的重复元素。

```python
# 去除重复
rng = np.random.default_rng()
x = rng.integers(5, size=(3,4))
print(np.unique(x)) # [0, 1, 2, 3, 4]
# 返回数组元组，第一个数组是去重后的元素，
# 第二个数组是每个元素在原数组中第一次出现的位置（一维展开）,
# 顺序与第一个数组对应
# (array([0, 1, 2, 3, 4]), array([4, 9, 8, 0, 1]))
print(np.unique(x, return_index=True))
# 返回的数组元组中有一个对应每个元素的出现次数的数组。
print(np.unique(x, return_counts=True))
```

`unique()` 可以指定 `axis` 参数。表示某行/列出现多少次。

### Transpose Matrix

```python
rng = np.random.default_rng()
x = rng.integers(5, size=(3,4))
print(x)
print(x.transpose())
print(x.T)
```

### Reverse Array

一维数组。

```python
x = np.arange(6)
print(np.flip(x))
```

二维数组。

```python
rng = np.random.default_rng()
x = rng.integers(5, size=(3,4))
print(x)
print(np.flip(x))
# [[1 4 3 4]
#  [3 2 0 1]
#  [3 0 1 4]]

# [[4 1 0 3]
#  [1 0 2 3]
#  [4 3 4 1]]
```

指定 `axis` 可以翻转行/列。

```python
rng = np.random.default_rng()
x = rng.integers(5, size=(3,4))
print(x)
print(np.flip(x, axis=0))
# [[2 4 1 1]
#  [4 1 3 3]
#  [1 3 0 1]]

# [[1 1 4 2]
#  [3 3 1 4]
#  [1 0 3 1]]
```

也可以只翻转某一列/行。

```python
rng = np.random.default_rng()
x = rng.integers(5, size=(3,4))
print(x)
x[:,1] = np.flip(x[:,1])
print(x)
# [[1 1 1 4]
#  [2 4 0 0]
#  [0 2 1 4]]

# [[1 2 1 4]
#  [2 4 0 0]
#  [0 1 1 4]]
```

### Flatten Multidimensional Array

`flatten()` 和 `ravel()` 都可以将多维数组展开。但 `flatten()` 会产生一个新的数组，而 `ravel()` 则产生一个引用。

```python
print(x.ravel())
print(x.flatten())

# [[4 2 2 3]
#  [0 1 4 0]
#  [3 4 3 3]]

# [4 2 2 3 0 1 4 0 3 4 3 3]
# [4 2 2 3 0 1 4 0 3 4 3 3]
```

### Other

```python
x = np.arange(10)
print(x.max())
print(x.min())
print(x.mean()) # 平均值
print(x.prod()) # 所有元素的积
print(x.std()) # 标准差

# 以上各方法都可指定 axis 参数
x = np.arange(12).reshape(2, 6)
print(x.mean(axis=0)) # [3. 4. 5. 6. 7. 8.] 各列的平均值
print(x.mean(axis=1)) # [2.5 8.5] 各行的平均值
```



## Broadcasting

## Random Number
