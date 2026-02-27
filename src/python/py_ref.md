# Python Reference

## Builtin Functions

Check this [site](https://docs.python.org/3/library/functions.html).

## Data Type

### Number

- integer
- float
- complex

```python
a = 42
b = 3.14
c = 4 + 2j
```

#### Operation

-  除法运算的结果为浮点数
```python
35 / 5 # 7.0
10 / 3 # 3.3333333333333335
```
- 整除，向下取整
```python
5 // 3 # 1
```
- 乘方
```python
2**3 # 8
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

### Sequence Types

Python 中的「序列类型」类似 C 中的数组，由一系列连续的内存存储，可通过索引访问。List、Tuple 和 Range 是三种基本的序列类型。另外还有为处理二进制数据和文本字符串而特别定制的序列类型 Bytes 和 String。

序列类型可大致分为「可变序列类型」和「不可变序列类型」。可变序列类型，如 List 可以修改元素，而不可变序列类型，如 String 则不允许修改元素，任何返回新序列的操作都会创建新序列。

以下是可变序列类型和不可变序列类型都支持的操作。

#### Index

序列类型支持通过索引访问元素，索引从 0 开始。

```python
s = "Hello World"
assert(s[0] == 'H')

l = [0, 1, 2]
assert(l[1] == 1)
```

索引可以是负数，负数索引从 -1 开始。

```python
s = "Hello World"
assert(s[-1] == 'd')
assert(s[-6] == ' ')

l = [0, 1, 2]
assert(l[-1] == 2)
assert(l[-3] == 0)
```

#### Slice

序列类型支持切片操作。切片是一个左闭右开区间，起始索引可以省略，表示从索引 0 开始；结束索引也可以省略，表示到最后一个元素。切片也支持负数索引和步进。

```python
s = "Hello World"
assert(s[0:5] == "Hello")
assert(s[:5] == "Hello")    # 省略起始索引
assert(s[6:] == "World")    # 省略结束索引
assert(s[:-6] == "Hello")   # 负数索引
assert(s[2:10:2] == "loWr") # 步进
```

切片只支持从左到右，不能从右到左。

```python
s = "Hello World"
assert(s[2:-2] == "llo Wor")
assert(s[-2:2] == "")
```

#### Concatenation

- `+`可以拼接两个序列
```python
assert("Hello" + "World" + "Again" == "HelloWorldAgain")
```

拼接不可变序列类型总是会创建新序列，并且`+`总是从左到右执行，因此`+`越多，时间复杂度越高。

对于 String 类型，可以使用`str.join()`拼接字符串。

```python
assert(" ".join(["Hello", "World"]) == "Hello World")
assert("".join(["Py", "thon"]) == "Python")
```

- `*`可以重复序列
```python
assert("Hello" * 3 == "HelloHelloHello")
assert(3 * "Hello" == "HelloHelloHello")
```

`*`只会进行「浅拷贝」。因此，对于列表等类型，`*`会多次引用同一个列表。

```python
l = [[]] * 3
assert(l == [[], [], []])
l[0].append(3)
assert(l == [[3], [3], [3]])

# 创建独立的多维数组
A = [None] * 3
for i in range(3):
    A[i] = [None] * 2
assert(A == [[None, None], [None, None], [None, None]])

# 使用列表生成表达式
B = [[None] * 2 for i in range(3)]
assert(B == [[None, None], [None, None], [None, None]])
```

#### Existence

`in`和`not in`可以判断序列存不存在某一元素。

```python
l = ["Python", "Rust", "C"]
assert("Python" in l)
assert("C++" not in l)
```

#### Builtin Functions

- `len()`返回序列的长度
```python
l = [0, 1, 2]
s = "C++"
assert(len(l) == len(s))
```
- `min()`返回序列中值最小的元素
```python
l = [0, 1, 2]
s = "abc"
assert(min(l) == 0)
assert(min(s) == 'a')
```
- `max()`返回序列中值最大的元素
```python
l = [0, 1, 2]
s = "abc"
assert(min(l) == 2)
assert(min(s) == 'c')
```

#### Builtin Methods

以下是可变序列类型和不可变序列类型都支持的方法。

- `sequence.count(value, /)`

返回指定元素在序列中出现的次数。

```python
s = "Hello World"
assert(s.count('l') == 3)
```

- `sequence.index(index[, start[, stop]])`

返回指定元素在序列中第一次出现的索引，可分别指定起始索引和结束索引。若元素不存在则抛出错误 ValueError。

```python
s = "Hello World"
assert(s.index('l') == 2)
```

### Immutable Sequence

所有不可变序列都支持`hash()`。`hash()`可以将对象转换为整数，加速查找。

### Mutable Sequence

可变序列类型支持通过索引、切片修改或删除元素。

```python
l = [0, 1, 2, 3, 4, 5]
l[2] = 1
assert(l[2] == 1)

l[0:3] = "abc" # 任意可迭代类型
assert(l == ['a', 'b', 'c', 3, 4, 5])

l = [0, 1, 2, 3, 4, 5]
l[::2] = "foo"
assert(l == ['f', '1', 'o', 3, 'o', 5])

l = [0, 1, 2, 3, 4, 5]
del l[0]
assert(l = [1, 2, 3, 4, 5])

del l[0:5:2]
assert(l = [2, 4])
```

可变序列类型支持`+`和`*`的自赋值。`*=`与`*`一样只进行浅拷贝。

```python
l = [0, 0]
assert(l+=[1, 1] == [0, 0, 1, 1])

l = [0, 0]
assert(l*=2 == [0, 0, 0, 0])
```

#### Builtin Methods

##### append()

```python
sequence.append(value, /)
```

在序列末尾添加元素。

```python
l = [0, 1, 2]
l.append(3)
assert(l == [0, 1, 2, 3])
```

##### clear()

清空序列元素。

```python
l = [0, 1, 2]
l.clear()
# del l[:]
assert(l == [])
```

##### copy()

浅拷贝序列。

```python
l = [[0, 1], [2, 3]]
l1 = l.copy()
l1[1].append(4)
assert(l[1] == [2, 3, 4])
```

##### extend()

```python
sequence.extend(iterable, /)
```

在序列末尾添加可迭代对象的元素。

```python
l = [0, 1]
l.extend([2, 3])
assert(l == [0, 1, 2, 3])

l = [0, 1]
l.append([2, 3])
assert(l == [0, 1, [2, 3]])
```

##### insert()

```python
sequence.insert(index, value, /)
```

在序列指定的索引处插入元素。

```python
l = [0, 2]
l.insert(1, 1)
assert(l == [0, 1, 2])
```

##### pop()

```python
sequence.pop(index=-1, /)
```

从序列中删除并返回指定索引处的元素，默认删除最后一个元素。

```python
l = [0, 1, 2]
assert(l.pop(0) == 0)
assert(l == [1, 2])
```

##### remove()

```python
sequence.remove(value, /)
```

删除第一个匹配的元素。

```python
l = [0, 1, 2, 1]
l.remove(1)
assert(l == [0, 2, 1])
```

##### reverse()

```python
sequence.reverse()
```

反转序列。

```python
l = [0, 1, 2]
assert(l == [2, 1, 0])
```

### List

列表是 Python 中最常用的数据类型，它与其他语言中的数组十分类似。列表是**可变序列类型**，可以容纳不同类型的元素。

```python
empty_list = []
type(empty_list) # <class 'list'>
```

创建列表最常用的方法是使用`[]`。

```python
list1 = [2, 4, 5]
list2 = ["Mek", "IC2", "IE"]
```

还可以使用类型构造方法创建列表。

```python
list(iterable=(), /)
```

`iterable`可以是序列类型，支持迭代容器类型或可迭代对象，省略则创建空列表。如果`iterable`是列表，那么将调用列表的`copy`方法（浅拷贝）。

```python
l_tuple = list((1, 2, 3))
assert(l_tuple == [1, 2, 3])

l_range = list(range(1, 4))
assert(l_range == [1, 2, 3])

l_str = list("abc")
assert(l_str == ['a', 'b', 'c'])

l_empty = list()
assert(l_empty == [])
```

列表支持序列类型的通用操作与方法。

```python
li = [0, 1, 2, 3, 4, 5, 6, 7]
assert(li[2:6:2] == [2, 4])
assert(li.pop() == 7)
```

列表还支持`sort`方法。

```python
list.sort(*, key = None, reverse = False)
```

`sort`方法就地排序列表，默认升序排列数字或字母序排列字符串。如果排序过程发生错误，那么整个排序操作将会失败，列表会停留在局部修改过的状态。

```python
l = [2, 8, 1, 3, 9]
l.sort()
assert(l == [1, 2, 3, 8, 9])
```

参数`reverse`可倒序排列。

```python
l = [2, 8, 1, 3, 9]
l.sort(reverse = True)
assert(l == [9, 8, 3, 2, 1])
```

参数`key`指定一个提取比较关键字的函数，该函数会在比较前作用于每一个元素，其返回值将作为比较的关键字。

```python
l = ['lkji', 'ax', 'dsA']
l.sort(key = len)
assert(l == ['ax', 'dsA', 'lkji'])
```

### Tuple

```python
class tuple(iterable = (), /)
```

元组是一种不可变序列类型，常用来存储异构的集合数据，如`enumerate()`产生二元组。

```python
t1 = (1, 3)
t2 = (2, "Python", [0, 1])
t3 = ([0, 1], ("Hello", "World"))
t4 = ()
```

虽然创建元组时通常会用到`()`，但真正构成元组的其实是`,`。`()`是可选的，除了创建空元组。

```python
t = 3,
assert(type(t) == type(tuple()))
```

### Range

Range 是一种不可变序列类型，常用于控制 for 循环次数。

```python
class range(stop, /)
class range(start, stop, step = 1, /)
```

若`step`是正数，Range 所表示的序列满足条件：

$$ r[i] = start + step*i \\ i \ge 0 \\ r[i] \lt stop $$

若`step`是负数，Range 所表示的序列满足条件：

$$ r[i] = start + step*i \\ i \ge 0 \\ r[i] \gt stop $$

```python
assert(list(range(2, 10, 2)) == [2, 4, 6, 8])
assert(list(range(20, 10, -2)) == [20, 18, 16, 14, 12])
assert(list(range(2, 10, -2)) == [])
```

Range 支持序列类型的通用操作与方法，除了`+`和`*`。与列表等类型相比，Range 内存占用更小，因为 Range 只存储`start`、`stop`和`step`三个值，只有在需要的时候才计算序列内容。

### String

字符串是**不可变序列类型**，不能通过索引修改某个字符，所有改变字符串的操作本质都是新建了一个字符串。

```python
s = "hello python"  # 双引号包裹
s = 'hello python'  # 单引号包裹
s = "hello\npython" # 支持转义字符
```

#### Raw String

在引号前加上`r`表示「原始字符串」。

```python
s = r"C:\users\documents"
```

原始字符串不能以奇数个`\`**结束**。因为`\`是表示转义字符开始，后面必须接一个合法字符。原始字符串只是不处理转义，Python 在进行语法分析时仍然把`\`当作转义字符进行处理。

要绕过这个限制可以使用普通字符串转义反斜杠或拼接`\`到末尾。

```python
s = r"C:\users\"       # 错误
s = "C:\\users\\"      # 转义 \
s = r"C:\users" + "\\" # 拼接
```

#### Multiple Line String

三重引号表示多行字符串。换行符会被自动添加到行尾。若不想换行，可以使用续行符`\`。续行符也可用在普通字符串。

```python
s = """\
line 1
line 2
line 3
"""
```

#### f-String

f-字符串是 Python 3.6 引入的格式化字符串语法。

```python
var = Python
s = f"Hello {var}" $ Hello Python
```

#### Builtin Methods

##### capitalize()

将字符串首字符大写，其余小写。

```python
s = "fOO"
assert(s.capitalize() == "Foo")
```

##### count()

```python
count(str, beg = 0, end = len(string))
```

返回字符串`str`在字符串`string`中出现的次数，可指定范围（左闭右开区间）。

```python
s = "abcabdbcab"
assert(s.count('ab') == 3)
assert(s.count('ab', 4) == 1)
assert(s.count('ab', 0, 5) == 2)
```

##### find()

```python
find(str, beg = 0, end = len(string))
```

查找字符串`string`是否包含子字符串`str`，若包含则返回第一个子字符串的起始索引，若不包含则返回 -1。

```python
s = "abcabdbcab"
assert(s.find('ca') == 2)
assert(s.find('ca', 4) == 7)
assert(s.find('ca', 0, 5) == 2)
assert(s.find('ac') == -1)
```

##### index()

```python
index(str, beg = 0, end = len(string))
```

与`find()`相同，但不包含时会抛出异常。

##### replace()

```python
replace(old, new[, max])
```

将字符串中的`old`子串替换为`new`子串，可指定最大范围。

##### split()

```python
split(str=" ", num=string.count(str))
```

使用指定字符分割字符串，默认为空格。返回一个字符串列表。`num`指定分割所得的字符串数量，分割除`num+1`个字符串。

```python
s = "Hello World"
assert(s.split() == ['Hello', 'World'])
assert(s.split('o') == ['Hell', ' W', 'rld'])
assert(s.split('o', 1) == ['Hell', ' World'])
```

##### splitlines()

```python
splitlines(keepends==False)
```

以换行符分割字符串，返回一个字符串列表。`keepends`指明是否保留换行符。

```python
s = "Hello\nWorld"
assert(s.splitlines() == ['Hello', 'World'])
assert(s.splitlines(True) == ['Hello\n', 'World'])
```

##### strip()

```python
strip(chars=None)
```

删除字符串头尾的指定字符。`chars`是要删除字符组成的字符串，省略则删除空格。

```python
s = "www.example.com"
assert(s.strip('w.com') == 'example')
```

### Type Conversion

```python
# 转换为整型
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
assert(r == "a")
```

### for statement

Python 的 for 循环可迭代列表或字符串等任意序列类型。

```python
animals = ['cat', 'dog', 'mouse', 'duck']
for animal in animals:
    print(animal)

# Range 控制 for 循环
for i in range(2, 10, 2):
    print(i)

# enumerate 生成 (index, value) 二元组
for index, animal in enumerate(animals):
    print(index, animal)
```

### while statement

```python
x = 0
while x < 4:
    print(i)
    x += 1
```

### break statement

```python
for i in range(0, 10, 2):
    print(i)
    if i > 6:
        break
```

### continue statement

```python
for i in range(10)
    if i % 2 == 0:
        continue
    print(i)
```

### else statement in loop

在`for`或`while`循环中可以加入`else`语句。

在`for`循环中，`else`语句会在遍历所有元素后执行。

```python
for i in range(0, 10, 2):
    print(i)
else: print("else here")
```

在`while`循环中，`else`语句会在判断条件不成立时执行。

```python
i = 4
while i:
    print(i)
    i -= 1
else: print("else")
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

## Function

### Definition

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

## Comprehension

```python
result = [x**2 for x in range(10) if x % 2 == 0]
# result is [0, 4, 16, 36, 64]
```

## Keywords

- 逻辑值
  - True
  - False
- 逻辑运算
  - and
  - or
  - not
- 条件控制
  - if
  - elif
  - else
- 循环控制
  - for
  - while
  - break
  - continue
- 函数
  - def
  - return
  - lambda
- 类与对象
  - class
  - in
  - is
  - None
  - del
- 异常处理
  - try
  - except
  - finally
  - raise
- 模块
  - import
  - from
  - as
- 作用域
  - global
  - nonlocal
- 异步
  - async
  - await
- 其他
  - assert
  - pass
  - with
  - yield
