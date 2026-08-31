# json 模块

## json.dump()

```python
json.dump(obj, fp, *)
```

将 Python 对象`obj`转换成已格式化的 JSON 流并写入文件型对象`fp`。

## json.dumps()

```python
json.dumps(obj, *)
```

将 Python 对象`obj`转换成 JSON 格式的字符串。

## json.load()

```python
json.load(fp, *)
```

反序列化文件型对象`fp`为 python 对象。

## json.loads()

```python
json.load(s, *)
```

反序列化 JSON 格式的字符串（或字节流，字节数组）为 python 对象。

## Python 与 JSON 类型对照表

|     JSON     | Python |
| ------------ |  ----  |
| object       | dict   |
| array        | list   |
| string       | str    |
| number (int) | int    |
| number (real)| float  |
| true         | True   |
| false        | False  |
| null         | None   |
