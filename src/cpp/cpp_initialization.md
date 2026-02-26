+++
title = 'C++ 初始化'
date = 2024-12-08T09:54:47+08:00
+++

变量的初始化会在构造时提供变量的初始值。

初始值可以由声明符或 new 表达式的 **初始化器** 部分提供。在函数调用时也会发生：函数形参及函数返回值也会被初始化。

初始化器（如果存在）必须是下列之一：

```markdown
1. = expression
2. = {}
   = { initializer-list }
   = { designated-initializer-list }
3. ( expression-list )
   ( initializer-list )
4. {}
   { initializer-list }
   { designated-initializer-list }
```

## 默认初始化

```markdown
1. T object;
2. new T;
```

当没有为对象指定初始化器时，该对象会默认初始化。具体有以下三种情况：

1. 不带初始化器声明具有自动、静态或线程局部存储器的变量；
2. 不带初始化器使用 new 表达式创建一个对象；
3. 构造函数的成员初始化器列表没有提及某个基类或非静态数据成员，且调用了该构造函数；

默认初始化的效果是：

1. 如果是类类型，调用默认构造函数；
2. 如果是数组类型，数组的每个元素都被默认初始化；
3. 否则不进行初始化；

### 不确定值

在获取到具有自动或动态存储期的对象的存储时，该对象具有不确定值。

如果不对对象进行任何初始化，那么该对象具有不确定值，直到该值被替换。

### 示例

#### case 1

不带初始化器声明具有自动、静态或线程局部存储器的变量。

```cpp
#include <print>

// 静态全局非类，两次初始化
// 1) 零初始化将 si1 初始化为 0
// 2) 默认初始化不做任何事
int si1;

int main() {
    std::println("si1 静态全局非类，零初始化：{}", si1);

    static int si2;     // 静态局部非类，同全局静态非类
    std::println("si2 静态局部非类，零初始化：{}", si2);

    int i1;             // 自动局部非类，默认初始化不做任何事，不确定值
    std::println("i1 非类，不确定值：{}", i1);

    return 0;
}
```

#### case 2

不带初始化器使用 new 表达式创建一个对象。

```cpp
#include <print>

// 动态全局非类，默认初始化不做任何事，不确定值
int *pi1 = new int;

int main() {
    int *pi2 = new int; // 动态局部非类，默认初始化不做任何事，不确定值
    std::println("*pi1 动态全局非类，不确定值：{}", *pi1);
    std::println("*pi2 动态局部非类，不确定值：{}", *pi2);

    return 0;
}
```

多次执行上方代码可能得到的都是相同的结果，`*pi1` 和 `*pi2` 的值都是 0。不能就此认为默认初始化是的值就是 0。如果多次销毁并分配 **同一块内存** 可以发现其初始化值是不确定值。

```cpp
#include <print>

int main() {
    int *p = new int;
    std::println("*p：{}", *p);
    std::println("*p：{:p}", static_cast<void *>(p));

    delete p;
    p = new int;
    std::println("*p：{}", *p);
    std::println("*p：{:p}", static_cast<void *>(p));

    return 0;
}
```

#### case 3

构造函数的成员初始化器列表没有提及某个基类或非静态数据成员，且调用了该构造函数。

```cpp
#include <print>

struct foo {
    int mem;
};

struct bar {
    int mema;
    int memb;
    bar() : mema() {}
};

int main() {
    foo f1;
    std::println("foo.mem 无成员初始化列表类，不确定值：{}", f1.mem);
    bar b1;
    std::println("bar.mema 有成员初始化列表类，值初始化：{}", b1.mema);
    std::println("bar.memb 无成员初始化列表类，不确定值：{}", b1.memb);

    return 0;
}
```

对于具有动态存储期的类类型变量，同样会出现第一次分配内存时，值被初始化为 0，但在销毁并再次分配后是不确定值的现象。

## 值初始化

```markdown
1. T()
2. new T()
3. Class::Class(...) : member() {...}
4. T object {};
5. T{}
6. new T{}
7. Class::Class(...) : member{} {...}
```

以空初始化器进行的初始化。有以下几种情况：

1. 以空的 `()` 或 `{}` 组成的初始化器创建临时对象（1，5）；
2. new 表达式以空的 `()` 或 `{}` 组成的初始化器创建动态存储期对象（2，6）；
3. 以空的 `()` 或 `{}` 组成的成员初始化器初始化非静态数据成员或基类（3，7）；
4. 以空的 `{}` 对声明 **具名对象**（4）；

另外，如果使用了 `{}` 且 T 是聚合体，那么就会进行聚合初始化。如果 T 没有默认构造函数但有接受 `std::initializer_list` 的构造函数，那么会进行列表初始化。

值初始化的效果是：

1. 如果 T 是（可有 cv 限定）类类型：
    1. 如果 T 的默认初始化选择了一个 **不由用户提供的构造函数**，那么对象会首先进行零初始化；
    2. 任何情况下，对象都被默认初始化；
2. 如果 T 是数组类型，值初始化每一个元素；
3. 否则，进行零初始化；

注意，引用不能被值初始化。

### 示例

#### case 1

以空的 `()` 或 `{}` 组成的初始化器创建临时对象。

```cpp
#include <print>

int main() {
    int i1 = int();       // 非类，空 () 创建临时对象，零初始化
    int i2 = int{};       // 非类，空 {} 创建临时对象，零初始化

    std::println("i1 非类，空 () 创建临时对象，零初始化：{}", i1);
    std::println("i2 非类，空 {{}} 创建临时对象，零初始化：{}", i2);

    return 0;
}
```

注意，进行值初始化的其实是 `int()` 和 `int{}`，而 `i1`、`i2` 则进行 **复制初始化**。

#### case 2

new 表达式以空的 `()` 或 `{}` 组成的初始化器创建动态存储期对象。

```cpp
#include <print>

int main() {
    int *ip1 = new int(); // 非类，空 () 创建动态对象，零初始化
    int *ip2 = new int{}; // 非类，空 {} 创建动态对象，零初始化

    std::println("*ip1 非类，空 () 创建动态对象，零初始化：{}", *ip1);
    std::println("*ip2 非类，空 {{}} 创建动态对象，零初始化：{}", *ip2);
}
```

注意，进行值初始化的其实是 `new int()` 和 `new int{}`，而 `ip1`、`ip2` 则进行 **复制初始化**。

#### case 3

以空的 `()` 或 `{}` 组成的成员初始化器初始化非静态数据成员或基类。

```cpp
#include <print>

struct foo {
    int mem; // 隐式构造函数，不由用户提供
    // foo() = default; 同上
};

struct bar {
    int mema;
    int memb;
    bar() : mema() {} // 用户提供构造函数，部分成员初始化列表
};

int main() {
    foo f = foo();
    std::println("foo::mem 类，隐式构造函数，零初始化：{}", f.mem);

    bar b = bar{};
    std::println("bar::mema 类，带成员初始化列表，零初始化：{}", b.mema);
    std::println("bar::memb 类，不带成员初始化列表，默认初始化：{}", b.memb);

    return 0;
}
```

#### case 4

以空的 `{}` 对声明 **具名对象**。

```cpp
#include <print>

struct foo() {
    int mem;
};

int main() {
    int i{};
    std::println("i 非类，零初始化：{}", i);

    foo f{};
    std::println("foo.mem 类，隐式构造函数，零初始化：{}", f1.mem);
}
```

注意，`T object()` 不初始化对象，而是声明一个无参且返回 `T` 的函数。

## 直接初始化

```markdown
1. T object(arg);
   T object(arg1, arg2, ...);
2. T object{arg};
3. T(other object)
   T(arg1, arg2)
4. static_cast<T>(other object)
5. new T(args, ...)
6. Class::Class() : member(args, ...) {...}
7. [arg]() {}
```

以一组明确的构造函数实参对对象进行初始化。有以下几种情况：

1. 以表达式的非空带括号列表初始化对象；
2. 以 `{}` 环绕的单个初始化器初始化一个 **非类类型** 对象；
3. 以函数风格转换或以带括号的表达式列表初始化 **纯右值的结果对象**；
4. 以 `static_cast` 表达式初始化 **纯右值的结果对象**；
5. 以带有非空初始化器的 new 表达式初始化具有动态存储期的对象；
6. 用构造函数初始化器列表初始化基类或非静态成员；
7. 在 lambda 表达式中从按复制捕获的变量初始化闭包对象的成员；

直接初始化的效果是：

1. 如果 T 是数组类型，那么程序非良构；
2. 如果 T 是类类型，
    1. 如果初始化器是纯右值表达式且类型与 T 为相同的类（忽略 cv 限定），则用初始化器表达式自身，而非从它实质化的临时量，初始化目标对象（参考复制消除）；
    2. 检验 T 的构造函数并由重载决议选取最佳匹配，然后调用该构造函数以初始化对象；
3. 否则，如果 T 是非类类型但源类型是类类型，则检验源类型及其各基类的转换函数，并由重载决议选取最佳匹配，然后用选取的转换函数，将初始化器表达式转换为所初始化的对象。
4. 否则，如果 T 是 `bool` 而原类型是 `std::nullptr_t`，则被初始化对象的值为 `false`；
5. 否则，在必要时使用标准转换，转换 *其他对象* 的值为 T 的无 cv 限定版本，而所初始化的对象的初值为（可能为转换后的）该值。

### 触发示例

#### case 1

以表达式的非空带括号列表初始化对象。

```cpp
#include <print>

int main(int argc, char *argv[]) {
    int i(3);
    std::println("{}", i);

    std::string str(3, 't');
    std::println("{}", str);

    return 0;
}
```

#### case 2

以 `{}` 环绕的单个初始化器初始化一个 **非类类型** 对象。

```cpp
#include <print>

int main(int argc, char *argv[]) {
    int i{3};
    std::println("{}", i);

    return 0;
}
```

#### case 3

以函数风格转换或以带括号的表达式列表初始化 **纯右值的结果对象**。

```cpp
#include <print>

int main(int argc, char *argv[]) {
    // 函数风格转换
    std::println("{}", int(3));

    // 带括号的表达式列表
    std::println("{}", std::string(3, 't'));

    // 初始化器得到的是纯右值结果对象
    // int &x(int(3));

    return 0;
}
```

#### case 4

以 `static_cast` 表达式初始化 **纯右值的结果对象**。

```cpp
#include <print>

int main(int argc, char *argv[]) {
    std::println("{}", static_cast<double>(3));

    std::println("{}", static_cast<std::string>("hello"));

    // 初始化器得到的是纯右值结果对象
    // int &x(static_cast<int>(3.3));
    // int &x(static_cast<std::string>("hello"));

    return 0;
}
```

#### case 5

以带有非空初始化器的 new 表达式初始化具有动态存储期的对象。

```cpp
#include <print>

int main(int argc, char *argv[]) {
    std::println("{}", *(new int(3)));

    std::println("{}", *(new std::string(3, 't')));

    // 初始化器得到的是纯右值结果对象
    // int &x(new int(3));

    return 0;
}
```

#### case 6

用构造函数初始化器列表初始化基类或非静态成员。

```cpp
#include <print>

struct foo {
    int mema;
    std::string memb;

    foo() : mema(42), memb(3, 't') {}
};

int main(int argc, char *argv[]) {
    foo f;
    std::println("f.mema: {}", f.mema);
    std::println("f.memb: {}", f.memb);

    return 0;
}
```

#### case 7

在 lambda 表达式中从按复制捕获的变量初始化闭包对象的成员。

```cpp
#include <print>

struct foo {
    int mema;
    std::string memb;

    foo() : mema(42), memb(3, 't') {}
};

int main(int argc, char *argv[]) {
    foo f;

    auto x = [f]() {
        std::println("f.mema: {}", f.mema);
        std::println("f.memb: {}", f.memb);
    };
    x();

    return 0;
}
```

### 效果示例

#### case 1

T 是类类型，初始化器是纯右值表达式且类型与 T 为相同的类，则用初始化器表达式自身，而非从它实质化的临时量，初始化目标对象（参考复制消除）。

```cpp
#include <iostream>
struct foo {
    foo(int) { std::cout << "foo ctor" << std::endl; }
    foo(const foo &) { std::cout << "foo copy ctor" << std::endl; }
};

int main(int argc, char *argv[]) {
    foo f(foo(1));

    return 0;
}
// outpus:
// foo ctor
```

在 C++17 之前，这并不是一种语言特性，而是编译器优化，可以通过 `-fno-elide-constructors` 关闭，而且类必须拥有拷贝构造函数。关闭后 `foo f(foo(1))` 会先调用合适的构造函数初始化一个纯右值临时量，再调用拷贝构造函数初始化 `f`。

```language
foo ctor
foo copy ctor
```

#### case 2

T 是类类型，检验 T 的构造函数并由重载决议选取最佳匹配，然后调用该构造函数以初始化对象。

```cpp
#include <print>
struct foo {
    foo(int, double) { std::println("ctor 0"); }
    foo(int) { std::println("ctor 1"); }
    foo(double) { std::println("ctor 2"); }
};

int main(int argc, char *argv[]) {
    foo f0(42, 3.14);
    foo f1(42);
    foo(3.14);
    return 0;
}
```

#### case 3

如果 T 是非类类型但源类型是类类型，则检验源类型及其各基类的转换函数，并由重载决议选取最佳匹配，然后用选取的转换函数，将初始化器表达式转换为所初始化的对象。

```cpp
#include <print>

struct foo {
    operator int() { return 42; }
};

struct bar : foo {
    operator int() { return 24; }
};

struct meow : foo {};

int main(int argc, char *argv[]) {
    foo f;
    bar b;
    meow m;
    int i(f);
    std::println("{}", i);

    int x(b);
    std::println("{}", x);

    int v(m);
    std::println("{}", v);

    return 0;
}
```

#### case 4

如果 T 是 `bool` 而原类型是 `std::nullptr_t`，则被初始化对象的值为 `false`。

```cpp
#include <print>

int main(int argc, char *argv[]) {
    int *p = nullptr;
    bool b(p);
    std::println("{}", b);

    return 0;
}
```

#### case 5

在必要时使用标准转换，转换 *其他对象* 的值为 T 的无 cv 限定版本，而所初始化的对象的初值为（可能为转换后的）该值。

```cpp
#include <print>

struct foo {
    foo(int) { std::println("foo ctor"); }
};

struct bar {
    bar() { std::println("bar ctor"); }
    operator int() {
        std::println("bar convertion");
        return 24;
    }
};

struct meow : foo {};

int main(int argc, char *argv[]) {
    // 类型为 bar 的临时变量被隐式转换为 int 传给 foo 的构造函数
    foo f(bar{});

    return 0;
}
// output:
// bar ctor
// bar convertion
// foo ctor
```

## 复制初始化

```markdown
1. T object = other;
2. f(other)
3. return other;
4. throw object;
   catch(T object)
5. T array[N] = {other-sequence};
```

从另一个对象初始化对象。有以下几种情况：

1. 当非引用类型 T 的具名变量（自动、静态或线程局部），声明时带有以等号后随一个表达式所构成的初始化器时；
2. 当按值传递实参到函数时；
3. 当从按值返回的函数中返回时；
4. 当按值抛出或捕获异常时；
5. 作为聚合初始化的一部分，用以初始化每个提供了初始化器的元素；

复制初始化的效果是：

1. 如果 T 是类类型，且初始化器是纯右值表达式，类型与 T 为相同的类（忽略 cv 限定），则用初始化器表达式自身，而非从它实质化的临时量，初始化目标对象（参考复制消除）；
2. 如果 T 是类类型，且 *其他对象* 的类型是 T 或从 T 派生的类（忽略 cv 限定），那么调用合适的 **非显示构造函数**；
3. 如果 T 是类类型，且 *其他对象* 的类型 **不是** T 或从 T 派生的类（忽略 cv 限定），那么调用合适的转换函数将 *其他对象* 转换到 T。该转换的结果会被用于直接初始化该对象；
4. 如果 T **不是** 类类型，且 *其他对象* 的类型是类类型，同上；
5. 如果 T 和 *其他对象* 都不是类类型，在需要时用标准转换将 *其他对象* 的值转换成 T 的无 cv 限定版本；

注意，explicit 构造函数不是转换构造函数，不会被复制初始化考虑。另外，如果 *其他对象* 是右值表达式，那么重载决议会选择 **移动构造函数** 并在复制初始化期间调用它。

复制初始化中的隐式转换必须从初始化器直接生成 T，而直接初始化则允许从初始化器到 T 的某个构造函数实参的隐式转换。

```cpp
#include <print>

struct foo {
    foo(int) { std::println("foo int ctor"); }
};
struct bar {
    bar(foo) { std::println("bar foo ctor"); }
};

int main(int argc, char *argv[]) {
    bar b1(42);  // OK。42 先被转换成 foo，再转换成 bar
    bar b2 = 42; // 错误。复制初始化的初始化器必须直接生成 T
    bar b3(foo{42}); // OK。初始化器 foo{42} 直接生成 T
    return 0;
}
```

### 触发示例

#### case 1

当非引用类型 T 的具名变量（自动、静态或线程局部），声明时带有以等号后随一个表达式所构成的初始化器时。

```cpp
#include <print>

struct foo {
    foo() { std::println("foo ctor"); }
    foo(const foo &) { std::println("foo copy ctor"); }
};

int main(int argc, char *argv[]) {
    foo f1 = foo(); // 复制消除
    foo f2 = f1;

    return 0;
}
```

#### case 2

当按值传递实参到函数时。

```cpp
#include <print>

struct foo {
    foo() { std::println("foo ctor"); }
    foo(const foo &) { std::println("foo copy ctor"); }
};

int main(int argc, char *argv[]) {
    no_ret_f(foo()); // 复制消除
    foo f;           // foo ctor
    no_ret_f(f);     // foo copy ctor

    return 0;
}
```

#### case 3

当从按值返回的函数中返回时。

```cpp
#include <print>

struct foo {
    foo() { std::println("foo ctor"); }
    foo(const foo &) { std::println("foo copy ctor"); }
};

foo ret_f() {
    foo f;
    return f;
}
foo ret_r_f() { return foo(); }

int main(int argc, char *argv[]) {
    ret_f();   // foo ctor
    ret_r_f(); // foo ctor

    return 0;
}
```

#### case 4

当按值抛出或捕获异常时。

```cpp
#include <print>

struct foo {
    foo() { std::println("foo ctor"); }
    foo(const foo &) { std::println("foo copy ctor"); }
};

int main(int argc, char *argv[]) {
    try {
        foo f;        // foo ctor
        throw f;      // foo copy ctor
    } catch (foo f) { // foo copy ctor
    }

    try {
        throw foo();  // foo ctor，复制消除
    } catch (foo f) { // foo copy ctor
    }

    return 0;
}
```

#### case 5

作为聚合初始化的一部分，用以初始化每个提供了初始化器的元素。

```cpp
#include <print>

struct foo {
    foo() { std::println("foo ctor"); }
    foo(const foo &) { std::println("foo copy ctor"); }
};

int main(int argc, char *argv[]) {
    foo f; // foo ctor
    foo arr[5] = {f, f, f};
    // foo copy ctor
    // foo copy ctor
    // foo copy ctor
    // foo ctor
    // foo ctor

    return 0;
}
```

### 效果示例

#### case 1

如果 T 是类类型，且初始化器是纯右值表达式，类型与 T 为相同的类（忽略 cv 限定），则用初始化器表达式自身，而非从它实质化的临时量，初始化目标对象（参考复制消除）。

```cpp
#include <print>
struct foo {
    foo() { std::println("foo ctor"); }
    foo(const foo &) { std::println("foo copy ctor"); }
};

int main(int argc, char *argv[]) { 
    foo f = foo();
    return 0;
}
```

#### case 2

如果 T 是类类型，且 *其他对象* 的类型是 T 或从 T 派生的类（忽略 cv 限定），那么调用合适的 **非显示构造函数**。

```cpp
#include <print>
struct foo {
    foo() { std::println("foo ctor"); }
    foo(const foo &) { std::println("foo copy ctor"); }
    explicit foo(int) {}
};
struct bar : foo {
    bar() { std::println("bar ctor"); }
};

int main(int argc, char *argv[]) {
    foo f1;

    foo f2 = f1; // 其他对象的类型是 T，此处调用拷贝构造函数

    foo f3 = bar(); // 其他对象的类型是 T 的派生类，bar 被隐式转换为
                    // foo，然后调用拷贝构造函数

    foo f4 = 42; // 错误。复制初始化不考虑显式构造函数

    return 0;
}
```

#### case 3

如果 T 是类类型，且 *其他对象* 的类型 **不是** T 或从 T 派生的类（忽略 cv 限定），那么调用合适的转换函数将 *其他对象* 转换到 T。该转换的结果会被用于直接初始化该对象。

```cpp
#include <print>
struct bar {
    bar() { std::println("bar ctor"); }
};
struct foo {
    foo() { std::println("foo ctor"); }
    foo(const foo &) { std::println("foo copy ctor"); }
    explicit foo(bar) { std::println("foo explicit conv from bar"); }
    foo(int) { std::println("foo implicit conv from int"); }
};

int main(int argc, char *argv[]) {
    foo f1{bar()};  // 直接初始化，考虑所有构造函数
    foo f2 = bar(); // 错误。复制初始化不考虑显式构造函数
    foo f3 = 42;    // 非显式构造函数
    return 0;
}
```

#### case 4

如果 T **不是** 类类型，且 *其他对象* 的类型是类类型，同 case 3。

```cpp
#include <print>
struct foo {
    foo() { std::println("foo ctor"); }
    foo(const foo &) { std::println("foo copy ctor"); }
    operator int() { return 42; }
};

int main(int argc, char *argv[]) { 
    int i = foo();
    std::println("{}", i);

    return 0;
}
```

#### case 5

如果 T 和 *其他对象* 都不是类类型，在需要时用标准转换将 *其他对象* 的值转换成 T 的无 cv 限定版本。

```cpp
#include <print>

int main(int argc, char *argv[]) {
    int i = 3.14;
    std::println("{}", i);

    return 0;
}
```
