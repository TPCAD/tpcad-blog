# Python Data Type

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
