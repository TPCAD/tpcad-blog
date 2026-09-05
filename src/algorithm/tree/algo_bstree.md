# 二叉搜索树

二叉搜索树（Binary Search Tree），又叫二叉排序树，二叉查找树，是一种高效的数据结构。

## 二叉搜索树定义

1. 空树是二叉搜索树
2. 若左子树不空，则左子树上所有节点的值都 **小于** 根节点的值
3. 若右子树不空，则右子树上所有节点的值都 **大于** 根节点的值
4. 二叉搜索树的左右子树也是二叉搜索树

## 节点定义

```cpp
template <typename T> struct binary_search_tree {
  private:
    struct bs_node {
      public:
        T key;
        unsigned int size;
        unsigned int count;

        bs_node *left;
        bs_node *right;

        bs_node(const T &value)
            : key(value), size(1), count(1), left(nullptr), right(nullptr) {}
    };

    bs_node *root;

  public:
    binary_search_tree() : root(nullptr) {}
    binary_search_tree(const T &value) : root(nullptr) {
        root = new bs_node(value);
    }

    binary_search_tree(std::initializer_list<T> list) : root(nullptr) {
        root = new bs_node(*list.begin());
        std::for_each(list.begin() + 1, list.end(),
                      [this](auto &&x) { this->insert(x); });
    }
```

## 遍历二叉搜索树

根据二叉搜索树的定义，中序遍历得到的序列是升序序列。因为要遍历所有节点，所以时间复杂度为 $O(n)$。

递归实现的中序遍历：

```cpp
    void inorder_traversal_aux(const bs_node *root, std::vector<T> &result) {
        if (root == nullptr) {
            return;
        }

        inorder_traversal_aux(root->left, result);
        for (auto i = root->count; i > 0; --i) {
            result.push_back(root->key);
        }
        inorder_traversal_aux(root->right, result);
    }

    void inorder_traversal(std::vector<T> &result) {
        inorder_traversal_aux(root, result);
    }
```

非递归实现的中序遍历：

```cpp
    void inorder_traversal_non_recursion(std::vector<T> &result) {
        std::stack<const bs_node *> s;
        const bs_node *rt = root;

        while (rt || s.size()) {
            while (rt) {
                s.push(rt);    // 保存根节点
                rt = rt->left; // 遍历左子树
            }

            rt = s.top(); // 获取保存的根节点
            s.pop();      // 弹出根节点
            for (auto i = rt->count; i > 0; --i) {
                result.push_back(rt->key); // 访问节点
            }
            rt = rt->right; // 遍历右子树
        }
    }
```

## 搜索元素

根据二叉搜索树的特性，搜索某一个节点只需要搜索一侧子树即可，因此搜索操作的时间复杂度为 $O(h)$，h 为树高。

递归实现：

```cpp
    bool exist_aux(const bs_node *root, const T &value) const {
        if (root == nullptr) {
            return false;
        }

        if (root->key == value) {
            return true;
        }

        return root->key > value ? exist_aux(root->left, value)
                                 : exist_aux(root->right, value);
    }

    bool is_exist(const T &value) const { return exist_aux(root, value); }
```

非递归实现：

```cpp
    bool is_exist_non_recursion(const T &value) const {
        const bs_node *rt = root;
        while (rt != nullptr) {
            if (rt->key == value) {
                return true;
            }
            rt = rt->key > value ? rt->left : rt->right;
        }
        return false;
    }
```

## 插入元素

与搜索元素类似，插入操作的时间复杂度为 $O(h)$。

递归实现：

```cpp
    void insert_aux(bs_node *root, const T &value) {
        if (root == nullptr) {
            return;
        }

        if (root->key == value) {
            root->count++;
            root->size++;
            return;
        }
        auto &child = root->key > value ? root->left : root->right;
        if (child == nullptr) {
            child = new bs_node(value);
        } else {
            insert_aux(child, value);
        }

        root->size = root->count + (root->left ? root->left->size : 0) +
                     (root->right ? root->right->size : 0);
    }

    void insert(const T &value) { insert_aux(root, value); }
```

非递归实现需要借助栈来保存父节点，以便在插入后回溯修改父节点的 `size` 字段：

```cpp
    void insert_non_recursion(const T &value) {
        bs_node *rt = root;
        std::stack<bs_node *> s;

        while (rt != nullptr) {
            if (rt->key == value) {
                rt->count++;
                break;
            }
            s.push(rt);

            // child 是引用
            auto &child = rt->key > value ? rt->left : rt->right;
            if (child == nullptr) {
                child = new bs_node(value);
                break;
            }
            rt = child;
        }

        // 回溯修改 size 字段
        while (s.size()) {
            rt = s.top();
            s.pop();
            rt->size = rt->count + (rt->left ? rt->left->size : 0) +
                       (rt->right ? rt->right->size : 0);
        }
    }
```

## 删除元素

对于删除操作，需要分以下情况讨论：

1. 待删除节点为叶子节点，直接删除即可
2. 待删除节点有一个子节点，将当前节点替换为子节点再删除
3. 待删除节点有两个子节点，将当前节点替换为其直接前驱或直接后继节点再删除

在递归实现中，往往将前两种情况合并，判断某一子树是否为空，若为空则返回另一子树，即使它为空。

```cpp
    binary_search_tree *remove(const T &value) {
        if (this->key == value) {
            if (this->count > 1) {
                this->count--;
            } else {
                if (this->left && this->right) {
                    // 寻找右子树的最小节点
                    binary_search_tree *successor = this->right->min();
                    // 替换
                    this->key = successor->key;
                    this->count = successor->count;

                    // 删除直接后继节点
                    successor->count = 1;
                    this->right = this->right->remove(successor->key);

                } else {
                    // 只存在左子树，或右子树，或都不存在
                    binary_search_tree *temp =
                        (this->left != nullptr) ? this->left : this->right;
                    delete this;
                    return temp;
                }
            }
        } else {
            auto &child = (this->key > value) ? this->left : this->right;
            if (child != nullptr) {
                child = child->remove(value);
            }
        }

        this->size = this->count + (this->left ? this->left->size : 0) +
                     (this->right ? this->right->size : 0);

        return this;
    }
```

非递归实现稍显繁琐，需要记录但删除节点的父节点，寻找直接后继节点时也需要记录其父节点。同时还需要借助栈回溯父节点以修改 `size` 字段。

1. 找到待删除节点及其父节点
2. 待删除节点左右节点都存在
    1. 寻找直接后继节点及其父节点
    2. 替换待删除节点，判断直接后继节点
       1. 若直接后继节点 **是** 待删除节点的子结点，使后继节点的父节点的 **右节点** 等于后继节点的右节点
       2. 若直接后继节点 **不是** 待删除节点的子结点，使后继节点的父节点的 **左节点** 等于后继节点的右节点
    3. 删除直接后继节点
3. 待删除节点存在至多一个子结点
    1. 若待删除节点是根节点，直接删除，并使根节点等于其子结点
    2. 若待删除节点不是根节点，用待删除节点的子结点替代待删除节点
    3. 删除待删除节点

```cpp
    void remove_non_recursion(const T &value) {
        bs_node *parent = nullptr;
        bs_node *current = root;
        std::stack<bs_node *> s;

        while (current != nullptr && current->key != value) {
            s.push(current);
            parent = current;
            current = current->key > value ? current->left : current->right;
        }

        // 元素不存在
        if (current == nullptr) {
            return;
        }

        if (current->count > 1) {
            current->count--;
        } else {
            // 左右子树存在
            if (current->left && current->right) {
                bs_node *successor_parent = current;
                bs_node *successor = current->right;

                // 寻找直接后继节点
                while (successor->left != nullptr) {
                    s.push(successor);
                    successor_parent = successor;
                    successor = successor->left;
                }

                // 替换
                current->key = successor->key;
                current->count = successor->count;
                successor->count = 1;

                // 更新后继节点的父节点，后继节点不存在左子树，最多存在一个右子树
                if (successor_parent == current) {
                    successor_parent->right = successor->right;
                } else {
                    successor_parent->left = successor->right;
                }
                delete successor;
            } else {
                // 只存在左子树，或右子树，或都不存在
                bs_node *child =
                    (current->left != nullptr) ? current->left : current->right;

                // 当前节点为根节点
                if (parent == nullptr) {
                    delete current;
                    root = child;
                } else {
                    // 更新父节点
                    if (parent->left == current) {
                        parent->left = child;
                    } else {
                        parent->right = child;
                    }
                    // 删除当前节点
                    delete current;
                }
            }
        }

        while (s.size()) {
            auto node = s.top();
            s.pop();
            node->size = node->count + (node->left ? node->left->size : 0) +
                         (node->right ? node->right->size : 0);
        }
    }
```

## 直接前驱节点和直接后继节点

一个节点的直接前驱节点是 **小于该节点的最大的节点**，直接后继节点是 **大于该节点的最小的节点**。

```cpp
    std::expected<const T *, tree_error> predecessor(const T &value) const {
        std::stack<const bs_node *> s;
        const bs_node *current = root;
        const bs_node *prev = nullptr;

        while (current || s.size()) {
            while (current) {
                s.push(current);
                current = current->left;
            }

            current = s.top();
            s.pop();

            // 当前节点符合条件，则父节点为直接前驱节点
            if (current->key == value) {
                return &prev->key;
            }

            prev = current;
            current = current->right;
        }
        return std::unexpected(tree_error::no_element);
    }

    std::expected<const T *, tree_error> successor(const T &value) const {
        std::stack<const bs_node *> s;
        const bs_node *current = root;
        const bs_node *prev = nullptr;

        while (current || s.size()) {
            while (current) {
                s.push(current);
                current = current->left;
            }

            current = s.top();
            s.pop();

            // 父节点符合条件，则当前节点为直接后继节点
            if (prev != nullptr && prev->key == value) {
                return &current->key;
            }

            prev = current;
            current = current->right;
        }
        return std::unexpected(tree_error::no_element);
    }
```

## 参考资料

1. [OI Wiki](https://oi-wiki.org/ds/bst/)
2. [pdai tech](https://pdai.tech/md/algorithm/alg-basic-tree-search.html)
