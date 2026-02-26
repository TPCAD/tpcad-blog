+++
title = 'Rust_process_module'
date = 2025-11-10T15:11:39+08:00
draft = true
+++

`std::process` 是 Rust 标准库中用于处理进程的模块，可以生成子进程并与之交互，同时也提供了 `abort` 和 `exit` 来中止当前进程。

## 生成子进程

`Command` 结构体是 `std::process` 最重要的结构体，用于配置和生成子进程。

`new` 方法只创建 `Command` 对象，并没有生成子进程。

```rust
let command = Command::new("ls");
```

`arg` 方法可以为子进程添加参数，一次只能传递一个参数，其返回值是 `Command` 对象的引用，因此可以链式调用添加多个参数。

```rust
let command = Command::new("ls")
    .arg("-l")
    .arg("-a")

// .arg("-c /path/to/something") // not work
// .arg("-c").arg("/path/to/something")
```

`args` 方法可以为子进程添加多个参数，返回值也是 `Command` 对象的引用。

```rust
let command = Command::new("ls")
    .args(["-l","-a"])
```

`spawn` 和 `output` 方法可以生成子进程。`output` 生成子进程并等待子进程中止，返回一个 `Output` 对象，而 `spawn` 方法返回一个代表子进程的 `Child` 对象。二者都需要进行错误处理。

```rust
let output = Command::new("ls")
    .args(["-l", "-a"])
    .output()
    .expect("ls command failed to start");


let child = Command::new("echo")
    .arg("Oh no, a tpyo!")
    .spawn()
    .expect("Failed to start echo process");
```

## 子进程退出状态

`status` 方法同样可以创建子进程并等待其完成，其返回值是 `ExitStatus` 对象，记录了子进程的退出信息。`ExitStatus` 还是实现了 `Display` Trait。

`success` 方法用于判断子进程是否成功结束。

```rust
pub fn success(&self) -> bool
```

```rust
use std::process::Command;

let status = Command::new("mkdir")
                     .arg("projects")
                     .status()
                     .expect("failed to execute mkdir");

if status.success() {
    println!("'projects/' directory created");
} else {
    println!("failed to create 'projects/' directory: {status}");
}
```

`code` 方法返回子进程的退出代码。

```rust
use std::process::Command;

let status = Command::new("mkdir")
                     .arg("projects")
                     .status()
                     .expect("failed to execute mkdir");

match status.code() {
    Some(code) => println!("Exited with status code: {code}"),
    None       => println!("Process terminated by signal")
}
```

## 子进程输出

`Output` 用于描述已结束进程的输出。`Command` 的 `output` 方法或 `Child` 的 `wait_with_output` 方法都可以返回 `Output` 对象。

```rust
pub struct Output {
    pub status: ExitStatus, // 进程退出码
    pub stdout: Vec<u8>,    // 进程写入 stdout 的数据
    pub stderr: Vec<u8>,    // 进程写入 stderr 的数据
}
```

`stdout` 和 `stderr` 都是原始的二进制数据，需要处理才适合阅读。

```rust
use std::process::Command;

fn main() {
    println!("Hello, world!");
    let output = Command::new("ls")
        .arg("-a")
        .arg("-l")
        .output()
        .expect("Failed to start process");
    let lines: Vec<String> = String::from_utf8(output.stdout)
        .expect("Failed")
        .lines()
        .map(|str| str.to_string())
        .collect();
    for line in lines.iter() {
        println!("{}", line)
    }
}
```

## 子进程 I/O

默认情况下，通过 `spawn` 或 `status` 方法创建的子进程会继承父进程的标准输入输出流，而 `output` 方法则会为子进程创建管道以截获子进程的输出到 Rust。`Command` 的 `stdin`，`stdout` 和 `stderr` 方法可以配置子进程的标准输入输出流。与之相关的结构体是 `Stdio`。

`Stdio::piped` 方法用于创建一个新管道连接父子进程。使用 `Stdio::pipe` 才能使 Rust 捕获子进程的输入输出流。

`Stdio::inherit` 方法使子进程继承父进程的标准输入输出流。

`Stdio::null` 方法使得子进程的流被忽略，相当于将流附加到 `/dev/null`。

在捕获输入流后，如果没有及时关闭输入流可能导致死锁。下方代码的目的是在父进程中向子进程写入数据，因为变量 `stdin` 持有输入流句柄，且只有在变量销毁时句柄才会被关闭，而子进程又需要在句柄关闭后才能结束，这就导致父进程调用 `wait_with_output` 后等待子进程结束，而子进程又在等待父进程关闭输入流，形成死锁。

```rust
use std::io::Write;
use std::process::{Command, Stdio};

fn main() {
    let mut child = Command::new("rev")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
        .expect("Failed to spawn child process");

    let mut stdin = child.stdin.take().expect("Failed to open stdin");
    stdin.write_all("Hello, world!".as_bytes()).expect("Failed to write to stdin");

    let output = child.wait_with_output().expect("Failed to read stdout");
    assert_eq!(String::from_utf8_lossy(&output.stdout), "!dlrow ,olleH");
}
```

及时销毁变量（限制句柄变量的作用域），关闭句柄即可消除该死锁。

```rust
{
    let mut stdin = child.stdin.take().expect("Failed to open stdin");
    stdin.write_all("Hello, world!".as_bytes()).expect("Failed to write to stdin");
}
```

使用多线程也可以消除该死锁。输入流句柄在线程结束后就被关闭。

```rust
let mut stdin = child.stdin.take().expect("Failed to open stdin");
std::thread::spawn(move || {
    stdin.write_all("Hello, world!".as_bytes()).expect("Failed to write to stdin");
});
```

