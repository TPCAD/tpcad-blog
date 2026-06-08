# Git Reference

## 设置用户名和邮箱

```bash
git config user.name "<username>" # 设置用户名
git config user.email "<email>"   # 设置邮箱
```

## 添加远程分支

```bash
git remote add <name> <url>
```

## 第一次推送时绑定本地分支与远程分支

```bash
git push --set-upstream <remote_branch> <local_branch>
# git push -u <remote_branch> <local_branch>
```

## 查看远程分支详细信息

```bash
git remote -v
```

## 游离分支

使用 commit ID 作为 checkout 参数会使 HEAD 指针处于游离状态（Detached）。在切换分支后，游离状态的所有提交都会变成「孤儿提交」，很难恢复。因此游离分支适合阅读代码。

如果游离分支没有修改可以直接切换回其他分支。

```bash
git checkout <branch_name>
```

如果要保存游离分支的提交可以在当前游离分支新建分支。

```bash
git checkout -b <branch_name>
# git switch -c <branch_name>
```

如果游离分支有未提交的修改但不想保存可以强制切换分支并丢弃修改。此时可以直接切换到其他分支，修改会被自动同步过去。

```bash
git switch -f <branch_name>
```

