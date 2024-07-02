+++
title = 'Rust_smart_pointer'
date = 2024-07-02T15:57:07+08:00
tags = ['Rust']
+++

# Smart Pointer in Rust

## Box<T>

Box 是最简单的智能指针，它允许你将一个值放在堆上而不是栈上。

```rust
fn main() {
    let f1 = foo { bar: 32 };
    let f2 = Box::new(foo { bar: 11 });
    println!("address on stack: {:p}", &f1);
    println!("address on heap: {:p}", f2);
    println!("address of box(on stack): {:p}", &f2);
}

struct foo {
    bar: i32,
}

// address on stack: 0x7ffd34540f0c
// address on heap: 0x57d39e669ba0
// address of box(on stack): 0x7ffd34540f10
```

Box 只提供了间接存储和堆分配，除此之外没有其他特殊功能。

```rust
// 利用 Box 实现递归类型
enum List {
    Cons(i32, Box<List>),
    Nil,
}

use crate::List::{Cons, Nil};

fn main() {
    let list = Cons(1, Box::new(Cons(2, Box::new(Cons(3, Box::new(Nil))))));
}
```

## Deref Trait

实现 `Deref` trait 可以重载解引用运算符 `*`。

```rust
use std::ops::Deref;

fn main() {
    let a = 4;
    let b = MyBox::new(a);
    println!("{:?}", *b);
    assert_eq!(4, *b);
}

#[derive(Debug)]
struct MyBox<T>(T);

impl<T> MyBox<T> {
    fn new(x: T) -> MyBox<T> {
        MyBox(x)
    }
}

// 为结构体实现 Deref Trait
impl<T> Deref for MyBox<T> {
    type Target = T;
    fn deref(&self) -> &Self::Target {
        &self.0
    }
}
```

在执行 `*y` 时，Rust 会将其替换为 `*(y.deref())`。 

### Deref 强制转换

**Deref 强制转换（Deref coercions）** 将实现了 `Deref` trait 的类型的引用**转换为另一种类型的引用**。比如将 `&String` 转换为 `&str`。

Deref 强制转换发生在编译时，因此并没有运行时损耗。

`Deref` trait 用于重载不可变引用的解引用运算符，而 `DerefMut` trait 用于重载可变引用的解引用运算符。

Rust 在发现类型和 trait 满足三种情况时会进行 Deref 强制转换：

- 当 `T: Deref<Target=U>` 时从 `&T` 到 `&U`。
- 当 `T: DerefMut<Target=U>` 时从 `&mut T` 到 `&mut U`。
- 当 `T: Deref<Target=U>` 时从 `&mut T` 到 `&U`。

## Drop Trait

`Drop` trait 允许我们在值要离开作用域时执行一些代码。

```rust
use std::ops::Deref;

fn main() {
    let a = 4;
    let b = MyBox::new(a);
    assert_eq!(4, *b);
}

#[derive(Debug)]
struct MyBox<T>(T);

impl<T> MyBox<T> {
    fn new(x: T) -> MyBox<T> {
        MyBox(x)
    }
}

// 为结构体实现 Deref Trait
impl<T> Deref for MyBox<T> {
    type Target = T;
    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

// 为结构体实现 Drop trait
impl<T> Drop for MyBox<T> {
    fn drop(&mut self) {
        println!("Drop MyBox");
    }
}
```

Rust 不允许直接调用 `Drop` trait 的 `drop` 方法。因为 Rust 仍然会在值离开作用域时自动调用，这会导致二次释放的错误。

若要强制提前清理值，可以使用 `std::mem::drop` 函数。

```rust
let b = MyBox::new(24);
// std::mem::drop 位于 prelude 中
drop(b);
```

## Rc<T>

有时候一个值会有多个所有者。比如图的节点会被多条边连接。

`Rc<T>` 允许我们在堆上分配一些可以被程序的多个部分**读取**的内存。`Rc<T>` 只用于**不可变引用**且只能用于**单线程**场景。

```rust
use std::rc::Rc;

#[derive(Debug)]
enum List {
    // 使用 Rc<T> 存储 List
    Cons(i32, Rc<List>),
    Nil,
}

use crate::List::{Cons, Nil};

fn main() {
    let a = Rc::new(Cons(24, Rc::new(Cons(25, Rc::new(Nil)))));

    println!("{:p}", a);
    // Rc 重载了 Deref trait，返回 T
    if let Cons(_, i) = &*a {
        println!("{:p}", i);
        if let Cons(_, k) = &**i {
            println!("{:p}", k)
        }
    }
    // 通过 Rc::strong_count(&a) 查看引用计数
    println!("{}", Rc::strong_count(&a));

    // Rc::clone() 增加引用计数，Rc 的 clone 方法的效果与 Rc::clone 相同
    let b = Rc::clone(&a);
    println!("{}", Rc::strong_count(&b));

    let c = Rc::clone(&a);
    println!("{}", Rc::strong_count(&c));

    // 普通的不可变引用，在栈上配分内存
    let d = &a;
    println!("{:p}", d);
}
```

## RefCell<T>

**内部可变性（Interior mutability）**是 Rust 中的一个设计模式，它允许你即使在有不可变引用时也可以改变数据，这通常是借用规则所不允许的。

```rust
#[derive(Debug)]
enum List {
    Cons(Rc<RefCell<i32>>, Rc<List>),
    Nil,
}

use crate::List::{Cons, Nil};
use std::cell::RefCell;
use std::rc::Rc;

fn main() {
    let value = Rc::new(RefCell::new(5));

    let a = Rc::new(Cons(Rc::clone(&value), Rc::new(Nil)));

    let b = Cons(Rc::new(RefCell::new(3)), Rc::clone(&a));
    let c = Cons(Rc::new(RefCell::new(4)), Rc::clone(&a));

    // value 本身不可变，但可以通过 RefCell<T> 的 borrow_mut 方法修改其内部的值
    // borrow_mut 返回 RefMut<T>，类似 &mut
    *value.borrow_mut() += 10;

    println!("a after = {a:?}");
    println!("b after = {b:?}");
    println!("c after = {c:?}");

    if let Cons(i, k) = b {
        println!("{:#?}", i);
        *i.borrow_mut() += 10;
        println!("{:#?}", i);

        if let Cons(x, _) = &*k {
            println!("{:#?}", x);
            *x.borrow_mut() += 10;
            println!("{:#?}", x);
        }
    }
}
```

## Weak<T>

```rust
use std::cell::RefCell;
use std::rc::{Rc, Weak};

#[derive(Debug)]
struct Node {
    value: i32,
    parent: RefCell<Weak<Node>>,
    children: RefCell<Vec<Rc<Node>>>,
}

fn main() {
    let leaf = Rc::new(Node {
        value: 3,
        parent: RefCell::new(Weak::new()),
        children: RefCell::new(vec![]),
    });

    println!(
        "leaf strong = {}, weak = {}",
        Rc::strong_count(&leaf),
        // 查看实例的弱引用计数
        Rc::weak_count(&leaf),
    );

    {
        let branch = Rc::new(Node {
            value: 5,
            parent: RefCell::new(Weak::new()),
            children: RefCell::new(vec![Rc::clone(&leaf)]),
        });

        // 创建弱引用
        *leaf.parent.borrow_mut() = Rc::downgrade(&branch);

        println!(
            "branch strong = {}, weak = {}",
            Rc::strong_count(&branch),
            Rc::weak_count(&branch),
        );

        println!(
            "leaf strong = {}, weak = {}",
            Rc::strong_count(&leaf),
            Rc::weak_count(&leaf),
        );
    }

    // upgrade() 方法检查所引用的实例是否还存在，返回 Option
    println!("leaf parent = {:?}", leaf.parent.borrow().upgrade());
    println!(
        "leaf strong = {}, weak = {}",
        Rc::strong_count(&leaf),
        Rc::weak_count(&leaf),
    );
}
```
