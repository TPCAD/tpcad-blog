+++
title = 'Rust_ownership'
date = 2025-11-10T09:33:38+08:00
draft = true
+++

## 结构体的所有权

结构体拥有其所有成员字段的所有权，且不允许只拥有部分所有权。

部分移动结构体后，结构体不再完整，Rust 不允许继续使用不完整的结构体。虽然无法使用完整的结构体，但仍能继续使用其他字段。

```rust
#[derive(Debug)]
struct Foo {
    two: String,
    one: String,
}

fn main() {
    println!("Hello, world!");
    let a = Foo {
        two: String::from("hello"),
        one: String::from("world"),
    };
    let s = a.one;  // 部分移动
    let ss = a.two; // 使用不完整结构体的字段
    println!("{}", s);
    println!("{}", ss);
    // error, borrow of partially moved value: `a`
    // println!("{:?}", a)
}
```

结构体方法与普通函数相同，也会移动所有权。

```rust
#[derive(Debug)]
struct Foo {
    two: String,
    one: String,
}

impl Foo {
    // self 会移动所有权
    fn do_something(self) {}
}

fn main() {
    println!("Hello, world!");
    let a = Foo {
        two: String::from("hello"),
        one: String::from("world"),
    };
    a.do_something(); // 所有权已被移动
    // error, borrow of moved value: `a`
    // println!("{:?}", a)
}
```
