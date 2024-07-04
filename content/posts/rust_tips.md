+++
title = 'Rust Tips'
date = 2024-06-30T08:38:38+08:00
draft = true
+++

## Useful Macros

### format!

`format!` 宏类似于 C/C++ 中的 `fprintf` 函数。

`format!` 宏的第一个参数是格式化字符串，它必须是一个字面量。表达式列表紧跟在格式化字符串之后。

`format!` 宏使用 `{}` 作为占位符。格式化的顺序与表达式列表的顺序相同。

```rust
format!("{} {} {}", 3, 2, 1); // => 3 2 1
```

#### 位置参数（Positional Parameters）

使用类似于数组索引的方式，指定表达式的位置。

```rust
format!("{2} {1} {0}", 3, 2, 1); // => 1 2 3
format!("{1} {2} {0}", 3, 2, 1); // => 2 1 3
```

位置参数与空占位符互不干扰。

```rust
// 即使第一个占位符指定了位置参数，后两个空占位符依然按顺序格式化
format!("{2} {} {}", 3, 2, 1); // => 1 3 2
```

注意，表达式列表的每一个值都要被使用。

```rust
// 最后一个表达式 `1` 从未被使用过
format!("{0} {} {}", 3, 2, 1); // => error
// 每一个表达式都至少被使用一次
format!("{2} {} {}", 3, 2, 1); // => 1 3 2
format!("{0} {} {} {}", 3, 2, 1); // => 1 3 2 1
```

#### 具名参数（Named Parameters）

具名参数必须位于参数列表的最后。

```rust
format!("{} {argument} {}", 2, 4, arguement=24); // 2 24 4
```

若具名参数没有出现在参数列表，`format!` 会从当前的作用域中寻找。

```rust
let argument = 24;
format!("{argument}");
```

#### 格式化参数（Formatting Parameters）

格式化参数以 `:` 开头。

##### 宽度

```rust
// 直接指定宽度
println!("Hello {:5}!", "x"); // => Hello x    !
// 通过位置参数指定，后跟一个 $
println!("Hello {:1$}!", "x", 5);
// 通过具名参数指定，后跟一个 $
println!("Hello {:width$}!", "x", width = 5);
```

##### 填充与对齐

```rust
println!("Hello {:5}!", "x"); // => Hello x    !
// 右对齐
println!("Hello {:>5}!", "x"); // => Hello     x!
// 左对齐
println!("Hello {:<5}!", "x"); // => Hello x    !
// 居中对齐
println!("Hello {:^5}!", "x"); // => Hello   x  !
// 填充，必须和对齐一起使用
println!("Hello {:!<5}!", "x"); // => Hello x!!!!!
```

##### 符号/#/0

```rust
// `+`，显示正负号，只对数字有效
println!("Hello {:+5}!", 2); // => Hello    +2!
// `0`，以 0 填充，该项会覆盖填充和对齐
println!("Hello {:05}!", 1); // => Hello 00001!
// `#`，以替代形式输出
// 0b
println!("Hello {:#b}!", 24);
// 0o
println!("Hello {:#o}!", 24);
// 0x
println!("Hello {:#x}!", 24);
// 0x
println!("Hello {:#X}!", 24);
// pretty-print Debug trait
println!("Hello {:#?}!", 24);
```

##### 精度

对于非数字类型，精度表示最大宽度。

对于整数，精度会被忽略。

对于浮点数，精度表示小数点后几位

```rust
println!("Hello {:.5}!", 2.423);
println!("Hello {:.1$}!", 2.423, 5);
println!("Hello {:.prec$}!", 2.423, prec = 5);

// 取*接下来*两个参数中的第一个作为精度，第二个作为要格式化的值
println!("Hello {:.*}!", 5, 2.423);
// 第一个参数 x 已经被第一个占位符使用了
println!("Hello {}, {:.*}!", "x", 5, 2.423);

// 要格式化的值已经确定。取接下来第一个参数作为精度，即 `5`
println!("Hello {1} is {2:.*}",  5, "x", 0.01);
// 要格式化的值已经确定，第一个参数 x 已经被第一个占位符使用。取接下来第一个参数作为精度，即 `5`
println!("Hello {} is {2:.*}",   "x", 5, 0.01);
```

##### 转义

```rust
println!("{{}}") // => {}
```

#### 语法

```language
format_string := text [ maybe_format text ] *
maybe_format := '{' '{' | '}' '}' | format
format := '{' [ argument ] [ ':' format_spec ] [ ws ] * '}'
argument := integer | identifier

format_spec := [[fill]align][sign]['#']['0'][width]['.' precision]type
fill := character
align := '<' | '^' | '>'
sign := '+' | '-'
width := count
precision := count | '*'
type := '' | '?' | 'x?' | 'X?' | identifier
count := parameter | integer
parameter := argument '$'
```

可见格式化参数是有顺序的，即填充、对齐、符号、#、0、宽度、精度、类型。
