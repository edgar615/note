# metrics

metrics，按字面意思是度量，指标。

举具体的例子来说，一个web服务器：

- 一分钟内请求多少次？
- 平均请求耗时多长？
- 最长请求时间？
- 某个方法的被调用次数，时长？

以缓存为例：

- 平均查询缓存时间？
- 缓存获取不命中的次数/比例？

以jvm为例：

- GC的次数？
- Old Space的大小？

在一个应用里，需要收集的metrics数据是多种多样的，需求也是各不同的。需要一个统一的metrics收集，统计，展示平台。

很多开源项目用到Dropwizard/metrics，比如Hadoop，kafka。

# Metric Registries

MetricRegistry类是Metrics的核心，它是存放应用中所有metrics的容器。也是我们使用 Metrics 库的起点。

MetricRegistry registry = new MetricRegistry();

每一个 metric 都有它独一无二的名字，Metrics 中使用句点名字，如 com.example.Queue.size。当你在 com.example.Queue 下有两个 metric 实例，可以指定地更具体：com.example.Queue.requests.size 和 com.example.Queue.response.size 。使用MetricRegistry类，可以非常方便地生成名字。

	MetricRegistry.name(Queue.class, "requests", "size")
	MetricRegistry.name(Queue.class, "responses", "size")

# Metrics 数据展示

Metircs 提供了 Report 接口，用于展示 metrics 获取到的统计数据。metrics-core中主要实现了四种 reporter： JMX, console, SLF4J, 和 CSV。 

# 五种 Metrics 类型

- Gauges 最简单的度量指标，只有一个简单的返回值
- Counters 计数器，Counter 只是用 Gauge 封装了 AtomicLong 。
- Meters 度量一系列事件发生的速率(rate)，例如TPS。Meters会统计最近1分钟，5分钟，15分钟，还有全部时间的速率。
- Histograms 统计数据的分布情况。比如最小值，最大值，中间值，还有中位数，75百分位, 90百分位, 95百分位, 98百分位, 99百分位, 和 99.9百分位的值(percentiles)。
- Timers  Histogram 和 Meter 的结合， histogram 某部分代码/调用的耗时， meter统计TPS。
- Health Checks 这个实际上不是统计数据。是接口让用户可以自己判断系统的健康状态。如判断数据库是否连接正常
- Metrics Annotation 利用dropwizard/metrics 里的annotation，可以很简单的实现统计某个方法，某个值的数据。

## Gauges
最简单的度量指标，只有一个简单的返回值，例如，我们想衡量一个待处理队列中任务的个数，

队列：

	public class QueueManager {
	  private final Queue queue;
	
	  public QueueManager(MetricRegistry metrics, String name) {
	    this.queue = new LinkedBlockingQueue();
	    //metric的名称：com.example.QueueManager.${name}.size"
	    metrics.register(MetricRegistry.name(QueueManager.class, name, "size"),
	                     new Gauge<Integer>() {
	                       @Override
	                       public Integer getValue() {
	                         return queue.size();
	                       }
	                     });
	  }
	
	  public Queue getQueue() {
	    return queue;
	  }
	}

metric：

	  private static final MetricRegistry metrics = new MetricRegistry();
	
	  public static void main(String[] args) {
	    startReport();
	    Queue queue = new QueueManager(metrics, "job").getQueue();
	    Runnable r = () -> {
	      for (int i = 0; i < 3; i ++) {
	        queue.offer(i);
	        wait1Seconds();
	      }
	    };
	    new Thread(r).start();
	    wait5Seconds();
	  }
	
	  static void startReport() {
	    ConsoleReporter reporter = ConsoleReporter.forRegistry(metrics)
	            .convertRatesTo(TimeUnit.SECONDS)
	            .convertDurationsTo(TimeUnit.MILLISECONDS)
	            .build();
	    reporter.start(1, TimeUnit.SECONDS);
	  }

输出：

	17-3-3 11:02:16 ================================================================
	
	-- Gauges ----------------------------------------------------------------------
	com.edgar.dropwizard.metrics.hello.QueueManager.job.size
	             value = 1
	
	
	17-3-3 11:02:17 ================================================================
	
	-- Gauges ----------------------------------------------------------------------
	com.edgar.dropwizard.metrics.hello.QueueManager.job.size
	             value = 2
	
	
	17-3-3 11:02:18 ================================================================
	
	-- Gauges ----------------------------------------------------------------------
	com.edgar.dropwizard.metrics.hello.QueueManager.job.size
	             value = 3
	
	
	17-3-3 11:02:19 ================================================================
	
	-- Gauges ----------------------------------------------------------------------
	com.edgar.dropwizard.metrics.hello.QueueManager.job.size
	             value = 3
	
	
	17-3-3 11:02:20 ================================================================
	
	-- Gauges ----------------------------------------------------------------------
	com.edgar.dropwizard.metrics.hello.QueueManager.job.size
	             value = 3

### JMX Gauges
鉴于许多第三方库只能通过JMX对外暴露metrics，Metric提供了JmxAttributeGauge 类： 

	registry.register(name(SessionStore.class, "cache-evictions"),
	                 new JmxAttributeGauge("net.sf.ehcache:type=Cache,scope=sessions,name=eviction-count", "Value"));
### Ratio Gauges
两个数之间的比例

	public class CacheHitRatio extends RatioGauge {
	    private final Meter hits;
	    private final Timer calls;
	
	    public CacheHitRatio(Meter hits, Timer calls) {
	        this.hits = hits;
	        this.calls = calls;
	    }
	
	    @Override
	    public Ratio getRatio() {
	        return Ratio.of(hits.getOneMinuteRate(),
	                        calls.getOneMinuteRate());
	    }
	}

### Cached Gauges
Cached Gauges用来缓存一些比较昂贵耗时的计算。在构造函数中缓存的过期时间。`getvalue()`的方法被从缓存中取值。`loadvalue()`方法用于内部刷新缓存值。

	registry.register(name(Cache.class, cache.getName(), "size"),
	                  new CachedGauge<Long>(10, TimeUnit.MINUTES) {
	                      @Override
	                      protected Long loadValue() {
	                          // assume this does something which takes a long time
	                          return cache.getSize();
	                      }
	                  });

## Derivative Gauges
Derivative Gauges允许你从其他源数据的值中得到数据：

	public class CacheSizeGauge extends DerivativeGauge<CacheStats, Long> {
	    public CacheSizeGauge(Gauge<CacheStats> statsGauge) {
	        super(statsGauge);
	    }
	
	    @Override
	    protected Long transform(CacheStats stats) {
	        return stats.getSize();
	    }
	}

## Counters
计数器，Counter 只是用 Gauge 封装了 AtomicLong。所有的counter从0开始计数

队列

	  private final Counter pendingJobs;
	
	  public CounterQueueManager(MetricRegistry metrics, String name) {
	    this.queue = new LinkedBlockingQueue();
	    //metric的名称：com.example.QueueManager.${name}.size"
	    pendingJobs = metrics.counter(MetricRegistry.name(QueueManager.class, name));
	  }
	
	  public Queue getQueue() {
	    return queue;
	  }
	
	  public void add(int i) {
	    pendingJobs.inc();
	    queue.add(i);
	  }
	
	  public Object take() {
	    pendingJobs.dec();
	    return queue.poll();
	  }

metric

	  private static final MetricRegistry metrics = new MetricRegistry();
	
	  public static void main(String[] args) {
	    startReport();
	    CounterQueueManager queue = new CounterQueueManager(metrics, "job");
	    Runnable r = () -> {
	      for (int i = 0; i < 3; i ++) {
	        queue.add(i);
	        wait1Seconds();
	      }
	    };
	    new Thread(r).start();
	    Runnable r2 = () -> {
	      for (int i = 0; i < 3; i ++) {
	        queue.take();
	        wait2Seconds();
	      }
	    };
	    new Thread(r2).start();
	    wait5Seconds();
	  }

输出：

17-3-3 11:08:27 ================================================================

-- Counters --------------------------------------------------------------------
com.edgar.dropwizard.metrics.hello.QueueManager.job
             count = 0


17-3-3 11:08:28 ================================================================

-- Counters --------------------------------------------------------------------
com.edgar.dropwizard.metrics.hello.QueueManager.job
             count = 1


17-3-3 11:08:29 ================================================================

-- Counters --------------------------------------------------------------------
com.edgar.dropwizard.metrics.hello.QueueManager.job
             count = 1


17-3-3 11:08:30 ================================================================

-- Counters --------------------------------------------------------------------
com.edgar.dropwizard.metrics.hello.QueueManager.job
             count = 1


17-3-3 11:08:31 ================================================================

-- Counters --------------------------------------------------------------------
com.edgar.dropwizard.metrics.hello.QueueManager.job
             count = 0


17-3-3 11:08:32 ================================================================

-- Counters --------------------------------------------------------------------
com.edgar.dropwizard.metrics.hello.QueueManager.job
             count = 0

这里通过 ` metrics.counter(MetricRegistry.name(QueueManager.class, name));`创建的metric，但是也可以像Gauge一样创建一个Counter

## Histograms
统计数据的分布情况。比如最小值，最大值，中间值，还有中位数，75百分位, 90百分位, 95百分位, 98百分位, 99百分位, 和 99.9百分位的值(percentiles)

	  private static final MetricRegistry metrics = new MetricRegistry();
	  private static final Histogram
	          responseSizes = metrics.histogram(
	          MetricRegistry.name("com.edgar.requestHandler",
	                                                                "response-sizes"));
	
	  public static void handleRequest() {
	    // etc
	    responseSizes.update(randomString().length());
	  }
	
	  public static void main(String[] args) {
	    startReport();
	    Runnable r = () -> {
	      for (int i = 0; i < 30; i ++) {
	        handleRequest();
	        wait1Seconds();
	      }
	    };
	    new Thread(r).start();
	    wait5Seconds();
	  }

输出：

	17-3-3 11:31:54 ================================================================
	
	-- Histograms ------------------------------------------------------------------
	com.edgar.requestHandler.response-sizes
	             count = 1
	               min = 78
	               max = 78
	              mean = 78.00
	            stddev = 0.00
	            median = 78.00
	              75% <= 78.00
	              95% <= 78.00
	              98% <= 78.00
	              99% <= 78.00
	            99.9% <= 78.00
	
	
	17-3-3 11:31:55 ================================================================
	
	-- Histograms ------------------------------------------------------------------
	com.edgar.requestHandler.response-sizes
	             count = 2
	               min = 74
	               max = 78
	              mean = 75.99
	            stddev = 2.00
	            median = 74.00
	              75% <= 78.00
	              95% <= 78.00
	              98% <= 78.00
	              99% <= 78.00
	            99.9% <= 78.00
	
	
	17-3-3 11:31:56 ================================================================
	
	-- Histograms ------------------------------------------------------------------
	com.edgar.requestHandler.response-sizes
	             count = 3
	               min = 59
	               max = 78
	              mean = 70.24
	            stddev = 8.20
	            median = 74.00
	              75% <= 78.00
	              95% <= 78.00
	              98% <= 78.00
	              99% <= 78.00
	            99.9% <= 78.00
	
	
	17-3-3 11:31:57 ================================================================
	
	-- Histograms ------------------------------------------------------------------
	com.edgar.requestHandler.response-sizes
	             count = 4
	               min = 34
	               max = 78
	              mean = 60.97
	            stddev = 17.32
	            median = 59.00
	              75% <= 74.00
	              95% <= 78.00
	              98% <= 78.00
	              99% <= 78.00
	            99.9% <= 78.00
	
	
	17-3-3 11:31:58 ================================================================
	
	-- Histograms ------------------------------------------------------------------
	com.edgar.requestHandler.response-sizes
	             count = 5
	               min = 6
	               max = 78
	              mean = 49.65
	            stddev = 27.07
	            median = 59.00
	              75% <= 74.00
	              95% <= 78.00
	              98% <= 78.00
	              99% <= 78.00
	            99.9% <= 78.00
	
	......

## Meters 
度量一系列事件发生的速率(rate)，例如TPS。Meters会统计最近1分钟，5分钟，15分钟，还有全部时间的速率

	  private static final Meter
	          request = metrics.meter(
	          MetricRegistry.name("com.edgar.requestHandler",
	                                                                "request"));
	
	  public static void handleRequest() {
	//    request.mark();
	    request.mark(new Random().nextInt(100));
	  }

输出：

	17-3-3 11:37:33 ================================================================
	
	-- Meters ----------------------------------------------------------------------
	com.edgar.requestHandler.request
	             count = 88
	         mean rate = 83.49 events/second
	     1-minute rate = 0.00 events/second
	     5-minute rate = 0.00 events/second
	    15-minute rate = 0.00 events/second
	
	
	17-3-3 11:37:34 ================================================================
	
	-- Meters ----------------------------------------------------------------------
	com.edgar.requestHandler.request
	             count = 169
	         mean rate = 82.77 events/second
	     1-minute rate = 0.00 events/second
	     5-minute rate = 0.00 events/second
	    15-minute rate = 0.00 events/second
	
	
	17-3-3 11:37:35 ================================================================
	
	-- Meters ----------------------------------------------------------------------
	com.edgar.requestHandler.request
	             count = 250
	         mean rate = 82.19 events/second
	     1-minute rate = 0.00 events/second
	     5-minute rate = 0.00 events/second
	    15-minute rate = 0.00 events/second
	
	
	17-3-3 11:37:36 ================================================================
	
	-- Meters ----------------------------------------------------------------------
	com.edgar.requestHandler.request
	             count = 270
	         mean rate = 66.81 events/second
	     1-minute rate = 0.00 events/second
	     5-minute rate = 0.00 events/second
	    15-minute rate = 0.00 events/second
	
	
	17-3-3 11:37:37 ================================================================
	
	-- Meters ----------------------------------------------------------------------
	com.edgar.requestHandler.request
	             count = 345
	         mean rate = 68.45 events/second
	     1-minute rate = 69.00 events/second
	     5-minute rate = 69.00 events/second
	    15-minute rate = 69.00 events/second

## Timers

Histogram 和 Meter 的结合， histogram 某部分代码/调用的耗时， meter统计TPS。

	  private static final Timer
	          responses = metrics.timer(
	          MetricRegistry.name("com.edgar.requestHandler",
	                              "response"));
	
	  public static void handleRequest() {
	    // etc
	    final Timer.Context context = responses.time();
	    try {
	      // etc;
	      waitRandomMill();
	      //return
	    } finally {
	      context.stop();
	    }
	  }

输出

17-3-3 11:41:31 ================================================================

-- Timers ----------------------------------------------------------------------
com.edgar.requestHandler.response
             count = 1
         mean rate = 0.00 calls/second
     1-minute rate = 0.00 calls/second
     5-minute rate = 0.00 calls/second
    15-minute rate = 0.00 calls/second
               min = 0.00 milliseconds
               max = 0.00 milliseconds
              mean = 0.00 milliseconds
            stddev = 0.00 milliseconds
            median = 0.00 milliseconds
              75% <= 0.00 milliseconds
              95% <= 0.00 milliseconds
              98% <= 0.00 milliseconds
              99% <= 0.00 milliseconds
            99.9% <= 0.00 milliseconds


17-3-3 11:41:32 ================================================================

-- Timers ----------------------------------------------------------------------
com.edgar.requestHandler.response
             count = 1
         mean rate = 0.49 calls/second
     1-minute rate = 0.00 calls/second
     5-minute rate = 0.00 calls/second
    15-minute rate = 0.00 calls/second
               min = 867.78 milliseconds
               max = 867.78 milliseconds
              mean = 867.78 milliseconds
            stddev = 0.00 milliseconds
            median = 867.78 milliseconds
              75% <= 867.78 milliseconds
              95% <= 867.78 milliseconds
              98% <= 867.78 milliseconds
              99% <= 867.78 milliseconds
            99.9% <= 867.78 milliseconds


17-3-3 11:41:33 ================================================================

-- Timers ----------------------------------------------------------------------
com.edgar.requestHandler.response
             count = 2
         mean rate = 0.66 calls/second
     1-minute rate = 0.00 calls/second
     5-minute rate = 0.00 calls/second
    15-minute rate = 0.00 calls/second
               min = 272.95 milliseconds
               max = 867.78 milliseconds
              mean = 565.90 milliseconds
            stddev = 297.38 milliseconds
            median = 272.95 milliseconds
              75% <= 867.78 milliseconds
              95% <= 867.78 milliseconds
              98% <= 867.78 milliseconds
              99% <= 867.78 milliseconds
            99.9% <= 867.78 milliseconds


17-3-3 11:41:34 ================================================================

-- Timers ----------------------------------------------------------------------
com.edgar.requestHandler.response
             count = 3
         mean rate = 0.74 calls/second
     1-minute rate = 0.00 calls/second
     5-minute rate = 0.00 calls/second
    15-minute rate = 0.00 calls/second
               min = 272.95 milliseconds
               max = 867.78 milliseconds
              mean = 550.32 milliseconds
            stddev = 242.57 milliseconds
            median = 520.06 milliseconds
              75% <= 867.78 milliseconds
              95% <= 867.78 milliseconds
              98% <= 867.78 milliseconds
              99% <= 867.78 milliseconds
            99.9% <= 867.78 milliseconds


17-3-3 11:41:35 ================================================================

-- Timers ----------------------------------------------------------------------
com.edgar.requestHandler.response
             count = 3
         mean rate = 0.60 calls/second
     1-minute rate = 0.60 calls/second
     5-minute rate = 0.60 calls/second
    15-minute rate = 0.60 calls/second
               min = 272.95 milliseconds
               max = 867.78 milliseconds
              mean = 550.32 milliseconds
            stddev = 242.57 milliseconds
            median = 520.06 milliseconds
              75% <= 867.78 milliseconds
              95% <= 867.78 milliseconds
              98% <= 867.78 milliseconds
              99% <= 867.78 milliseconds
            99.9% <= 867.78 milliseconds


17-3-3 11:41:36 ================================================================

-- Timers ----------------------------------------------------------------------
com.edgar.requestHandler.response
             count = 4
         mean rate = 0.66 calls/second
     1-minute rate = 0.60 calls/second
     5-minute rate = 0.60 calls/second
    15-minute rate = 0.60 calls/second
               min = 272.95 milliseconds
               max = 867.78 milliseconds
              mean = 520.15 milliseconds
            stddev = 214.87 milliseconds
            median = 434.06 milliseconds
              75% <= 520.06 milliseconds
              95% <= 867.78 milliseconds
              98% <= 867.78 milliseconds
              99% <= 867.78 milliseconds
            99.9% <= 867.78 milliseconds

## - Health Checks 
这个实际上不是统计数据。是接口让用户可以自己判断系统的健康状态。如判断数据库是否连接正常

依赖metrics-healthchecks组件

	 private static final HealthCheckRegistry healthChecks = new HealthCheckRegistry();
	
	  public static void main(String[] args) {
	    DatabaseHealthCheck healthCheck = new DatabaseHealthCheck(new Database());
	    healthChecks.register("database", healthCheck);
	    for (int i = 0; i < 10; i ++) {
	      check();
	    }
	  }
	
	  private static void check() {
	    final Map<String, HealthCheck.Result> results = healthChecks.runHealthChecks();
	    for (Map.Entry<String, HealthCheck.Result> entry : results.entrySet()) {
	      if (entry.getValue().isHealthy()) {
	        System.out.println(entry.getKey() + " is healthy");
	      } else {
	        System.err.println(entry.getKey() + " is UNHEALTHY: " + entry.getValue().getMessage());
	        final Throwable e = entry.getValue().getError();
	        if (e != null) {
	          e.printStackTrace();
	        }
	      }
	    }
	  }
	}

	public class Database {
	  //可以使用SELECT 1来ping数据库
	  public boolean ping() {
	    return new Random().nextInt(100) % 2 == 0;
	  }
	}

输出：

	database is healthy
	database is healthy
	database is UNHEALTHY: Cannot connect to com.edgar.dropwizard.metrics.hello.Database@3a71f4dd

# Reporters

dropwizard/metrics 里提供了reporter的接口，用户可以自己实现如何处理metrics数据。

dropwizard/metrics有不少现成的reporter：

- ConsoleReporter  输出到stdout
- JmxReporter  转化为MBean
- metrics-servlets  提供http接口，可以查询到metrics信息
- CsvReporter 输出为CSV文件
- Slf4jReporter 以log方式输出
- GangliaReporter  上报到Ganglia
- GraphiteReporter 上报到Graphite

除此之外，还有一些第三方实现的Reporter

## JMX

	final JmxReporter reporter = JmxReporter.forRegistry(registry).build();
	reporter.start();

## Console

	final ConsoleReporter reporter = ConsoleReporter.forRegistry(registry)
	                                                .convertRatesTo(TimeUnit.SECONDS)
	                                                .convertDurationsTo(TimeUnit.MILLISECONDS)
	                                                .build();
	reporter.start(1, TimeUnit.MINUTES);

## CSV

	final CsvReporter reporter = CsvReporter.forRegistry(registry)
	                                        .formatFor(Locale.US)
	                                        .convertRatesTo(TimeUnit.SECONDS)
	                                        .convertDurationsTo(TimeUnit.MILLISECONDS)
	                                        .build(new File("~/projects/data/"));
	reporter.start(1, TimeUnit.SECONDS);

## SLF4J

	final Slf4jReporter reporter = Slf4jReporter.forRegistry(registry)
	                                            .outputTo(LoggerFactory.getLogger("com.example.metrics"))
	                                            .convertRatesTo(TimeUnit.SECONDS)
	                                            .convertDurationsTo(TimeUnit.MILLISECONDS)
	                                            .build();
	reporter.start(1, TimeUnit.MINUTES);

## Ganglia

	final GMetric ganglia = new GMetric("ganglia.example.com", 8649, UDPAddressingMode.MULTICAST, 1);
	final GangliaReporter reporter = GangliaReporter.forRegistry(registry)
	                                                .convertRatesTo(TimeUnit.SECONDS)
	                                                .convertDurationsTo(TimeUnit.MILLISECONDS)
	                                                .build(ganglia);
	reporter.start(1, TimeUnit.MINUTES);

## Graphite

	final Graphite graphite = new Graphite(new InetSocketAddress("graphite.example.com", 2003));
	final GraphiteReporter reporter = GraphiteReporter.forRegistry(registry)
	                                                  .prefixedWith("web1.example.com")
	                                                  .convertRatesTo(TimeUnit.SECONDS)
	                                                  .convertDurationsTo(TimeUnit.MILLISECONDS)
	                                                  .filter(MetricFilter.ALL)
	                                                  .build(graphite);
	reporter.start(1, TimeUnit.MINUTES);

批量处理

	final PickledGraphite pickledGraphite = new PickledGraphite(new InetSocketAddress("graphite.example.com", 2004));
	final GraphiteReporter reporter = GraphiteReporter.forRegistry(registry)
	                                                  .prefixedWith("web1.example.com")
	                                                  .convertRatesTo(TimeUnit.SECONDS)
	                                                  .convertDurationsTo(TimeUnit.MILLISECONDS)
	                                                  .filter(MetricFilter.ALL)
	                                                  .build(pickledGraphite);
	reporter.start(1, TimeUnit.MINUTES);

## Servlet
有下列几种不同的Servlet，由于工作中没有用到，暂时没有研究。

HealthCheckServlet

ThreadDumpServlet

MetricsServlet

PingServlet

AdminServlet

# Instrumenting 
Dropwizard/metrics还提供了一些开源工具的度量实现

- Ehcache 
- HttpClient
- JDBI
- Jersey 
- Log4j
- Logback
- Web Applications
- JVM 

除此之外，还有一些第三方的开源实现

# JVM
## JvmAttributeGaugeSet
A set of gauges for the JVM name, vendor, and uptime.

    metrics.register(MetricRegistry.name("com.edgar.jvm"),
                     new JvmAttributeGaugeSet());

输出

	17-3-6 14:06:13 ================================================================
	
	-- Gauges ----------------------------------------------------------------------
	com.edgar.jvm.name
	             value = 1792@edgar
	com.edgar.jvm.uptime
	             value = 1366
	com.edgar.jvm.vendor
	             value = Oracle Corporation Java HotSpot(TM) 64-Bit Server VM 25.20-b23 (1.8)

## GarbageCollectorMetricSet
A set of gauges for the counts and elapsed times of garbage collections.

    metrics.register(MetricRegistry.name("com.edgar.jvm.gc"),
                     new GarbageCollectorMetricSet());

输出 

	17-3-6 14:08:03 ================================================================
	
	-- Gauges ----------------------------------------------------------------------
	com.edgar.jvm.gc.PS-MarkSweep.count
	             value = 0
	com.edgar.jvm.gc.PS-MarkSweep.time
	             value = 0
	com.edgar.jvm.gc.PS-Scavenge.count
	             value = 0
	com.edgar.jvm.gc.PS-Scavenge.time
	             value = 0

## MemoryUsageGaugeSet
A set of gauges for JVM memory usage, including stats on heap vs. non-heap memory, plus GC-specific memory pools.

    metrics.register(MetricRegistry.name("com.edgar.jvm.mem"),
                     new MemoryUsageGaugeSet());

	17-3-6 14:10:03 ================================================================
	
	-- Gauges ----------------------------------------------------------------------
	com.edgar.jvm.mem.heap.committed
	             value = 64487424
	com.edgar.jvm.mem.heap.init
	             value = 67108864
	com.edgar.jvm.mem.heap.max
	             value = 926941184
	com.edgar.jvm.mem.heap.usage
	             value = 0.016319421621469352
	com.edgar.jvm.mem.heap.used
	             value = 15127144
	com.edgar.jvm.mem.non-heap.committed
	             value = 12320768
	com.edgar.jvm.mem.non-heap.init
	             value = 2555904
	com.edgar.jvm.mem.non-heap.max
	             value = -1
	com.edgar.jvm.mem.non-heap.usage
	             value = -1.1966192E7
	com.edgar.jvm.mem.non-heap.used
	             value = 11967384
	com.edgar.jvm.mem.pools.Code-Cache.committed
	             value = 2621440
	com.edgar.jvm.mem.pools.Code-Cache.init
	             value = 2555904
	com.edgar.jvm.mem.pools.Code-Cache.max
	             value = 251658240
	com.edgar.jvm.mem.pools.Code-Cache.usage
	             value = 0.010206349690755208
	com.edgar.jvm.mem.pools.Code-Cache.used
	             value = 2568512
	com.edgar.jvm.mem.pools.Compressed-Class-Space.committed
	             value = 1048576
	com.edgar.jvm.mem.pools.Compressed-Class-Space.init
	             value = 0
	com.edgar.jvm.mem.pools.Compressed-Class-Space.max
	             value = 1073741824
	com.edgar.jvm.mem.pools.Compressed-Class-Space.usage
	             value = 9.525865316390991E-4
	com.edgar.jvm.mem.pools.Compressed-Class-Space.used
	             value = 1022832
	com.edgar.jvm.mem.pools.Metaspace.committed
	             value = 8650752
	com.edgar.jvm.mem.pools.Metaspace.init
	             value = 0
	com.edgar.jvm.mem.pools.Metaspace.max
	             value = -1
	com.edgar.jvm.mem.pools.Metaspace.usage
	             value = 0.9691485780658144
	com.edgar.jvm.mem.pools.Metaspace.used
	             value = 8383864
	com.edgar.jvm.mem.pools.PS-Eden-Space.committed
	             value = 16777216
	com.edgar.jvm.mem.pools.PS-Eden-Space.init
	             value = 16777216
	com.edgar.jvm.mem.pools.PS-Eden-Space.max
	             value = 341835776
	com.edgar.jvm.mem.pools.PS-Eden-Space.usage
	             value = 0.04425266476496597
	com.edgar.jvm.mem.pools.PS-Eden-Space.used
	             value = 15127144
	com.edgar.jvm.mem.pools.PS-Eden-Space.used-after-gc
	             value = 0
	com.edgar.jvm.mem.pools.PS-Old-Gen.committed
	             value = 45088768
	com.edgar.jvm.mem.pools.PS-Old-Gen.init
	             value = 45088768
	com.edgar.jvm.mem.pools.PS-Old-Gen.max
	             value = 695205888
	com.edgar.jvm.mem.pools.PS-Old-Gen.usage
	             value = 0.0
	com.edgar.jvm.mem.pools.PS-Old-Gen.used
	             value = 0
	com.edgar.jvm.mem.pools.PS-Old-Gen.used-after-gc
	             value = 0
	com.edgar.jvm.mem.pools.PS-Survivor-Space.committed
	             value = 2621440
	com.edgar.jvm.mem.pools.PS-Survivor-Space.init
	             value = 2621440
	com.edgar.jvm.mem.pools.PS-Survivor-Space.max
	             value = 2621440
	com.edgar.jvm.mem.pools.PS-Survivor-Space.usage
	             value = 0.0
	com.edgar.jvm.mem.pools.PS-Survivor-Space.used
	             value = 0
	com.edgar.jvm.mem.pools.PS-Survivor-Space.used-after-gc
	             value = 0
	com.edgar.jvm.mem.total.committed
	             value = 76808192
	com.edgar.jvm.mem.total.init
	             value = 69664768
	com.edgar.jvm.mem.total.max
	             value = 926941183
	com.edgar.jvm.mem.total.used
	             value = 27142736

## ClassLoadingGaugeSet
A set of gauges for JVM classloader usage.

    metrics.register(MetricRegistry.name("com.edgar.jvm.mem"),
                     new ClassLoadingGaugeSet());

输出

	17-3-6 14:12:16 ================================================================
	
	-- Gauges ----------------------------------------------------------------------
	com.edgar.jvm.class.loaded
	             value = 1429
	com.edgar.jvm.class.unloaded
	             value = 0

## ThreadStatesGaugeSet
A set of gauges for the number of threads in their various states and deadlock detection

    metrics.register(MetricRegistry.name("com.edgar.jvm.thread"),
                     new ThreadStatesGaugeSet());

输出

	17-3-6 14:13:32 ================================================================
	
	-- Gauges ----------------------------------------------------------------------
	com.edgar.jvm.thread.blocked.count
	             value = 0
	com.edgar.jvm.thread.count
	             value = 8
	com.edgar.jvm.thread.daemon.count
	             value = 6
	com.edgar.jvm.thread.deadlock.count
	             value = 0
	com.edgar.jvm.thread.deadlocks
	             value = []
	com.edgar.jvm.thread.new.count
	             value = 0
	com.edgar.jvm.thread.runnable.count
	             value = 4
	com.edgar.jvm.thread.terminated.count
	             value = 0
	com.edgar.jvm.thread.timed_waiting.count
	             value = 2
	com.edgar.jvm.thread.waiting.count
	             value = 2

## CachedThreadStatesGaugeSet

    metrics.register(MetricRegistry.name("com.edgar.jvm.thread"),
                     new CachedThreadStatesGaugeSet(10, TimeUnit.SECONDS));

输出

	17-3-6 14:17:38 ================================================================
	
	-- Gauges ----------------------------------------------------------------------
	com.edgar.jvm.thread.blocked.count
	             value = 0
	com.edgar.jvm.thread.count
	             value = 8
	com.edgar.jvm.thread.daemon.count
	             value = 6
	com.edgar.jvm.thread.deadlock.count
	             value = 0
	com.edgar.jvm.thread.deadlocks
	             value = []
	com.edgar.jvm.thread.new.count
	             value = 0
	com.edgar.jvm.thread.runnable.count
	             value = 4
	com.edgar.jvm.thread.terminated.count
	             value = 0
	com.edgar.jvm.thread.timed_waiting.count
	             value = 2
	com.edgar.jvm.thread.waiting.count
	             value = 2

## BufferPoolMetricSet
 A set of gauges for the count, usage, and capacity of the JVM's direct and mapped buffer pools. **JDK7才支持**
