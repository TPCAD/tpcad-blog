+++
title = 'Classic Sort Algorithm'
date = 2024-07-02T20:48:29+08:00
tags = ['Algorithm']
+++

## Selection Sort

以升序为例，选择排序的思想是遍历未排序元素，选择其中最小的元素，将其移动到未排序元素开始位置。因此选择排序的最优时间复杂度、平均时间复杂度、最坏时间复杂度都是 $O(n^2)$。选择排序是一种不稳定的排序算法。

假设有数组 `3, 4, 1, 9, 5, 8, 0`。

以升序为例，选择索引为 0 的元素，将它和其后的每一个元素比较，若所选元素较大，则交换二者位置。再选择索引为 1 的元素，将它和其后的每一个元素比较，若所选元素较大，则交换二者位置。依此类推，直至倒数第二个元素。

```rust
// 第一轮
[0, 4, 3, 9, 5, 8, 1]
// 第二轮，从索引为 1 的元素开始
[0, 1, 4, 9, 5, 8, 3]
// 第三轮，从索引为 2 的元素开始
[0, 1, 3, 9, 5, 8, 4]
// ...
```

```c
void selection_sort(int *arr, int len) {
    for (int i = 0; i < len - 1; ++i) {
        int min_idx = i;
        int j = i + 1;
        for (; j < len; ++j) {
            if (arr[min_idx] > arr[j]) {
                min_idx = j;
            }
        }
        swap(&arr[i], &arr[min_idx]);
    }
}
```

## Bubble Sort

以升序为例，在未排序元素中依次比较相邻两个元素，若乱序则交换两个元素，这样一来较大的元素就会被慢慢移动到末尾有序排列。通常在冒泡排序中设置一个 `flag`，当没有发生比较操作时，说明数组已经有序，停止遍历。冒泡排序的最优时间复杂度为 $O(n)$（正序），最坏时间复杂度为 $O(n^2)$（逆序），平均时间复杂度为 $O(n^2)$。冒泡排序是一种稳定的排序算法。

假设有数组 `3, 4, 1, 9, 5, 8, 0`。

以升序为例，比较索引为 0 的元素和索引为 1 的元素，若前者大于后者，交换二者位置。接着比较索引为 1 的元素和索引为 2 的元素，若前者大于后者，交换二者位置。依次类推，直至最后一组相邻元素。然后再从头开始比较相邻的两个元素，此次不包括最后一个元素。

```rust
// 第一轮
[3, 1, 4, 5, 8, 0, 9]
// 第二轮，不包括最后一个元素
[1, 3, 4, 5, 0, 8, 9]
// 第三轮，不包括最后两个元素
[1, 3, 4, 0, 5, 8, 9]
// ...
```

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

以升序为例，插入排序将数组分成未排序和已排序两部分，每次从未排序部分按顺序选择一个元素与已排序部分比较，将其插入到合适位置。插入排序的最优时间复杂度为 $O(n)$（正序），最坏时间复杂度为 $O(n^2)$（逆序），平均时间复杂度为 $O(n^2)$。冒泡排序是一种稳定的排序算法。

假设有数组 `3, 1, 4, 9, 5, 8, 0`。

视索引为 `0` 的元素为已排序部分，剩下元素为未排序部分。选择未排序部分的第一个元素 `1` 与已排序部分元素倒序比较，插入合适位置。

```c
// 初始状态
[3, 1, 4, 9, 5, 8, 0]
// 第一轮
[1, 3, 4, 9, 5, 8, 0]
// 第二轮
[1, 3, 4, 9, 5, 8, 0]
```

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

在将元素插入到已排序部分的操作中，可以使用二分查找法优化，但不会改变时间复杂度。

TODO: 折半插入排序

## Shell Sort

**希尔排序**，又叫**缩小增量排序**，是插入排序的一种改良版本。希尔排序充分利用了插入排序的两个优点：

1. 插入排序在数组几乎有序时效率极高
2. 插入排序在元素数量较少时效率极高

希尔排序依据间距将数组分为若干子序列，并对子序列进行插入排序，然后缩小间距，产生新的子序列，再对新的子序列进行插入排序，如此往复，直至间距为 1，此时再进行插入排序就是对整个数组进行插入排序。

```c
// 待排序数组
[3, 54, 35, 87, 23, 11, 74, 2, 9, 12, 45, 53]
// 假设间距为 4，则可得以下子序列
[3, 23, 9]
[54, 11, 12]
[35, 74, 45]
[87, 2, 53]
// 对子序列进行插入排序
[3, 11, 35, 9, 2, 12, 45, 53, 23, 54, 74, 87]
// 取间距为 1
[2, 3, 9, 11, 12, 23, 35, 45, 53, 54, 74, 87]
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

        // 直接使用插入排序
        // for (int i = 0; i < d; ++i) {
        //     for (int j = i + d; j < len; j += d) {
        //         int key = arr[j];
        //         int k = j - d;
        //         while (k >= 0 && arr[k] > key) {
        //             arr[k + d] = arr[k];
        //             k -= d;
        //         }
        //         arr[k + d] = key;
        //     }
        // }
        d /= 3;
    }
}
```

希尔排序的时间复杂度与间距的选择有关，最好时间复杂度为 $O(nlog^2n)$，最坏时间复杂度为 $O(n^2)$，平均时间复杂度为 $O(nlog^2n)$。希尔排序是不稳定排序。

## Quick Sort

快速排序是一种递归的排序算法，它将数组以某个元素为基准，划分为小于基准和大于基准的两部分，再分别在这两个部分中执行相同操作直至不能再划分。

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

快速排序的最优时间复杂度和平均时间复杂度为 $O(n\log n)$，最坏时间复杂度为 $O(n^2)$，平均时间复杂度为 $O(n\log n)$。因为快速排序是递归的，需要额外的调用栈，因此快速排序的空间复杂度为 $O(\log n)$。快速排序是不稳定的排序算法。

## Merge Sort

归并排序基于分治思想将数组分段排序后合并。分段操作，当只有一个元素时，数组有序，不再分段，当元素大于 1 时，数组被递归地分成有序的两部分；合并操作，借助额外的数组，有序地将两部分数组中最小的元素放入额外数组，再用额外数组覆盖原数组。时间复杂度在最优、最坏与平均情况下均为 $O(n \log n)$，空间复杂度为 $O(n)$。

```c
static void merge(int *arr, int l, int r, int len) {
    int *tmp = (int *)malloc(sizeof(int) * len);
    if (tmp == NULL) {
        printf("Can not allocate memory!\n");
        exit(1);
    }

    int mid = (l + r) >> 1;
    int i = l, j = mid, k = l; // index variable

    while (i < mid && j < r) {
        if (arr[i] <= arr[j]) {
            tmp[k++] = arr[i++];
        } else {
            tmp[k++] = arr[j++];
        }
    }

    if (j == r) {
        while (i < mid) {
            tmp[k++] = arr[i++];
        }
    } else {
        while (j < r) {
            tmp[k++] = arr[j++];
        }
    }

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

堆排序
