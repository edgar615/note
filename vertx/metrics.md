vertx-dropwizard-metrics

Vert.x提供了metric组件，用于收集应用的各种指标

# 快速入门

创建Vert.x的时候开启metric

    Vertx.vertx(new VertxOptions()
                        .setMetricsOptions(new MetricsOptions().setEnabled(true)))

也可以在启动时通过命令行参数控制

	java -jar your-fat-jar -Dvertx.metrics.options.enabled=true


`vertx.metrics.options.registryName`可以配置Dropwizard Registry

java -jar your-fat-jar -Dvertx.metrics.options.enabled=true -Dvertx.metrics.options.registryName=my-registry

`vertx.metrics.options.jmxEnabled` 和 `vertx.metrics.options.jmxDomain` 可以配置JMX

	java -ja	r your-fat-jar -Dvertx.metrics.options.enabled=true -Dvertx.metrics.options.jmxEnabled=true

**创建MetricsService**

	MetricsService service = MetricsService.create(vertx);

MetricsService定义了指标收集的一些接口

**获取指标**

      JsonObject metrics = service.getMetricsSnapshot(vertx.eventBus());
      System.out.println(metrics);

getMetricsSnapshot可以通过每个度量指标的名称搜索。`service.getMetricsSnapshot("vertx.eventbus.handlers");`也可以通过实现了`Measured`接口的组件来获取

也可以通过metricsNames方法获取所有的指标名称

      Set<String> metricsNames = service.metricsNames();
      for (String metricsName : metricsNames) {
        System.out.println("Known metrics name " + metricsName);
      }

# 源码
## VertxMetrics
VertxMetrics定义了一下基本的metric接口：verticle的部署和卸载，EventBus、HttpServer等组件的metric接口。

Vertx对象在创建时，会创建一个对应的VertxMetrics对象

	  private VertxMetrics initialiseMetrics(VertxOptions options) {
	    if (options.getMetricsOptions() != null && options.getMetricsOptions().isEnabled()) {
	      VertxMetricsFactory factory = options.getMetricsOptions().getFactory();
	      if (factory == null) {
	        factory = ServiceHelper.loadFactoryOrNull(VertxMetricsFactory.class);
	        if (factory == null) {
	          log.warn("Metrics has been set to enabled but no VertxMetricsFactory found on classpath");
	        }
	      }
	      if (factory != null) {
	        VertxMetrics metrics = factory.metrics(this, options);
	        Objects.requireNonNull(metrics, "The metric instance created from " + factory + " cannot be null");
	        return metrics;
	      }
	    }
	    return DummyVertxMetrics.INSTANCE;
	  }

如果在classpath中没有找到对应Metric的工厂实现，会使用core包中的DummyVertxMetrics。DummyVertxMetrics不会收集任何指标，它所有的方法实现都是空

	@Override
	public void verticleDeployed(Verticle verticle) {
	}
	
	@Override
	public void verticleUndeployed(Verticle verticle) {
	}

## VertxMetricsFactoryImpl 
下面我们看一下vertx-dropwizard-metrics提供的的实现

metrics方法首先会创建一个 MetricRegistry用于存放所有的指标数据。

	MetricRegistry registry = new MetricRegistry();
	boolean shutdown = true;
	if (metricsOptions.getRegistryName() != null) {
	  MetricRegistry other = SharedMetricRegistries.add(metricsOptions.getRegistryName(), registry);
	  if (other != null) {
	    registry = other;
	    shutdown = false;
	  }
	}

接着会创建一个VertxMetrics对象

	VertxMetricsImpl metrics = new VertxMetricsImpl(registry, shutdown, options, metricsOptions);

如果开启了JMX支持，还会创建一个JmxReporter，并将它的关闭注册为VertxMetrics关闭的回调函数。然后启动 JmxReporter;

    if (metricsOptions.isJmxEnabled()) {
      String jmxDomain = metricsOptions.getJmxDomain();
      if (jmxDomain == null) {
        jmxDomain = "vertx" + "@" + Integer.toHexString(vertx.hashCode());
      }
      JmxReporter reporter = JmxReporter.forRegistry(metrics.registry()).inDomain(jmxDomain).build();
      metrics.setDoneHandler(v -> reporter.stop());
      reporter.start();
    }

## VertxMetricsImpl
VertxMetricsImpl的构造方法首先会创建两个Counter类型的度量指标

    this.timers = counter("timers");
    this.verticles = counter("verticles");

- vertx.timers 定时器的数量
- vertx.verticles 当前部署的verticle数量
- vertx.verticles.<verticle-name> 某个verticle当前部署的数量

创建几个Guage类型的指标

    gauge(options::getEventLoopPoolSize, "event-loop-size");
    gauge(options::getWorkerPoolSize, "worker-pool-size");
    if (options.isClustered()) {
      gauge(options::getClusterHost, "cluster-host");
      gauge(options::getClusterPort, "cluster-port");
    }

- vertx.event-loop-size eventloop的大小
- vertx.worker-pool-size 工作线程池的大小

如果Vert.x处于集群环境，还会创建

- vertx.cluster-host 集群的HOST
- vertx.cluster-port 集群的端口

在部署和卸载Verticle时，会调用VertxMetrics对应的方法更新vertx.verticles

	  @Override
	  public void verticleDeployed(Verticle verticle) {
	    verticles.inc();
	    counter("verticles", verticleName(verticle)).inc();
	  }
	
	  @Override
	  public void verticleUndeployed(Verticle verticle) {
	    verticles.dec();
	    counter("verticles", verticleName(verticle)).dec();
	  }
部署

	vertx.metricsSPI().verticleDeployed(verticle);

卸载

	vertx.metricsSPI().verticleUndeployed(verticleHolder.verticle);

在创建和取消定时/延时任务时，会更新vertx.timers

	@Override
	public void timerCreated(long id) {
	timers.inc();
	}
	
	@Override
	public void timerEnded(long id, boolean cancelled) {
	timers.dec();
	}

创建

	metrics.timerCreated(timerID);

取消

	metrics.timerEnded(timerID, true);

如果是延时任务，在执行完成之后会将timer减1

    private void cleanupNonPeriodic() {
      VertxImpl.this.timeouts.remove(timerID);
      metrics.timerEnded(timerID, false);
      ContextImpl context = getContext();
      if (context != null) {
        context.removeCloseHook(this);
      }
    }

## EventBusMetrics
EventBusMetricsImpl的构造方法会创建一系列EventBus相关的指标，这些指标的基础名称都是vertx.eventbus

    handlerCount = counter("handlers");
    pending = counter("messages", "pending");
    pendingLocal = counter("messages", "pending-local");
    pendingRemote = counter("messages", "pending-remote");
    receivedMessages = throughputMeter("messages", "received");
    receivedLocalMessages = throughputMeter("messages", "received-local");
    receivedRemoteMessages = throughputMeter("messages", "received-remote");
    deliveredMessages = throughputMeter("messages", "delivered");
    deliveredLocalMessages = throughputMeter("messages", "delivered-local");
    deliveredRemoteMessages = throughputMeter("messages", "delivered-remote");
    sentMessages = throughputMeter("messages", "sent");
    sentLocalMessages = throughputMeter("messages", "sent-local");
    sentRemoteMessages = throughputMeter("messages", "sent-remote");
    publishedMessages = throughputMeter("messages", "published");
    publishedLocalMessages = throughputMeter("messages", "published-local");
    publishedRemoteMessages = throughputMeter("messages", "published-remote");
    replyFailures = meter("messages", "reply-failures");
    bytesRead = meter("messages", "bytes-read");
    bytesWritten = meter("messages", "bytes-written");
    

Couter类型

- handlers eventbus的handler数量
- messages.pending 已经收到，但还没有被handler处理的消息数量
- messages.pending-local 已经收到，但还没有被handler处理的本地消息数
- messages.pending-remote 已经收到，但还没有被handler处理的远程消息数

ThroughputMeter类型

- messages.sent 发送的消息
- messages.sent-local 发送的本地消息
- messages.sent-remote 发送的远程消息
- messages.published 发布的消息
- messages.published-local 发布的本地消息
- messages.published-remote 发布的远程消息
- messages.received 收到的消息
- messages.received-local 收到的本地消息
- messages.received-remote 收到的远程消息
- messages.delivered - A [throughpu_metert] representing the rate of which messages are being delivered to an handler
- messages.delivered-local - A ThroughputMeter representing the rate of which local messages are being delivered to an handler
- messages.delivered-remote - A ThroughputMeter representing the rate of which remote messages are being delivered to an handler
- messages.bytes-read 读取的远程消息字节
- messages.bytes-written 发送的远程消息字节
- messages.reply-failures 回应失败

