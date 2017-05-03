Context

http://vertx.io/blog/an-introduction-to-the-vert-x-context-object/

当执行一个vert.x的handler，或者verticle的start、stop方法时，方法的执行会与一个特定的context关联。一般这个context是一个event-loop类型的context，它会与一个event-loop的线程关联。context会被传播，当一个handler被一个特定的context创建之后，这个handler的执行会被同一个context执行。例如：如果verticle的start方法设置了一些eventbus的handler，那么这些handler会在同一个context里执行，这个context与verticle的start方法也是同一个context.

当我们通过deployVerticle方法部署一个Verticle的时候，会为这个Verticle分配一个Context

	  public void deployVerticle(String identifier,
	                             DeploymentOptions options,
	                             Handler<AsyncResult<String>> completionHandler) {
	    ContextImpl callingContext = vertx.getOrCreateContext();
	    ClassLoader cl = getClassLoader(options, callingContext);
	    doDeployVerticle(identifier, generateDeploymentID(), options, callingContext, callingContext, cl, completionHandler);
	  }

所有在同一个context中允许的handler都会在同一个eventloop线程中运行。这样如果一个Verticle是唯一一个访问一个临界资源的Verticle，那么这个临界资源置只会被一个线程访问，因此不需要使用同步方法连限制资源的访问


用法

    vertx.runOnContext(v -> {
      //todo
    });

# 实现

	Context
		-ContextInternal
			-ContextImpl
				-EventLoopContext
				-WorkerContext
					-MultiThreadedWorkerContext

根据Context的继承关系，可以看出，有三种类型的Context

- EventLoopContext
- WorkerContext
- MultiThreadedWorkerContext

## Context接口
Context接口定义了一些基本的方法

判断context类型的方法
	
	boolean isEventLoopContext();
	
	boolean isWorkerContext();
	
	boolean isMultiThreadedWorkerContext();

共享数据的方法

	<T> T get(String key);
	
	void put(String key, Object value);
	
	boolean remove(String key);

异常处理

	Context exceptionHandler(@Nullable Handler<Throwable> handler);
	
	Handler<Throwable> exceptionHandler();

关闭钩子

	void addCloseHook(Closeable hook);
	
	void removeCloseHook(Closeable hook);

Verticle部署相关

	String deploymentID();
	
	JsonObject config();

执行handler

	void runOnContext(Handler<Void> action);
	
	<T> void executeBlocking(Handler<Future<T>> blockingCodeHandler, boolean ordered, Handler<AsyncResult<T>> resultHandler);
	
	<T> void executeBlocking(Handler<Future<T>> blockingCodeHandler, Handler<AsyncResult<T>> resultHandler);

## ContextInternal
ContextInternal接口增加了一些内部方法，这些方法不会暴露给开发者

  //返回Context使用的Netty EventLoop
  EventLoop nettyEventLoop();

  <T> void executeBlocking(Handler<Future<T>> blockingCodeHandler, TaskQueue queue, Handler<AsyncResult<T>> resultHandler);

  /**
   * Execute the context task and switch on this context if necessary, this also associates the
   * current thread with the current context so {@link Vertx#currentContext()} returns this context.<p/>
   *
   * The caller thread should be the the event loop thread of this context.<p/>
   *
   * Any exception thrown from the {@literal stack} will be reported on this context.
   *
   * @param task the task to execute
   */
  void executeFromIO(ContextTask task);

## ContextImpl
ContextImpl封装了Context的基本逻辑，它有几个抽象方法需要子类实现

	  protected abstract void executeAsync(Handler<Void> task);
	
	  @Override
	  public abstract boolean isEventLoopContext();
	
	  @Override
	  public abstract boolean isMultiThreadedWorkerContext();
	
	  protected abstract void checkCorrectThread();

## EventLoopContext
最通用的类型，它的executeAsync直接将handler交由Eventloop线程执行

	public void executeAsync(Handler<Void> task) {
		// No metrics, we are on the event loop.
		nettyEventLoop().execute(wrapTask(null, task, true, null));
	}

它的checkCorrectThread方法会检查线程是否是VertxThread，并且线程必须和context的线程相同

	@Override
	protected void checkCorrectThread() {
		Thread current = Thread.currentThread();
		if (!(current instanceof VertxThread)) {
		  throw new IllegalStateException("Expected to be on Vert.x thread, but actually on: " + current);
		} else if (contextThread != null && current != contextThread) {
		  throw new IllegalStateException("Event delivered on unexpected thread " + current + " expected: " + contextThread);
		}
	}

## WorkerContext
使用worker pool线程池运行，所有的任务按顺序执行

它的executeAsync和executeFromIO方法会将任务放在一个队列(TaskQueue)中执行

	@Override
	public void executeAsync(Handler<Void> task) {
		orderedTasks.execute(wrapTask(null, task, true, workerPool.metrics()), workerPool.executor());
	}

	@Override
	public void executeFromIO(ContextTask task) {
		orderedTasks.execute(wrapTask(task, null, true, workerPool.metrics()), workerPool.executor());
	}

## MultiThreadedWorkerContext

使用worker pool线程池运行，所有的任务并发执行

它的executeAsync方法会将任务直接交由工作线程池执行

	@Override
	public void executeAsync(Handler<Void> task) {
		workerPool.executor().execute(wrapTask(null, task, false, workerPool.metrics()));
	}