# 概率的定义及其性质

在 $ n $ 次试验中如果事件 $ A $ 出现了 $ n_A $ 次，则称比值 $ \frac{n_A}{n} $，为这 $ n $ 次试验中事件 $ A $ 出现的「频率」。记为 $ f_n(A) = \frac{n_A}{n} $，$ n_A $ 称为事件 $ A $ 发生的频数。

概率的统计定义为：随着试验次数 $ n $ 的增大，频率值逐步「稳定」到一个实数，这个实数称为事件 $ A $ 发生的概率。

## 概率的定义

设任一随机试验 $ E $，$ \Omega $ 为相应的样本空间，若对任意事件 $ A $，有唯一实数 $ P(A) $ 与之相对应，且满足下面条件，则数 $ P(A) $ 称为事件 $ A $ 的概率：

1. 非负性公理：对于任意事件 $ A $，总有 $ P(A) \ge 0$
2. 规范性公理：$ P(\Omega) = 1 $
3. 可列可加性公理：若 $ A_1，A_2，\dots，A_n $ 为两两互不相容事件，则有 $ P(\bigcup\limits_{i=1}^{\infty}A_i) = \sum\limits_{i=1}^{\infty}P(A_i) $

## 概率的性质

**性质 1**：$ P(\varnothing) = 0 $

**性质 2（有限可加性）**：设 $ A_1，A_2，\dots，A_n $ 为两两互不相容事件，则有 $ P(\bigcup\limits_{i=1}^nA_i) = \sum\limits_{i=1}^nP(A_i) $

**性质 3**：对任意事件 $ A $，有 $ P(\overline{A}) = 1 - P(A) $

**性质 4**：若事件 $ A \subset B $，则 $ P(B-A) = P(B) - P(A) $

**推论**：若事件 $ A \subset B $，则 $ P(A) \le P(B) $

**性质 5（减法公式）**：设 $ A $，$ B $ 为任意事件，则 $ P(A-B) = P(A) - P(AB) $

**性质 6（加法公式）**：设 $ A $，$ B $ 为任意事件，则 $ P(A \cup B) = P(A) + P(B) - P(AB) $

## 性质的证明

### 性质 3

**性质 3**：对任意事件 $ A $，有 $ P(\overline{A}) = 1 - P(A) $

因为事件 $ A $ 与 $ \overline{A} $ 互不相容，且 $ \Omega = A \cup \overline{A} $，由规范性公理和性质 2 可知，$ P(\Omega) = P(A) + P(\overline{A}) = 1 $，由此得证。

### 性质 4

**性质 4**：若事件 $ A \subset B $，则 $ P(B-A) = P(B) - P(A) $

因为 $ A \subset B $，所以 $ B = A \cup (B-A) $，

又因 $ A $ 与 $ (B-A) $ 互不相容，由性质 2 可得 $ P(B) = P(A) + P(B-A) $，

即 $ P(B-A) = P(B) - P(A) $。

**推论**：若事件 $ A \subset B $，则 $ P(A) \le P(B) $

根据非负性公理和性质 4，可得 $ P(B-A) = P(B) - P(A) \ge 0 $，

因此 $ P(A) \le P(B) $。

注意，该推论的逆命题不一定成立，$ P(A) \le P(B) $ 成立无法证明 $ A \subset B $。

### 性质 5

**性质 5（减法公式）**：设 $ A $，$ B $ 为任意事件，则 $ P(A-B) = P(A) - P(AB) $

$ A - B = A - AB $，且 $ AB \subset A $，

由性质 4 可得 $ P(A-B) = P(A-AB) = P(A) - P(AB) $。

### 性质 6

**性质 6（加法公式）**：设 $ A $，$ B $ 为任意事件，则 $ P(A \cup B) = P(A) + P(B) - P(AB) $

$ A \cup B = A \cup (B-AB) $，且 $ A $ 与 $ B-AB $ 互不相容，

由性质 2 可得，$ P(A \cup B) = P(A) + P(B-AB) $，

由性质 5 可得，$ P(B-AB) = P(B) - P(AB) $，

即 $ P(A \cup B) = P(A) + P(B) - P(AB) $。
