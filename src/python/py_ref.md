# Python Reference

## Builtin Functions

Check this [site](https://docs.python.org/3/library/functions.html).

## Names and Objects

在 C 中，每个变量对应着一块唯一的内存地址，哪怕变量的值相等，它们的地址也是不同的。Python 的变量，或者叫「名称（Name）」，更像是某块内存的标签，多个名称可以绑定到同一块内存地址。因此，赋值在 Python 中并不意味着拷贝一块内存到另一块内存，而是为内存贴上新的标签。

```python
i = 42
j = 42
assert(id(i) == id(j))
```

对于不可变类型，因为无法修改对象本身，所以修改变量的操作会创建一个新的对象，这使得每个变量看起来都是独立的。

```python
i = 42
j = i
assert(id(i) == id(j))
j += 1
assert(i == 42)
assert(j == 43)
assert(id(i) != id(j))
```

但对于可变类型，通常都是容器类型，即在栈区存储胖指针，在堆区存储实际数据，赋值只是为栈区内存添加新的标签。因此，当对象被修改时，所有的绑定到该对象的名称都可以观测到。

```python
la = [1, 2, 3]
lb = la
assert(id(la) == id(lb))
assert(la == lb)
lb.append(4)
assert(la == lb)
```

注意，这并不意味着具有相同内容的可变类型变量都指向同一块内存。以列表为例，因为是可变类型，所以每次创建列表时都会开辟一块新的内存，而不是指向一块内容相同的旧内存。

```python
la = [1, 2, 3]
lb = [1, 2, 3]
assert(id(la) != id(lb))
```

这种特性同样适用于函数传参等场景。

### Shallow Copy and Deep Copy

深浅拷贝对于不可变类型的效果是一样的。

对于可变类型（容器类型，如列表，字典），赋值拷贝只是将一个新的标签绑定到容器的栈内存。

```python
l = [[1,2,3], 4]
la = l
assert(la == l)
assert(id(la) == id(l))

l.append(5)

assert(la == l)
assert(id(la) == id(l))
```

可变类型的浅拷贝会同时拷贝容器的栈内存和堆内存。

```python
l = [[1,2,[3,4]], 5]
lb = l.copy()
assert(lb == l)
assert(id(lb) != id(l))

# 只拷贝元素的栈内存，不拷贝元素的堆内存
l[0].append(6)
assert(lb == l)
assert(id(lb[0]) == id(l[0]))

l[0][2].append(5)
assert(lb == l)
assert(id(lb[0]) == id(l[0]))

l.append(6)
assert(lb != l)
```

可变类型的深拷贝不仅会拷贝栈内存，还会递归拷贝堆内存的元素。

```python
from copy import deepcopy
l = [[1,2,[3,4]], 5]

lc = deepcopy(l)
assert(lc == l)
# 拷贝栈内存
assert(id(lc) != id(l))

# 递归拷贝堆内存元素
assert(id(l[0]) != id(lc[0]))
assert(id(l[0][2]) != id(lc[0][2]))

l[0].append(6)
assert(lc != l)

l[0][2].append(5)
assert(lc != l)

l.append(6)
assert(lc != l)
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
result = []
for x in [1,2,3]:
    for y in [3,1,4]:
        if x != y:
            result.append((x, y))
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

## Decorators

装饰器（Decorators）是一种动态修改函数或类行为的方式。装饰器的本质是将原函数或类包装，返回并使用经过包装的函数或类。

```python
def language(func):
    def wrapped():
        func()
        print("Python")

    return wrapped

@language
def hello():
    print("Hello")

hello()
```

原函数带参数时，可以通过不定长参数传入。

```python
def language(func):
    def wrapped(*vargs, **kwargs):
        func(*vargs, **kwargs)
        print("Python")

    return wrapped

@language
def hello(word: str):
    print(word)

hello("hi")
```

原函数带返回值时，直接返回即可。

```python
def logger(func):
    def wrapper(*args, **kwargs):
        print("=== log ===")
        return func(*args, **kwargs)
    return wrapper

@logger
def inc(num):
    print(num+1)

def dec(num):
    return num - 1

inc(10)
print(dec(10))
```

装饰器函数也可以带参数，只需要对装饰器函数包装即可。

```python
def language(lang):
    def language_wrapped(func):
        def wrapped(*vargs, **kwargs):
            func(*vargs, **kwargs)
            print(lang)
        return wrapped
    return language_wrapped

@language("Java")
def hello(word: str):
    print(word)

hello("hi")
```

多个装饰器按照从下往上的顺序执行。

```python
def decorator_one(func):
    def wrapped():
        func()
        print("decorator_one")
    return wrapped

def decorator_two(func):
    def wrapped():
        func()
        print("decorator_two")
    return wrapped

@decorator_two
@decorator_one
def func():
    print("func")

func()
# func
# decorator_one
# decorator_two
```

类装饰器用函数和类两种方式实现。

```python
# 使用函数实现
def logger(cls):
    class Wrapper:
        def __init__(self, *args, **kwargs) -> None:
            self.wrapped = cls(*args, **kwargs)

        # 访问包装类型不存在的属性时将其转发给原类型
        def __getattr__(self, name):
            return getattr(self.wrapped, name)

        def count_down(self):
            print("=== log ===")
            self.wrapped.count_down()

    return Wrapper

@logger
class Timer:
    def __init__(self, limit):
        self.limit = limit

    def count_down(self):
        for i in range(self.limit):
            print(i)

timer = Timer(10)
timer.count_down()
print(timer.limit)
```

类形式的装饰器一般借助`__call__`方法实现。`__call__`方法会在对象以函数形式使用时执行。

```python
# 类形式的单例装饰器
class Singleton:
    def __init__(self, cls) -> None:
        self.cls = cls
        self. instance = None

    def __call__(self, *args, **kwargs):
        if self.instance is None:
            self.instance = self.cls(*args, **kwargs)
        return self.instance

@Singleton
class Timer:
    def __init__(self, limit):
        self.limit = limit

    def count_down(self):
        for i in range(self.limit):
            print(i)

timer_one = Timer(10)
timer_two= Timer(20)
assert(timer_two.limit == 10)
assert(timer_one.limit == timer_two.limit)
```

## Iterators

为类实现`__iter__`和`__next__`方法即可实现迭代器类。

```python
class CustomRange:
    def __init__(self, start, stop, step):
        self.current = start
        self.end= stop
        self.step = step

    def __iter__(self):
        return self

    def __next__(self):
        if self.current < self.end:
            x = self.current
            self.current = self.current + self.step
            return x
        else:
            raise StopIteration

for i in CustomRange(1, 10, 1):
    print(i)
```

## Generators

生成器是一种快速产生迭代器的方式。使用`yield`关键字定义一个生成器函数。每次迭代到`yield`语句时，函数会返回指定的值并在此阻塞，直到下一次迭代。

```python
def fibonacci(n):
    a, b, counter = 0, 1, 0
    while True:
        if (counter > n): 
            return
        yield a
        a, b = b, a + b
        counter += 1

for i in fibonacci(10):
    print(i)
```

除了`yield`关键字，还可以使用推导式产生生成器。

```python
gen = (x * 2 for x in range(5))

for i in gen:
    print(i)
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
