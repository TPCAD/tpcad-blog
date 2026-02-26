# 二叉平衡树

平衡二叉树是一种平衡的二叉搜索树。

1. 空树是平衡二叉树
2. 左右子树的高度差的绝对值不超过 1
3. 左右子树也是平衡二叉树

AVL 树是一种平衡二叉树，它会在插入或删除节点时调整二叉树使每个节点的左右子树的高度差的绝对值不超过 1。通常把左右子树的差叫做 **平衡因子**。即

$$
平衡因子 = 左子树的高度 - 右子树的高度
$$

## 节点定义

AVL 树的节点与二叉搜索树类似，但多了一个 `height` 字段，用于保存当前节点的高度。规定空树的高度为 0，非空树的高度等于它的最大层次（其根节点的层次为 1，依次类推）。

```cpp
struct avl_tree {
  private:
    struct avl_node {
      public:
        T key;
        unsigned size;
        unsigned count;
        unsigned height;
        avl_node *left;
        avl_node *right;

        avl_node(const T &value)
            : key(value), size(1), count(1), height(1), left(nullptr),
              right(nullptr) {}
    };

    avl_node *root;

  public:
    avl_tree() : root(nullptr) {}
    avl_tree(const T &value) : root(nullptr) { root = new avl_node(value); }

    avl_tree(std::initializer_list<T> list) : root(nullptr) {
        root = new avl_node(*list.begin());
        std::for_each(list.begin() + 1, list.end(),
                      [this](auto &&x) { this->insert(x); });
    }
}
```

## 平衡

### 旋转

**旋转** 是一种将节点变成它的子节点的节点的操作，可以分为 **左旋** 和 **右旋**。关于旋转方向的定义有很多，甚至有些相互矛盾。这里规定，

**左旋** 指的是将一个节点变成它的右子节点的左子节点的操作，即该节点向左下方旋转，其子节点向左上方旋转，整体呈逆时针旋转。

**右旋** 指的是将一个节点变成它的左子节点的右子节点的操作，即该节点向右下方旋转，其子节点向右上方旋转，整体呈顺时针旋转。

下图是一个右旋操作，节点 6 和其左子节点 4 顺时针旋转，旋转后节点 4 的右子节点会变成节点 6 的左子节点。

```language
        6                               4
      /   \                           /   \
     4     7      Right Rotate       3     6
    / \           ------------>     /     / \
   3   5                           2     5   7
  /
 2
```

下图是一个左旋操作，节点 6 和其右子节点 9 逆时针旋转，旋转后节点 9 的左子节点会变成节点 6 的右子节点。

```language
        6                               9
      /   \                           /   \
     4     9       Left Rotate       6     10
          / \     ------------>     / \     \
         8  10                     4   8     11
              \
              11
```


在插入或删除节点时可能会导致 AVL 树不平衡，即平衡因子的绝对值大于 1，此时便需要通过 **旋转** 操作使二叉树再次平衡。

失衡状态可以分为四种情况：

### LL 型

```language
                       6  <-- h(l) - h(r) = 2                      4
                     /   \                                       /   \
h(l) - h(r) = 1 --> 4     7                    --------->       3     6
                   / \                                         /     / \
                  3   5                                       2     5   7
                 /
                2
```

以上图为例，根节点的平衡因子等于 2，根节点的左子树的平衡因子等于 1，这种失衡状态称为 **LL 型**。对于 LL 型失衡，将其失衡根节点进行一次 **右旋** 即可重新平衡。

```cpp
    /**
     *  @brief  处理 LL 型失衡
     *  @param  root  失衡节点
     *  @return  旋转后的根节点，即原失衡节点的左子节点
     */
    avl_node *left_left_rotation(avl_node *root) {
        avl_node *new_rt = root->left; // 失衡节点的左子节点

        // 失衡节点的新左子节点等于其旧左子节点的右子节点
        root->left = new_rt->right;
        // 左子节点的右子节点等于失衡节点
        new_rt->right = root;

        // 更新高度
        root->height = std::max(height(root->left), height(root->right)) + 1;
        new_rt->height =
            std::max(height(new_rt->left), height(new_rt->right)) + 1;

        // 返回新的根节点
        return new_rt;
    }
```

### RR 型

```language
        6 --> h(l) - h(r) = -2                    9
      /   \                                     /   \
     4     9 --> h(l) - h(r) = -1              6     10
          / \                     ------>     / \     \
         8  10                               4   8     11
              \
              11
```

以上图为例，根节点的平衡因子等于 -2，根节点的右子树的平衡因子等于 -1，这种失衡状态称为 **RR 型**。对于 RR 型失衡，将其失衡根节点进行一次 **左旋** 即可重新平衡。

```cpp
    /**
     *  @brief  处理 RR 型失衡
     *  @param  root  失衡节点
     *  @return  旋转后的根节点，即原失衡节点的右子节点
     */
    avl_node *right_right_rotation(avl_node *root) {
        avl_node *new_rt = root->right; // 失衡节点的右子节点

        // 失衡节点的新右子节点等于其旧右子节点的左子节点
        root->right = new_rt->left;
        // 右子节点的左子节点等于失衡节点
        new_rt->left = root;

        root->height = std::max(height(root->left), height(root->right)) + 1;
        new_rt->height =
            std::max(height(new_rt->left), height(new_rt->right)) + 1;

        return new_rt;
    }
```

### LR 型

```language
                        6 --> h(l) - h(r) = 2
                      /   \
h(l) - h(r) = -1 <-- 4     7
                    / \
                   3   5
                        \
                         2
```

以上图为例，根节点的平衡因子等于 2，根节点的左子树的平衡因子等于 -1，这种失衡状态称为 **LR 型**。对于 LR 型失衡，需要一次左旋和一次右旋才能重新平衡。

```language
        6                       6                   5
      /   \                   /   \               /   \
     4     7                 5     7             4     6
    / \                     / \                 /     / \
   3   5                   4   2               3     2   7
        \                 /
         2               3
    Original               Left Rotate          Right Rotate
```

第一次旋转是对失衡节点的左子节点左旋，旋转之后二叉树的失衡状态变为 LL 型。第二次旋转是对失衡节点的右旋，旋转后二叉树重新平衡。

```cpp
    /**
     *  @brief  处理 LR 型失衡
     *  @param  root  失衡节点
     *  @return  旋转后的根节点
     */
    avl_node *left_right_rotation(avl_node *root) {
        // 对失衡节点的左节点左旋
        root->left = right_right_rotation(root->left);

        // 对失衡节点右旋
        return left_left_rotation(root);
    }
```

### RL 型

```language
        6 --> h(l) - h(r) = 2
      /   \
     4     9 --> h(l) - h(r) = 1
          / \
         8  10
        /
       11
```

以上图为例，根节点的平衡因子等于 -2，根节点的右子树的平衡因子等于 1，这种失衡状态称为 **RL 型**。对于 RR 型失衡，需要一次左旋和一次右旋才能重新平衡。

```language
        6                       6                   8
      /   \                   /   \               /   \
     4     9                 4     8             6     9
          / \                     / \           / \     \
         8  10                  11   9         4  11    10
        /                             \
       11                             10
     Original               Right Rotate        Left Rotate
```

第一次旋转是对失衡节点的右子节点右旋，旋转之后二叉树的失衡状态变为 RR 型。第二次旋转是对失衡节点的左旋，旋转后二叉树重新平衡。

```cpp
    /**
     *  @brief  处理 RL 型失衡
     *  @param  root  失衡节点
     *  @return  旋转后的根节点
     */
    avl_node *right_left_rotation(avl_node *root) {
        // 对失衡节点的右节点右旋
        root->right = left_left_rotation(root->right);

        // 对失衡节点左旋
        return right_right_rotation(root);
    }
```

## 插入

AVL 树的插入操作与二叉搜索树类似，但在每次插入后都要检查当前节点是否失衡，若失衡则要进行调整。

```cpp
    avl_node *insert_aux(avl_node *root, const T &value) {
        if (root == nullptr) {
            return new avl_node(value);
        }

        if (root->key == value) {
            root->count++;
        } else if (root->key > value) {
            root->left = insert_aux(root->left, value);

            // 检查失衡
            if (height(root->left) - height(root->right) == 2u) {
                // 根据插入节点的位置判断 LL 型或 LR 型
                root = (root->left->key > value) ? left_left_rotation(root)
                                                 : left_right_rotation(root);
            }
        } else {
            root->right = insert_aux(root->right, value);

            // 检查失衡
            if (height(root->left) - height(root->right) == -2u) {
                // 根据插入节点的位置判断 RR 型或 RL 型
                root = (root->right->key > value) ? right_left_rotation(root)
                                                  : right_right_rotation(root);
            }
        }

        root->height = std::max(height(root->left), height(root->right)) + 1;
        root->size = root->count + (root->left ? root->left->size : 0) +
                     (root->right ? root->right->size : 0);
        return root;
    }
```

## 删除

AVL 树的删除操作与二叉搜索树类似，但在每次删除后都要检查当前节点是否失衡，若失衡则要进行调整。

```cpp
    avl_node *remove_aux(avl_node *root, const T &value) {
        if (root == nullptr) {
            return root;
        }

        if (root->key == value) {
            if (root->count > 1) {
                root->count--;
            } else {
                if (root->left && root->right) {
                    avl_node *successor = min_node(root->right);

                    root->key = successor->key;
                    root->count = successor->count;
                    successor->count = 1;

                    root->right = remove_aux(root->right, successor->key);

                } else {
                    avl_node *child =
                        root->left != nullptr ? root->left : root->right;
                    delete root;
                    return child;
                }
            }
        } else {
            avl_node *&child = root->key > value ? root->left : root->right;
            child = remove_aux(child, value);
        }

        // 检查失衡
        if (height(root->left) - height(root->right) == 2u) {
            root = (height(root->left->left) - height(root->left->right) == 1u)
                       ? left_left_rotation(root)
                       : left_right_rotation(root);
        } else if (height(root->left) - height(root->right) == -2u) {
            root =
                (height(root->right->left) - height(root->right->right) == 1u)
                    ? right_left_rotation(root)
                    : right_right_rotation(root);
        }

        root->height = std::max(height(root->left), height(root->right)) + 1;
        root->size = root->count + (root->left ? root->left->size : 0) +
                     (root->right ? root->right->size : 0);

        return root;
    }
```

## 其他操作

AVL 树的其他操作与普通的二叉搜索树相同。

## 参考资料

1. [OI Wiki](https://oi-wiki.org/ds/avl/)
2. [pdai tech](https://pdai.tech/md/algorithm/alg-basic-tree-balance.html)
