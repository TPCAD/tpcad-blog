# Python Reference

## Builtin Functions

Check this [site](https://docs.python.org/3/library/functions.html).

## Names and Objects

Python 的「变量」，准确来说是「名称」，与 C 中的变量不同，它更像是 C 中的指针。在 C 中，变量代表了内存中的一个值，每个变量都是一块独立的内存空间。而在 Python 中，名称是某块内存的标签，一个对象可以拥有多个不同的标签，就像 C 的指针一样，多个指针变量可以指向同一块内存。因此，赋值在 Python 中并不意味着拷贝一块内存到另一块内存，而是让新的指针变量指向一块已经存在的内存。

```python
i = 42
j = 42
assert(id(i) == id(j))
```

对于不可变类型，因为无法修改对象本身，所以修改变量的操作会创建一个新的对象，这使得每个变量看起来都是独立的。

```python
i = 42
j = i
j += 1
assert(i == 42)
assert(j == 43)
```

但对于可变类型，赋值只是拷贝了指针的值，而非指针指向的内存。因此，当对象被修改时，所有的绑定到该对象的名称都可以观测到。

```python
la = [1, 2, 3]
lb = la
lb.append(4)
assert(la = [1, 2, 3, 4])
```

这种特性同样适用于函数传参等场景。

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

```python
s[i:j]
s[i:j:k]
```

切片是一个左闭右开区间，步进省略则为 1，步进不能为 0。

```python
s = [i for i in range(5)]
assert(s[0:5] == [0, 1, 2, 3, 4])
assert(s[10:5] == [])
assert(s[2:4:2] == [2]) # 步进
```

步进的正负决定切片从哪一端开始。当步进为正数时，起始索引必须小于结束索引，此时切片从左侧开始；当步进为负数时，起始索引必须大于结束索引，此时切片从右侧开始。

```python
s = [i for i in range(8)]

assert(s[2:5:2] == [2, 4])
assert(s[5:2:2] == [])

assert(s[-1:-5:-2] == [7, 5])
assert(s[-5:-1:-2] == [])
```

起始索引省略时，根据步进正负决定从哪一端开始；结束索引省略时，根据步进正负决定在哪一端结束。二者都省略则表示整个序列。

```python
s = [i for i in range(8)]

assert(s[:5:2] == [0, 2, 4])
assert(s[:5:-2] == [7])

assert(s[2::2] == [2, 4, 6])
assert(s[2::-2] == [2, 0])

assert(s[::2] == [0, 2, 4, 6])
assert(s[::-2] == [7, 5, 3, 1])
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
l.reverse()
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

### Dictionary

```python
class dict(**kwargs)
class dict(mapping, /, **kwargs)
class dict(iterable, /, **kwargs)
```

字典是一种**映射**类型。与序列类型以连续整数为索引不同，字典以**键**为索引。键可以是任意不可变类型，最常见的是字符串和数字。元组只在其仅包含不可变类型时可作为键。字典的**键**是唯一的，因此可以把字典看作一种**键值对**的集合。

```python
d1 = dict(foo=100, bar=200)
d2 = {"foo": 100, "bar": 200}
assert(d1 == d2)

assert(dict() == {})
```

使用可迭代对象创建字典时，可迭代对象的每一项必须是一个恰好包含两个元素的可迭代对象。第一个元素将作为字典的键，第二个元素将作为字典的值。如果一个键出现多次，那么最后一个值将作为字典的值。

```python
d3 = dict([('foo', 100), ('bar', 200)])
d4 = dict([['foo', 100], ['bar', 200]])
assert(d3 == d4)

d5 = dict([('foo', 100), ('bar', 200), ('foo', 300)])
assert(d5 == {"foo": 300, "bar": 200})
```

#### Index

字典支持通过`[]`或`get()`方法进行索引操作。`get()`方法在键不存在时返回`None`，而`[]`则会报错。

```python
d = {"foo": 100, "bar": 200}
assert(d["foo"] == 100)

d = {1: 100, (1, 2): 200}
assert(d[1] == 100)
assert(d[(1, 2)] == 200)

assert(d.get("ivk") == None)
```

字典是一种可变类型，支持通过索引修改，删除元素。

```python
d = {"foo": 100, "bar": 200}
d["foo"] = 300
assert(d["foo"] == 300)

del d["foo"]
assert("foo" not in d)
```

对一个不存在的键赋值会在尾部插入新的键值对。

```python
d = {"foo": 100, "bar": 200}
d["new"] = 300
assert({"foo": 100, "bar": 200, "new": 300})
```

#### Builtin Functions

##### list()

返回字典所有**键**组成的列表。

```python
d = {"foo": 100, "bar": 200}
assert(list(d) == ["foo", "bar"])
```

##### len()

返回字典项数。

```python
d = {"foo": 100, "bar": 200}
assert(len(d) == 2)
```

##### iter()

返回以字典的键为元素的迭代器。

```python
d = {"foo": 100, "bar": 200}
for i in iter(d):
    print(d[i])
```

##### reversed()

返回一个**逆序**获取字典键的迭代器，相当于`reversed(dict.keys())`。

```python
d = {"foo": 100, "bar": 200}
for i in reversed(d):
    print(d[i])
```

#### Builtin Methods

##### clear()

移除字典所有元素。

```python
d = {"foo": 100, "bar": 200}
d.clear()
assert(d == None)
```

##### copy()

返回字典的浅拷贝。

```python
d = {"foo": [1, 3, 4]}
d1 = d.copy()
d1['foo'][1] = 2

assert(d == {"foo": [1, 2, 4]})
```

##### items()

返回键值对组成的视图。

```python
d = {"foo": [1, 3, 4]}
for i in d.items():
    assert(i == ("foo", [1, 3, 4]))
```

##### keys()

返回由键组成的视图。

```python
d = {"foo": [1, 3, 4]}
for i in d.keys():
    assert(i == "foo")
```

##### values()

返回由值组成的视图。

```python
d = {"foo": [1, 3, 4]}
for i in d.values():
    assert(i == [1, 3, 4])
```

##### update()

```python
dict.update(**kwargs)
dict.update(mapping, /, **kwargs)
dict.update(iterable, /, **kwargs)
```

更新或添加键值对，覆盖原有键。返回 None。

```python
d = {"foo": 100, "bar": 200}
d.update(new=300, bar=400)
assert(d == {"foo": 100, "bar": 400, "new": 300})

d.update([("foo", 100), ("bar", 200)])
assert(d == {"foo": 100, "bar": 200, "new": 300})
```

##### pop()

```python
pop(key, /)
pop(key, default, /)
```

如果`key`存在则将其移除并返回其值，否则返回`default`。若`default`未指定且`key`不存在，则引发`KeyError`。

```python
d = {"foo": 100, "bar": 200}
assert(d.pop("bar") == 200)
assert(d.pop("new", 400) == 400)

assert(d == {"foo": 100})
```

##### popitem()

按 LIFO 顺序移除并返回一个键值对。字典为空则引发`KeyError`。

```python
d = {"foo": 100, "bar": 200}
assert(d.popitem() == ("bar", 200))
```

### Set

```python
class set(iterable=(), /)
```

**集合**是一种由不同**元素**组成的**无序**多项集。

```python
s = {1, 3, 8, 3}
assert(s == {1, 3, 8})
```

#### Builtin Methods

##### add()

```python
set.add(elem, /)
```

添加一个元素到集合。

```python
s = set([1, 5, 8])
s.add(4)
assert(s == {1, 4, 5, 8})
```

##### remove()

```python
set.remove(elem, /)
```

从集合中移除元素，如果不存在则引发`KeyError`。

```python
s = set([1, 5, 8])
s.remove(1)
assert(s == {5, 8})
```

##### discard()

```python
set.discard(elem, /)
```

如果元素`elem`存在于集合中则将其移除。

```python
s = set([1, 5, 8])
s.discard(1)
assert(s == {5, 8})
s.discard(1)
assert(s == {5, 8})
```

##### pop()

从集合中移除并返回任意一个元素。如果集合为空则会引发`KeyError`。

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

### loop tips

遍历字典时可以使用`items()`方法提取键值对。

```python
knights = {'gallahad': 'the pure', 'robin': 'the brave'}
for k, v in knights.items():
    print(k, v)
```

遍历序列时可以使用`enumerate()`函数提取位置索引和对应的值。

```python
for i, v in enumerate(['tic', 'tac', 'toe']):
    print(i, v)
```

遍历多个序列时可以使用`zip()`函数将序列的元素一一匹配。元素个数取决于长度最短的序列。

```python
l = [1, 3, 4]
s = "abcd"
d = {"foo": 100, "bar": 200}
for i in zip(l, s, d):
    print(i)

# (1, 'a', 'foo')
# (3, 'b', 'bar')
```

逆序遍历序列但不改变序列顺序可以使用`reversed()`函数。

```python
l = [1, 3, 4]
for i in reversed(l):
    print(i)
```

不改变序列的前提下重新排序可以使用`sorted()`函数。

```python
l = [10, 3, 1, 4]
for i in sorted(l):
    print(i)
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

### Variable Scope

定义在函数外部的变量都是全局变量（文件内部），函数内部定义的变量是局部变量。函数内部无法访问全局变量。

```python
var = 10
def foo():
    var = 20

foo()
assert(var == 10)
```

保留字`global`用于在函数内部声明全局变量。

```python
var = 10
def foo():
    global var
    var = 20

foo()
assert(var == 20)
```

### Default Argument Values

为参数指定默认值可以以更少的参数调用函数。默认值参数不能位于必选参数之前。

```python
def foo(x, y = 10):
    return x + y

assert(foo(10) == 20)
```

默认值只在函数定义时进行一次求值并存储在函数对象的内部属性`__defaults__`中，后续调用函数时使用的默认值都是这个值。

```python
i = 5
def foo(a=i):
    return i

i += 1
assert(foo() == 5)

def bar(a = 1, b = 2):
    return a + b

assert(bar.__defaults__ == (1, 2))
```

因为默认值只求值一次，所以当默认值是列表、字典等可变对象时，调用函数会共享默认值。

```python
def foo(a, l=[]):
    l.append(a)
    return l

assert(foo(1) == [1])
assert(foo(2) == [1, 2])
assert(foo(3) == [1, 2, 3])
```

若不想在后续调用时共享默认值，可以将默认值设为`None`。

```python
def foo(a, l=None):
    if l is None:
        l = []
    l.append(a)
    return l

assert(foo(1) == [1])
assert(foo(2) == [2])
assert(foo(3) == [3])
```

### Keyword Arguments

除了按顺序传入参数外，Python 还支持键值对形式的关键字参数。

```python
def foo(a, b, c):
    return a + b + c

foo(1, 2, 3)
foo(a=1, b=2, c=3)
foo(b=2, c=3, a=1)  # 乱序
foo(1, c=3, b=2)
# foo(a=1, b=2, 3)  # 关键字参数之后不能有位置参数
```

### Special Parameters

默认情况下，参数可以按顺序或关键字传递给函数。使用`/`和`*`可以限制传参方式。

```python
def foo(pos1, pos2, /, pos_or_kwd, *, kwd1, kwd2):
    pass

# 两种传参方式是等价的
foo(1, 2, 3, kwd1=4, kwd2=5)
foo(1, 2, pos_or_kwd=3, kwd1=4, kwd2=5)
```

#### Positional-Only Arguments

仅位置参数，位于`/`前，传参时必须严格按照顺序。

```python
def foo(arg, /):
    pass

foo(42)
# foo(arg=42)  # 只接受位置参数
```

#### Positional-Or-Keyword Arguments

位于`/`后，`*`前，`/`和`*`可以省略。这是默认的传参方式。

```python
def foo(arg):
    pass

foo(42)
foo(arg=42)
```

#### Keyword-Only Arguments

仅关键字参数，位于`*`后，传参时必须指定参数名称。

```python
def foo(*, arg):
    pass

foo(arg=42)
# foo(42)  # 只接受关键字参数
```

### Arbitrary Arguments List

有时候函数会需要接受任意多个实参。形参的`*`或`**`前缀使得函数可以接受任意多个位置参数或关键字参数。

使用`*`定义不定长位置参数。不定长位置参数必须位于所有普通参数之后，其后的所有参数只能是关键字参数。不定长位置参数会将任意数量的位置参数打包成元组。

```python
def foo(a, b, *args):
    return args

assert(foo(1, 3, 4, 5) == (4, 5))
```

使用`**`定义不定长关键字参数。不定长关键字参数必须位于所有参数之后。不定长关键字参数会将任意数量的关键字参数打包成字典。

```python
def foo(a, b, **kwargs):
    return kwargs

assert(foo(1, 3, f='a', b='d') == {"f": "a", "b": "d"})
```

在传参时使用`*`或`**`可以解包列表、元组或字典。

```python
def foo(a, b, c, d, e, f):
    print(a, b, c, d, e, f)

foo(*[1, 3], *(2, 4), **{"e": 42, "f": 24})
```

### Lambda Expression

函数体只能有一行。

```python
def foo(n):
    return lambda x: x + n

f = foo(42) # 返回一个函数
print(f(2)) # 44
```

## Comprehension

**推导式**可以方便地从一个序列创建新的序列。

### List Comprehension

```python
list = [expression for var in sequence]
list = [expression for var in sequence if condition]
```

列表推导式将`sequence`的每个元素`var`作为参数传入`expression`得到新列表的元素。`if`可以对`var`进行过滤。

```python
assert([x**2 for x in range(10) if x % 2 == 0] == [0, 4, 16, 36, 64])
```

推导式可以包含多个`for`子句。

```python
result = [(x, y) for x in [1,2,3] for y in [3,1,4] if x != y]

# 等价于
combs = []
for x in [1,2,3]:
    for y in [3,1,4]:
        if x != y:
            combs.append((x, y))
```

### Dictionary Comprehension

```python
dict = {key_expression : value_expression for var in sequence}
dict = {key_expression : value_expression for var in sequence if condition}
```

字典推导式比列表推导式多了`key_expression`，用于生成字典的键。

```python
d = {i : i**2 for i in range(3)}
assert({i : i**2 for i in range(3)} == {0: 0, 1: 1, 2: 4})

l = ['foo', 'bar']
assert({l : i for i in range(1, 3)} == {"foo": 1, "bar": 2})
```

### Set Comprehension

集合推导式使用`{}`包裹，语法与列表推导式相同。

```python
assert({i**2 for i in (1,2,3)} == {1, 4, 9})
```

### Tuple Comprehension

元组没有推导式，但可以使用生成器表达式代替。生成器表达式使用`()`包裹，语法与列表推导式相似，但其返回值是一个生成器类型，需要使用`tuple()`生成元组。

```python
assert(tuple((x for x in range(1,3))) == (1, 2))
```

## File Operation

```python
open(filename, mode, encoding=None)
```

`open()`方法用于打开一个文件，其返回一个文件对象。文件对象使用完后必须使用`close()`方法正确关闭。

参数`mode`指明打开文件的方式。在任意模式后加上`b`可以用二进制模式打开文件，以该模式打开文件应该使用`bytes`处理数据。

- `r`：只读
- `w`：只写（覆写）
- `a`：追加
- `r+`：读写

默认编码与平台有关，但最常用的是`encoding='utf-8'`。

在处理文件对象时，最好使用`with`语句。在子句体结束后，文件会被正确关闭。

```python
file = open('file.md', 'w')
file.write("Hello World\n")
file.close()

wiht open('file.md', 'a', encoding='utf-8') as file:
    file.write("Hello World\n")
```

### Builtin Methods

#### read()

```python
fileObject.read(size)
```

`size`指定读取的字符数（文本模式）或字节数（二进制模式）。若省略`size`或`size`为负数则读取整个文件。

```python
wiht open('file.md', 'a', encoding='utf-8') as file:
    while True:
        s = file.read(1024)
        if not s:
            break
        print(s)
```

#### readline()

读取一行数据，返回的字符串保留换行符。

```python
wiht open('file.md', 'a', encoding='utf-8') as file:
    while True:
        l = file.readline()
        if not l:
            break
        print(l, end="")
```

#### readlines()

读取整个文件，返回按行划分的字符串列表。

```python
wiht open('file.md', 'a', encoding='utf-8') as file:
    for l in file.readlines():
        print(l, end="")
```

读取整个文件可以直接遍历文件对象。

```python
wiht open('file.md', 'a', encoding='utf-8') as file:
    for l in file:
        print(l, end="")
```

#### write()

```python
fileObject.write(str)
```

向文件写入字符串。

```python
wiht open('file.md', 'a', encoding='utf-8') as file:
    file.write("Hello World\n")
```

## Exception

```python
try:
    statements
except ErrorType as var:
    statements
except ErrorType:
    statements
else:
    statements
finally:
```

`try`语句执行过程如下：

- 执行`try`子句
- 若没发生异常则跳过`except`子句，跳转执行`else`子句
- 若发生异常，跳过`try`子句的剩余内容，跳转至匹配的`except`子句执行
- 若没有匹配的`except`子句，则向上抛出异常
- 无论发生异常与否都会执行`finally`子句

只有最先匹配的`except`子句会被执行，若想一次匹配多个异常，可以使用元组包裹异常类型。类型`Exception`是所有异常类型的父类，可以用作通配符。一些异常会带有参数，在`except`后使用`as`可以将异常绑定到变量上。

```python
except (NameError, ValueError, TypeError):
    pass
```

## Module

使用`import`导入模块时会执行对应的 Python 文件。利用`__name__`可以避免执行测试代码。

```python
if __name__ == '__main__':
    pass
```

```python
import math
print(math.abs(-42))

from math import abs
print(abs(-42))
print(math.sqrt(9))

from math import *
print(abs(-42))
print(sqrt(9))
```

## Class

```python
class ClassName:
    pass

c = ClassName()
```

`__init__`方法类似与 C++ 中的构造函数，在实例化一个类时会自动调用该函数。

```python
class Complex:
    def __init__(self, real, image):
        self.r = real
        self.i = image

c = Complex(3, 4)
assert(c.r == 3)
assert(c.i == 4)
```

### Class Objects

类本身也是一个对象，在类定义结束时会创建一个「类对象」。类对象支持「属性引用」和「实例化」两种操作。

任何定义在类中的名称都是类对象的属性。

```python
class Foo:
    i = 42

    def bar(self):
        pass
```

`Foo.i`和`Foo.bar`都是类对象`Foo`的有效属性引用，一个返回整数，一个返回函数对象。属性可以被赋值或删除，且不是必须定义在类内部。

```python
assert(Foo.i == 42)
Foo.i = 24
assert(Foo.i == 24)

Foo.a = 100
```

类的实例化使用函数表示法。

```python
foo = Foo()
```

类对象的数据属性是所有实例共享的。因此在共享列表、字典等可变类型时，修改可以被所有实例观测到。

```python
class Foo:
    l = []

f1 = Foo()
f2 = Foo()
f1.l.append(42)
f2.l.append(24)

assert(Foo.l == [42, 24])
```

### Instance Objects

实例对象只支持属性引用操作。实例对象的属性分为两种：数据属性和方法。

数据属性类似于 C++ 中的数据成员，但与 C++ 不同，数据属性无需显式声明，在首次赋值时就会出现。实例对象的数据属性只属于对应实例，其他实例无法访问。

```python
class Foo:
    i = 42

    def bar(self):
        pass

foo = Foo()
foo.a = 10
assert(foo.a == 10)
```

实例对象的方法来自于类对象的函数属性。在定义时，方法的第一个参数通常被命名为`self`，但这只是一个约定，而非语法规定。在使用实例对象调用方法时会自动传入实例本身到这个参数中。而如果使用类对象调用则会要求显式传入一个实例。

```python
class Foo:
    i = 42

    def bar(self):
        pass

foo = Foo()

foo.bar()
Foo.bar(foo)
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
