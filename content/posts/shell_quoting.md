+++
title = 'Bash Reference'
date = 2025-12-26T21:17:29+08:00
tag = ['Shell', 'Bash']
draft = true
+++

## 概念定义

下面是一些会经常出现的概念的定义：

- 空白（blank）： 一个空格或 Tab
- Token：被 Shell 视为一个单元的字符序列，可以是「词」或「操作符」
- 词（word）：被 Shell 视为一个整体的字符序列，不能包含**未引用**的「元字符」
- 元字符（metacharacter）：未被引用时将作为「词」的分隔符。它是下列字符之一：
  - `|`，`&`，`;`，`(`，`)`，`<`，`>`
  - 空格，Tab，`<newline>`
- 操作符（operator）：一个「控制操作符」或「重定向操作符」
- 控制操作符（control operator）：一个拥有控制功能的 Token。它是下列字符之一：
  - `||`，`&&`，`&`，`;`，`;;`，`;&`，`;;&`，`|`，`|&`，`(`，`)`
  - `<newline>`
- 名称（name）：一个由字母，数字和下划线构成的「词」，且以字母和下划线起始

## Shell 操作

Shell 在执行命令时会按以下顺序进行一系列操作：

1. 读取输入（文件、参数或终端输入）
2. 将输入拆分成 Token。Token 将按元字符进行拆分，该过程遵守「引用」规则并执行 alias 扩展
3. 将得到的 Token 解析为「简单命令」或「复合命令」
4. 执行一系列 Shell 扩展
5. 处理重定向
6. 执行命令
7. 如有需要，等待命令结束并收集退出状态

## Token 拆分

Token 是 Shell 的最小解析单元，因此 Shell 需要先把一条命令拆分成一系列 Token。

下面尝试将一条简单的命令拆分成 Token。

```bash
VAR="hello world"; echo "$VAR" | grep hello && echo done > out.txt
```

拆分时以「元字符」分隔 Token，需要注意，操作符是一个语法层面的概念，而元字符是词法层面的概念，因此在进行 Token 拆分，也就是词法分析时应该把`|`这样既是元字符又是操作符的符号时看作元字符。同时，在遇到操作符时，尝试匹配最长操作符，比如`&&`会被视为一个 Token，而不是两个单独的`&`。

由此，我们可以得出这条命令中出现了空格，`;`，`|`和`>`四种元字符。通过这四种元字符可以得到下列 Token：

`VAR="hello world"`、`;`、`echo`、`"$VAR"`、`|`、`grep`、`hello`、`&&`、`echo`、`done`、`>`、`out.txt`。

## 引用（Quoting）

这里的「引用」是「Quoting」而非 C++ 等语言中的「Reference」，Shell 中的引用更像是一种「转义」。

引用（Quoting）是 Shell 中一种用于消除字符或词的特殊意义的机制。Shell 有四种引用机制：

- 转义字符
- 单引号
- 双引号
- 美元单引号

### 转义字符

`\`是一个转义字符（escape character），它会保留其后一个字符的字面意义，除非是`<newline>`。

转义字符常用于输出「元字符（metacharacter）」。

```bash
echo \$n # $n
echo \; echo # ; echo
echo ; echo # tow blank lines
```

当 `\` 和 `<newline>` 成对出现，且 `\` 没有被引用，即 `\<newline>`，则表示续行，常用于多行命令。

```bash
echo hello \
world
# hello world
```

若要输出 `\` 自身，引用自身即可。

```bash
echo \\ # \
```

### 单引号

「单引号引用」将保留其中所有字符的字面意义。单引号不能包含单引号，哪怕前面加上了转义字符。

```bash
echo '\$;' # \$;
echo '$PATH' # $PATH
echo "''" # ''
```

### 双引号

「双引号引用」会保留其中所有字符的字面意义，除了 `$`，`` ` ``, `\`。

`$` 表示「参数扩展」。`$*` 和 `$@` 在双引号中有特殊含义。`$*` 会被扩展为「一个」词，值为各个参数，以 IFS 的第一个字符分隔；`$@` 则是每个参数扩展为一个词。

```bash
echo "$PATH" # expand variable PATH

# 假设参数为 "a", "b c", "d"
# 没有双引号时没有差别
printf "%s\n" $*
printf "%s\n" $@
# a
# b
# c
# d
# 有双引号时，"$*" 会扩展成一个词，而 "$@" 则是每个参数扩展为一个词
printf "%s\n" "$*" # a b c d
printf "%s\n" "$@"
# a
# b c
# d
```

`` ` `` 用于执行其中的命令。

```bash
echo "`ls`" # execute ls
```

`\` 代表转义字符，但只有在其后是 `$`，`` ` ``，`"`，`\` 或 `<newline>` 时才生效。

```bash
echo "\$" # $
echo ";" # ;
echo "\"" # "
```

### 美元单引号

形如 `$'string'` 的词会被替换为 `string`，如果 `string` 是以下 ANSI C 的转义字符则会按其转义后的意义解析。

- `\a`：alert(bell)
- `\b`：backspace
- `\e`：An escape character(not in ANSI C)
- `\E`：like `\e`
- `\f`：form feed
- `\n`：newline
- `\r`：carriage return
- `\t`：horizontal tab
- `\v`：vertival tab
- `\\`：backslash
- `\'`：single quote
- `\"`：double quote
- `\?`：question mark
- `\nnn`：八进制数字 `nnn` 对应的 ASCII 字符
- `\xHH`：十六进制数字 `HH` 对应的 ASCII 字符
- `\uHHHH`：十六进制数字 `HHHH` 对应的 Unicode 字符（ISO/IEC 10646）
- `\UHHHHHHHH`：十六进制数字 `HHHHHHHH` 对应的 Unicode 字符（ISO/IEC 10646）
- `\cx`：A control-x character

```bash
echo $'\U1f980' # 🦀
```

## Shell 参数

在 Shell 中，参数（parameter）是存储值的实体。它可以是一个名称（name），一个数字，或「特殊参数」。而变量（variable）则是一个有名称的参数。可以看出，「参数」类似于其他编程语言中的「变量」，而 Shell 中的「变量」只是参数的一种。

**使用参数时必须加上前缀 `$` 进行「参数扩展」**。

```bash
echo "$1"
echo "$PATH"
echo "$@"
```

### 变量赋值

```txt
name=[value]
```

变量可以通过以上语句赋值，一旦被赋值，变量就只能通过内建命令 `unset` 来取消。如果没有给出 `value` 那么变量被赋值为**空字符串**。所有 `value` 都会经过 Shell 扩展才被赋值给变量。

```bash
v=~/projects    # "/home/username/projects"
v=$(( 1+1 ))    # "2"
v=hello         # "hello"
v="hello world" # "hello world"
v=              # ""
```

### 位置参数

位置参数（positional parameter）是由一个或多个数字代表的参数，除了 0。位置参数是 Shell 启动时，根据它的参数来赋值的。位置参数不能通过「赋值语句」修改，但可以使用内建命令 `set` 来重新赋值。当 Shell 函数被执行时，位置参数会被暂时替换为该函数的参数。

当位置参数由两个以上的数字构成时，它必须放在花括号内。

```bash
echo "$1"
echo "${10}"

# 重新赋值位置参数，如果没有值，则赋值空字符串
set -- a b c
echo "$1"    # a
echo "${10}" # ""
```

### 特殊参数

Shell 对一些参数作特殊处理，这些参数只能被引用而不能被赋值。

- `*`：扩展为位置参数，从 1 开始。在双引号中会有不同
- `@`：扩展为位置参数，从 1 开始。在双引号中会有不同
- `#`：扩展为位置参数个数，以十进制表示
- `?`：扩展为最近执行的前台管道的状态（上一个命令的退出状态）
- `-`：扩展为当前选项标志
- `$`：扩展为 Shell 的进程 ID。在 `()` 子 Shell 中则扩展为当前 Shell 的进程 ID，而不是子 Shell 的
- `!`：扩展为最近一次执行的后台（异步）命令的进程号
- `0`：扩展为 Shell 或 Shell 脚本的名称
- `_`：

## Shell 扩展

在 Token 拆分之后，Shell 会进行一系列扩展，具体有如下 7 种：

1. 花括号扩展（brace expansion）
2. 波浪线扩展（tilde expansion）
1. 参数和变量扩展（parameter and variable expansion）
1. 算术扩展（arithmetic expansion）
4. 命令替换（command substitution）
6. 词的拆分（word splitting）
7. 文件名扩展（filename expansion）
8. 引号删除（quote removal）

以上顺序也是扩展的先后顺序。

### 花括号扩展

花括号扩展可以产生一系列具有相同前后缀的字符串。

```bash
prefix{string1,string2...}suffix
```

花括号扩展支持嵌套。扩展字符串的结果保留从左到右的顺序。因为花括号扩展最先发生，任何对其他扩展有特殊含义的字符都保留在结果中。同时，为了不与参数扩展冲突，字符串`${`不被认为是有效组合。

```bash
echo shell_{brace,tilde,parameter}_expansion
# shell_brace_expansion shell_tilde_expansion shell_parameter_expansion
echo ab${c,d}ef
# abef
chown root /usr/{ucb/{ex,edit},lib/{ex?.?*,how_ex}}
```

如果花括号内的表达式是形如`x..y[..incr]`的序列，其中`x`和`y`是数字或字母，`incr`是可选的步进数字，那么扩展结果将是从`x`到`y`的数字或字母（`x`和`y`必须是相同类型）。步进如果省略，默认为 1 或 -1。

```bash
echo a{2..6}c
# a2c a3c a4c a5c a6c
echo a{2..6..2}c
# a2c a4c a6c
echo a{x..z}2
# ax2 ay2 az2
echo a{z..w}c
# azc ayc axc awc
```

### 波浪号扩展

一个词的第一个字符如果是`~`，那么该词中第一个`\`之前的字符被称为「波浪号前缀」。如果波浪号前缀中没有被引用的字符，那么该波浪号前缀被认为是一个可能的「登录名」。如果登录名是空字符串，那么波浪号会被替换为环境变量`HOME`的值。如果`HOME`没有设置，那么波浪号将被替换为执行当前 Shell 的用户的家目录。否则替换为「登录名」对应用户的家目录。如果登录名无效，那么波浪号扩展失败，保留波浪号前缀。

```bash
echo ~/Documents # /home/foo/Documents
echo ~bar/Documents # /home/bar/Documents
```

在赋值语句中也可以使用`~`。

```bash
v=~
echo "$v" # /home/foo
```

波浪号扩展还有以下变体：

- `~+`：扩展为`$PWD`
- `~-`：扩展为`$OLDPWD`
- `~N`：与`dirs +N`输出相同
- `~N`：与`dirs +N`输出相同
- `~+N`：与`dirs +N`输出相同
- `~-N`：与`dirs -N`输出相同

### 参数扩展

参数扩展将参数替换成对应的值。

```bash
${parameter}
```

参数扩展以`$`开头，紧接着被花括号包裹的参数，花括号是可选的。当位置参数的数字超过两位时，必须使用花括号。此外，花括号还可以避免混淆，如`$abc`和`${a}bc`。

```bash
v="hello world"
echo "$v" # hello world

echo "$1"
echo "${11}"
```

除了上面的基本形式，参数扩展还有很多变体，使用这些变体时必须加上花括号。

#### ${!parameter}

`!`引入一层「间接扩展」。如果`parameter`不是`nameref`，那么将使用`parameter`的值作为变量名进行扩展。

```bash
foo="bar"
bar="hello"
echo "${!foo}" # hello
```

如果`parameter`是`nameref`，那么将扩展为`nameref`所引用的「变量名」。

```bash
declare -n foo=bar
bar="hello"
echo "$foo"    # hello
echo "${!foo}" # bar
```

#### ${parameter:-word}

当`parameter`不存在或为空时，使用`word`作为扩展结果，否则使用`parameter`的值。

```bash
echo "${var:-unset-or-null}" # unset-or-null
var=""                       # 为空
echo "${var:-unset-or-null}" # unset-or-null
var="hello"
echo "${var:-unset-or-null}" # hello
```

`:`可以省略，省略时，只检测是否存在。

```bash
echo "${var-unset-or-null}" # unset-or-null
var=""                      # 为空
echo "${var-unset-or-null}" # ""
var="hello"
echo "${var-unset-or-null}" # hello
```

#### ${parameter:=word}

当`parameter`不存在或为空时，将`word`赋值给`parameter`，最终扩展结果为`parameter`的值。位置参数和特殊参数无法通过这种方式赋值。

```bash
echo "${var:=unset-or-null}" # unset-or-null
var=""                       # 为空
echo "${var:=unset-or-null}" # unset-or-null
var="hello"
echo "${var:=unset-or-null}" # hello
```

`:`可以省略，效果同上。

#### ${parameter:?word}

当`parameter`不存在或为空时，输出`word`到标准错误，如果是非交互 Shell，那么以非 0 状态退出，如果是交互 Shell，则不会退出，但也不会执行该扩展相关的命令。

```bash
echo "hello ${var:?unset-or-null}" # unset-or-null
var=""                             # 为空
echo "hello ${var:?unset-or-null}" # unset-or-null
var="hello"
echo "${var:?unset-or-null}"       # hello
```

`:`可以省略，效果同上。

#### ${parameter:+word}

当`parameter`不存在或为空时，什么也不做，反之则使用`word`作为扩展结果。

```bash
echo "${var:+unset-or-null}" # ""
var=""                             # 为空
echo "${var:+unset-or-null}" # ""
var="hello"
echo "${var:+set-and-non-null}"    # set-and-non-null
```

`:`可以省略，效果同上。

#### ${parameter:offset:length}

如果`parameter`是字符串，则扩展为`parameter`从第`offset`个字符开始，长度为`length`的子串，即区间`[offset, offset + length - 1]`，字符串从 0 开始索引，`offset`和`length`都是算术表达式。

```bash
var="hello world"
echo "${var:3:7}" # lo worl
```

如果省略`:length`（注意`:`），则区间为`[offset, end-of-string]`

```bash
echo "${var:3}" # lo world
```

如果省略`length`（注意`:`），则视`length`为 0，此时子串长度为 0。

```bash
echo "${var:3:}" # nothing
```

如果省略`offset`，则区间为`[0, length-1]`

```bash
echo "${var::5}" # hello
```

如果

## Shell 命令

### 简单命令（Simple Command）

```txt
[assignment...] [<word>|<redirection>]...<control operator>
```

「简单命令」由一系列**可选的**变量赋值，空格分隔的词和重定向，一个控制操作符结尾构成。第一个词指明要执行的命令，其余词则是该命令的参数。

变量赋值只在要执行的命令中生效，不会影响当前 Shell。

```bash
# 变量 VAR 只在 echo 中才有效，在当前 Shell 调用 echo 不会生效
VAR="hello" echo "$VAR" # ""
```

### 管道（Pipeline）

管道（pipeline）是一个或多个命令的序列，通过控制操作符 `|` 或 `|&` 分隔。

```txt
[time [-p]] [!] command [| or |& command2...]
```

命令 command 的标准输出通过管道连接到命令 command2 的标准输入。连接发生在命令 command 指定的任何重定向之前。若使用 `|&` 则会把 command 的标准输出和标准错误连接到 command2 的标准输入。这是对 `2>&1 |` 的简写，且这种对标准错误的重定向发生在命令 command 指定的任何重定向之后。

管道的退出状态将是最后一个命令的退出状态，若有 `!` 前缀，则为最后一个命令退出状态的逻辑非值。若有 `time` 前缀，管道中止后将给出执行管道耗费的用户和系统时间，选项 `-p` 将使输出符合 POSIX 指定的格式。环境变量 `TIMEFORMAT` 可以控制时间信息的格式。

管道中的每个命令都作为**单独的进程**来执行（即，在一个子 Shell 中执行）。

### 序列（List）

命令序列（list）是一个或多个管道的序列，通过操作符 `;`、`&`、`&&`、`||` 分隔，并且可以选择用 `;`、`&` 或 `<newline>` 结束。

```bash
false || echo 5 # 5
false && echo 5 # nothing
echo 1;echo 2
echo 1&echo 2
echo 42&
```

在一个命令序列中使用一个或多个 `<newline>` 分隔命令效果与 `;` 相同。

如果一个命令以 `&` 结束，那么 Shell 将在子 Shell 中执行该命令，且不会等待其结束，返回状态总是 0。以 `;` 分隔的命令会被顺序执行，且 Shell 会等待每个命令依次结束，返回状态是最后执行的命令的返回状态。

使用 `&&` 分隔的命令序列被称为 AND 命令序列。command2 只有在 command1 的退出状态为 0 时才会执行。

```bash
command1 && command2
```

使用 `||` 分隔的命令序列被称为 OR 命令序列。command2 只有在 command1 的退出状态为非 0 时才会执行。

```bash
command1 || command2
```

AND 序列或 OR 序列的返回状态是序列中最后一个执行的命令的返回状态。

四个分隔命令序列的操作符中，`&&` 和 `||` 优先级相同，其次是具有相同优先级的 `;` 和 `&`。

```bash
# 类似 C 的三目运算符
grep hello test.txt && echo yes || echo no
```

### 复合命令（Compound Command）

下方语法描述中，`list` 后的 `;` 是序列的结束标志，这里写出来是因为把命令都写在了同一行，也可以用 `<newline>` 或 `&` 代替（以 `&` 结束表示异步执行，其返回状态总是 0）。

```bash
# 以 <newline> 结束
count=1
until [ $count -gt 10 ]
do
echo "$count"
((count++))
done
```

保留字与命令之间的空格是词的分隔符，可以使用 `<newline>` 或 Tab 替代（其他元字符无效）。

#### 循环结构（Looping Constructs）

循环结构均支持使用内建命令 `continue` 和 `break` 进行控制。

##### until

```bash
until test-list...; do consequent-list...; done
```

只要 `test-list` 返回状态不为 0 就执行 `consequent-list`。返回状态是最后执行的命令的返回状态，如果没有命令执行则为 0。

```bash
# '[' 是一个内建命令
count=1
until [ $count -gt 10 ]; do
    echo "$count"
    ((count++))
done
```

##### while

```bash
while test-list; do consequent-list; done
```

只要 `test-list` 返回状态为 0 就执行 `consequent-list`。返回状态是最后执行的命令的返回状态，如果没有命令执行则为 0。

```bash
count=1
while [ $count -lt 10 ]; do
    echo "$count"
    ((count++))
done
```

##### for

```bash
for name [[in words...];] do list...; done
```

`in` 之后的一系列词会被扩展，产生一个项目列表。变量 `name` 会被一次赋以列表的每一个元素，然后执行 `list`。返回状态是最后执行的命令的返回状态。如果 `in word` 被省略，那么则会使用「位置参数」作为列表，相当于 `in "$@"`。如果列表为空，则不会执行任何命令，返回状态是 0。

```bash
for p in /etc/*; do
    echo "$p"
done

# 省略 `in word`
for p; do
    echo "$p"
done
```

还有一种类似 C 的 for 循环：

```bash
for (( expr1 ; expr2 ; expr3 )) [;] do list... ; done
```

其执行方式也与 C 类似。其中的 `;` 是固定格式，不能用其他符号替换。

```bash
for ((i = 0; i < 100; i++)); do
    echo $i
done
```

#### 条件结构（Conditional Construct）

##### if

```bash
if test-list; then consequent-list;
[elif test-list; then consequent-list;]...
[else consequent-list;]
fi
```

与 C 中的 if 语句类似。返回状态是最后执行的命令的返回状态，若没有任何命令执行则为 0。

##### case

```bash
case word in
    [ [(] pattern [| pattern]...) list... ;; ]
esac
```

`case`会执行第一个匹配`word`的分支对应的命令序列。`word`和`pattern`都会进行扩展，`word`会依次与分支比较，并执行匹配成功的分支对应的命令序列，是否继续比较取决于分支的结束控制符。分支由模式列表、命令序列和结束控制符组成。模式列表由一个或多个模式序列构成，模式序列通过`|`分隔，以`)`结束。匹配规则与「路径名扩展」相同。

每个分支都以`;;`、`;&`或`;;&` 结束。使用`;;`结束分支会使得`case`在成功匹配该分支后停止执行；使用`;&`会在成功匹配该分支后无条件执行下一个分支；使用`;;&`会在成功匹配该分支后继续匹配的剩下分支（再次成功匹配后是否继续匹配取决于新分支的结束符号）。

使用`*`作为模式可以定义一个默认分支，该分支必须是最后一个分支，当其他分支都不匹配时则会匹配该分支。

TODO: 更多示例。双引号引用在模式中的问题。

```bash
case "$1" in
start | up)
    vagrant up
    ;;
*)
    echo "Usage: $0 {start|stop|ssh}"
    ;;
esac
```

##### select

##### ((...))

##### \[\[...]]

#### 组命令（Grouping Command）

##### ()

```bash
(list...)
```

使用一对圆括号可以强制在子 Shell 中执行 `list`。

##### {}

```bash
{ list...; }
```

使用一对花括号可以在当前 Shell 执行能够 `list`。命令与花括号之间的「空白」是必须的，命令后面的 `;` 或 `<newline>` 也是必须的。
