# Benchmark
通过JMH实现基准测试

## Hello World

    @Benchmark
    public void wellHelloThere() {
        // this method was intentionally left blank.
    }

    public static void main(String[] args) throws RunnerException {

        Options opt = new OptionsBuilder()
                .include(JMHSample_01_HelloWorld.class.getSimpleName())
                .forks(1)
                .build();
        new Runner(opt).run();
    }

**eclipse和Idea都需要安装相应的插件，才能直接使用IDE运行**

输出结果如下

	# JMH version: 1.19
	# VM version: JDK 1.8.0_121, VM 25.121-b13
	# VM invoker: D:\Program Files\Java\jdk1.8.0_121\jre\bin\java.exe
	# VM options: -Didea.launcher.port=7533 -Didea.launcher.bin.path=D:\Program Files (x86)\JetBrains\IntelliJ IDEA 15.0.1\bin -Dfile.encoding=UTF-8
	# Warmup: 20 iterations, 1 s each
	# Measurement: 20 iterations, 1 s each
	# Timeout: 10 min per iteration
	# Threads: 1 thread, will synchronize iterations
	# Benchmark mode: Throughput, ops/time
	# Benchmark: com.edgar.jmh.JMHSample_01_HelloWorld.wellHelloThere
	
	# Run progress: 0.00% complete, ETA 00:00:40
	# Fork: 1 of 1
	# Warmup Iteration   1: 3334587130.932 ops/s
	# Warmup Iteration   2: 3372276836.066 ops/s
	# Warmup Iteration   3: 3384310844.194 ops/s
	# Warmup Iteration   4: 3387476909.671 ops/s
	# Warmup Iteration   5: 3380642559.445 ops/s
	# Warmup Iteration   6: 3393149632.385 ops/s
	# Warmup Iteration   7: 3378950192.071 ops/s
	# Warmup Iteration   8: 3393519457.265 ops/s
	# Warmup Iteration   9: 3382872378.666 ops/s
	# Warmup Iteration  10: 3368376265.110 ops/s
	# Warmup Iteration  11: 3391371337.236 ops/s
	# Warmup Iteration  12: 3383800118.631 ops/s
	# Warmup Iteration  13: 3383415802.274 ops/s
	# Warmup Iteration  14: 3371278558.012 ops/s
	# Warmup Iteration  15: 3366417297.267 ops/s
	# Warmup Iteration  16: 3374286593.526 ops/s
	# Warmup Iteration  17: 3389915878.583 ops/s
	# Warmup Iteration  18: 3405257506.150 ops/s
	# Warmup Iteration  19: 3408615811.184 ops/s
	# Warmup Iteration  20: 3406636073.194 ops/s
	Iteration   1: 3399227672.975 ops/s
	Iteration   2: 3404088125.346 ops/s
	Iteration   3: 3386996791.875 ops/s
	Iteration   4: 3386906925.560 ops/s
	Iteration   5: 3386609807.965 ops/s
	Iteration   6: 3381818133.096 ops/s
	Iteration   7: 3406243496.806 ops/s
	Iteration   8: 3406180039.465 ops/s
	Iteration   9: 3399250423.656 ops/s
	Iteration  10: 3390079424.132 ops/s
	Iteration  11: 3389738822.993 ops/s
	Iteration  12: 3394852882.096 ops/s
	Iteration  13: 3396847962.170 ops/s
	Iteration  14: 3399010497.882 ops/s
	Iteration  15: 3391950932.885 ops/s
	Iteration  16: 3398861290.412 ops/s
	Iteration  17: 3399068792.245 ops/s
	Iteration  18: 3396571548.943 ops/s
	Iteration  19: 3388550184.040 ops/s
	Iteration  20: 3407022297.611 ops/s
	
	
	Result "com.edgar.jmh.JMHSample_01_HelloWorld.wellHelloThere":
	  3395493802.608 ±(99.9%) 6423090.888 ops/s [Average]
	  (min, avg, max) = (3381818133.096, 3395493802.608, 3407022297.611), stdev = 7396841.019
	  CI (99.9%): [3389070711.719, 3401916893.496] (assumes normal distribution)
	
	
	# Run complete. Total time: 00:00:40
	
	Benchmark                                Mode  Cnt           Score         Error  Units
	JMHSample_01_HelloWorld.wellHelloThere  thrpt   20  3395493802.608 ± 6423090.888  ops/s

从上面的描述可以看到wellHelloThere方法的吞吐量

- 第一部分描述了一些参数设置，然后预热迭代执行，上述方法以秒为单位执行20次迭代
- 第二部分描述了正常的迭代执行
- 第三部分描述了基准测试的结果，

  	3395493802.608 ±(99.9%) 6423090.888 ops/s [Average]表示20次迭代里平均每次可以执行3395493802.608次操作。

	(min, avg, max) = (3381818133.096, 3395493802.608, 3407022297.611), stdev = 7396841.019 表示最小值，平均值，最大值，标准偏差

	CI (99.9%): [3389070711.719, 3401916893.496] (assumes normal distribution) 假设结果是正常分布的，基于该样本大小，该方法的真正执行次数在`3395493802.608-6423090.888`到`3395493802.608+6423090.888`之间


## 测试模式 BenchmarkMode

测试方法上@BenchmarkMode注解表示使用特定的测试模式：

- Mode.Throughput 	计算一个时间单位内操作数量
- Mode.AverageTime 	计算平均运行时间
- Mode.SampleTime 	计算一个方法的运行时间(包括百分位)
- Mode.SingleShotTime 	方法仅运行一次(用于冷测试模式)。或者特定批量大小的迭代多次运行(具体查看后面的“`@Measurement“`注解)——这种情况下JMH将计算批处理运行时间(一次批处理所有调用的总时间)
- 上述模式的任意组合，可以指定这些模式的任意组合——该测试运行多次(取决于请求模式的数量)
- Mode.All 	所有模式依次运行

## 时间单位

使用@OutputTimeUnit指定时间单位，它需要一个标准Java类型java.util.concurrent.TimeUnit作为参数。可是如果在一个测试中指定了多种测试模式，给定的时间单位将用于所有的测试(比如，测试SampleTime适宜使用纳秒，但是throughput使用更长的时间单位测量更合适)。

示例:

	public static void main(String[] args) throws RunnerException {
	
		Options opt = new OptionsBuilder()
		        .include(JMHSample_02_BenchmarkModes.class.getSimpleName())
		        .warmupIterations(5)
		        .measurementIterations(5)
		        .forks(1)
		        .build();
		new Runner(opt).run();
	}

	  @Benchmark
	  @BenchmarkMode(Mode.Throughput)
	  @OutputTimeUnit(TimeUnit.SECONDS)
	  public void measureThroughput() throws InterruptedException {
	    TimeUnit.MILLISECONDS.sleep(100);
	  }

	  @Benchmark
	  @BenchmarkMode(Mode.AverageTime)
	  @OutputTimeUnit(TimeUnit.MICROSECONDS)
	  public void measureAvgTime() throws InterruptedException {
	    TimeUnit.MILLISECONDS.sleep(100);
	  }

	  @Benchmark
	  @BenchmarkMode(Mode.SampleTime)
	  @OutputTimeUnit(TimeUnit.MICROSECONDS)
	  public void measureSamples() throws InterruptedException {
	    TimeUnit.MILLISECONDS.sleep(100);
	  }

	  @Benchmark
	  @BenchmarkMode(Mode.SingleShotTime)
	  @OutputTimeUnit(TimeUnit.MICROSECONDS)
	  public void measureSingleShot() throws InterruptedException {
	    TimeUnit.MILLISECONDS.sleep(100);
	  }

	  @Benchmark
	  @BenchmarkMode({Mode.Throughput, Mode.AverageTime, Mode.SampleTime, Mode.SingleShotTime})
	  @OutputTimeUnit(TimeUnit.MICROSECONDS)
	  public void measureMultiple() throws InterruptedException {
	    TimeUnit.MILLISECONDS.sleep(100);
	  }

	  @Benchmark
	  @BenchmarkMode(Mode.All)
	  @OutputTimeUnit(TimeUnit.MICROSECONDS)
	  public void measureAll() throws InterruptedException {
	    TimeUnit.MILLISECONDS.sleep(100);
	  }

## 测试参数状态 State

测试方法可能接收参数。这需要提供单个的参数类，这个类遵循以下4条规则：

    有无参构造函数(默认构造函数)
    是公共类
    内部类应该是静态的
    该类必须使用@State注解

@State注解定义了给定类实例的可用范围。JMH可以在多线程同时运行的环境测试，因此需要选择正确的状态。

- Scope.Thread 	默认状态。实例将分配给运行给定测试的每个线程。
- Scope.Benchmark 	运行相同测试的所有线程将共享实例。可以用来测试状态对象的多线程性能(或者仅标记该范围的基准)。
- Scope.Group 	实例分配给每个线程组(查看后面的线程组部分)

除了将单独的类标记@State，也可以将你自己的benchmark类使用@State标记。上面所有的规则对这种情况也适用。