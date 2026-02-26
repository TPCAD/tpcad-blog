+++
title = 'Find 参考手册'
date = 2025-07-14T11:13:50+08:00
draft = true
+++

Find 可以递归地在层次目录中处理文件。

```bash
find [-H] [-L] [-P] [-D debugopts] [-Olevel] [path...] [expression]
```

## 选项（命令行参数）

五个「选项」（或者叫命令行参数。注意与下文表达式中的选项区分） `-H`，`-L`，`-P`，`-D`，`-O` 必须出现在路径之前。

`-H`，`-L`，`-P` 控制 find 对符号链接（软链接）的处理方式。

`-P` 表示不解析符号链接，这也是 find 的默认行为。当 find 处理符号链接时，使用的是符号链接本身的文件信息而非其指向的文件。

`-L` 表示解析符号链接。当 find 处理符号链接时，使用的文件信息是符号链接所指向的文件。

`-H` 表示只解析指定路径的符号链接。

当这三个参数有多个同时出现时，**只有最后出现的会生效**。

```bash
ll
# total 0
# lrwxrwxrwx 1 root root 4 Jul 31 17:06 link -> /etc
# lrwxrwxrwx 1 root root 8 Jul 31 17:07 link.txt -> /version
# -rw-r--r-- 1 root root 0 Jul 31 16:18 nolink.md

find -maxdepth 2 -ctime +1
# no files found
find -L -maxdepth 2 -ctime +1
# ./link.txt
# ./link/passwd.OLD
# ./link/sensors3.conf
# ./link/libva.conf
# ./link/avahi
# ./link/zsh

find link -maxdepth 2 -ctime +1
# no files found
find -H link -maxdepth 2 -ctime +1
# ./link/passwd.OLD
# ./link/sensors3.conf
# ./link/libva.conf
# ./link/avahi
# ./link/zsh
```

## 路径

路径指定 find 要搜索的范围，可以指定多个路径，以空格分隔。若不提供则默认当前目录。

## 表达式

表达式，控制 find 如何匹配文件以及如何操作匹配的文件。

表达式主要由「选项」、「测试」和「动作」组成，彼此之间以运算符分隔，

测试（Tests）是匹配的主要方式，根据文件的某一属性判断文件是否匹配，并依此返回真值或假值。

动作（Actions）用于操作匹配的文件，通常伴随着副作用（如打印内容到标准输出），根据操作结果返回真值或假值。

选项（Options）又分为全局选项和位置选项，全局选项会影响所有测试和动作，而位置选项只会影响跟在它后面测试和动作。选项总是返回真值。

运算符（Operators）也是表达式的一部分，用于连接表达式的各个组成部分。默认的运算符是 `-and`。

若不提供则默认使用 `-print`。

因为选项、测试和动作的作用顺序有可能影响结果，所以应遵循选项、测试、动作的顺序书写命令。

## 运算符

- `( expr )` 强制优先
- `! expr` 或 `-not expr` 逻辑非
- `expr1 expr2` 或 `expr1 -a expr2` 或 `expr1 -and expr2` 逻辑与
- `expr1 -o expr2` 或 `expr1 -or expr2` 逻辑或
- `expr1, expr2` 列表。`expr1` 和 `expr2` 都会被执行。`expr1` 的值被忽略，列表的值是 `expr2` 的值

## 选项

## 测试

一些测试接受数字参数，数字参数有三种形式：`+n`，`-n`，`n`。`+n` 表示大于 n，`-n` 表示小于 n，`n` 表示恰好是 n。

### -[acm]time [+-]n

匹配上次访问时间小于、大于或等于 `n*24` 小时以前的文件。

`-atime` 等测试的精度是 24 小时，也就是说 30 小时会被认为是 24 小时，而非大于 24 小时。

```bash
find -atime 0 # 上次访问时间在 24 小时以内
find -atime 1 # 上次访问时间在 24～48 小时之间
find -atime +1 # 上次访问时间在 48 小时以前
find -atime -1 # 上次访问时间在 24 小时以内
```

### -[acm]min [+-]n

与 `atime` 等相同，但精度是分钟。同样的，10 min 40 s 会被认为是 10 min。
