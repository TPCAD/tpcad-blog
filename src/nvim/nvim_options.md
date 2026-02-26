+++
title = 'Neovim Options'
date = 2025-10-27T10:06:35+08:00
+++

选项（Options）是用于配置 Vim/Neovim 行为和外观的各种内置变量。选项可以是「数字」、「布尔」或「字符串」三种类型之一。

## 设置选项

`:set` 可以用于设置 option，比如 `:set number` 开启行号显示。

一些常用的 `:set` 命令：

- `:set`：列出所有与默认值不同的选项
- `:set!`：列出所有与默认值不同的选项，每个选项单独一行
- `:set all`：列出所有选项
- `:set! all`：列出所有选项，每个选项单独一行
- `:set {option}?`：查看指定选项的值
- `:set {option}`：
    - 布尔类型：true
    - 数字类型：查看选项的值
    - 字符串类型：查看选项的值
- `:set no{option}：将布尔类型的选项设为 false
- `:set inv{option}` 或 `:set {option}!`：反转布尔类型 option
- `:set {option}&`：设置选项为默认值
- `:set all&`：设置所有选项为默认值
- `:set {option}={value}` 或 `:set {option}:{value}`：设置数字或字符串类型选项

```vimscript
:set number                   " 布尔类型
:set clipboard=unnamedplus    " 字符串类型
:set cmdheight=2              " 数字类型
```

## 选项作用域

选项有三种作用域：

- 全局选项（global）
- 窗口局部选项（local to window）
- 缓存区局部选项（local to buffer）

使用 `:setglobal` 和 `:setlocal` 可以分别设置选项的全局值和局部值，而 `:set` 会同时设置选项的全局值和局部值。

对于大部分全局选项，单独设置全局值或局部值是没有意义的，因为 `:setglobal` 和 `:setlocal` 都会同时设置全局值和局部值。但也有一些全局选项可以单独设置局部值，这些选项通常被称为「全局-局部选项」（global-local option）。例如 `makeprg` 是一个全局-缓冲区局部选项，可以使用 `:setlocal` 为每个缓冲区设置独立的 make 程序，若没有则使用全局选项。

「窗口局部选项」的作用域是窗口，但 Neovim/Vim 会为每个缓冲区单独保存其在每个窗口的选项，也就是说，每个缓冲区在每个窗口都有独立的配置。比如，同一个缓冲区在不同窗口可以有不同选项，同一窗口的不同缓冲区可以有不同选项。使用 `:setglobal` 设置窗口局部选项并不会影响已加载的缓冲区，而是只影响新打开的缓冲区。而 `:setlocal` 只会影响当前缓冲区。

## 自动设置选项

除了在命令行模式使用 `:set` 设置选项外，Neovim 提供了几种自动设置选项的方法：

1. 使用配置文件或启动参数（见 `:h config` 和 `:h -c`）
2. 自动命令
3. 局部配置文件 `.nvim.lua`（开启 `exrc` 选项）
4. `editorconfig`
5. 位于文件开头后末尾的 `modeline` 设置

### modeline

在文件的开头或末尾添加格式如下的 `modeline` 可以帮助 Neovim/Vim 设置选项。

```language
[text{white}]{vi:|vim:|ex:}[white]{options}
```

- [text{white}]：任意文本或空白符（至少一个空白符）。通常是编程语言的注释符号
- {vi:|vim:|ex:}：三个中的任一个
- [while]：可选空白符
- {options}：一系列用空格或 `:` 分隔的选项

下面是一行在 Lua 文件中的 `modeline`：

```lua
-- vim: nonumber norelativenumber
```

`modeline` 中的设置指向影响当前缓冲区和窗口，就像 `:setlocal`。

## 帮助文档

相关帮助文档：

- :help options
- :help option-list
- :help option-summary
- :help local-options
- :help global-local

在线帮助文档：

- [options](https://neovim.io/doc/user/options.html)
- [option-list](https://neovim.io/doc/user/quickref.html#option-list)。
- [option-summary](https://neovim.io/doc/user/options.html#_3.-options-summary)
- [global-local](https://neovim.io/doc/user/quickref.html#global-local)。
- [local-options](https://neovim.io/doc/user/quickref.html#local-options)。
