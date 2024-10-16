+++
title = 'Classic Sort Algorithm'
date = 2024-07-02T20:48:29+08:00
tags = ['Algorithm']
+++

## Selection Sort

以升序为例，选择排序的思想是遍历未排序元素，选择其中最小的元素，将其移动到未排序元素开始位置。

### 性质

- 最好时间复杂度：$O(n^2)$
- 最坏时间复杂度：$O(n^2)$
- 平均时间复杂度：$O(n^2)$
- 稳定性：不稳定

### 演示

```c
// 原数组，所有元素均位于未排序部分
[3, 4, 1, 9, 5, 8, 0]
// 第一轮，遍历未排序部分，选择最小的元素（0），移动到未排序部分开始位置
// 有序部分位于数组头部
[0, 4, 3, 9, 5, 8, 1]
// 第二轮，遍历未排序部分，选择最小的元素（1），移动到未排序部分开始位置
[0, 1, 4, 9, 5, 8, 3]
// 第三轮，遍历未排序部分，选择最小的元素（3），移动到未排序部分开始位置
[0, 1, 3, 9, 5, 8, 4]
// ...
```

### 示例代码

```c
void selection_sort(int *arr, int len) {
    for (int i = 0; i < len - 1; ++i) {
        int min_idx = i;
        int j = i + 1;
        for (; j < len; ++j) {
            if (arr[min_idx] > arr[j]) {
                min_idx = j; // 记录索引位置
            }
        }
        if (min_idx != i) {
            swap(&arr[i], &arr[min_idx]);
        }
    }
}
```

## Bubble Sort

以升序为例，在未排序元素中依次比较相邻两个元素，若乱序则交换两个元素，这样一来较大的元素就会被慢慢移动到末尾有序排列。通常在冒泡排序中设置一个 `flag`，当没有发生交换操作时，说明数组已经有序，停止遍历。

### 性质

- 最优时间复杂度：$O(n)$（正序）
- 最坏时间复杂度：$O(n^2)$（逆序）
- 平均时间复杂度：$O(n^2)$
- 稳定性：稳定

### 演示

假设有数组 `3, 4, 1, 9, 5, 8, 0`。

以升序为例，比较索引为 0 的元素和索引为 1 的元素，若前者大于后者，交换二者位置。接着比较索引为 1 的元素和索引为 2 的元素，若前者大于后者，交换二者位置。依次类推，直至最后一组相邻元素。然后再从头开始比较相邻的两个元素，此次不包括最后一个元素。

```rust
// 原数组
[3, 4, 1, 9, 5, 8, 0]
// 第一轮，3<4，不交换
[3, 4, 1, 9, 5, 8, 0]
// 第一轮，1<4，交换
[3, 1, 4, 9, 5, 8, 0]
// 第一轮，4<9，不交换
[3, 1, 4, 9, 5, 8, 0]
// 第一轮，5<9，交换
[3, 1, 4, 5, 9, 8, 0]
// 第一轮，9>8，交换
[3, 1, 4, 5, 8, 9, 0]
// 第一轮，9>0，交换
[3, 1, 4, 5, 8, 0, 9]
// 第一轮结束，最大值 9 被交换到数组尾部
[3, 1, 4, 5, 8, 0, 9]
// 第二轮，不包括尾部有序部分
[1, 3, 4, 5, 0, 8, 9]
// 第三轮，不包括尾部有序部分
[1, 3, 4, 0, 5, 8, 9]
// ...
```

### 示例代码

```rust
fn main() {
    let mut arr = [1, 2, 6, 3, 7, 3, 9, 4, 0];
    let mut flag = true;

    while flag {
        flag = false;
        for j in 0..arr.len() - 1 {
            if arr[j] > arr[j + 1] {
                flag = true;
                arr.swap(j, j + 1)
            }
        }
    }
    println!("{:#?}", arr)
}
```

上面的实现每次都要比较到数组的最后，而每次遍历之后尾部的元素都是有序的，并不需要再进行比较，因此可以记录上次交换操作的位置，下一轮循环就可以在该位置结束，因为后面的元素已经是有序的了。

```rust
fn main() {
    let mut arr = [1, 2, 6, 3, 7, 3, 9, 4, 0];
    let mut unsorted = arr.len() - 1;

    while unsorted != 0 {
        let mut u = 0;
        for j in 0..unsorted {
            if arr[j] > arr[j + 1] {
                arr.swap(j, j + 1);
                u = j; // 记录上次比较操作的位置
            }
        }
        unsorted = u;
    }
    println!("{:#?}", arr)
}
```

## Insertion Sort

以升序为例，插入排序将数组分成未排序和已排序两部分，每次从未排序部分按顺序选择一个元素与已排序部分比较，将其插入到合适位置。

### 性质

- 最优时间复杂度：$O(n)$（正序）
- 最坏时间复杂度：$O(n^2)$（逆序），
- 平均时间复杂度：$O(n^2)$
- 稳定性：稳定

### 演示

```c
// 原数组，视索引为 `0` 的元素为已排序部分，剩下元素为未排序部分。
[3, 1, 4, 9, 5, 8, 0]
// 第一轮，选择未排序部分第一个元素，将其插入到已排序部分合适位置
[1, 3, 4, 9, 5, 8, 0]
// 第一轮，选择未排序部分第一个元素，将其插入到已排序部分合适位置
[1, 3, 4, 9, 5, 8, 0]
```

### 示例代码

```cpp
void insertion_sort(int a[], int len) {
    for (auto i = 1; i < len; ++i) {
        int key = a[i];
        int j = i - 1;

        while (j >= 0 && a[j] > key) { 
            a[j + 1] = a[j];
            --j;
        }
        a[j + 1] = key;
    }
}
```

### 优化

在将元素插入到已排序部分的操作中，可以使用二分查找法优化，但不会改变时间复杂度。

TODO: 折半插入排序

## Shell Sort

**希尔排序**，又叫**缩小增量排序**，是插入排序的一种改良版本。希尔排序充分利用了插入排序的两个优点：

1. 插入排序在数组几乎有序时效率极高
2. 插入排序在元素数量较少时效率极高

希尔排序依据间距将数组分为若干子序列，并对子序列进行插入排序，然后缩小间距，产生新的子序列，再对新的子序列进行插入排序，如此往复，直至间距为 1，此时再进行插入排序就是对整个数组进行插入排序。

### 性质

希尔排序的时间复杂度与间距的选择有关，通常情况下：

- 最好时间复杂度：$O(nlog^2n)$
- 最坏时间复杂度：$O(n^2)$
- 平均时间复杂度：$O(nlog^2n)$
- 稳定性：不稳定

### 演示

```c
// 待排序数组
[3, 54, 35, 87, 23, 11, 74, 2, 9, 12, 45, 53]
// 假设间距为 4，可得以下子序列
[3, 23, 9] -> [3, 9, 23]
[54, 11, 12] -> [11, 12, 54]
[35, 74, 45] -> [35, 45, 74]
[87, 2, 53] -> [2, 53, 87]
// 对子序列进行插入排序
[3, 11, 35, 9, 2, 12, 45, 53, 23, 54, 74, 87]
// 取间距为 1，即插入排序
[2, 3, 9, 11, 12, 23, 35, 45, 53, 54, 74, 87]
```

### 示例代码

```c
void shell_sort(int *arr, int len) {
    int d = 1;
    while (d < len / 3) {
        d = d * 3 + 1;
    }

    // 直接使用插入排序
    while (d >= 1) { // 每个间距一次循环
        for (int i = 0; i < d; ++i) { // 间距划分出的子序列数量
            for (int j = i + d; j < len; j += d) { // 每个子序列进行插入排序
                int key = arr[j];
                int k = j - d;
                while (k >= 0 && arr[k] > key) {
                    arr[k + d] = arr[k];
                    k -= d;
                }
                arr[k + d] = key;
            }
        }
        d /= 3;
    }
}
```

如果直接使用类似前文的插入排序算法，需要用到四层循环。而下面的插入排序只需要三层循环，这种形式的插入排序并不会一次性将子序列排序，而是每次只排序一个子序列的一个元素。

```c
void shell_sort(int *arr, int len) {
    int d = 1;
    while (d < len / 3) {
        d = d * 3 + 1;
    }

    while (d >= 1) {
        // i 从间距 d 开始，将前面的排序视为每个子序列已排序部分，每次自增 1，
        // 每次只排序一个子序列的一个元素，i 每自增 d 次就表示所有子序列都排序
        // 了一个元素
        for (int i = d; i < len; ++i) {
            int key = arr[i];
            int j = i - d;
            for (; j >= 0 && arr[j] > key; j -= d) {
                arr[j + d] = arr[j];
            }
            arr[j + d] = key;
        }

        d /= 3;
    }
}
```

## Quick Sort

快速排序是一种递归的排序算法，它将数组以某个元素为基准，划分为小于基准和大于基准的两部分，再分别在这两个部分中执行相同操作直至不能再划分。

### 性质

- 最优时间复杂度：$O(n\log n)$
- 最坏时间复杂度：$O(n^2)$
- 平均时间复杂度：$O(n\log n)$
- 空间复杂度：$O(\log n)$（递归调用栈）
- 稳定性：不稳定

### 演示

```c
[3, 54, 35, 87, 23, 11, 74, 2, 9, 12, 45, 53]
// 以 53 为基准，与 l 比较，小于或等于则 l+1，并继续比较 l，
// 大于则将 l 移动到 r，且 r+1，并比较 r，如此往复。
[3, 54, 35, 87, 23, 11, 74, 2, 9, 12, 45, 53]
 ^l                                       ^r
[3, 54, 35, 87, 23, 11, 74, 2, 9, 12, 45, 53]
    ^l                                    ^r
[3, 54, 35, 87, 23, 11, 74, 2, 9, 12, 45, 54]
    ^l                                ^r
[3, 45, 35, 87, 23, 11, 74, 2, 9, 12, 45, 54]
        ^l                            ^r
[3, 45, 35, 87, 23, 11, 74, 2, 9, 12, 45, 54]
            ^l                        ^r
[3, 45, 35, 87, 23, 11, 74, 2, 9, 12, 87, 54]
            ^l                    ^r
[3, 45, 35, 12, 23, 11, 74, 2, 9, 12, 87, 54]
                ^l                ^r
[3, 45, 35, 12, 23, 11, 74, 2, 9, 12, 87, 54]
                    ^l            ^r
[3, 45, 35, 12, 23, 11, 74, 2, 9, 12, 87, 54]
                        ^l        ^r
[3, 45, 35, 12, 23, 11, 74, 2, 9, 74, 87, 54]
                        ^l     ^r   
[3, 45, 35, 12, 23, 11, 9, 2, 9, 74, 87, 54]
                           ^l ^r
[3, 45, 35, 12, 23, 11, 9, 2, 9, 74, 87, 54]
                              ^lr
[3, 45, 35, 12, 23, 11, 9, 2, 53, 74, 87, 54]
                              ^lr
```

### 示例代码

```c
static int partition(int *arr, int low, int high) {
    int pivot = arr[low];
    while (low < high) {
        while (low < high && pivot <= arr[high]) {
            --high;
        }
        arr[low] = arr[high];
        while (low < high && pivot >= arr[low]) {
            ++low;
        }
        arr[high] = arr[low];
    }
    arr[low] = pivot;
    return low;
}

static void quick_sort_helper(int *arr, int lhs, int rhs) {
    if (lhs < rhs) {
        int pivot = partition(arr, lhs, rhs);

        quick_sort_helper(arr, lhs, pivot - 1);
        quick_sort_helper(arr, pivot + 1, rhs);
    }
}

void quick_sort(int *arr, const int len) { quick_sort_helper(arr, 0, len - 1); }
```

## Merge Sort

归并排序基于分治思想将数组分段排序后合并。分段操作，当只有一个元素时，数组有序，不再分段，当元素大于 1 时，数组被递归地分成有序的两部分；合并操作，借助额外的数组，有序地将两部分数组中最小的元素放入额外数组，再用额外数组覆盖原数组。

- 最优时间复杂度：$O(n \log n)$
- 最坏时间复杂度：$O(n \log n)$
- 平均时间复杂度：$O(n \log n)$
- 空间复杂度：$O(n)$

```c
static void merge(int *arr, int l, int r, int len) {
    int *tmp = (int *)malloc(sizeof(int) * len);
    if (tmp == NULL) {
        printf("Can not allocate memory!\n");
        exit(1);
    }

    int mid = (l + r) >> 1;
    int i = l, j = mid, k = l; // index variable

    // 合并两个子序列
    while (i < mid && j < r) {
        if (arr[i] <= arr[j]) {
            tmp[k++] = arr[i++];
        } else {
            tmp[k++] = arr[j++];
        }
    }

    // 未结束的子序列
    if (j == r) {
        while (i < mid) {
            tmp[k++] = arr[i++];
        }
    } else {
        while (j < r) {
            tmp[k++] = arr[j++];
        }
    }

    // 有序序列覆盖原序列
    for (k = l; k < r; ++k) {
        arr[k] = tmp[k];
    }

    free(tmp);
}

static void merge_sort_helper(int *arr, int l, int r, int len) {
    if (r - l <= 1) {
        return;
    }

    int mid = (r + l) >> 1;
    merge_sort_helper(arr, l, mid, len);
    merge_sort_helper(arr, mid, r, len);

    merge(arr, l, r, len);
}

void merge_sort(int *arr, const int len) {
    merge_sort_helper(arr, 0, len, len);
}
```

### 归并排序求逆序对数量

逆序对是 `i < j` 且 $a_i > a_j$ 的有序数对 `(i, j)`。

在归并排序进行合并操作时，若出现左子序列元素 `a` 大于右子序列元素 `b`，则说明左子序列元素 `a` 及左子序列剩余元素都大于右子序列元素 `b`。

设全局变量 `cnt = 0` 以记录逆序对个数。在合并操作中添加 `cnt += mid - i` 即可记录逆序对个数。

```c
while (i < mid && j < r) {
    if (arr[i] <= arr[j]) {
        tmp[k++] = arr[i++];
    } else {
        tmp[k++] = arr[j++];
        cnt += mid - i; // 记录逆序对个数
    }
}
```

## Heap Sort

**堆排序**是一种基于**二叉堆**的排序算法。**二叉堆**是一棵**完全二叉树**。**大根堆**是指二叉堆的每棵子树的父结点的值都大于其子结点，**小根堆**则相反。

堆排序首先要建堆，在建堆过程中会把数组中最大的元素移动到根结点，将根结点与数组最后一个元素交换即可完成一次排序。之后继续将剩余元素建堆、交换，直至完成排序。

采用向下调整的方法建堆，即选择一个非叶子结点，与其最大子结点交换，若交换后该结点仍为非叶子结点，则继续与其最大子结点交换，直至该结点为叶子结点。

### 性质

- 最优时间复杂度：$O(n\log n)$
- 最坏时间复杂度：$O(n\log n)$
- 平均时间复杂度：$O(n\log n)$
- 稳定性：不稳定

### 示例代码

```c
void heapify(int *arr, int parent, int len) {
    int child = (parent << 1) + 1; // 左子结点索引

    while (child < len) { // 判断是否为非叶子结点
        // 最大子结点
        if (arr[child + 1] > arr[child]) {
            ++child;
        }
        if (arr[parent] >= arr[child]) {
            break;
        } else {
            // 与最大子结点交换
            swap(&arr[parent], &arr[child]);
            // 继续向下调整
            parent = child;
            child = (parent << 1) + 1;
        }
    }
}

void heap_sort(int *arr, const int len) {
    // 首次建堆，从最后一个非叶子结点开始向前遍历
    for (int i = (len - 1 - 1) >> 2; i >= 0; --i) {
        heapify(arr, i, len);
    }
    for (int i = len - 1; i > 0; --i) {
        // 交换完成一次排序
        swap(&arr[0], &arr[i]);
        heapify(arr, 0, i - 1);
    }
}
```

## 计数排序

计数排序使用一个额外数组记录待排序数组中元素的个数，然后根据该数组将待排序数组的元素排到正确位置。

- 最好时间复杂度：$O(n+w)$
- 最坏时间复杂度：$O(n+w)$
- 平均时间复杂度：$O(n+w)$
- 空间复杂度：$O(w)$，其中 `w` 代表待排序数据的值域大小
- 稳定性：稳定

### 示例代码

```c
void counting_sort(int *arr, const int len) {
    int max = arr[0];
    int *aux = (int *)malloc(len * sizeof(int)); // 拷贝数组

    for (int i = 0; i < len; ++i) {
        if (max < arr[i]) {
            max = arr[i]; // 找到序列最大值
        }
        aux[i] = arr[i];
    }

    int *cnt = (int *)malloc((max + 1) * sizeof(int));
    for (int i = 0; i < len; ++i) { // 计数
        cnt[arr[i]]++;
    }
    // 计算前缀和，使计数数组表示有多少个元素小于或等于（包括自己）其所代表的元素
    for (int i = 1; i < max + 1; ++i) {
        cnt[i] += cnt[i - 1];
    }
    // 排序
    for (int i = len - 1; i >= 0; --i) {
        arr[--cnt[aux[i]]] = aux[i];
    }
    free(cnt);
    free(aux);
}
```
