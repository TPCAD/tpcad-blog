+++
title = 'Hugo + Github Action，搭建个人博客'
date = 2024-06-29T10:59:27+08:00
+++

# Hugo + Github Action，搭建个人博客

## 创建 Github 仓库

### 创建博客源仓库

博客源仓库用于对 Hugo 的配置文件以及 Markdown 源文件进行备份和管理，并配合 Github Action 自动将生成的静态网页推送到 Github Pages 仓库。

### 创建 Github Pages 仓库

以 `username.github.io` 形式命名的特殊仓库，使用 Github Pages 实现部署网站。

## 创建博客

```bash
hugo new site Blog
```

Hugo 生成的目录结构。

```language
Blog
├── archetypes
│   └── default.md
├── assets
├── content
├── data
├── hugo.toml
├── i18n
├── layouts
├── static
└── themes
```

### 关联博客源仓库

```bash
cd Blog
git init
git remote add origin git@github.com:TPCAD/tpcad-blog.git
```

### 配置 Hugo 主题

为了方便对主题进行自定义和版本控制，我们将 Hugo 主题 fork 到自己的 Github 账户，并以 submodule 的方式将主题添加到我们的博客源仓库。

```bash
git submodule add https://github.com/TPCAD/hugo-PaperMod.git themes/hugo-PaperMod
```

关于 PaperMod 主题的配置，见[官方文档](https://github.com/adityatelange/hugo-PaperMod/wiki)。

如果需要同步主题仓库的最新修改，运行如下命令：

```bash
git submodule update --remote
```

### 关联 Github Pages 仓库

Hugo 默认会将生成的静态网页存放在 `public` 目录。我们可以将 Github Pages 仓库以子模块的方式添加到博客源仓库。

```bash
# 生成静态网页
hugo

cd public

# 在 public 目录下建立 git 仓库，并关联远程仓库
git init
git remote add git@github.com:TPCAD/tpcad.github.io.git

# 进行一次 push，因为无法添加空的远程仓库作为子模块
git add .
git commit -m "init"
git push -u origin master

# 回到根目录添加子模块
cd ..
git submodule add git@github.com:TPCAD/tpcad.github.io.git public
```

现在已经可以通过 `username.tpcad.io' 访问访问博客了。

## 自动发布

借助 Github Action，可以实现在博客源仓库提交后，自动生成静态网页并推送到 Github Pages 仓库。

### 访问 Token

因为需要推送到外部仓库，我们要先获取一个访问 Token。

进入 Github，在 `Settings -> Developer Setttings -> Personal access tokens -> Generate new token(classic` 创建一个 Token。

`Socpes` 选择 `repo` 和 `workfolw` 。

复制该 Token（Token 只会出现一次）到博客源仓库的 `Settings -> Secrets and variables -> Actions -> Repository secrets` 创建一个 `Repository secrets`。

### 创建 Github Action

在博客源仓库目录下创建 `.github/workflows/deploy.yml`。

配置如下。将 `EXTERNAL_REPOSITORY` 替换为自己的 Github Pages 仓库。

```yml
name: deploy

on:
    push:
    workflow_dispatch:
    schedule:
        # Runs everyday at 8:00 AM
        - cron: "0 0 * * *"

jobs:
    build:
        runs-on: ubuntu-latest
        steps:
            - name: Checkout
              uses: actions/checkout@v2
              with:
                  submodules: true
                  fetch-depth: 0

            - name: Setup Hugo
              uses: peaceiris/actions-hugo@v2
              with:
                  hugo-version: "latest"

            - name: Build Web
              run: hugo

            - name: Deploy Web
              uses: peaceiris/actions-gh-pages@v3
              with:
                  PERSONAL_TOKEN: ${{ secrets.PERSONAL_TOKEN }}
                  EXTERNAL_REPOSITORY: TPCAD/tpcad.github.io
                  PUBLISH_BRANCH: master
                  PUBLISH_DIR: ./public
                  commit_message: ${{ github.event.head_commit.message }}
```

同步修改后，以后只需要在博客源仓库进行 push 就会自动将内容推送到 Github Pages 仓库中。

## 常见问题

### Github Pages 仓库没有启用 Github Action

在仓库的 `Settings -> Pages -> Build and deployment -> Branch` 中选择需要分支并保存，即可启用 Github Pages。 

## 参考资料

1. [Hugo + GitHub Action，搭建你的博客自动发布系统](https://www.pseudoyu.com/en/2022/05/29/deploy_your_blog_using_hugo_and_github_action/)
2. [如何用 GitHub Pages + Hugo 搭建个人博客](https://cuttontail.blog/blog/create-a-wesite-using-github-pages-and-hugo/)
