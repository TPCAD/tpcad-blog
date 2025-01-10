+++
title = '在 Linux 下配置 Neovim'
date = 2024-11-30T15:12:16+08:00
draft = true
+++

本文所用的 Neovim 版本为 `0.11.0-dev-851+g4f9311b75`。

```bash
NVIM v0.11.0-dev-851+g4f9311b75
Build type: RelWithDebInfo
LuaJIT 2.1.1724512491
Run "nvim -V1 -v" for more info
```

## 配置文件

Neovim 支持使用 Lua 进行配置，本文也使用 Lua 进行配置。

Neovim 的配置文件位于 `~/.config/nvim/init.lua`。虽然可以将所有配置都写到 `init.lua` 中，但这样非常不利于管理。通常把 `init.lua` 作为配置的入口文件，真正的配置内容都放到 `lua` 目录下。本文采用如下的目录结构。

```language
nvim/
├── ftplugin/
├── lua/
│   ├── config/
│   │   ├── autocmd.lua
│   │   ├── basic.lua
│   │   ├── keymaps.lua
│   │   ├── plugins.lua
│   ├── plugins/
│   └── utils/
├── snippets/
├── init.lua
├── lazy-lock.json
└── stylua.toml
```

- `ftplugin` 用于为不同文件类型进行不同配置
- `lua/config` Neovim 的具体配置，包括基础配置，按键映射，插件等
- `lua/plugins` 插件的具体配置
- `lua/utils` 自定义的功能配置
- `snippets` 代码片段
- `init.lua` 配置入口
- `stylua.toml` lua 文件格式化配置文件，非必需

### NVIM_APPNAME

除了默认的配置文件，还可以通过环境变量 `NVIM_APPNAME` 来指定 Neovim 的配置文件。

```bash
NVIM_APPNAME=foo nvim
```

Neovim 会读取 `~/.config/foo/init.lua` 的配置，如果不存在则会打开没有配置过的 Neovim。

## init.lua

`init.lua` 通常作为配置的入口文件，用来加载位于 lua 目录下的其他 Lua 文件。当加载位于 lua 目录下的 lua 文件时，文件路径不需要再包含 lua 目录。

```lua
require("config.autocmd")
require("config.basic")
require("config.keymaps")
require("config.plugins")
require("utils.colorscheme")
```

## 基础配置

在 Vim 中可以使用 `set` 来设置 options，比如 `set number` 开启行号显示。在 Neovim 中可以使用 `vim.opt` 替代 `set`。

```lua
vim.opt.number = true -- line number
vim.opt.relativenumber = true -- relative line number
```

关于 Neovim 的更多 options 可以查阅 [option-list](https://neovim.io/doc/user/quickref.html#option-list)。

### vim.o

`vim.o` 也可以替代 `set`，使用起来也与 `set` 更加相似。

```lua
-- set number
vim.o.number = true

-- set wildignore '*.o,*.a,__pycache__'
vim.o.wildignore = '*.o,*.a,__pycache__'
```

同时也可以直接获取 options。

```lua
vim.o.cmdheight = 4
print(vim.o.cmdheight) -- 4
```

### vim.opt

与 `vim.o` 相比，`vim.opt` 显得更加 Lua。`vim.opt` 允许用户像操作 list 和 map 一样配置 options，而且还提供了面向对象的增加和删除方法。

虽然 `set` 只有三种参数类型，但实际上一些字符串类型的参数会以列表（list）或字典（dictionary/map）的方式存储。

例如 `set listchars=space:_,tab:>~` 中的 `space:_,tab:>~` 是一个 **以逗号分隔的 map**，它会以字典的方式存储。例如 `set wildignore=*.pyc,*.o` 中的 `*.pyc,*.o` 是一个 **以逗号分隔的 list**，它会以列表的方式存储。

```lua
-- set listchars=space:_,tab:>~
vim.opt.listchars = { space = '_', tab = '>~' }

-- set wildignore=*.o,*.a,__pycache__
vim.opt.wildignore = { '*.o', '*.a', '__pycache__' }
```

#### prepend

在字符串类型（list，map） options 的头部附加值。

```lua
--  Option:prepend({value})
--  @param  value  Value to prepend
--  like :set^=

-- list-like
vim.opt.wildignore:prepend('*.o')
vim.opt.wildignore = vim.opt.wildignore ^ '*.o'

-- map-like
vim.opt.listchars:prepend({trail = '-'})
```

#### append

在字符串类型（list，map） options 的头部附加值。

```lua
--  Option:append({value})
--  @param  value  Value to append
--  like :set+=
vim.opt.wildignore:append('*.o')
vim.opt.wildignore = vim.opt.wildignore + '*.o'

vim.opt.listchars:append({trail = '-'})
```

#### get

返回 option 的值。`vim.opt` 返回一个 `Option` 对象，并不是对应 option 的值，需要通过 `get` 方法访问。对于布尔、数字和一般的字符串类型会返回它们对应的值，而对于特殊的字符串类型（list，map）则会返回对应的 table。对于标志列表，会返回以标志为键，`true` 为值的 table。

```lua
-- boolean
vim.print(vim.opt.number:get())
-- true

-- number
vim.print(vim.opt.updatetime:get())
-- 500

-- string
vim.print(vim.opt.foldmethod:get())
-- manual

-- list-like
vim.print(vim.opt.wildignore:get())
-- { "*.pyc", "*.o"}

-- map-like
vim.print(vim.opt.listchars:get())
-- {
--      nbsp = "+",
--      space = ".",
--      tab = "> ",
--      trail = "-",
-- }
```

#### remove

删除字符串类型（list，map） options 的某个值。

```lua
--  Option:remove({value})
--  @param  value  Value to remove
--  like :set-=
vim.opt.wildignore:remove('*.o')
vim.opt.wildignore = vim.opt.wildignore - '*.o'

vim.opt.listchars:remove({trail = '-'})
```

## 按键映射

leader 键可以通过 `vim.g.mapleader` 设置。

```lua
vim.g.mapleader = ";"
```

### vim.keymap.set()

可以使用 `vim.keymaps.set()` 创建按键映射。这个函数有三个强制参数：

- **mode** 指定按键映射在什么模式下生效，可以是字符串或字符串数组
- **lhs** 触发该映射的按键序列
- **rhs** 触发该映射后的动作，可以是 Vim 命令（字符串）或 Lua 函数，空字符串表示禁用该按键

```lua
-- Normal mode mapping for Vim command
vim.keymap.set('n', '<Leader>ex1', '<cmd>echo "Example 1"<cr>')

-- Normal and Command-line mode mapping for Vim command
vim.keymap.set({'n', 'c'}, '<Leader>ex2', '<cmd>echo "Example 2"<cr>')

-- Normal mode mapping for Lua function
vim.keymap.set('n', '<Leader>ex3', vim.treesitter.start)

-- 想要带参数执行函数需要对函数进行包装
vim.keymap.set('n', '<Leader>ex4', function() print('Example 4') end)
```

`vim.keymaps.set()` 的第四个参数是可选参数，是一个控制映射行为 table。以下是一些常用的功能：

- **buffer**：控制映射是否只在指定 buffer 生效，0 或 true 表示当前 buffer。

```lua
-- set mapping for the current buffer
vim.keymap.set('n', '<Leader>pl1', require('plugin').action, { buffer = true })

-- set mapping for the buffer number 4
vim.keymap.set('n', '<Leader>pl1', require('plugin').action, { buffer = 4 })
```

- **silent**：`true` 表示不输出错误信息。

```lua
vim.keymap.set('n', '<Leader>pl1', require('plugin').action, { silent = true })
```

- **expr**：`true` 表示触发映射后的动作不是执行函数，而是使用函数返回值作为动作。

```lua
vim.keymap.set('c', '<down>', function()
  if vim.fn.pumvisible() == 1 then return '<c-n>' end
  return '<down>'
end, { expr = true })
```

- **desc**：表述按键映射的字符串。

```lua
vim.keymap.set('n', '<Leader>pl1', require('plugin').action,
  { desc = 'Execute action from plugin' })
```

- **remap**：递归执行映射。

```lua
vim.keymap.set('n', '<Leader>ex1', '<cmd>echo "Example 1"<cr>')

-- add a shorter mapping
vim.keymap.set('n', 'e', '<Leader>ex1', { remap = true })
```

### vim.keymap.del()

`vim.keymap.del()` 可以删除指定映射。

```lua
vim.keymap.del('n', '<Leader>ex1', '<cmd>echo "Example 1"<cr>')
```

## Lua API

- 获取当前缓冲区号 `vim.api.nvim_get_current_buf()`
- 获取当前窗口号 `vim.api.nvim_get_current_win()`
