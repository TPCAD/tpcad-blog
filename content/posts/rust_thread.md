+++
title = 'Thread in Rust'
date = 2024-07-03T11:47:33+08:00
tags = ['Rust']
+++

## 线程基础

- 创建线程

使用 `thread::spawn` 创建线程，它接受一个 `FnOnce` 闭包。

```rust
use std::{thread, time::Duration};

fn main() {
    let handle = thread::spawn(|| {
        for i in 0..10 {
            println!("{i}: spawned thread echo");
            thread::sleep(Duration::from_millis(10));
        }
    });

    for i in 0..5 {
        println!("{i}: main thread echo");
        thread::sleep(Duration::from_millis(10));
    }

    handle.join().unwrap();
}
```

- 等待线程结束

使用 `join` 方法等待线程结束。

```rust
let handle = thread::spawn(|| {
    for i in 0..10 {
        println!("{i}: spawned thread echo");
        thread::sleep(Duration::from_millis(10));
    }
});

// 对 spawn 的返回值调用 join 方法
handle.join().unwrap();
```

- move 闭包与线程

```rust
use std::thread;

fn main() {
    let v = vec![1, 2, 3];

    // 使用 move 获取所有权
    let handle = thread::spawn(move || {
        println!("Here's a vector: {v:?}");
    });

    handle.join().unwrap();
}
```

## 消息传递

Rust 通过**信道（channel）**实现消息传递。

信道由两部分组成：一个发送者（transmitter）和接收者（receiver）。当任一方被丢弃时可以认为信道被关闭了。

Rust 的信道实现在 `std::sync::mpsc` 中。

`mpsc::channel` 函数用于创建一个信道。它会返回一个元祖，第一个元素是发送者，第二个元素是接收者。

发送者调用 `send` 方法发送消息。它的参数就是要发送的值。它返回一个 `Result<(), SendError<T>>`。错误通常发生在接收者已经被丢弃时。

注意，`send` 方法会获取参数的所有权。

接受者调用 `recv` 方法接收消息。该方法会阻塞线程执行直到从信道中获取一个值。若信道已经被关闭，则会返回一个错误。

另外还有 `try_recv` 方法可以接收信息。这个方法不会阻塞线程，而是立刻返回一个 Result。

```rust
use std::{sync::mpsc, thread};
fn main() {
    // mpsc:;channel 创建一个信道。
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let val = "hello".to_owned();
        // 调用 send 方法发送消息
        tx.send(val).unwrap();
    });

    // 接收者调用 recv 方法接收消息
    let rec = rx.recv().unwrap();
    println!("{rec} from spwaned thread");
}
```

### 创建多个发送者

可以使用 `clone` 方法创建多个发送者。同时，将接收者当作一个迭代器不断从信道中获取消息。

```rust
use std::{sync::mpsc, thread};
fn main() {
    let (tx, rx) = mpsc::channel();
    let tx1 = tx.clone();

    thread::spawn(move || {
        let val = "hello".to_owned();
        tx.send(val).unwrap();
    });

    thread::spawn(move || {
        let val = "hello".to_owned();
        tx1.send(val).unwrap();
    });

    for rec in rx {
        println!("{rec} from spwaned thread");
    }
}
```

## 互斥器

**互斥器**保证在任意时刻，只有一个线程访问某些数据。

在 Rust 中通过 `Mutex<T>` 创建一个互斥锁。访问互斥器的数据前需要获取锁。`lock` 方法返回一个类型为 `MutexGuard` 的智能指针。在 `MutexGuard` 离开作用域时，会调用 `Drop`
 trait 释放锁。

```rust
use std::sync::Mutex;

fn main() {
    let m = Mutex::new(5);

    {
        let mut num = m.lock().unwrap();
        *num = 6;
    }

    println!("m = {m:?}");
}
```

`Mutex<T>` 并不能直接用于多线程。`Arc<T>` 是一个类似 `Rc<T>` 但可用于多线程的智能指针。

```rust
use std::{
    sync::{Arc, Mutex},
    thread,
};
fn main() {
    // 将 Mutex<T> 放在 Arc<T> 中
    let counter = Arc::new(Mutex::new(0));
    let mut handlers = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handler = thread::spawn(move || {
            let mut num = counter.lock().unwrap();
            *num += 1;
            println!("counter: {num}");
        });
        handlers.push(handler);
    }

    for handler in handlers {
        handler.join().unwrap();
    }

    // println!("Result: {}", *counter.lock().unwrap());
}
```
