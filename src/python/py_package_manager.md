# Python 项目管理

Python 内置的 venv 模块可以为每个项目创建独立的「虚拟环境」以隔离项目。每个虚拟环境都是独立的 Python 运行环境，有各自的 Python 版本、库和环境变量，互不影响。

## venv

### Create Virtual Environment

```bash
python -m venv <project_name>
```

venv 会创建项目目录，并在其中创建以下内容：

```language
project
├── bin/
├── include/
├── lib/
├── lib64/ -> lib/
├── .gitignore
└── pyvenv.cfg
```

`bin`目录包含适用于不同系统的启动脚本；`lib`则是当前虚拟环境安装的库，默认自带 pip。

### Activate Virtual Environment

Linux 系统启动虚拟环境：

```bash
source <project_name>/bin/activate
```

### Deactivate Virtual Environment

```bash
deactivate
```

## pip

pip 是 Python 官方的包管理器。

### Install/Uninstall Packages

```bash
pip install package_name

pip uninstall package_name
```

### List Packages

```bash
pip list
```

### Show Certain Package

```bash
pip show package_name
```

## uv

uv 是使用 Rust 编写的 Python 包管理器，旨在替代 pip、pip-tools、poetry、pyenv 等工具。

### Create Python Project

```bash
uv init
```

uv 会以当前目录名作为项目名称。`pyproject.toml`是项目的配置文件。

```language
project
├── .git
├── .gitignore
├── main.py
├── pyproject.toml
├── .python-version
├── README.md
└── uv.lock
```

### Run Python File

```bash
uv run <file_name>
uv run -p <python_version> <file_name> # 以指定 Python 版本运行
```

首次运行会生成`.venv`目录，其内容与 venv 生成的内容相似。

### Add/Remove Packages

```bash
uv add <package_name>       # 添加依赖
uv remove <package_name>    # 删除依赖
uv tree                     # 输出依赖树
```

