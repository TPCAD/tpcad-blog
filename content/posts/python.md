+++
title = 'Python Reference'
date = 2024-11-22T08:24:44+08:00
tags = ['Python']
+++

# Python CheatSheet

## Python Virtual Environment

Python 虚拟环境可以为每个 Python 项目创建一个隔离的环境，每个项目可以拥有独立的依赖包环境，且互不影响

### Create Virtual Environment

```bash
python -m venv venv_name
```

### Activate Virtual Environment

```bash
source venv_name/bin/activate
```

### Deactivate Virtual Environment

```bash
deactivate
```

### Pip Commands

#### Install/Uninstall Packages

```bash
pip install package_name

pip uninstall package_name
```

#### List Packages

```bash
pip list
```

#### Show Certain Package

```bash
pip show package_name
```

## Data Type

### Number

- Integer
- Float
- Complex

#### Operation

1. 除法运算的结果为浮点数
```python
35 / 5 # => 7.0
10 / 3 # => 3.3333333333333335
```
2. 整除，向下取整
```python
5 // 3 # => 1
```
3. 乘方
```python
2**3 # => 8
```

### Boolean

```python
True # 真
False # 假

# 取非
not
# 逻辑与
and
# 逻辑或
or
```

布尔类型其实是整型的子集。

```python
0 == False
1 == True
23 == True # 所有非 0 数值皆为真
```

### Type Conversion

```python
# 转换为浮点数
x = int(1)       # 得到 1
y = int(2.8)     # 得到 2
z = int("3")     # 得到 3
# 转换为浮点数
x = float(1)     # 得到 1.0
y = float(2.8)   # 得到 2.8
z = float("3")   # 得到 3.0
w = float("4.2") # 得到 4.2
# 转换为字符串
x = str("s1")    # 得到 "s1"
y = str(2)       # 得到 "2"
z = str(3.0)     # 得到 "3.0"
# 转换为布尔值
x = bool(23) # True
y = bool('a') # True
z = bool("hello") # True
o = bool("") # False
p = bool('') # False
q = bool(0) # False
```

## Control Flow

### if statement

```python
num = 5
if num > 10:
    print("num is totally bigger than 10.")
elif num < 10:
    print("num is smaller than 10.")
else:
    print("num is indeed 10.")
```

### if expression

```python
a = 330
b = 200
r = "a" if a > b else "b" # 条件放在中间
# r is "a"
```

### for statement

Python 的 for 循环可迭代列表或字符串等任意序列。

```python
animals = ['cat', 'dog', 'mouse', 'duck']
for animal in animals:
    print(animal)

# 带索引
for index, animal in enumerate(animals):
    print(index, animal)
```

#### range()

若想遍历数字序列可以使用 `range()`。

```python
for i in range(5):
    print(i)
# 0 1 2 3 4
# 不包括 5
```

`range()` 可以不从 0 开始。

```python
for i in range(5, 10):
    print(i)
# 5 6 7 8 9
```

`range()` 支持步进。

```python
# 第三个参数为步进值
for i in range(0, 10, 2):
    print(i)
# 0 2 4 6 8
```

#### break statement

```python
for i in range(0, 10, 2):
    print(i)
    if i > 6:
        break
```

#### else statement in for loop

for 循环的 else 语句会在 break 语句未执行的情况下执行，即使没有 break 语句。

```python
for i in range(0, 10, 2):
    if i > 8:
        break
    print(i)
else: print("else here")
```

#### continue statement

```python
for i in range(10)
    if i % 2 == 0:
        continue
    print(i)
```

### pass statement

pass 语句不执行任何操作。语法上需要一个语句，但程序不实际执行任何动作时，可以使用该语句。

```python
while True:
    pass

class example:
    pass

def foo():
    pass
```

### match statement

match 语句类似 C 的 switch 语句。

```python
animal = 'cat'

match animal:
    case 'cat':
        print(animal)
    case 'dog':
        print(animal)
    case 'mouse':
        print(animal)
    case _: # like default in C
        print("No Animal")
```

### while statement

```python
x = 0
while x < 4:
    print(i)
    x += 1
```

### List Generation Expression

```python
result = [x**2 for x in range(10) if x % 2 == 0]
# result is [0, 4, 16, 36, 64]
```

## Function

### Basic Definition

```python
def foo():
    print("foo")

def bar(x, y):
    return x + y
```

### Return Multiple Values

```python
def swap(x, y):
    return y, x

x = 10
y = 20
x, y = swap(x, y)
```

### Default Arguments

```python
def foo(x = 10, y)
    print(x + y)
```

### Special Arguments

```python
def foo(pos1, pos2, /, pos_or_kwd, *, kwd1, kwd2):
    print(pos1)
    print(pos2)
    print(pos_or_kwd)
    print(kwd1)
    print(kwd2)

# 两种传参方式是等价的
foo(1, 2, 3, kwd1=4, kwd2=5)
foo(1, 2, pos_or_kwd=3, kwd1=4, kwd2=5)
```

#### Positional-Only Arguments

仅位置参数，位于 `/` 前，传参时必须严格按照顺序。

```python
def foo(*varargs):
    print(varargs)

foo("hello", " ", "world")
# ('hello', ' ', 'world')
```

#### Positional-Or-Keyword Arguments

位于 `/` 前，`*` 后，这是默认的传参方式。

#### Keyword-Only Arguments

仅关键字参数，位于 `*` 后，传参时必须指定参数名称。

```python
def foo(**varargs):
    print(varargs)

foo(kwd1="hello", kwd2=" ", kwd3="world")
# {'kwd1': 'hello', 'kwd2': ' ', 'kwd3': 'world',}
```

### Lambda Expression

```python
def foo(n):
    return lambda x: x + n

f = foo(42) # 返回一个函数
print(f(2)) # 44
```

## List

列表是 Python 中最常用的数据类型，它与数组十分类似。列表用 `[]` 声明。

```python
empty_list = []
type(empty_list) # <class 'list'>
```

### Definition

常见的定义一个列表的方式：

- []
```python
list1 = [2, 4, 5]
list2 = ["mek", "ic2", "ie"]
```
- from tuple
```python
list3 = list((1, 3, 4))
```
- from range
```python
list4 = list(range(1, 10))
```

### Index

Python 支持负数索引。-1 是最后一个元素，依次类推。正负索引可以混用。

### Slice

切片会返回一个新的列表，原列表不会受影响。
基本语法：

- a_list[start:end]
- a_list[start:end:step]

均为左闭右开区间。

```python
li = [0, 1, 2, 3, 4, 5, 6, 7]
li[2:5] # [2, 3, 4]
li[-5:-2] # [3, 4, 5]
# 注意顺序只能是从左到右，li[-2:-5] 是无效的
li[2:-2] # [2, 3, 4, 5]
```

索引可以省略。

```python
# 起始索引省略表示从索引 0 开始
li[:4] # [0, 1, 2, 3]
# 结束索引省略表示在索引 -1 结束
li[3:] # [3, 4, 5, 6, 7]
# 起始、结束索引都省略可以得到整个列表
li[:] # [0, 1, 2, 3, 4, 5, 6, 7]
```

可以指定步进值，步进值可以为负。

```python
li[2:6:2] # [2, 4]
li[::-1] # [7, 6, 5, 4, 3, 2, 1, 0]
```

### Common Operations

#### Append Element

在末尾添加一个元素。

```python
li.append(8)
```

#### Extend List

用可迭代对象扩展列表。

```python
li.extend([9, 10])
li.extend((11, 12))

# 这个操作会返回一个新的列表，原列表不受影响。
li1 = li + [13]
```

#### Insert Element

在指定索引插入一个元素。

```python
li.insert(2, 78) # [0, 1, 78, 2, 3, ...]
```

#### Remove Element

删除列表中第一个值为 x 的元素。

```python
li.remove(78)
```

删除指定索引的元素，并返回该元素。

```python
li.pop(10)
li.pop() # 若不指定索引则删除并返回最后一个元素
```

#### Delete List

删除列表所有元素。

```python
li.clear() # []
del li[:]
# 这样会把 li 这个变量也删除
del li
```

#### Get Index of Element

获取指定元素在列表中的索引。

```python
li.index(3)
```

可以在特定子序列中搜索。

```python
# 在 [0:2] 区间搜索
li.index(3, 0, 2)
```

#### Count Element

计算列表中指定元素出现的次数。

```python
li.count(3)
```

#### Sort List

就地排序列表。

```python
li.sort()
li.sort(reverse=True) # 倒序
```

#### Reverse List

翻转列表。

```python
li.reverse()
```
