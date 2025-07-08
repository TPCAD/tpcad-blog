+++
title = 'Rust Traits'
date = 2024-07-04T15:00:42+08:00
tags = ['Rust']
+++

trait 定义了某个特定类型拥有可能与其他类型共享的功能。

## 定义与实现 trait

### 定义 trait

一个 trait 体中可以有多个方法：一行一个方法签名且都以分号结尾。

```rust
trait Area {
    fn area(&self) -> u32;
}
```

### 为类型实现 trait

使用 `impl for` 为类型实现 trait。

```rust
impl Area for Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }
}

impl Area for Circle {
    fn area(&self) -> u32 {
        3 * self.radio * self.radio
    }
}
```

### 默认实现

```rust
trait Summary {
    fn summarize(&self) -> String {
        String::from("(Read more...)");
    }
}

// 因为有默认实现，所以可以指定一个空 impl 块
impl Summary for Tweet {}
```

## trait 作为参数

通过将 trait 作为函数参数，可以使该参数支持任何实现了指定 trait 的类型。

### impl Trait 语法

```rust
fn notify(item: &impl Summary) {
    println!("{}", item.summarize());
}
```

### Trait Bound 语法

```rust
fn notify<T: Summary>(item: &T) {
    println!("{}", item.summarize());
}
```

```rust
// 泛型限制了两个参数必须是相同类型
fn notify<T: Summary>(item1: &T, item2: &T) {

// impl Trait 允许两个参数是不同类型
fn notify(item1: &impl Summary, item2: &impl Summary) {
```

### 通过 + 指定多个 trait bound

```rust
fn notify(item: &(impl Summary + Display)) {}

fn notify<T: Summary + Display>(item: &T) {}
```

### 通过 where 简化 trait bound

```rust
fn some_function<T, U>(t: &T, u: &U) -> i32
where
    T: Display + Clone,
    U: Clone + Debug,
{
```

## 返回实现了 trait 的类型

```rust
fn returns_summarizable() -> impl Summary {
```

注意，这只适用于返回单一类型的情况。

## 使用 trait bound 有条件地实现方法

```rust
impl<T> Pair<T> {
    fn new(x: T, y: T) -> Self {
        Self { x, y }
    }
}

// 只有实现了 Display 和 PartialOrd Trait 的泛型 T 才会拥有这个方法
impl<T: Display + PartialOrd> Pair<T> {
    fn cmp_display(&self) {
        if self.x >= self.y {
            println!("The largest member is x = {}", self.x);
        } else {
            println!("The largest member is y = {}", self.y);
        }
    }
}
```

也可以对任何实现了特定 trait 的类型有条件地实现 trait。对任何满足特定 trait bound 的类型实现 trait 被称为 blanket implementations

```rust
// blanket implementations
// 任何实现了 Display trait 的类型都会自动实现 ToString trait
impl<T: Display> ToString for T {
```

## 孤儿规则

只有在 trait 或类型至少有一个属于当前 crate 时，才能对类型实现该 trait。

比如，不能在自己的 crate 中为标准库中的类型实现标准库中的 trait。因为它们均不属于当前 crate。

## Trait 对象

泛型虽然很方便，但也有限制。比如，泛型限制了参数只能是同一种类型。

如下代码所示，Vec 的元素必须是相同类型的。

```rust
trait Draw {
    fn draw(&self);
}
struct Button {
    name: String,
}

impl Draw for Button {
    fn draw(&self) {
        println!("Draw button");
    }
}

struct TextField {
    name: String,
}

impl Draw for TextField {
    fn draw(&self) {
        println!("Draw text field");
    }
}

fn main() {
    let vec = vec![
        Box::new(Button {
            name: "button".to_string(),
        }),
        // mismatched types expected `Button`, found `TextField` 
        Box::new(TextField {
            name: "text field".to_string(),
        }),
    ];
}
```

Trait 对象则允许在运行时替代多种具体类型。

```rust
// 使用 dyn 关键字声明 trait 对象
let vec: Vec<Box<dyn Draw>> = vec![
    Box::new(Button {
        name: "button".to_string(),
    }),
    Box::new(TextField {
        name: "text field".to_string(),
    }),
];

for i in vec {
    i.draw();
}
```

Rust 使用使用动态分发（Dynamic Dispatch）实现 trait 对象。此时编译器无法知晓所有可能用于 trait 对象代码的类型，所以它也不知道应该调用哪个类型的哪个方法实现。为此，Rust 在运行时使用 trait 对象中的指针来知晓需要调用哪个方法。而编译器只能保证类型实现了相应的 trait。

## 关联类型

关联类型（associated types）的作用与泛型十分相似，但关联类型限制了我们只能实现一次 trait。

```rust
pub trait Iterator {
    type Item;

    fn next(&mut self) -> Option<Self::Item>;
}

impl Iterator for Counter {
    // 只能指定一次 Item 的类型
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        // --snip--
```

## 默认泛型类型参数

在使用泛型类型参数时，可以为泛型指定一个默认的具体类型。

```rust
// 提供默认的泛型类型参数
trait Add<Rhs=Self> {
    type Output;

    fn add(self, rhs: Rhs) -> Self::Output;
}

// 使用默认泛型类型参数
impl Add for Point {
    type Output = Point;

    fn add(self, other: Point) -> Point {
        Point {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

// 不使用默认泛型类型参数
impl Add<Meters> for Millimeters {
    type Output = Millimeters;

    fn add(self, other: Meters) -> Millimeters {
        Millimeters(self.0 + (other.0 * 1000))
    }
}
```

## 完全限定语法

Rust 不能避免一个 trait 与另一个 trait 拥有同名的方法，也不能阻止为同一类型实现这两个 trait。

```rust
trait Pilot {
    fn fly(&self);
}

trait Wizard {
    fn fly(&self);
}

struct Human;

// 实现两个有同名方法的 trait
impl Pilot for Human {
    fn fly(&self) {
        println!("Pilot fly");
    }
}

impl Wizard for Human {
    fn fly(&self) {
        println!("Wizard fly");
    }
}

// 自身也实现该方法
impl Human {
    fn fly(&self) {
        println!("Flying");
    }
}

fn main() {
    let human = Human {};
    // 默认调用自身实现
    human.fly();
    Wizard::fly(&human);
    Pilot::fly(&human);
}
```

关联函数没有 `&self` 参数，不能使用上面的方法来消除歧义。此时只能使用**完全限定语法（fully qualified syntax）**。

```rust
// 关联函数而非方法
trait Pilot {
    fn fly();
}
trait Wizard {
    fn fly();
}

struct Human;
impl Pilot for Human {
    fn fly() {
        println!("Pilot fly");
    }
}
impl Wizard for Human {
    fn fly() {
        println!("Wizard fly");
    }
}
impl Human {
    fn fly() {
        println!("Flying");
    }
}

fn main() {
    Human::fly();
    // 完全限定语法调用同名关联函数
    <Human as Wizard>::fly();
    <Human as Pilot>::fly();
}
```

## 父 trait

父 trait 可以让类型在一个 trait 的同时也必须实现另一个 trait。

```rust
use std::fmt;

// 父 trait
trait OutlinePrint: fmt::Display {
    fn outline_print(&self) {
        // 可以使用父 trait 的方法
        let output = self.to_string();
        let len = output.len();
        println!("{}", "*".repeat(len + 4));
        println!("*{}*", " ".repeat(len + 2));
        println!("* {output} *");
        println!("*{}*", " ".repeat(len + 2));
        println!("{}", "*".repeat(len + 4));
    }
}
```

## Sized Trait

**动态大小类型（dynamically sized types）**允许我们处理只用在运行时才知道大小的类型。

因为动态大小类型只能在运行时确定，所以它的**值必须置于某种指针之后**。

比如 trait。每一个 trait 都是一个可以通过 trait 名称来引用的动态大小类型。所以它必须放在指针之后，`&dyn trait` 或 `Box<dyn trait>`。

为了处理 DST，Rust 提供了 Sized trait 来决定一个类型的大小是否在编译时可知。这个 trait 会自动为所有在编译时就知道大小的类型实现。另外，Rust 会为每一个泛型函数增加 `Sized` bound。

```rust
fn generic<T>(t: T){}

fn generic<T: Sized>(t: T){}
```

`Sized` trait 还有一个特殊的语法，`?Sized`。它表示该类型可能是也可能不是 `Sized`。该语法只能用于 `Sized`。

```rust
// 参数类型从 T 变成了 &T，因为 DST 必须置于某种指针之后
fn generic<T: ?Sized>(t: &T){}
```

```rust
#[derive(Debug)]
struct Bar<T: ?Sized>(T);

// [i32] 没有实现 Sized trait，所以它的大小在编译时是不可知的
// 如果不使用 ?Sized trait，以下代码将无法编译
fn main() {
    let sized: Bar<[i32; 8]> = Bar([0; 8]);
    let dynamic1: Box<Bar<[i32]>> = Box::new(Bar([]));
    let dynamic2: Box<Bar<[i32]>> = Box::new(sized);
    println!("{:#?}", dynamic1);
    println!("{:#?}", dynamic2);
}
```
