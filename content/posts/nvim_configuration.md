+++
title = '在 Linux 下配置 Neovim'
date = 2024-11-30T15:12:16+08:00
draft = true
+++

本文所用的 Neovim 版本为 `0.11.4`。

```bash
NVIM v0.11.4
Build type: RelWithDebInfo
LuaJIT 2.1.1753364724
Run "nvim -V1 -v" for more info
```

## 配置文件

Neovim 支持使用 Lua 进行配置，本文也使用 Lua 进行配置。

Neovim 的配置文件位于 `~/.config/nvim/init.lua`。虽然可以将所有配置都写到 `init.lua` 中，但这样非常不利于管理。通常把 `init.lua` 作为配置的入口文件，真正的配置内容都放到 `lua` 目录下。本文采用如下的目录结构。

```language
nvim/
├── ftplugin/
├── lua/
│   ├── autocmd.lua
│   ├── options.lua
│   ├── keymaps.lua
│   ├── pluginmanager.lua
│   ├── plugins/
│   └── utils/
├── snippets/
├── init.lua
├── lazy-lock.json
└── stylua.toml
```

- `ftplugin/` 用于为不同文件类型进行不同配置
- `lua/autocmd.lua` 自动命令
- `lua/options.lua` Vim options
- `lua/keymaps.lua` 快捷键
- `lua/pluginmanager.lua` 插件管理器
- `lua/plugins/` 插件的具体配置
- `lua/utils/` 自定义的功能配置
- `snippets/` 代码片段
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
require("config.options")
require("config.keymaps")
require("config.plugins")
require("utils.colorscheme")
```

## Vim options

选项（Options）是用于配置 Vim/Neovim 行为和外观的各种内置变量。Neovim 提供了一系列 Lua 式的 API 来访问 Vim 选项。

### vim.o

`vim.o` 类似 `:set {option}={value}`，同时设置全局值和局部值。

```lua
vim.o.number = true                         -- 布尔类型
vim.o.wildignore = '*.o,*.a,__pycache__'    -- 字符串类型
vim.o.cmdheight = 4                         -- 数字类型
```

同时也可以直接获取 option 的值。

```lua
local cmdheight = vim.o.cmdheight
```

#### vim.go

`vim.go` 类似 `:setglobal`，用于设置全局选项或局部选项的全局值。

```lua
vim.go.number=true    -- 相当于 :setglobal number
```

#### vim.wo 和 vim.bo

`vim.wo[{winid}][{bufnr}]` 和 `vim.bo[{bufnr}]` 分别用于设置窗口局部选项和缓冲区局部选项。

`vim.wo[{winid}][{bufnr}]` 只有在设置「全局-窗口局部选项」或给出 `bufnr`（`bufnr` 只能为 0，表示当前缓冲区）时才相当于 `:setlocal`。其他情况相当于 `:set`。

```lua
vim.wo.number=false              -- 相当于 :set number
vim.wo.scrolloff=10              -- 相当于 :setlocal scrolloff=10
local winid = vim.api.nvim_get_current_win()
vim.wo[winid].number=false       -- 相当于 :set number
vim.wo[winid][0].number=false    -- 相当于 :setlocal number
```

`vim.bo[{bufnr}]` 的 `bufnr` 可以省略，表示当前缓冲区。

```lua
local bufnr = vim.api.nvim_get_current_buf()
vim.bo[bufnr].buflisted = true    -- 相当于 vim.bo.buflisted = true
```

### vim.opt

与 `vim.o` 相比，`vim.opt` 显得更加 Lua。`vim.opt` 允许用户更分便地操作 list 和 map 形式的选项，而且还提供了面向对象的增加和删除方法。

同时，还有 `vim.opt_local` 和 `vim.opt_global` 分别设置全局值和局部值。

虽然选项只有三种类型（数字，布尔，字符串），但实际上一些字符串类型的参数会以列表（list）或字典（dictionary/map）的方式解析。

例如 `:set listchars=space:_,tab:>~` 中的 `space:_,tab:>~` 是一个**以逗号分隔的 map**，它会以字典的方式解析。例如 `:set wildignore=*.pyc,*.o` 中的 `*.pyc,*.o` 是一个**以逗号分隔的 list**，它会以列表的方式解析。

```lua
vim.opt.number = true            -- :set number
vim.opt.relativenumber = true    -- :set relativenumber

-- set listchars=space:_,tab:>~
vim.opt.listchars = { space = '_', tab = '>~' }

-- set wildignore=*.o,*.a,__pycache__
vim.opt.wildignore = { '*.o', '*.a', '__pycache__' }
```

#### get

`vim.opt` 返回一个 `Option` 对象，并不是对应选项的值，需要通过 `get` 方法访问。对于布尔、数字和一般的字符串类型会返回它们对应的值，而对于特殊的字符串类型（list，map）则会返回对应的 table。对于标志列表，会返回以标志为键，`true` 为值的 table。

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

#### prepend

在字符串类型（list，map）选项的头部附加值。

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

在字符串类型（list，map）选项的尾部附加值。

```lua
--  Option:append({value})
--  @param  value  Value to append
--  like :set+=
vim.opt.wildignore:append('*.o')
vim.opt.wildignore = vim.opt.wildignore + '*.o'

vim.opt.listchars:append({trail = '-'})
```

#### remove

删除字符串类型（list，map）选项的某个值。

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

```lua
---@param mode string|string[] Mode "short-name" or a list of thereof
---@param lhs string Left-hand side of mapping
---@param rhs string|function Right-hand side of mapping
---@param opts? table Table of map-arguments
vim.keymaps.set(mode, lhs, rhs, opts?)
```

可以使用 `vim.keymaps.set()` 创建按键映射。这个函数有三个强制参数：

- **mode**：按键映射生效模式，可以是字符串或字符串数组
- **lhs**：触发该映射的按键序列
- **rhs**：触发该映射后的动作，可以是 Vim 命令（字符串）或 Lua 函数，空字符串表示禁用该按键

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

`opts` 是可选参数，是一个控制映射行为 table。有以下常用的字段：

- **buffer**：控制映射是否只在指定 buffer 生效，0 或 true 表示当前 buffer。

```lua
-- set mapping for the current buffer
vim.keymap.set('n', '<Leader>pl1', require('plugin').action, { buffer = true })

-- set mapping for the buffer number 4
vim.keymap.set('n', '<Leader>pl1', require('plugin').action, { buffer = 4 })
```

- **silent**：静默执行，不在命令行输出执行命令，默认 `false`。

```lua
vim.keymap.set('n', '<tab>', ':bnext<cr>', { silent = true }) -- same as below
-- vim.keymap.set('n', '<tab>', '<cmd>bnext<cr>')
```

- **expr**：以 `rhs` 返回的字符串作为触发后动作，默认 `false`。

```lua
vim.keymap.set('c', '<down>', function()
  if vim.fn.pumvisible() == 1 then return '<c-n>' end
  return '<down>'
end, { expr = true })
```

- **desc**：描述按键映射的字符串。

```lua
vim.keymap.set('n', '<Leader>pl1', require('plugin').action,
  { desc = 'Execute action from plugin' })
```

- **remap**：递归映射，默认 `false`。

```lua
vim.keymap.set('n', '<Leader>ex1', '<cmd>echo "Example 1"<cr>')

-- add a shorter mapping
vim.keymap.set('n', 'e', '<Leader>ex1', { remap = true })
```

- **noremap**：禁止递归映射，默认 `true`。

### vim.keymap.del()

```lua
---@param mode string|string[] Mode "short-name" or a list of thereof
---@param lhs string Left-hand side of mapping
---@param rhs string|function Right-hand side of mapping
vim.keymaps.del(mode, lhs, rhs)
```

删除指定映射。

```lua
vim.keymap.del('n', '<Leader>ex1', '<cmd>echo "Example 1"<cr>')
```

## Lua API

- 获取当前缓冲区号 `vim.api.nvim_get_current_buf()`
- 获取当前窗口号 `vim.api.nvim_get_current_win()`
