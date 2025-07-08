+++
title = 'Sed 参考手册'
date = 2025-07-08T17:20:30+08:00
tags = ['Linux']
+++

Sed 是一个流编辑器，按行处理输入的文本。Sed 默认不会修改文件，只会将修改的内容输出到标准输出。

## 模式空间与保持空间

Sed 有两个用于处理输入行的临时缓冲区，模式空间（Pattern Space）和保持空间（Holding Space）。

模式空间相当于工厂的流水线，每一个输入行都会进入模式空间，一般的命令都会在模式空间进行。在处理结束后模式空间的内容会被打印到标准输出，并自动清空模式空间。

保持空间是模式空间的缓冲区，用于临时保存模式空间的数据，一般的命令无法作用于保持空间。保持空间的内容不会主动清空，也不会主动打印。

Sed 每处理一行都会先将其保存到模式空间，若该行满足条件，则执行命令。命令执行完毕或输入行不满足条件，则打印模式空间内容到标准输出并清空模式空间。

## 命令行参数

### -n, --silent, --quiet

Sed 处理完一行后默认会打印模式空间内容到标准输出。

```bash
# test.md
line one

sed '1p' test.md
# output
# line one
# line one
# line two
```

使用 `-n`，`--silent` 或 `--quiet` 参数可以关闭自动打印。

```bash
sed '1p' test.md
# output
# line one
```

### -e, --expression

`-e` 和 `--expression` 用于直接指定 sed 脚本。

```bash
sed -e 's/Tmux/Zellij/' todo.md
sed --expression='s/Tmux/Zellij/' todo.md
```

一般情况下不需要使用参数指定 sed 脚本，但 `-e` 和 `--expression` 可以同时指定多个 sed 脚本。

```bash
sed --expression='s/Tmux/Zellij/' -e 's/\[\ \]/[x]/' todo.md
#output
[x] Zellij 重复环境变量
[x]
```

## 地址

地址用于过滤需要处理的行。没有提供地址时，sed 会处理所有的输入行。提供一个地址时 sed 只会选择对应的行。提供两个地址时，sed 会选择对应范围的行。

地址有「数字」和「正则表达式」两种形式。

数字表示某一行，正则表达式则表示所有匹配行。数字不能为 0，正则表达式有两种书写方式。

```bash
# 1. /regexp/
# 2. \cregexpc
# 第二种方式中的 'c' 可以是任意字符。若 'c' 出现在正则表达式中，则需要转义。
sed '/font/d' alacritty.toml
sed '\cfontcd' alacritty.toml
sed '\tfon\ttd' alacritty.toml
```

#### 单地址

单个数字选择某一行，单个正则表达式选择匹配的所有行。

```bash
sed '3d' test.md # 删除第 3 行
sed '/font/d' alacritty.toml # 删除所有含「font」的行
```

#### 双地址

双地址可以组合使用数字和正则表达式，两个地址之间以 `,` 分隔。

```text
# 测试文本 alacritty.toml
1  [font]
2  size = 18.0
3  [font.bold]
4  family = "Maple Mono NL NF CN"
5  style = "Bold"
6  [font.bold_italic]
7  family = "Maple Mono NL NF CN"
8  style = "Bold Italic"
9  [font.italic]
10 family = "Maple Mono NL NF CN"
11 style = "Italic"
12 [font.normal]
13 family = "Maple Mono NL NF CN"
14 style = "Regular"
15 [general]
16 import = ["/home/tpcad/.config/alacritty/catppuccin-frappe.toml"]
```

```bash
sed '2,4d' test.md # 删除 2, 3, 4 行
sed '/Italic/, /Maple/d' alacritty.toml # 删除第 8～10 行，第 11～13 行
sed '2,/Italic/d' test.md # 删除第 2 行到第一次匹配到「Italic」的行（2～8 行）
sed '/font/, 7d' test.md # 删除第一次匹配到「font」的行到第 7 行（1～7 行）以及之后所有包含「font」的行
```

当以正则表达式为起始条件时，sed 会选择所有符合条件的「范围」。如 `/Italic/, /Maple/` 选择了第 8～10 行和第 11～13 行两个范围。下一个范围不会选择上一个范围的行，也就是说每个范围不会互相重叠。

若没有匹配的结束条件，则会一直选择至下一个匹配的起始条件，若已是最后一个范围则选择至最后一行。若结束条件为数字并小于起始条件匹配到的第一行，则只会选择起始条件匹配的所有行。

```bash
# 结束条件不存在，选择至下一个匹配的起始条件
nl alacritty.toml | sed -n '/style/,/non/p'
nl alacritty.toml | sed -n '/style/,33p'
#      5  style = "Bold"
#      6  [font.bold_italic]
#      7  family = "Maple Mono NL NF CN"
#      8  style = "Bold Italic"
#      9  [font.italic]
#     10  family = "Maple Mono NL NF CN"
#     11  style = "Italic"
#     12  [font.normal]
#     13  family = "Maple Mono NL NF CN"
#     14  style = "Regular"
#     15  [general]
#     16  import = ["/home/tpcad/.config/alacritty/catppuccin-frappe.toml"]

# 小于起始条件匹配到的第一行，选择所有含有 `style` 的行
nl alacritty.toml | sed -n '/style/,3p'
#      5  style = "Bold"
#      8  style = "Bold Italic"
#     11  style = "Italic"
#     14  style = "Regular"
```

使用双地址时，匹配起始条件的行无论如何都会被选中，哪怕结束条件匹配的行在该行之前。

```bash
sed '3, 2p' -n # 打印第 3 行
```

当第二个地址是正则表达式时，sed 不会再检查第一个地址所选择的行是否满足第二个地址的正则表达式。

```bash
sed '3, /font/p' -n # 打印 3～6 行
```

#### 其他形式

`$` 表示最后一行。

```bash
sed '$d' alacritty.toml # 删除最后一行
```

`first~step` 表示从第 `first` 行开始，步进为 `step` 行。`first` 可以为 0，此时相当于从 `step` 行开始。

```bash
sed '2~4d' test.md # 删除 2, 6, 10 行（从 2 开始，步进为 4）
```

`0,regexp` 表示从第 1 行开始直至第一次匹配到 `regexp`。与 `number,regexp` 不同，该形式检查第一个地址是否匹配正则表达式。

```bash
sed '0,/font/d' alacritty.toml
# [font]
sed '1,/font/d' alacritty.toml
# [font]
# size = 18.0
# [font.bold]
```

`addr1,+N` 表示选择 `addr1` 和其随后的 `N` 行。`N` 为数字。

```bash
nl alacritty.toml | sed '/font/,+3'
#     1  [font]
#     2  size = 18.0
#     3  [font.bold]
#     4  family = "Maple Mono NL NF CN"
#     6  [font.bold_italic]
#     7  family = "Maple Mono NL NF CN"
#     8  style = "Bold Italic"
#     9  [font.italic]
#    12  [font.normal]
#    13  family = "Maple Mono NL NF CN"
#    14  style = "Regular"
#    15  [general]

# 正则表达式作为第一个地址时仍然会选择多个范围
```

`addr1,~N` 表示选择 `addr1` 和其随后的行，直至行号等于 `N` 的倍数。

```bash
nl alacritty.toml | sed -n '/style/,~5p' # 两个范围
#      5  style = "Bold"
#      6  [font.bold_italic]
#      7  family = "Maple Mono NL NF CN"
#      8  style = "Bold Italic"
#      9  [font.italic]
#     10  family = "Maple Mono NL NF CN"
#     11  style = "Italic"
#     12  [font.normal]
#     13  family = "Maple Mono NL NF CN"
#     14  style = "Regular"
#     15  [general]
nl alacritty.toml | sed -n '9,~5p'
#      9  [font.italic]
#     10  family = "Maple Mono NL NF CN"
```

## 命令

命令必须包裹在单引号中。

### 常用命令

#### 打印行号

`=` 打印当前行行号。行号会在新的一行输出。

```bash
sed '/font/=' alacritty.toml -n
# 1
# 3
# 6
# 9
# 12
```

#### 插入内容

`a` 在行后插入内容。若有多行内容使用 `\` 分隔。

```bash
sed '/general/anew line' alacritty.toml

sed '/general/aline one\
line two\
line three' alacritty.toml
```

`i` 在行前插入内容。若有多行内容使用 `\` 分隔。

```bash
sed '/general/inew line' alacritty.toml

sed '/general/iline one\
line two\
line three' alacritty.toml
```

#### 删除

`d` 清空当前模式空间并开始处理下一行。

```bash
sed '/font/, /Maple/d' alacritty.toml
```

`D` 删除模式空间的第一行并立即开始（跳过自动打印和清空）下一轮处理但不读取新的行。

```bash
# 与 d 相同，因为模式空间总是只有一行
sed '/font/, /Maple/D' alacritty.toml

sed 'N;D' alacritty.toml # 打印最后一行
```

#### 替换

`c` 替换所选择的行为指定内容。若有多行内容使用 `\` 分隔。

```bash
# test.md
# line one
# line two
# line three

sed '/line/c\new line' test.md
# new line
# new line
# new line

# 若为范围则会替换整个范围。
sed '/one/,/two/c\new line' test.md
# new line
# line three
```

`s/regexp/replacement` 替换行的匹配部分为指定内容。

```bash
sed '/line/s/line/LINE/' append.txt
# LINE one
# LINE two
# LINE three

sed '1,2s/line/LINE/' append.txt
# LINE one
# LINE two
# line three
```

#### 打印模式空间

`p` 打印整个模式空间；`P` 打印模式空间的第一行。

打印命令通常搭配 `-n` 参数使用，避免自动打印影响输出内容。

#### 读取下一行

`n` 清空当前模式空间并读取下一行到模式空间；`N` 读取下一行并附加到模式空间。若没有可读取的下一行则结束 sed。

```bash
sed 'n;p;q' test.md -n
# line two

sed 'N;p;q' test.md -n
# line one
# line two
```

### 进阶命令

#### 停止并退出

`q`，`Q` 立即停止并退出 sed。`q` 不会停止自定打印，`Q` 会停止自动打印。

```bash
nl alacritty.toml | sed '/font/p;q'
#      1  [font]
#      1  [font]
nl alacritty.toml | sed '/font/p;Q'
#      1  [font]
```

#### 从文件获取插入内容

`r` 从文件中获取所有内容并插入到匹配「行后」。

```bash
sed '/font/r append.txt' alacritty.toml
# [font]
# line one
# line two
# size = 18.0
# [font.bold]
# line one
# line two
# family = "Maple Mono NL NF CN"
# style = "Bold"
# [font.bold_italic]
# line one
# line two
```

#### 操作保持空间

`x` 交换模式空间和保持空间。保持空间默认只有一个换行符。

```bash
sed 'x;p;q' test.md # 打印空行。
```

`h` 拷贝模式空间内容到保持空间；`H` 附加模式空间内容到保持空间。拷贝会覆盖原有的内容。

```bash
sed 'h;x;p' test.md -n
# line one
# line two
# line three

sed 'H;${x;p}' test.md -n
# 
# line one
# line two
# line three
```

`g` 拷贝保持空间内容到模式空间；`G` 附加保持空间内容到模式空间。拷贝会覆盖原有的内容。

```bash
# 倒序
sed '1!G;h;$!d' test.md
# line three
# line two
# line one
```

#### 保存模式空间到文件

`w` 将模式空间写入到指定文件（会覆盖已有内容）。

```bash
sed '/font/!wnew.txt' alacritty.toml
```

#### 字符替换

`y/source/dest` 将匹配行中 `dest` 的字符替换为 `source` 中的对应字符。`soucre` 和 `dest` 的长度必须相同。

```bash
sed 'y/abcefghijk/1234567980' test.md
# l8n4 on4
# l8n4 two
# l8n4 t7r44
```

### GNU 扩展

`q`，`Q` 可以指定退出码。

```bash
nl alacritty.toml | sed '/font/p;Q 0'

nl alacritty.toml | sed '/font/p;Q 3'
```

`R` 逐行读取文件内容并插入到匹配行后。

```bash
sed '/font/R append.txt' alacritty.toml
# [font]
# line one # 第一行
# size = 18.0
# [font.bold]
# line two # 第一行
# family = "Maple Mono NL NF CN"
# style = "Bold"
# [font.bold_italic]
# family = "Maple Mono NL NF CN"
```

`W` 将模式空间第一行写入指定文件。
