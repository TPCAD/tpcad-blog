+++
title = 'C++ 特殊成员函数'
date = 2024-12-07T09:07:08+08:00
draft = true
+++

# 类的默认函数

当没有为类提供以下函数时，编译器会为类自动生成这些函数：

- 默认构造函数
- 析构函数
- 复制构造函数
- 复制赋值运算符
- 移动构造函数
- 移动赋值运算符

## 默认构造函数

构造函数用于初始化对象，可以重载。默认构造函数是构造函数的一种，当没有显式提供初始值时，会调用默认构造函数，每个类只能有一个默认构造函数。

```c++
class A{};

A a; // 调用默认构造函数
A *aa = new A; // 调用默认构造函数
```

当没有显式定义构造函数时，编译器会自动生成一个无参构造函数。如果显式定义了构造函数（有参或无参），那么编译器就不会生成构造函数。

对于内置类型，如 `int`、`double` 等，这个构造函数不会进行初始化，对于自定义类型，如 `class`、`struct`、`union` 等，这个构造函数会调用它们的默认构造函数。

除了无参构造函数，提供全默认值的构造函数也可以是默认构造函数。

```c++
struct A{
    int a;
    int b;

    A(int a = 1, int b = 1) {}
}

int main() {
    A a;
    std::cout << a.a << "," << a.b << std::endl;
}
```

## 析构函数

析构函数的作用是对对象中的资源进行释放。析构函数不能重载，每个类只能有一个析构函数。

当没有显式定义析构函数时，编译器会自动生成一个析构函数。

对于内置类型，不需要资源清理，系统会直接将内存回收，对于自定义类型，析构函数会调用该类型对应的析构函数。

```cpp
struct String {
    String() {
        m_size = 0;
        m_data = nullptr;
    }
    ~String() {
        delete m_data;
    }

private:
    unsigned int m_size;
    char *m_data;
}
```

## 拷贝构造函数

拷贝构造函数是构造函数的一个重载，其参数为对应类型的**引用**（一般用 `const` 修饰）。

当没有显式定义拷贝构造函数时，编译器会自动生成一个拷贝构造函数。编译器生成的拷贝构造函数只对对象进行**浅拷贝**。

下面的示例中，没有显式定义拷贝构造函数，因此在发生拷贝初始化时，会调用默认的拷贝构造函数，这个构造函数只会进行**浅拷贝**，所以拷贝赋值后会有两个对象拥有同一块内存，在析构时就会发生**二次释放**。

```cpp
struct String {
    String(const char *string) {
        m_size = strlen(string);
        m_data = new char[m_size];
        memcpy(m_data, string, m_size);
    }
    ~String() {
        delete m_data;
    }

private:
    unsigned int m_size;
    char *m_data;
}

int main() {
    String str1("hello");
    String str2(str1); // 会造成二次释放
    String str3 = str1; // 会造成二次释放
}
```

因此，涉及到堆内存资源时，必须显式定义拷贝构造函数。

```cpp
struct String {
    String(const char *string) {
        m_size = strlen(string);
        m_data = new char[m_size];
        memcpy(m_data, string, m_size);
    }
    ~String() {
        delete m_data;
    }
    // 显式定义拷贝构造函数
    String(const String& other) {
        m_size = other.m_size;
        m_data = new char[m_size];
        memcpy(m_data, other.m_data, m_size);
    }

private:
    unsigned int m_size;
    char *m_data;
}
```

拷贝构造函数通常在以下场景调用：

1. 使用已有对象初始化新对象
2. 以值传递方式向函数传参
3. 函数返回值是值

## 拷贝赋值运算符

拷贝赋值运算符是对赋值运算符的重载，其参数为对应类型的**引用**（一般用 `const` 修饰），返回值为对应类型的引用（也可以是值，但会调用拷贝构造函数）。拷贝赋值函数通常在使用已有对象对已有对象进行赋值时调用。

当没有显式定义拷贝赋值函数时，编译器会自动生成一个拷贝赋值函数。编译器生成的拷贝赋值函数只对对象进行**浅拷贝**。

此外，应当避免对对象本身进行拷贝赋值。下面的例子中，没有对检查是否是对对象本身进行拷贝赋值，因此导致对象丢失了原来的堆资源。

```cpp
String &operator=(const String &other) {
    fmt::println("Copied assignment!");
    m_size = other.m_size;
    m_data = new char[m_size]; // 分配了新的堆内存，原来的堆内存丢失了
    memcpy(m_data, other.m_data, m_size); // 无意义的拷贝，新的堆内存是随机内容

    return *this;
}
```

拷贝赋值前应进行检查。

```cpp
String &operator=(const String &other) {
    fmt::println("Copied assignment!");
    if (this != &other) {
        m_size = other.m_size;
        m_data = new char[m_size];
        memcpy(m_data, other.m_data, m_size);
    }
    return *this;
}
```

## 移动构造函数

拷贝构造函数将资源进行拷贝，而移动构造函数则是直接使用资源，避免不必要的拷贝。

对于内置类型，编译器自动生成的移动构造函数进行拷贝，对于自定义类型，则调用对应的移动构造函数，若没有则调用拷贝构造函数。

当没有显式定义移动构造函数，但显式定义了拷贝构造函数，那么在应当使用移动构造函数的场合会调用拷贝构造函数。

显式定义移动构造函数时，必须把原来的指针变量赋值为空指针以避免二次释放。

```cpp
String(String &&other) : m_size(other.m_size), m_data(other.m_data) {
    fmt::println("Move constructor!");
    other.m_data = nullptr;
    other.m_size = 0;
}
```

## 移动赋值运算符

移动赋值运算符是对赋值运算符的重载，其参数为对应类型的**右值引用**，返回值为对应类型的引用（也可以是值，但会调用拷贝构造函数）。移动赋值函数通常在使用已有对象的右值对已有对象进行赋值时调用。

当没有显式定义移动赋值函数时，编译器会自动生成一个默认移动赋值函数。这个函数所进行的操作与默认生成的移动赋值函数类似。

当没有显式定义移动赋值函数，但显式定义了拷贝赋值函数，那么在应当使用移动赋值函数的场合会调用拷贝赋值函数。

```cpp
String &operator=(String &&other) {
    fmt::println("Moved assignment!");
    if (this != &other) { // 避免对自己进行移动赋值
        m_size = other.m_size;
        m_data = other.m_data;
        other.m_data = nullptr;
        other.m_size = 0;
    }
    return *this;
}
```
