http://ifeve.com/leader-follower-thread-model/amp/

# Leader-follower线程模型

![img](https://upload-images.jianshu.io/upload_images/5879294-d958e4cedb1a737d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/578)

image.png

- 在Leader-follower线程模型中每个线程有三种模式，leader,follower, processing。
- 在Leader-follower线程模型一开始会创建一个线程池，并且会选取一个线程作为leader线程，leader线程负责监听网络请求，其它线程为follower处于waiting状态，当leader线程接受到一个请求后，会释放自己作为leader的权利，然后从follower线程中选择一个线程进行激活，然后激活的线程被选择为新的leader线程作为服务监听，然后老的leader则负责处理自己接受到的请求（现在老的leader线程状态变为了processing），处理完成后，状态从processing转换为。follower

可知这种模式下接受请求和进行处理使用的是同一个线程，这避免了线程上下文切换和线程通讯数据拷贝。

L/F多线程模型，共6个关键点：

（1）线程有3种状态：领导leading，处理processing，追随following；

（2）假设共N个线程，其中只有1个leading线程（等待任务），x个processing线程（处理），余下有N-1-x个following线程（空闲）；

（3）有一把锁，谁抢到就是leading；

（4）事件/任务来到时，leading线程会对其进行处理，从而转化为processing状态，处理完成之后，又转变为following；

（5）丢失leading后，following会尝试抢锁，抢到则变为leading，否则保持following；

（6）following不干事，就是抢锁，力图成为leading；