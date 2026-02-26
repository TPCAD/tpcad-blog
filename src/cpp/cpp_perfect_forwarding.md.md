+++
title = 'How Perfect Forwarding Works'
date = 2024-08-12T17:46:57+08:00
tags = ['cpp']
+++

**转发** 指的是函数之间的参数传递。比如下面的代码，函数 `foo` 向函数 `bar` 传递了参数 `a`。

```c
foo(int a) {
    bar(a)
}

bar(int b) {}
```

**完美转发**则是在转发过程中，参数的各种属性都保持不变。比如右值仍是右值，左值仍是左值。

## 普通转发的问题

在下面的代码中，函数 `pass` 接受一个右值引用，并将该参数传递给函数 `reference`。当向 `pass` 传入字面量 `1` 时，最终的输出结果是 `lvalue`。这是因为虽然向 `pass` 传入了右值，但在函数体内，变量 `x` 的值类别变成了**左值**，即 `x` 的类型是右值引用，值类别是左值，所以最终会调用 `reference(int &y)`。

这就是普通转发存在的问题，在转发过程中可能会改变参数某些属性。

```c
#include <fmt/core.h>

void reference(int &&y) { fmt::println("rvalue"); }
void reference(int &y) { fmt::println("lvalue"); }
void pass(int &&x) {
    fmt::println("general pass");
    reference(x);
}

int main(int argc, char *argv[]) {
    pass(1);
    return 0;
}
```

## 实现完美转发

### 万能引用

在普通函数中，若参数类型为 `&&`，则函数只能接受右值。

```c
void foo(int &&x) {}

int main() {
    int a = 1;
    foo(1);
    // foo(a); 无法编译
}
```

但在模板函数中，若 `&&` 与模板参数结合，即 `T&&`，那么它将不再代表右值引用，而是**万能引用**。它既能接受左值，又能接受右值。

```c
template <typename T> void foo(T &&x) {
}

int main(int argc, char *argv[]) {
    foo(1); // 传入右值
    int a = 0;
    foo(a); // 传入左值
    return 0;
}
```

### 引用折叠规则

引用折叠规则是在对引用类型进行连续引用时所要遵循的规则。

| 函数形参类型 | 实参参数类型 | 推导后函数形参类型 |
| ------------ | ------------ | ------------------ |
|      T&      |    左引用    |         T&         |
|      T&      |    右引用    |         T&         |
|      T&&     |    左引用    |         T&         |
|      T&&     |    右引用    |         T&&        |

简而言之，**当且仅当模板函数的形参与实参都是右引用时，形参才会被推导为右引用**。

### std::forward

C++ 使用 `std::forward` 进行完美转发。`std::forward` 的实现如下：

```c
/**
 *  @brief  Forward an lvalue.
 *  @return The parameter cast to the specified type.
 *
 *  This function is used to implement "perfect forwarding".
 */
template<typename _Tp>
  constexpr _Tp&&
  forward(typename std::remove_reference<_Tp>::type& __t) noexcept
  { return static_cast<_Tp&&>(__t); }

/**
 *  @brief  Forward an rvalue.
 *  @return The parameter cast to the specified type.
 *
 *  This function is used to implement "perfect forwarding".
 */
template<typename _Tp>
  constexpr _Tp&&
  forward(typename std::remove_reference<_Tp>::type&& __t) noexcept
  {
    static_assert(!std::is_lvalue_reference<_Tp>::value, "template argument"
      " substituting _Tp is an lvalue reference type");
    return static_cast<_Tp&&>(__t);
  }
```

其中 `std::remove_reference` 是一个模板类，它的实现如下：

```c
template<class T> struct remove_reference { typedef T type; };
template<class T> struct remove_reference<T&> { typedef T type; };
template<class T> struct remove_reference<T&&> { typedef T type; };
```

通过 `std::remove_reference` 将类型的引用去除，得到值类型。`std::forward` 有两个重载，分别匹配左值引用和右值引用，当匹配左值引用时，根据引用折叠规则，`static_cast<_Tp&&>(__t)` 返回左值引用，当匹配右值引用时，根据引用折叠规则，`static_cast<_Tp&&>(__t)` 返回右值引用。

## 使用 std::forward

```c
#include <fmt/core.h>
#include <utility>

void reference(int &&x) { fmt::println("rvalue"); }
void reference(int &x) { fmt::println("lvalue"); }

template <typename T> void pass(T &&x) {
    fmt::println("general pass");
    reference(x);

    fmt::println("forward pass");
    reference(std::forward<T>(x));
}

int main(int argc, char *argv[]) {
    pass(1);
    fmt::println("===");
    int a{1};
    pass(a);
    return 0;
}

// general pass
// lvalue
// forward pass
// rvalue
// ===
// general pass
// lvalue
// forward pass
// lvalue
```
