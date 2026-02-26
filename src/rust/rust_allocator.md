+++
title = 'Rust Allocator'
date = 2025-09-10T15:36:44+08:00
draft = true
+++

`alloc::alloc::GlobalAlloc` trait 是全局分配器必须实现的。

实现 `GlobalAlloc` trait 的类型可以使用 `#[global_allocator]` 设置成默认全局分配器。


`alloc::alloc::Allocator` trait 是分配器必须实现的。

标准库的容器都要求分配器实现 `Allocator` trait。


`std::alloc::System` 是依赖操作系统的全局分配器，其底层是调用操作系统的内存管理函数（如 malloc）。它实现了 `GlobalAlloc` 和 `Allocator`。


`std::alloc::Global` 是一个全局分配器，它只实现了 `Allocator`。它会将相应调用转发到使用 `#[global_allocator]` 注册的全局分配器，如果没有则使用 `std` 提供的全局分配器（std::alloc::System）。
