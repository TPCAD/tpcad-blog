+++
title = 'Rust Iterator'
date = 2024-07-10T20:54:19+08:00
+++

# Rust Iterator

## 可迭代对象与迭代器（Iterable and Iterator）

迭代器（Iterator）是一种可以让你方便地遍历序列中每一个元素的工具。迭代器有两个重要的功能：

1. 记录当前的迭代状态
2. 产生可以访问下一个元素的迭代器

可迭代对象（Iterable）是一种可以产生迭代器的对象。比如 `Vec<T>` 可以通过 `iter` 方法获得一个迭代器，但 `Vec<T>` 本省不是一个迭代器。

一个可迭代对象通常有三个方法，分别对应三种迭代类型。

- `iter()`，迭代 `&T`
- `iter_mut()`，迭代 `&mut T`
- `into_iter()`，迭代 `T`

## Iterator Trait

Rust 迭代器的核心是 `Iterator` trait。`Iterator` trait 的核心代码看起来像下面这样：

```rust
trait Iterator {
    type Item;
    fn next(&mut self) -> Option<Self::Item>;
}
```

关联类型 `Item` 表明迭代器返回的对象，`next` 方法表明迭代器如何返回该对象。

### 实现 Iterator Trait 遍历 &T

假设有以下结构体，现在需要为 `Todos` 实现 `Iterator` trait。

```rust
pub struct Todos {
    pub list: Vec<Todo>,
}

#[derive(Debug)]
pub struct Todo {
    pub message: String,
    pub done: bool,
}
```

实现 `Iterator` trait 的关键是记录当前的迭代状态。`Todos` 使用一个 `Vec<T>` 来进行存储，非常适合用索引来记录迭代状态。我们可以为 `Todos` 添加一个 `index` 字段来记录迭代状态。但很显然，这并不妥当。当你对 `Todos` 进行迭代时会修改 `index` 字段的值，如果想要再次进行迭代，就必须重置 `index` 字段，因为迭代器不会在迭代结束后重置状态。

所以我们更倾向于只把 `Todos` 当作一个可迭代对象，并用一个新的数据结构来记录迭代状态。

下面是一个名为 `TodosIterator` 的结构体，它两个字段，`todos` 是对 `Todos` 的不可变引用，`index` 是一个 `usize`，用于记录当前的迭代状态。接下来将为 `TodosIterator` 实现 `Iterator` trait。

```rust
pub struct TodosIterator<'a> {
    todos: &'a Todos,
    index: usize,
}
```

首先指定关联类型 `Item` 为 `&'a Todo`，这表明这个迭代器用于迭代 `&T`。

接着实现 `next` 方法。通过比较当前 `index` 的值与 Vec 的长度判断是否迭代结束。若否，`index` 字段加 1，并返回当前索引对应的 `Some(&Todo)`。

```rust
impl<'a> Iterator for TodosIterator<'a> {
    type Item = &'a Todo;
    fn next(&mut self) -> Option<Self::Item> {
        if self.index < self.todos.list.len() {
            let result = Some(&self.todos.list[self.index]);
            self.index += 1;
            result
        } else {
            None
        }
    }
}
```

现在我们还需要为 `Todos` 实现一个用于产生迭代器的方法，使其成为可迭代对象。对于迭代 `&T` 的迭代器，这个方法通常是 `iter()`。

```rust
impl Todos {
    pub fn iter(&self) -> TodosIterator {
        TodosIterator {
            todos: self,
            index: 0,
        }
    }
}
```

现在可以通过 `iter` 方法在 for 循环中迭代 `Todos` 了。

```rust
fn main() {
    let todos = Todos {
        list: vec![
            Todo {
                message: "Hello".to_string(),
                done: false,
            },
            Todo {
                message: "Rust".to_string(),
                done: false,
            },
            Todo {
                message: "World".to_string(),
                done: false,
            },
        ],
    };

    for todo in todos.iter() {
        println!("{todo:#?}")
    }
}
```

## IntoIterator Trait

`IntoIterator` trait 的核心代码看起来像下面这样。它有一个 `into_iter` 方法，用于产生一个拥有对象所有权的迭代器。

关联类型 `Item` 与 `Iterator` 的 `Item` 相同，`IntoIter` 是一个实现了 `Iterator` trait 的类型。 方法 `into_iter` 会获取对象的所有权，并返回 `IntoIter`。

```rust
pub trait IntoIterator {
    type Item;
    type IntoIter: Iterator<Item = Self::Item>;

    fn into_iter(self) -> Self::IntoIter;
}
```

Rust 在标准库中为所有实现了 `Iterator` trait 的类型实现了 `IntoIterator`。

```rust
impl<I: Iterator> IntoIterator for I
```

### 实现 IntoIterator Trait 遍历 T

因为 `IntoIterator` 会获取对象的所有权，所以不能继续使用 `TodosIterator` 来实现。我们使用一个新的结构体来实现。

```rust
pub struct TodosIntoIterator {
    todos: Todos,
}
```

接着为 `Todos` 实现 `IntoIterator`。将关联类型 `IntoIter` 指定为 `TodosIntoIterator`，并在 `into_iter` 方法中返回一个 `TodosIntoIterator`。

```rust
impl IntoIterator for Todos {
    type Item = Todo;
    type IntoIter = TodosIntoIterator;

    fn into_iter(self) -> Self::IntoIter {
        TodosIntoIterator { todos: self }
    }
}
```

因为 `IntoIter` 是一个实现了 `Iterator` trait 的类型，所以我们需要为 `TodosIntoIterator` 实现 `Iterator` trait。

因为 `TodosIntoIterator` 拥有所有权，所以这里在每次迭代中删除 Vec 的第一个元素，这样迭代器总是指向这个元素。同时以 Vec 为空为迭代结束条件。

```rust
impl Iterator for TodosIntoIterator {
    type Item = Todo;

    fn next(&mut self) -> Option<Self::Item> {
        if self.todos.list.is_empty() {
            return None;
        }
        let result = self.todos.list.remove(0);
        Some(result)
    }
}
```

如此一来便能在 `for` 循环中遍历 `todos` 并获得其所有权。

```rust
for todo in todos {
    println!("{todo:#?}")
}
```

## 实现 Iterator Trait 遍历 &mut T

要实现遍历 `&mut T` 的 `Iterator` trait 并不容易。

若仿照 `&T` 来实现 `&mut T`，编译器会抱怨生命周期太短。

```rust
impl Todos {
    pub fn iter_mut(&mut self) -> TodosMutIterator {
        TodosMutIterator {
            todos: self,
            index: 0,
        }
    }
}

pub struct TodosMutIterator<'a> {
    todos: &'a mut Todos,
    index: usize,
}

impl<'a> Iterator for TodosMutIterator<'a> {
    type Item = &'a mut Todo;
    fn next(&mut self) -> Option<Self::Item> {
        if self.index < self.todos.list.len() {
            let result = Some(&mut self.todos.list[self.index]);
            self.index += 1;
            result
        } else {
            None
        }
    }
}

// error: lifetime may not live long enough
//   --> src/main.rs:87:13
//    |
// 81 | impl<'a> Iterator for TodosMutIterator<'a> {
//    |      -- lifetime `'a` defined here
// 82 |     type Item = &'a mut Todo;
// 83 |     fn next(&mut self) -> Option<Self::Item> {
//    |             - let's call the lifetime of this reference `'1`
// ...
// 87 |             result
//    |             ^^^^^^ method was supposed to return data with lifetime `'a` but it is returning da
// ta with lifetime `'1`
```

`iter_mut` 方法通常用于返回一个可以遍历 `&mut T` 的迭代器。显然，迭代器只要能访问元素，并记录迭代状态就行了。因此我们可以借助 Vec 来实现 `iter_mut` 方法。

创建一个类型为 `Vec<&mut Todo>` 的 Vec，并获取 `Todos` 的 Vec 的元素的可变引用，也就是 `&mut Todo`。最后对新的 Vec 调用方法 `into_iter`，返回一个可以以可变引用访问元素的迭代器。

这样虽然不再需要额外的结构体，但每次遍历都需要创建一个新的 Vec。

```rust
impl Todos {
    pub fn iter_mut(&mut self) -> std::vec::IntoIter<&mut Todo> {
        let mut v: Vec<&mut Todo> = vec![];
        for todo in self.list.iter_mut() {
            v.push(todo)
        }
        v.into_iter()
    }
}
```

## 实现 IntoIterator Trait 遍历 &T 和 &mut T

只需要为对应的类型实现 `IntoIterator` trait，`into_iter` 方法就可以根据上下文返回遍历 `&T`、`&mut T` 或 `T` 的迭代器。

```rust
impl<'a> IntoIterator for &'a Todos {
    type Item = &'a Todo;
    type IntoIter = TodosIterator<'a>;

    fn into_iter(self) -> Self::IntoIter {
        self.iter()
    }
}

impl<'a> IntoIterator for &'a mut Todos {
    type Item = &'a mut Todo;
    type IntoIter = std::vec::IntoIter<&'a mut Todo>;

    fn into_iter(self) -> Self::IntoIter {
        self.iter_mut()
    }
}
```

## 解引用裸指针实现 Iterator Trait 遍历 &mut T

此前编译器抱怨生命周期太短，可以通过解引用裸指针解决。

这样做的本质是将变量的生命周期变为 `'static`。将一个值转化为原始指针后，它的生命周期信息会被丢弃，再次引用原始指针则会赋予静态生命周期。静态生命周期存活时间非常长，这样做会带来一些潜在的安全风险。

```rust
pub struct TodosMutIterator<'a> {
    todos: &'a mut Todos,
    index: usize,
}

impl<'a> Iterator for TodosMutIterator<'a> {
    type Item = &'a mut Todo;
    fn next(&mut self) -> Option<Self::Item> {
        if self.index < self.todos.list.len() {
            // 解引用裸指针
            let result = unsafe { &mut *(&mut self.todos.list[self.index] as *mut _) };
            self.index += 1;
            Some(result)
        } else {
            None
        }
    }
}
```

如下代码所示，变量 `a` 是一个引用，它会指向 `s1` 或 `s2` 所指向的内容，而 `s1` 和 `s2` 在离开其作用域后会被清理，因为 `a` 拥有静态生命周期，所以它在离开作用域后仍能使用，而它所指向的内容已经被释放，这会导致访问到完全随机的数据。

```rust
fn main() {
    let a;
    {
        let mut v1 = vec![2, 3];
        let s1 = &mut v1;
        let mut v2 = vec![1, 8];
        let s2 = &mut v2;
        a = test(s1, s2);
    }
    println!("{a:?}")
}

fn test<'a>(s1: &mut Vec<i32>, s2: &mut Vec<i32>) -> &'a mut Vec<i32> {
    let i = 2;
    if i == 1 {
        unsafe { &mut *(s1 as *mut _) }
    } else {
        unsafe { &mut *(s2 as *mut _) }
    }
}

// 一种可能的结果
// [-502036575, 23992]
```

## 参考资料

1. [Effectively Using Iterators In Rust](https://hermanradtke.com/2015/06/22/effectively-using-iterators-in-rust.html/)
2. [How do I create mutable iterator over struct fields](https://stackoverflow.com/questions/61978903/how-do-i-create-mutable-iterator-over-struct-fields)
3. [Implementing Iterator and IntoIterator in Rust](https://dev.to/wrongbyte/implementing-iterator-and-intoiterator-in-rust-3nio#:~:text=IntoIterator%20is%20a%20bit%20different,be%20converted%20into%20an%20iterator.)
4. [Does dereferencing a raw pointer back to a reference change the lifetime of the reference?](https://www.reddit.com/r/rust/comments/1bfzs0m/does_dereferencing_a_raw_pointer_back_to_a/)
5. [Module std::iter](https://doc.rust-lang.org/std/iter/index.html)
