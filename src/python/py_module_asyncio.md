# Python asyncio 模块

异步 Python 执行的核心是事件循环（Event Loop）。事件循环就像一个「调度器」，它管理着所有的异步任务，当有任务阻塞，让出 CPU 时，事件循环会寻找合适的任务执行，保证 CPU 不空闲。在 Python 中，同一时刻执行的任务只能有一个，且任务调度是非抢占式的，只有任务主动让出 CPU，调度器才能执行其他的任务。

被`async`关键字修饰的函数称为「协程函数（Coroutine Function）」。执行协程函数并不会返回函数原本的返回值，而是会返回`CoroutineType`，也就是「协程对象（Coroutine Object）」。注意，协程对象还不是调度器所能调度的最小单位，「任务（Task）」才是。

使用函数`asyncio.run`是最常用的生成并执行任务的方式。`asyncio.run`是进入异步执行的入口，它将传入的协程对象转换为任务加入到事件循环的任务列表中，并以异步方式执行该任务。

`await`关键字后接一个协程对象，其作用是告诉调度器，当前任务需要等待`await`关键字后的协程对象执行完成，才能继续执行。也就是说，当前任务在这里让出 CPU。

下面的示例中，函数`asyncio.sleep`返回的也是一个协程对象，该函数的作用与函数`time.sleep`相同。调度器发现此时并没有可执行的任务，在等待 1 秒后，任务`main`可以继续执行，于是执行任务`main`。

```python
import asyncio

async def main():
    print('Hello ...')
    await asyncio.sleep(1)
    print('... World!')

asyncio.run(main())
```

`await`关键字并不会将协程对象转换为任务。下面的示例中，当任务`main`执行到`await say_hello(1, "hello")`后并不会让出 CPU，而是会进入`say_hello`继续执行，执行完后才继续执行下一个`await`。因为，`await`并不会将协程对象转换为任务，此时调度器里只有一个任务`main`，两个`await`只能按顺序先后执行。

```python
import asyncio
import time


async def say_hello(delay: float, what: str):
    await asyncio.sleep(delay)
    print(what)


async def main():
    print(f"started at {time.strftime('%X')}")

    await say_hello(1, "hello")
    await say_hello(2, "world")

    print(f"finished at {time.strftime('%X')}")


asyncio.run(main())
```

要想实现并行，应在`await`之前便将协程对象转换为任务，注册到事件循环中。最常用的方法是使用函数`asyncio.create_task`。`asyncio.create_task`接受一个协程对象，并返回一个`Task`，它会将协程对象转换为`Task`，加入到事件循环的任务列表中，同时返回这个`Task`。

下面的示例中，异步函数`main`创建了两个`Task`，当程序执行到`await task1`时，任务`main`让出 CPU，等待任务`task1`执行完成。此时事件循环中除了任务`main`，还有`task1`和`task2`两个任务。事件循环会选择合适的任务进行执行（通常是按顺序的）。`task1`执行到`await asyncio.sleep(delay)`时让出 CPU，事件循环调度执行`task2`。`task2`执行到相同地方也让出 CPU，此时没有可执行的任务。等待一秒后，`task1`可以执行，事件循环继续执行`task1`至结束。又等待一秒后，`task2`可以继续执行，事件循环继续执行`task2`至结束。随后任务`main`可以继续执行，事件循环继续执行任务`main`至结束。

```python
import asyncio
import time


async def say_hello(delay: float, what: str):
    await asyncio.sleep(delay)
    print(what)


async def main():
    task1 = asyncio.create_task(say_hello(1, "hello"))
    task2 = asyncio.create_task(say_hello(2, "world"))

    print(f"started at {time.strftime('%X')}")

    await task1
    await task2

    print(f"finished at {time.strftime('%X')}")


asyncio.run(main())
```

`await`除了阻塞当前任务，让出 CPU 外，还有接收协程对象或任务返回值的作用。原函数的返回值只能通过`await`关键字获取。

```python
import asyncio
import time


async def say_hello(delay: float, what: str):
    await asyncio.sleep(delay)
    return f"{what} - {delay}"


async def main():
    print(f"started at {time.strftime('%X')}")

    task1 = asyncio.create_task(say_hello(1, "hello"))
    task2 = asyncio.create_task(say_hello(2, "world"))

    ret1 = await task1
    ret2 = await task2

    print(ret1)
    print(ret2)

    print(f"finished at {time.strftime('%X')}")


asyncio.run(main())
```

除了`asyncio.create_task`外，函数`asyncio.gather`也是常用的向事件循环注册任务的方法。

`asyncio.gather`接受若干个协程对象或任务，并将它们注册到事件循环中，其返回值是一个`Future`，这也是一个可放在`await`后的类型。若是参数协程对象，`asyncio.gather`会将其先包装成任务，再注册到事件循环。使用`asyncio.gather`还有一个好处是可以方便地获取原函数的返回值，它会将返回值放入一个列表中一次返回。

```python
import asyncio
import time


async def say_hello(delay: float, what: str):
    await asyncio.sleep(delay)
    return f"{what} - {delay}"


async def main():
    print(f"started at {time.strftime('%X')}")

    task1 = asyncio.create_task(say_hello(1, "hello"))

    results = await asyncio.gather(task1, say_hello(2, "world"))

    print(results)

    print(f"finished at {time.strftime('%X')}")


asyncio.run(main())
```
