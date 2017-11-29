从某个历史版本创建新的分支在 Git 中从当前分支创建并检出新分支的命令是
```
git checkout -b name-of-new-branch
```
这个命令实际上是
```
git checkout -b name-of-new-branch current-branch
```
的简写形式。也就是说，当我们不指定 checkout 起点时，Git 默认从当前活动分支开始创建新的分支。
Git 的每个提交都有一个 SHA1 散列值（Hash 值）作为 ID。我们可以在 `checkout` 命令中使用这些 ID 作为起点。比如：
```git checkout -b name-of-new-branch 169d2dc
```
这样，Git 的活动分支会切换到 `name-of-new-branch` 这个分支上，而它的内容与 `169d2dc` 这个分支一致。
注意：SHA1 的散列值有 40 个字母，相当长。所以 Git 允许我们在不引起歧义的情况下，使用散列值的前几位作为缩写。
提示：你也可以用 `git branch name-of-new-branch 169d2dc` 来创建一个历史分支，而不切换到该分支。