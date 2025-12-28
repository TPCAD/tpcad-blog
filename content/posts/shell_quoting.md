+++
title = 'Shell 引用'
date = 2025-12-26T21:17:29+08:00
+++

这里的「引用」是「Quoting」而非 C++ 等语言中的「Reference」，Shell 中的引用更像是一种「转义」。

## Shell 引用

引用（Quoting）是 Shell 中一种用于消除字符或词的特殊意义的机制。Shell 有四种引用机制：

- 转义字符
- 单引号
- 双引号
- 美元单引号

### 转义字符

`\` 是一个转义字符（escape character），它会保留其后一个字符的字面意义，除非是 `<newline>`。

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
