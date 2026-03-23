# Python Class

## Class

```python
class ClassName:
    pass

c = ClassName()
```

### Instance Objects

```python
class ClassName:
    pass

c = ClassName()
```

在 Python 中，实例的数据成员并不需要显式声明，其在首次赋值时就会出现。数据成员必须以`object.member`的形式访问。实例对象的数据属性只属于对应实例，其他实例无法访问。

```python
class Foo:
    pass

foo = Foo()
foo.bar = 42

foo_secd = Foo()
# assert(foo_secd.bar == 42) # 实例 foo_secd 没有 bar 属性
```

除了数据属性外，函数也可以作为实例的成员。作为实例属性的函数称为方法，其第一个参数必须是实例本身。通常这个参数会被命名为`self`，但这并非强制。通过`object.func()`形式调用方法时会自动传入实例本身作为第一个参数。方法的声明除了和数据成员一样在类外部声明，更常见的是在类内部声明。

```python
class Foo:
    def bar(self):
        pass

foo = Foo()
foo.bar()
```

### Class Objects

在 Python 中，万物皆对象。类本身也是一个对象，在类定义结束时会创建一个「类对象」。

任何定义在类中的名称都是类对象的属性。类的数据属性将作为所有实例的共享数据，任何实例访问到的都是同一份数据。因此在共享列表、字典等可变类型时，修改可以被所有实例观测到。而类的函数属性将作为实例的方法。类对象的属性以`ClassName.member`形式访问。

```python
class Foo:
    i = 42

    def bar(self):
        pass

assert(Foo.i == 42)
Foo.i = 24
assert(Foo.i == 24)

Foo.a = 100 # 为类对象声明一个新的数据属性
```

实例方法与函数并不是同一种类型。

```python
import inspect

class Foo:
    def bar(self):
        pass

foo = Foo()

assert(inspect.ismethod(foo.bar))
assert(inspect.isfunction(Foo.bar))
```

#### Class Methods

使用装饰器`@classmethod`可以定义类方法。类方法与实例方法类似，其第一个参数必须是类本身，常命名为`cls`。类方法常被用作工厂方法。

```python
from datetime import date

class Person:
    species = "Homo sapiens"

    def __init__(self, name, age):
        self.name = name
        self.age = age

    @classmethod
    def from_birth_year(cls, name, birth_year):
        """Alternative constructor to create a Person instance from a birth year."""
        current_year = date.today().year
        age = current_year - birth_year
        return cls(name, age) # This calls the __init__ method of the class

    @classmethod
    def display_species(cls):
        """Class method to access and display a class attribute."""
        print(f"This is a {cls.species}")

    def display_info(self):
        """Instance method to display instance-specific info."""
        print(f"{self.name} is {self.age} years old.")

person = Person.from_birth_year('John', 1985)

assert(person.name == "John")
assert(person.age == 1985)
```

#### Static Methods

使用装饰器`@staticmethod`可以定义静态方法。静态方法不需要类或实例本身作为第一个参数，且类和实例都可以调用。

```python
class Base:
    @staticmethod
    def the_answer() -> int:
        return 42

base = Base()

asssert(Base.the_answer = 42)
asssert(base.the_answer = 42)
```

### Magic Methods

「魔术方法」是实例在特定场景下自动执行的方法，方法名以`__`开始和结束。

#### \_\_init\_\_

`__init__`方法会在创建实例时执行，类似 C++ 的构造函数。通常实例的数据属性会在此时声明。

```python
class Complex:
    def __init__(self, real, image):
        self.r = real
        self.i = image

c = Complex(3, 4)
assert(c.r == 3)
assert(c.i == 4)
```

#### \_\_del\_\_

`__del__`方法会在实例被销毁时执行，类似 C++ 的析构函数，用于回收对象所占用的资源等。

#### \_\_str\_\_

`__str__`方法会在实例需要转换成字符串时执行，如`print()`。

```python
class Complex:
    def __init__(self, real, image):
        self.r = real
        self.i = image

    def __str__(self):
        if image < 0:
            return f"{self.real} - {-self.image}j"

        return f"{self.real} + {self.image}j"

c = Complex(3, 4)
assert(str(c) == "3 + 4j")
```

### Private Attributes

Python 中并不存在所谓的「私有属性」，但按照**约定**，以`_`开头的属性应当被认为是 API 的非公有部分。

```python
class Person:
    def __init__(self, name: str, age: int): -> None
        self.name:str = name
        self.__age:int = age

person = Person("John", 42)

assert(person.name == "John")
assert(person.__age == 42) # it's only a convention
```

### Inheritance

```python
class BaseClass:
    pass

class DerivedClass(BaseClass):
    pass
```

Python 同样支持「继承」。使用`super()`可以调用父类的方法。

```python
class Animal:
    def __init__(self, name: str) -> None:
        self.name:str = name

class Cat(Animal):
    def __init__(self, name: str, age: int) -> None:
        super().__init__(name)
        self.age:int = age

cat = Cat("neko", 2)
assert(cat.name == "neko")
assert(cat.age == 2)
```

### Polymorphism

```python
from typing import override

class Animal:
    def __init__(self, name: str) -> None:
        self.name:str = name

    def call(self) -> str:
        return "animal calls"

class Cat(Animal):
    def __init__(self, name: str, age: int) -> None:
        super().__init__(name)
        self.age:int = age

    @override
    def call(self) -> str:
        return "meow"

class Dog(Animal):
    def __init__(self, name: str, age: int) -> None:
        super().__init__(name)
        self.age:int = age

    @override
    def call(self) -> str:
        return "bark"

def animal_call(animal: Animal) -> str:
    return animal.call()

cat = Cat("kitty", 2)
dog = Dog("Bruce", 1)

assert(animal_call(cat) == "meow")
assert(animal_call(dog) == "bark")
```

