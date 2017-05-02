断路器 Circuit Breaker

参考

http://ju.outofmemory.cn/entry/68192


今天稍微复杂点的互联网应用，服务端基本都是分布式的，大量的服务支撑起整个系统，服务之间也难免有大量的依赖关系，依赖都是通过网络连接起来。

![](https://github.com/Netflix/Hystrix/wiki/images/soa-1-640.png)


然而任何一个服务的可用性都不是 100% 的，网络亦是脆弱的。当我依赖的某个服务不可用的时候，我自身是否会被拖死？当网络不稳定的时候，我自身是否会被拖死？这些在单机环境下不太需要考虑的问题，在分布式环境下就不得不考虑了。假设我有5个依赖的服务，他们的可用性都是99.95%，即一年不可用时间约为4个多小时，那么是否意味着我的可用性最多就是 99.95% 的5次方，99.75%（近乎一天），再加上网络不稳定因素、依赖服务可能更多，可用性会更低。考虑到所依赖的服务必定会在某些时间不可用，考虑到网络必定会不稳定，我们应该怎么设计自身服务？即，怎么为出错设计？


    使用超时
    使用断路器

第一条，通过网络调用外部依赖服务的时候，都必须应该设置超时。在健康的情况下，一般局域往的一次远程调用在几十毫秒内就返回了，但是当网络拥堵的时候，或者所依赖服务不可用的时候，这个时间可能是好多秒，或者压根就僵死了。通常情况下，一次远程调用对应了一个线程或者进程，如果响应太慢，或者僵死了，那一个进程/线程，就被拖死，短时间内得不到释放，而进程/线程都对应了系统资源，这就等于说我自身服务资源会被耗尽，导致自身服务不可用。假设我的服务依赖于很多服务，其中一个非核心的依赖如果不可用，而且没有超时机制，那么这个非核心依赖就能拖死我的服务，尽管理论上即使没有它我在大部分情况还能健康运转的。

当我们的服务访问某项依赖有大量超时的时候，再让新的请求去访问已经没有太大意义，那只会无谓的消耗现有资源。即使你已经设置超时1秒了，那明知依赖不可用的情况下再让更多的请求，比如100个，去访问这个依赖，也会导致100个线程1秒的资源浪费。这个时候，断路器就能帮助我们避免这种资源浪费，在自身服务和依赖之间放一个断路器，实时统计访问的状态，当访问超时或者失败达到某个阈值的时候（如50%请求超时，或者连续20次请失败），就打开断路器，那么后续的请求就直接返回失败，不至于浪费资源。断路器再根据一个时间间隔（如5分钟）尝试关闭断路器（或者更换保险丝），看依赖是否恢复服务了。

# 断路器
https://en.wikipedia.org/wiki/Circuit_breaker_design_pattern

假设有个应用程序每秒会与数据库沟通数百次，此时数据库突然发生了错误，程序员并不会希望在错误时还不断地访问数据库。因此会在等待TCP连线逾时之前直接处理这个错误，并进入正常的结束程序（而非直接结束程式）。简单来说，断路器会侦测错误并且“预防”应用程序不断地呼叫一个近乎毫无回应的服务（除非该服务已经安全到可重试连线了）。

断路器有分简单与较进阶的版本，简单的断路器只需要知道服务是否可用。而较进阶的版本比起前者更有效率。进阶的断路器带有至少三个状态：

    关闭：断路器在预设的情形下是呈现关闭的状态，而断路器本身“带有”计数功能，每当错误发生一次，计数器也就会进行“累加”的动作，到了一定的错误发生次数断路器就会被“开启”，这个时候亦会在内部启用一个计时器，一但时间到了就会切换成半开启的状态。
    开启：在开启的状态下任何请求都会“直接”被拒绝并且抛出异常讯息。
    半开启：在此状态下断路器会允许部分的请求，如果这些请求都能成功通过，那么就意味着错误已经不存在，则会被“切换回”关闭状态并“重置”计数。倘若请求中有“任一”的错误发生，则会回复到“开启”状态，并且重新计时，给予系统一段休息时间。

# Vert.x的断路器

## 创建断路器

        CircuitBreaker breaker = CircuitBreaker.create("my-circuit-breaker", vertx,
                new CircuitBreakerOptions()
                        .setMaxFailures(5) // number of failure before opening the circuit
                        .setTimeout(1000) // consider a failure if the operation does not succeed in time
                        .setResetTimeout(3000) // time spent in open state before attempting to re-try
        )
                .openHandler(v -> {
                    System.out.println("Circuit opened");
                }).closeHandler(v -> {
                    System.out.println("Circuit closed");
                }).halfOpenHandler(v -> {
                    System.out.println("reset (half-open state)");
                });;

- setMaxFailures方法用来定义一个错误次数，断路器execute方法的错误次数到达这个错误次数之后，断路器会被开启
- setTimeout方法用来定义超时时间，如果断路器execute方法超过这个时间仍未完成，断路器会认为这个方法超时
- setResetTimeout方法用来定义断路器从开启状态到半开启状态的时间

我们通过一个定时器来测试一下上面创建的断路器

    AtomicInteger seq = new AtomicInteger();
    vertx.setPeriodic(1000, l -> {
      final long time = System.currentTimeMillis();
      final int i = seq.incrementAndGet();
      breaker.<String>execute(future -> {
        //do nothing
      }).setHandler(ar -> {
        if (ar.succeeded()) {
          System.out.println(time + " : OK: "
                             + ar.result() + " " + i);
        } else {
          System.out.println(
                  time + " : ERROR: " + ar.cause() + " " + i);
        }
      });
    });

输出

	1493714248939 : ERROR: io.vertx.core.impl.NoStackTraceThrowable: operation timeout 1
	1493714249939 : ERROR: io.vertx.core.impl.NoStackTraceThrowable: operation timeout 2
	1493714250939 : ERROR: io.vertx.core.impl.NoStackTraceThrowable: operation timeout 3
	1493714251939 : ERROR: io.vertx.core.impl.NoStackTraceThrowable: operation timeout 4
	1493714253939 : Circuit opened
	1493714252939 : ERROR: io.vertx.core.impl.NoStackTraceThrowable: operation timeout 5
	1493714254939 : ERROR: java.lang.RuntimeException: open circuit 7
	1493714253938 : ERROR: io.vertx.core.impl.NoStackTraceThrowable: operation timeout 6
	1493714255938 : ERROR: java.lang.RuntimeException: open circuit 8
	1493714256938 : ERROR: java.lang.RuntimeException: open circuit 9
	1493714256941 : reset (half-open state)
	1493714258939 : ERROR: java.lang.RuntimeException: open circuit 11
	1493714258941 : Circuit opened
	1493714257938 : ERROR: io.vertx.core.impl.NoStackTraceThrowable: operation timeout 10
	1493714259939 : ERROR: java.lang.RuntimeException: open circuit 12
	1493714260939 : ERROR: java.lang.RuntimeException: open circuit 13
	1493714261939 : ERROR: java.lang.RuntimeException: open circuit 14
	1493714261942 : reset (half-open state)
	1493714263939 : ERROR: java.lang.RuntimeException: open circuit 16
	1493714263939 : Circuit opened

观察输出，可以看到，在第五个请求超时后，断路器被打开；

	1493714253939 : Circuit opened

在断路器打开之后的请求，全部直接返回的RuntimeException，而不再是超时的错误

在3秒后，断路器处于半开状态，

	1493714256941 : reset (half-open state)

这之后的第一个请求通过了断路器

	1493714257938 : ERROR: io.vertx.core.impl.NoStackTraceThrowable: operation timeout 10

他在超时之后又重新将断路器打开

我们将断路器的逻辑做一点修改

	  breaker.<String>execute(future -> {
	    //do nothing
	    if (i >= 12) {
	      future.complete();
	    }
	  })

输出

	1493714640143 : ERROR: io.vertx.core.impl.NoStackTraceThrowable: operation timeout 1
	1493714641145 : ERROR: io.vertx.core.impl.NoStackTraceThrowable: operation timeout 2
	1493714642143 : ERROR: io.vertx.core.impl.NoStackTraceThrowable: operation timeout 3
	1493714643145 : ERROR: io.vertx.core.impl.NoStackTraceThrowable: operation timeout 4
	1493714645144 : Circuit opened
	1493714644144 : ERROR: io.vertx.core.impl.NoStackTraceThrowable: operation timeout 5
	1493714646144 : ERROR: java.lang.RuntimeException: open circuit 7
	1493714645144 : ERROR: io.vertx.core.impl.NoStackTraceThrowable: operation timeout 6
	1493714647144 : ERROR: java.lang.RuntimeException: open circuit 8
	1493714648144 : ERROR: java.lang.RuntimeException: open circuit 9
	1493714648145 : reset (half-open state)
	1493714650144 : ERROR: java.lang.RuntimeException: open circuit 11
	1493714650146 : Circuit opened
	1493714649144 : ERROR: io.vertx.core.impl.NoStackTraceThrowable: operation timeout 10
	1493714651144 : ERROR: java.lang.RuntimeException: open circuit 12
	1493714652144 : ERROR: java.lang.RuntimeException: open circuit 13
	1493714653143 : ERROR: java.lang.RuntimeException: open circuit 14
	1493714653147 : reset (half-open state)
	1493714654145 : Circuit closed
	1493714654144 : OK: null 15
	1493714655143 : OK: null 16
	1493714656144 : OK: null 17
	1493714657144 : OK: null 18
	1493714658143 : OK: null 19

虽然我们设置了从第12个请求开始，所有的请求都成功，但是由于在第10个请求时，断路器被重新开启，所以第12，13，14个请求都直接由断路器返回了失败，直到第15个请求，断路器才关闭

## 断路器开启时的默认值

     breaker.<String>executeWithFallback(future -> {
        vertx.createHttpClient().getNow(8080, "localhost", "/", response -> {
          if (response.statusCode() != 200) {
            future.fail("HTTP error");
          } else {
            response
                    .exceptionHandler(future::fail)
                    .bodyHandler(buffer -> {
                      future.complete(buffer.toString());
                    });
          }
        });
      }, r -> "Hello").setHandler(ar -> {
        if (ar.succeeded()) {
          System.out.println(ar.result());
        } else {
          System.out.println(ar.cause());
        }
      });

在断路器开启之后，会直接通过`r -> "Hello"`返回

输出

	io.vertx.core.impl.NoStackTraceThrowable: HTTP error
	io.vertx.core.impl.NoStackTraceThrowable: HTTP error
	io.vertx.core.impl.NoStackTraceThrowable: HTTP error
	io.vertx.core.impl.NoStackTraceThrowable: HTTP error
	Circuit opened
	io.vertx.core.impl.NoStackTraceThrowable: HTTP error
	Hello
	Hello
	Hello
	reset (half-open state)
	Circuit opened
	io.vertx.core.impl.NoStackTraceThrowable: HTTP error
	Hello

也可以在创建断路器时指定fallback

    CircuitBreaker breaker = CircuitBreaker.create("my-circuit-breaker", vertx,
                                                   new CircuitBreakerOptions()
                                                           .setMaxFailures(5)
                                                           .setTimeout(1000)
                                                           .setResetTimeout(3000)
    ).fallback(t -> "HELLO")

# Retry
通过setMaxRetries方法设置断路器的重试次数

    CircuitBreaker breaker = CircuitBreaker.create("my-circuit-breaker", vertx,
                                                   new CircuitBreakerOptions()
                                                           .setMaxFailures(5)
                                                           .setTimeout(1000)
                                                           .setResetTimeout(3000)
                                                           .setMaxRetries(3)
    )

输出

	1493716673245 execute:1
	1493716674234 execute:2
	1493716674248 execute:1
	1493716675232 execute:3
	1493716675235 execute:2
	1493716675249 execute:1
	1493716676238 execute:4
	1493716676238 execute:3
	1493716676238 execute:2
	1493716673232 : ERROR: io.vertx.core.impl.NoStackTraceThrowable: operation timeout 1

# Eventbus通知

	  CircuitBreaker breaker = CircuitBreaker.create("my-circuit-breaker", vertx,
	                                                   new CircuitBreakerOptions()
	                                                           .setMaxFailures(5)
	                                                           .setTimeout(2000)
	                                                           .setNotificationAddress(
	                                                                   "vertx.circuit-breaker")
	    );
	
	    vertx.eventBus().consumer("vertx.circuit-breaker", msg -> {
	      System.out.println(msg.body());
	    });

每个通知的事件包括下列属性

- state : 断路器的状态 (OPEN, CLOSED, HALF_OPEN)
- name : 断路器的名称
- failures : 失败次数
- node : 节点标识符 (单机模式下为local)
- resetTimeout、timeout、metricRollingWindow等属性

# Hystrix集成
通过HystrixMetricHandler可以将断路器的状态上报到Hystrix中

如果想使用Hystrix的断路器，可以通过executeBlocking来实现

	HystrixCommand<String> someCommand = getSomeCommandInstance();
	vertx.<String>executeBlocking(
	future -> future.complete(someCommand.execute()),
	ar -> {
	// back on the event loop
	String result = ar.result();
	}
	);

或者

	vertx.runOnContext(v -> {
	Context context = vertx.getOrCreateContext();
	HystrixCommand<String> command = getSomeCommandInstance();
	command.observe().subscribe(result -> {
	context.runOnContext(v2 -> {
	// Back on context (event loop or worker)
	String r = result;
	});
	});
	});

# 实现

CircuitBreaker的创建很简单，就是做了一下基本的参数设置，并用了一个定时器想eventbus广播消息

	  public CircuitBreakerImpl(String name, Vertx vertx, CircuitBreakerOptions options) {
	    Objects.requireNonNull(name);
	    Objects.requireNonNull(vertx);
	    this.vertx = vertx;
	    this.name = name;
	
	    if (options == null) {
	      this.options = new CircuitBreakerOptions();
	    } else {
	      this.options = new CircuitBreakerOptions(options);
	    }
	
	    this.metrics = new CircuitBreakerMetrics(vertx, this, options);
	
	    sendUpdateOnEventBus();
	
	    if (this.options.getNotificationPeriod() > 0) {
	      this.periodicUpdateTask = vertx.setPeriodic(this.options.getNotificationPeriod(), l -> sendUpdateOnEventBus());
	    } else {
	      this.periodicUpdateTask = -1;
	    }
	  }
CircuitBreaker会有一个状态属性，两个计数器：

	  private CircuitBreakerState state = CircuitBreakerState.CLOSED;
	  private long failures = 0;//失败次数
	  private final AtomicInteger passed = new AtomicInteger(); //半开状态下的通过次数

断路器的execute和executeAndReport都是通过executeAndReportWithFallback来实现，这个方法首先会查询断路器的状态：

    CircuitBreakerState currentState;
    synchronized (this) {
      currentState = state;
    }

然后根据状态来执行不同的逻辑

## 关闭

如果断路器是关闭状态，则执行用户的请求

    if (currentState == CircuitBreakerState.CLOSED) {
      if (options.getMaxRetries() > 0) {
        executeOperation(context, command, retryFuture(context, 1, command, operationResult, call), call);
      } else {
        executeOperation(context, command, operationResult, call);
      }
    } 

executeOperation方法，会直接执行用户的方法，并在方法执行完成后修改operationResult的完成状态

    try {
      // We use an intermediate future to avoid the passed future to complete or fail after a timeout.
      Future<T> passedFuture = Future.future();
      passedFuture.setHandler(ar -> {
        context.runOnContext(v -> {
          if (ar.failed()) {
            if (!operationResult.isComplete()) {
              operationResult.fail(ar.cause());
            }
          } else {
            if (!operationResult.isComplete()) {
              operationResult.complete(ar.result());
            }
          }
        });
      });

      operation.handle(passedFuture);
    } catch (Throwable e) {
      context.runOnContext(v -> {
        if (!operationResult.isComplete()) {
          if (call != null) {
            call.error();
          }
          operationResult.fail(e);
        }
      });
    }

同时，executeOperation会开启一个定时器，如果在规定的时间operationResult并没有完成，则经operationResult设为超时失败

    if (options.getTimeout() != -1) {
      vertx.setTimer(options.getTimeout(), (l) -> {
        context.runOnContext(v -> {
          // Check if the operation has not already been completed
          if (!operationResult.isComplete()) {
            if (call != null) {
              call.timeout();
            }
            operationResult.fail("operation timeout");
          }
          // Else  Operation has completed
        });
      });
    }

如果断路器开启了重试机制，会将operationResult封装为一个新的Future，只有在断路器的状态是关闭时才会执行重试，其他状态直接返回失败

在operationResult标记为完成之后,会根据返回的结果更新断路器的状态

    operationResult.setHandler(event -> {
      context.runOnContext(v -> {
        if (event.failed()) {
          incrementFailures();
          call.failed();
          if (options.isFallbackOnFailure()) {
            invokeFallback(event.cause(), userFuture, fallback, call);
          } else {
            userFuture.fail(event.cause());
          }
        } else {
          call.complete();
          reset();
          userFuture.complete(event.result());
        }
        // Else the operation has been canceled because of a time out.
      });

    });

//TODO 

如果是开启状态，则执行fallback或者抛出异常

	else if (currentState == CircuitBreakerState.OPEN) {
      // Fallback immediately
      call.shortCircuited();
      invokeFallback(new RuntimeException("open circuit"), userFuture, fallback, call);
    } 

如果是半开状态，

	 else if (currentState == CircuitBreakerState.HALF_OPEN) {
      if (passed.incrementAndGet() == 1) {
        operationResult.setHandler(event -> {
          if (event.failed()) {
            open();
            if (options.isFallbackOnFailure()) {
              invokeFallback(event.cause(), userFuture, fallback, call);
            } else {
              userFuture.fail(event.cause());
            }
          } else {
            reset();
            userFuture.complete(event.result());
          }
        });
        // Execute the operation
        executeOperation(context, command, operationResult, call);
      } else {
        // Not selected, fallback.
        call.shortCircuited();
        invokeFallback(new RuntimeException("open circuit"), userFuture, fallback, call);
      }
    }