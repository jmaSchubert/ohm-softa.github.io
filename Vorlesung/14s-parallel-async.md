#SoftA [[../Notizen/14ln-parallel-async.md]]

---

# Parallel Processing

## Threads

Korbinian Riedhammer

---

# Process

```java
class MyProgram {
	String name;
	MyProgram(String name) {
		this.name = name;
		System.out.println("Created MyProgram: " + name);
	}
	void printNum(int n) {
		System.out.println(name + ": " + n);
	}
	public static void main(String[] args) {
		MyProgram mp = new MyProgram("Test");
		for (int i = 0; i < 3; i++)
			mp.printNum(i);
	}
}
```

---

# Process

![single-process](../ohm-softa.github.io/assets/process.svg)

---

# Bean Counters

```java
class BeanCounter {
	private final String name;
	private final double[] data;
	BeanCounter(String name, int n) {
		this.name = name;
		this.data = new double [n];
	}

	public void run() {
		System.out.println(name + " is starting...");
		Arrays.sort(data);
		System.out.println(name + " is done!");
	}
}
```
```java
public static void main(String... args) {
	BeanCounter b1 = new BeanCounter("Bureaucrat 1", 10000);
	BeanCounter b2 = new BeanCounter("Bureaucrat 2", 1000);

	b1.run();
	b2.run();

	System.out.println("main() done!");
}
```

---

# Bean Counters

![bureaucrats-1](../ohm-softa.github.io/assets/bureaucrats.svg)

---

# Threaded Bean Counters

```java
class BeanCounter implements Runnable {
	// ...
}
```

```java
public static void main(String[] args) {
	BeanCounter b1 = new BeanCounter("Bureaucrat 1", 10000);
	BeanCounter b2 = new BeanCounter("Bureaucrat 2", 1000);

	new Thread(b1).start();
	new Thread(b2).start();

	System.out.println("main() done!");
}
```

---
# Threaded Bean Counters

.w80[
![bureaucrats-2](../ohm-softa.github.io/assets/bureaucrats_001.svg)
]

---

# Threading: Examples

Multi-threaded programming is ubiquitous in modern applications:
- browser: loading multiple resources at a time using concurrent connections
- rendering multiple animations on a page/screen
- handling user interactions such as clicks or swipes
- sorting data using divide-and-conquer
- concurrent network, database and device connections
- ability to control (pause, abort) certain long-lasting processes

---

# Shared Resources

```java
class Counter {
	private int c = 0;
	int getCount() { 
		return c; 
	}
	void increment() {
		c = c + 1;
	}
}
```
```java
public class TeamBeanCounter implements Runnable {
	Counter c;
	TeamBeanCounter(Counter c) {
		this.c = c;
	}

	@Override
	public void run() {
		for (int i = 0; i < 100000; i++) {
			c.increment();
		}
		System.out.println("Total beans: " + c.getCount());
	}
}
```

---

# Shared Resources

```java
public static void main(String[] args) {
	Counter c = new Counter();

	new Thread(new TeamBeanCounter(c)).start();
	new Thread(new TeamBeanCounter(c)).start();
	new Thread(new TeamBeanCounter(c)).start();
	new Thread(new TeamBeanCounter(c)).start();
}
```

```
Total beans: 362537
```

---

# Shared Resources: Inconsistent State!

.pure-table.pure-table-bordered.pure-table-striped[
|   | Thread 1 | Thread 2 | _result_ |
| - | -------- | -------- | -------- |
| 1 | tmp1 = c |          | tmp1 = 0 |
| 2 |          | tmp2 = c | tmp2 = 0 |
| 3 | ++tmp1   |          | tmp1 = 1 |
| 4 |          | ++tmp2   | tmp2 = 1 |
| 5 | c = tmp1 |          | c = 1    |
| 6 |          | c = tmp2 | **c = 1 !** |
]

---

# Deadlock

![Deadlock](../ohm-softa.github.io/assets/threads-deadlock.svg)

---

# Wait - Notify

![threads-wait-notify](../ohm-softa.github.io/assets/threads-wait-notify.svg)

---

# Consumer/Producer and Synchronized Buffer

![consumer-producer](../ohm-softa.github.io/assets/consumer-producer.png)

---

# Thread Lifecycle

![thread-lifecycle](../ohm-softa.github.io/assets/thread-lifecycle.svg)

---

# Futures, Callables, Executor

```java
interface Callable<V> {
	V call();
}
```

```java
interface Future<T> {
	T get();
	// ...
}
```

```java
interface ExecutorService {
	void execute(Runnable command);
	<T> Future<T> submit(Callable<T> task);
	// ...
}
```

`ExecutorService`s provided by Java:

```java
Executors.newSingleThreadExecutor();
Executors.newCachedThreadPool();  // reuses threads
Executors.newFixedThreadPool(5);  // use 5 threads
```

---

# Chaining with CompletableFuture

```java
class CompletableFuture<T> implements CompletionStage<T>, Future<T> {
	static <U> CompletableFuture<U> supplyAsync(Supplier<U> supplier) { 
		// ...
	}
	<U> CompletionStage<U> thenApplyAsync(Function<? super T, ? extends U> fn) {
		// ...
	}
	<U> CompletionStage<U> thenAcceptAsync(Consumer<? super T> action) { 
		// ...
	}
	CompletableFuture<T> exceptionally(Function<Throwable, ? extends T> fn) {
		// ...
	}
	// and much more...
}
```

---

# Chaining with CompletableFuture

```java
CompletableFuture<?> cf = CompletableFuture.supplyAsync(() -> "riko493:12345")
	.thenApplyAsync(creds -> {
		System.out.println("Authenticating with " + creds);
		return "secrettoken";
	})
	.thenApplyAsync(token -> {
		System.out.println("Retrieving status with token=" + token);
		return "in the mood for holidays";
	})
	.thenAccept(status -> System.out.println(status))
	.exceptionally(ex -> { System.out.println("Oops, something went wrong: " + ex); return null; });

System.out.println("All done!");
```

---

# Summary (1)

Use threads to run code asynchronously and in parallel.

- _asynchronously_ means the caller/delegator immediately continues execution after queueing the task
- _parallel_ means that more than one method is executed at the same time; asynchronous methods are typcially executed in parallel.
- use `join` to wait on threads to complete

Be extra careful when threads _share resources_.

- use thread-safe containers
- protect critical sections with `synchronized`
- minimize blocking time and avoid deadlocks with inter-thread communication (`wait`, `yield`, `notify`, `notifyAll`)

---

# Summary (2)

Use `Future` to retrieve results and handle exceptions within the threads.

- `get()` will block until the thread has completed (and raise possible exception)
- `cancel()` terminates the execution of the task
- `isDone()` returns `true` if the task completed

Use `CompletableFuture` for elegant asynchronous programming.

- use `supplyAsync` to create a chainable `CompletableFuture`
- use `thenApplyAsync` to transform intermediate results
- use `thenAcceptAsyc` to consume final results (end of chain!)
- use `thenCombineAsync` to join multiple `CompletableFuture`

Use `ExecutorService`s when batch-processing large quantities of data, e.g. importing multiple files, scaling images, downloading resources, etc.


---

.center[
![berch](../ohm-softa.github.io/assets/bergkirchweih.gif)
]

.skip[
.center[Enjoy the holiday break and Bergkirchweih!]]
