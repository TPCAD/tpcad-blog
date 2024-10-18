+++
title = 'How Nullptr Works'
date = 2024-08-06T17:46:57+08:00
+++

## 为什么需要 nullptr

在 C 中，`NULL` 被定义为 `(void*)0` 或 `0`。而 C++ 因为不允许直接将 `void*` 隐式转换到其他类型，所以在没有 `nullptr` 之前，C++ 的 `NULL` 就是 0（也可能是 `0L`）。这导致 0 的二义性。

0 的二义性给函数重载带来了混乱。考虑下面的代码，如果 `NULL` 被定义为 `0`，那么 `foo(NULL)` 会严格匹配 `foo(int)`，但如果 `NULL` 被定义为 `0`，那么将不存在严格匹配，而 `0L` 可以同时转换为 `int` 和 `int*`，编译器无法知道应该调用哪个函数。

```c++
void foo(int){}
void foo(int*){}

foo(0); // 调用 foo(int)
foo(NULL);
```

为了解决这个问题，C++ 11 引入了 `nullptr` 关键字，用于区分空指针和 `0`。

## 使用 nullptr

`nullptr` 是一个纯右值，无法被 `&` 取地址，可以被隐式转换为任意的指针或成员指针类型。

```c++
void foo(int){}
void foo(int*){}

foo(0); // 调用 foo(int)
foo(nullptr); // 隐式转换到 int*，调用 foo(int*)
```

`nullptr` 可以取代 `NULL` 的所有场景。

```c++
int* ptr = nullptr;
if (ptr == nullptr){}
```

## 理解 nullptr

`nullptr` 的类型是 `nullptr_t`。下面是一个可能的实现。

```cpp
struct nullptr_t {
    // 不能对 nullptr 取地址
    void operator&() const = delete;
    // 隐式转换为任意类型指针
    template<class T>
    inline operator T*() const { return 0; }
    // 隐式转换为任意类型成员指针
    template<class C, class T>
    inline operator T C::*() const { return 0; }
};
nullptr_t nullptr;
```

从上面的实现可以看出，在隐式转换到其他指针或成员指针类型时，返回的就是 `0`。所以尽管类型不同，但 `nullptr` 在数值上等于 `0`。

```cpp
int *p = nullptr;
std::cout << (nullptr == 0) << std::endl;
std::cout << (p == 0) << std::endl;
cout << reinterpret_cast<long>(nullptr) << endl;
```

## nullptr 的类型转换

因为可以隐式转换到任意类型的指针和成员指针，所以可以使用 `static_cast` 对 `nullptr` 进行显示转换。

```c++
int *p;
p = static_cast<int*>(nullptr);
```

`nullptr` 不能使用 `static_cast` 显示转换到 `int` 等类型，除了 `bool`。

```
std::cout << static_cast<int>(nullptr)  << std::endl; // not allowed
std::cout << static_cast<bool>(nullptr)  << std::endl;
```

可以使用 `reinterpret_cast` 显示转换 `nullptr` 到整数类型。

```cpp
std::cout << static_cast<long>(nullptr)  << std::endl; // 大小必须兼容
```

## Reference

[What Exactly Nullptr Is in C++?](https://dzone.com/articles/what-exactly-nullptr-is-in-c)
[C++11nullptr](https://blog.csdn.net/xp178171640/article/details/104327385)
[A name for the null pointer: nullptr (revision 4)](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2007/n2431.pdf)
