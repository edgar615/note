ArrayBlockingQueue

阻塞队列（BlockingQueue）是一个支持两个附加操作的队列。这两个附加的操作是：在队列为空时，获取元素的线程会等待队列变为非空。当队列满时，存储元素的线程会等待队列可用。阻塞队列常用于生产者和消费者的场景，生产者是往队列里添加元素的线程，消费者是从队列里拿元素的线程。阻塞队列就是生产者存放元素的容器，而消费者也只从容器里拿元素。

阻塞队列提供了四种处理方法:
方法\处理方式 	抛出异常 	返回特殊值 	一直阻塞 	超时退出
插入方法 	add(e) 	offer(e) 	put(e) 	offer(e,time,unit)
移除方法 	remove() 	poll() 	take() 	poll(time,unit)
检查方法 	element() 	peek() 	不可用 	不可用

    抛出异常：是指当阻塞队列满时候，再往队列里插入元素，会抛出IllegalStateException("Queue full")异常。当队列为空时，从队列里获取元素时会抛出NoSuchElementException异常 。
    返回特殊值：插入方法会返回是否成功，成功则返回true。移除方法，则是从队列里拿出一个元素，如果没有则返回null
    一直阻塞：当阻塞队列满时，如果生产者线程往队列里put元素，队列会一直阻塞生产者线程，直到拿到数据，或者响应中断退出。当队列空时，消费者线程试图从队列里take元素，队列也会阻塞消费者线程，直到队列可用。
    超时退出：当阻塞队列满时，队列会阻塞生产者线程一段时间，如果超过一定的时间，生产者线程就会退出。


先看看成员变量有哪些
```
    /** 存放元素的数组 */
    final Object[] items;

	//出队，入队索引，通过这两个索引，在出队，入队的时候不需要移动数组中元素的位置
    /** 下一次出队的索引(take, poll, peek, remove) */
    int takeIndex;

    /** 下一次入队的索引(put,off,add) */
    int putIndex;

    /** 元素的数量 */
    int count;

   /** 锁 */
    final ReentrantLock lock;

    /** 出队的条件 */
    private final Condition notEmpty;

    /** 入队的条件 */
    private final Condition notFull;

    /**
     * 迭代器，不做序列号
     */
    transient Itrs itrs = null;
```

构造方法
```
    public ArrayBlockingQueue(int capacity, boolean fair) {
        if (capacity <= 0)
            throw new IllegalArgumentException();
        //初始化元素数组
        this.items = new Object[capacity];
        //初始化锁和条件
        lock = new ReentrantLock(fair);
        notEmpty = lock.newCondition();
        notFull =  lock.newCondition();
    }
		//使用一个集合初始化队列
        public ArrayBlockingQueue(int capacity, boolean fair,
                              Collection<? extends E> c) {
        this(capacity, fair);

        final ReentrantLock lock = this.lock;
        //同步锁，迭代集合，依次填充到数组中
        lock.lock(); // Lock only for visibility, not mutual exclusion
        try {
            int i = 0;
            try {
                for (E e : c) {
                    checkNotNull(e);
                    items[i++] = e;
                }
            } catch (ArrayIndexOutOfBoundsException ex) {
                throw new IllegalArgumentException();
            }
            //count等于集合的大小
            count = i;
            //如果队列已满,下次入队索引为队首，否则为i
            putIndex = (i == capacity) ? 0 : i;
        } finally {
            lock.unlock();
        }
    }
```

入队
```
	//使用AbstractQueue的add方法，最终调用offer方法
    public boolean add(E e) {
        return super.add(e);
    }
    //AbstractQueue的add方法，入队成功返回true，否则抛出异常
    public boolean add(E e) {
        if (offer(e))
            return true;
        else
            throw new IllegalStateException("Queue full");
    }
    //同步锁入队
    //如果队列已满返回false，否则返回true
    public boolean offer(E e) {
        checkNotNull(e);
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
        //如果队满，返回false，因为enqueue方法在将元素放在数组末尾后，会将putIndex设置为0，所以需要在调用enqueue方法之前判断是否队满
            if (count == items.length)
                return false;
            else {
            //使用enqueue方法入队
                enqueue(e);
                return true;
            }
        } finally {
            lock.unlock();
        }
    }
    
    private void enqueue(E x) {
        // assert lock.getHoldCount() == 1;
        // assert items[putIndex] == null;
        //将元素加到数组的末尾
        final Object[] items = this.items;
        items[putIndex] = x;
        //如果数组已满，将下次入队索引设为0
        if (++putIndex == items.length)
            putIndex = 0;
        //队列长度+1
        count++;
        //唤醒等待的线程
        notEmpty.signal();
    }
    
    //如果队列已满，会休眠线程，等待唤醒
    public void put(E e) throws InterruptedException {
        checkNotNull(e);
        final ReentrantLock lock = this.lock;
        lock.lockInterruptibly();
        try {
            while (count == items.length)
                notFull.await();
            enqueue(e);
        } finally {
            lock.unlock();
        }
    }
    //带超时时间的休眠，如果约定的时间仍没有入队，则返回false
    public boolean offer(E e, long timeout, TimeUnit unit)
        throws InterruptedException {

        checkNotNull(e);
        long nanos = unit.toNanos(timeout);
        final ReentrantLock lock = this.lock;
        lock.lockInterruptibly();
        try {
            while (count == items.length) {
                if (nanos <= 0)
                    return false;
                nanos = notFull.awaitNanos(nanos);
            }
            enqueue(e);
            return true;
        } finally {
            lock.unlock();
        }
    }
```
出队

```
//调用poll方法出队，如果返回null，抛出异常
    public E remove() {
        E x = poll();
        if (x != null)
            return x;
        else
            throw new NoSuchElementException();
    }
//同步锁，出队，如果队列为空，返回null
// 因为dequeue方法在将元素放在数组末尾后，会将putIndex设置为0，所以需要在调用enqueue方法之前判断是否队满
    public E poll() {
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
        	//调用dequeue方法出队
            return (count == 0) ? null : dequeue();
        } finally {
            lock.unlock();
        }
    }

    private E dequeue() {
        // assert lock.getHoldCount() == 1;
        // assert items[takeIndex] != null;
        //移除数组中的原型
        final Object[] items = this.items;
        @SuppressWarnings("unchecked")
        E x = (E) items[takeIndex];
        items[takeIndex] = null;
        //如果删除到了队尾，将takeIndex设为队首
        if (++takeIndex == items.length)
            takeIndex = 0;
        //队列长度-1
        count--;
        if (itrs != null)
            itrs.elementDequeued();
        //唤醒等待线程
        notFull.signal();
        return x;
    }
    
    //如果队列为空，休眠
    public E take() throws InterruptedException {
        final ReentrantLock lock = this.lock;
        lock.lockInterruptibly();
        try {
            while (count == 0)
                notEmpty.await();
            return dequeue();
        } finally {
            lock.unlock();
        }
    }
    
    //带超时时间的休眠，在约定的时间内队列扔为空，返回null
    public E poll(long timeout, TimeUnit unit) throws InterruptedException {
        long nanos = unit.toNanos(timeout);
        final ReentrantLock lock = this.lock;
        lock.lockInterruptibly();
        try {
            while (count == 0) {
                if (nanos <= 0)
                    return null;
                nanos = notEmpty.awaitNanos(nanos);
            }
            return dequeue();
        } finally {
            lock.unlock();
        }
    }

```