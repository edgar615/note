Stream

Stream是vert.x提供的对对象写入和读取的接口

在Vert.x里，写是立即写入，并且再内部队列中排队．因此如果对对象的写入速度比它将数据实际写到底层资源对速度快，那么写队列可以无限增长，最终会导致内存耗尽．可以通过Vert.x提供的某些简单的流量控制来解决这个问题．

所有能够写入的对象都可以实现WriteStream，所有能够读取的对象都可以实现ReadStream．

# 示例　NetSocket 
ＮetSocket实现了ReadStream和WriteStream接口

	interface NetSocket extends ReadStream<Buffer>, WriteStream<Buffer>

下面来演示一个从socket读取和写入数据的功能

## 最简单的实现

	    vertx.createNetServer().connectHandler(socket -> {
	      socket.handler(buffer -> {
		socket.write(buffer);
	      });
	    }).listen(1234, ar -> {
	      if (ar.succeeded()) {
		System.out.println("Echo server is now listening");
	      } else {

	      }
	    });
	    
上述例子有一个问题，如果从socket中读取数据速度比写回socket的速度要快，它会在NetSocket上建立写入队列，总在耗尽内存．这种情况是可能发生的，例如如果socket另一端的client读取数据对速度不够快，将会将连接上对压力往后推．

因为NetSocket实现了WriteStream，我们可以再写入数据之前判断WriteStream是否已经满了．

      socket.handler(buffer -> {
        if (!socket.writeQueueFull()) {
          socket.write(buffer);
        }
      });

上面例子不会写入内存，但是如果写队列已经满类，最终会丢失数据．而我们真正想做的是在写队列满对时候暂停写入．

      socket.handler(buffer -> {
        socket.write(buffer);
        if (socket.writeQueueFull()) {
          socket.pause();
        }
      });

之后，我们还需要取消暂停

      socket.handler(buffer -> {
        socket.write(buffer);
        if (socket.writeQueueFull()) {
          socket.pause();
          socket.drainHandler(v -> socket.resume());
        }
      });
      
在写队列可以写入数据的时候，drainHandler会恢复NetSocket，来允许新数据的读取．

Vert.x提供了一个辅助函数用来完成上诉功能

      socket.handler(buffer -> {
        Pump.pump(socket, socket).start();
      });

## ReadStream