+++
title = 'Rust 常用迭代器方法'
date = 2024-07-12T16:04:04+08:00
draft = true
+++

# Rust 常用迭代器方法

主要介绍一些 `Iterator` trait 中常用的方法，特别是**迭代器适配器**。

## 常用迭代器适配器

获取迭代器并返回另一个迭代器的函数称为**迭代器适配器**。

### chain

```rust
fn chain<U>(self, other: U) -> Chain<Self, <U as IntoIterator>::IntoIter>
where
    Self: Sized,
    U: IntoIterator<Item = Self::Item>,
```

`chain` 方法可以按顺序连接两个**类型相同**的迭代器。

```rust
let v1 = vec![3, 4, 54];
let v2 = vec!["hhh", "ooo"];
// error: expected &{integer}, found &&str
let iter = v1.iter().chain(v2.iter());

let v1 = vec![3, 4, 54];
let v2 = vec![4, 2, 5];
let iter = v1.iter().chain(v2.iter());

for i in iter {
    print!("{i:#?} ")
}
// 3 4 54 4 2 5
```

### zip

```rust
fn zip<U>(self, other: U) -> Zip<Self, <U as IntoIterator>::IntoIter>
where
    Self: Sized,
    U: IntoIterator,
```

`zip` 方法将两个相同或不同类型的迭代器“打包”在一起，并产生一个 `Zip` 迭代器。`Zip` 迭代器会返回一个包含两个元素的元组。

当任意一个迭代器返回 `None` 时，`next` 方法就会返回 `None`，即使另一个迭代器中还有元素。

```rust
let v1 = [3, 4, 54, 8];
let v2 = [4, 2, 5];
let iter = v1.iter().zip(v2.iter());

for i in iter {
    println!("{i:?} ")
}
// (3, 4)
// (4, 2)
// (54, 5)
```

`unzip` 方法可以对 `Zip` 迭代器“解压”，获得一个包含两个 `Option<T>` 的元组。

```rust
let mut iter = v1.iter().zip(v2.iter());
let (a, b) = iter.next().unzip();
```

### map

```rust
fn map<B, F>(self, f: F) -> Map<Self, F>
where
    Self: Sized,
    F: FnMut(Self::Item) -> B,
```

`map` 常用于将一个类型转换成另一类型。它接受一个以迭代器的元素为参数的闭包，`map` 会为每个元素调用该闭包以产生新的类型。

```rust
let v2 = ["Rust", "Go", "Kotlin", "C"];
let iter = v2
    .iter()
    .enumerate()
    .filter(|(idx, _)| *idx != 2)
    .map(|(_, val)| *val) // 将元组中的元素提取出来
    .collect::<Vec<&str>>();
for i in iter {
    println!("{i:?} ")
}
```

### filter

```rust
fn filter<P>(self, predicate: P) -> Filter<Self, P>
where
    Self: Sized,
    P: FnMut(&Self::Item) -> bool,
```

`filter` 用于过滤元素。`filter` 接受一个返回值为布尔类型的闭包。`Filter` 迭代器只会包含闭包返回值为 `true` 的元素。

```rust
let v2 = ["Rust", "Go", "Kotlin", "C"];
let iter = v2
    .iter()
    .enumerate()
    .filter(|(idx, _)| *idx != 2)
    .map(|(_, val)| *val) // 将元组中的元素提取出来
    .collect::<Vec<&str>>();
for i in iter {
    println!("{i:?} ")
}
```

### enumerate

`Enumerate` 迭代器返回一个元组，第一个元素是当前元素的索引（usize），第二个元素则是当前元素的值。

```rust
let v = ['a', 'b', 'c'];
for (i, v) in v.iter().enumerate() {
    println!("{i}: {v}")
}
```

### peekable

`peekable` 返回一个可以调用 `peek` 和 `peek_mut` 的迭代器。这两个方法可以查看迭代器的下一个元素而不消耗迭代器。

```rust
let mut v2 = [
    "Rust".to_owned(),
    "Go".to_owned(),
    "Kotlin".to_owned(),
    "C".to_owned(),
];
let mut iter = v2.iter().peekable();
assert_eq!(iter.peek(), Some(&&"Rust".to_owned()));
assert_eq!(iter.peek(), Some(&&"Rust".to_owned()));
```

### skip

```rust
fn skip(self, n: usize) -> Skip<Self>
where
    Self: Sized,
```

跳过前 n 个元素，`Skip` 迭代器只包含后剩下的元素。

```rust
let mut v2 = [
    "Rust".to_owned(),
    "Go".to_owned(),
    "Kotlin".to_owned(),
    "C".to_owned(),
];
let iter = v2.iter().skip(2);
for i in iter {
    println!("{i}")
}
```

### take

```rust
fn take(self, n: usize) -> Take<Self>
where
    Self: Sized,
```

获取前 n 个元素。与 `Skip` 相反，`Take` 只包含前 n 个元素。

```rust
let mut v2 = [
    "Rust".to_owned(),
    "Go".to_owned(),
    "Kotlin".to_owned(),
    "C".to_owned(),
];
let mut iter = v2.iter();
iter.next();
let iter = iter.take(2);
for i in iter {
    println!("{i}")
}
```

### scan

```rust
fn scan<St, B, F>(self, initial_state: St, f: F) -> Scan<Self, St, F>
where
    Self: Sized,
    F: FnMut(&mut St, Self::Item) -> Option<B>,
```

与 `fold` 类似，但 `fold` 只返回最终结果，`scan` 返回一个迭代器，可以访问每次闭包调用的结果。

```rust
let a = [1, 2, 3, 4];

let mut iter = a.iter().scan(1, |state, &x| {
    // each iteration, we'll multiply the state by the element ...
    *state = *state * x;

    // ... and terminate if the state exceeds 6
    if *state > 6 {
        return None;
    }
    // ... else yield the negation of the state
    Some(-*state)
});

assert_eq!(iter.next(), Some(-1));
assert_eq!(iter.next(), Some(-2));
assert_eq!(iter.next(), Some(-6));
assert_eq!(iter.next(), None);
```

### flatten

```rust
fn flatten(self) -> Flatten<Self>
where
    Self: Sized,
    Self::Item: IntoIterator,
```

`flatten` 用于平展嵌套的结构。一次只能消除一层嵌套。

```rust
let data = vec![vec!["C", "Rust"], vec!["Go", "C++"]];
let flattened = data.into_iter().flatten().collect::<Vec<&str>>();
assert_eq!(flattened, &["C", "Rust", "Go", "C++"]);
```

### fuse

`Fuse` 迭代器在第一次返回 `None` 后就只会返回 `None` 。

### inspect

```rust
fn inspect<F>(self, f: F) -> Inspect<Self, F>
where
    Self: Sized,
    F: FnMut(&Self::Item),
```

`inspect` 常用于调试。

```rust
let a = [1, 4, 2, 3];

// this iterator sequence is complex.
let sum = a.iter()
    .cloned()
    .filter(|x| x % 2 == 0)
    .fold(0, |sum, i| sum + i);

println!("{sum}");

// let's add some inspect() calls to investigate what's happening
let sum = a.iter()
    .cloned()
    .inspect(|x| println!("about to filter: {x}"))
    .filter(|x| x % 2 == 0)
    .inspect(|x| println!("made it through filter: {x}"))
    .fold(0, |sum, i| sum + i);

println!("{sum}");

// 6
// about to filter: 1
// about to filter: 4
// made it through filter: 4
// about to filter: 2
// made it through filter: 2
// about to filter: 3
// 6
```

### filter_map

```rust
fn filter_map<B, F>(self, f: F) -> FilterMap<Self, F>
where
    Self: Sized,
    F: FnMut(Self::Item) -> Option<B>,
```

`filter_map` 将 `filter` 与 `map` 结合，接受一个返回 `Option<T>` 的闭包。`FilterMap` 迭代器只包含闭包返回值为 `Some(val)` 的元素。

```rust
let mut v2 = [
    "Rust".to_owned(),
    "Go".to_owned(),
    "Kotlin".to_owned(),
    "C".to_owned(),
];
let iter = v2
    .iter()
    .enumerate()
    .filter_map(|(idx, val)| if idx != 2 { Some(val) } else { None })
    .collect::<Vec<&String>>();
for i in iter {
    println!("{i:?} ")
}
```

### skip_while

```rust
fn skip_while<P>(self, predicate: P) -> SkipWhile<Self, P>
where
    Self: Sized,
    P: FnMut(&Self::Item) -> bool,
```

跳过元素，直到第一个闭包返回值为 `false` 的元素。`SkipWhile` 迭代器包含第一个闭包返回值为 `false` 及其后面的所有元素。

### take_while

```rust
fn take_while<P>(self, predicate: P) -> TakeWhile<Self, P>
where
    Self: Sized,
    P: FnMut(&Self::Item) -> bool,
```

获取元素，直到第一个闭包返回值为 `false` 的元素。`TakeWhile` 迭代器包含第一个闭包返回值为 `false` 的元素之前的所有元素。

### map_while

```rust
fn map_while<B, P>(self, predicate: P) -> MapWhile<Self, P>
where
    Self: Sized,
    P: FnMut(Self::Item) -> Option<B>,
```

`map` 与 `take_while` 的结合。

### flat_map

```rust
fn flat_map<U, F>(self, f: F) -> FlatMap<Self, U, F>
where
    Self: Sized,
    U: IntoIterator,
    F: FnMut(Self::Item) -> U,
```

`map` 与 `flatten` 的结合。

## 常用迭代器方法
### for_each

### fold
