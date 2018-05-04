## auto.offset.reset

**earliest** 

 当各分区下有已提交的offset时，从提交的offset开始消费；无提交的offset时，从头开始消费 

  **latest** 

  当各分区下有已提交的offset时，从提交的offset开始消费；无提交的offset时，消费新产生的该分区下的数据 

  **none**  

  topic各分区都存在已提交的offset时，从offset后开始消费；只要有一个分区不存在已提交的offset，则抛出异常



## max.poll.records

 变量限制了每次 poll 的消息条数，不管 consumer 对应多少个 partition，从所有 partition 拉取到的消息条数总和不会超过 `maxPollRecords`

默认值500

## max.partition.fetch.bytes

限制了 consumer 每次从每个 partition 拉取的数据量

在满足max.partition.fetch.bytes限制的情况下，假如fetch到了100个record，放到本地缓存后，由于max.poll.records限制每次只能poll出15个record。那么KafkaConsumer就需要执行7次才能将这一次通过网络发起的fetch请求所fetch到的这100个record消费完毕。其中前6次是每次pool中15个record，最后一次是poll出10个record。

## heartbeat.interval.ms

心跳间隔。心跳是在 consumer 与 coordinator 之间进行的。心跳是确定 consumer 存活，加入或者退出 group 的有效手段。这个值必须设置的小于 session.timeout.ms，因为：当 consumer 由于某种原因不能发 heartbeat 到 coordinator 时，并且时间超过 session.timeout.ms 时，就会认为该 consumer 已退出，它所订阅的 partition 会分配到同一 group 内的其它的 consumer 上

默认值：3000 (3s)，通常设置的值要低于session.timeout.ms的1/3。

## session.timeout.ms

consumer session 过期时间。如果超时时间范围内，没有收到消费者的心跳，broker 会把这个消费者置为失效，并触发消费者负载均衡。因为只有在调用 poll 方法时才会发送心跳，更大的 session 超时时间允许消费者在 poll 循环周期内处理消息内容，尽管这会有花费更长时间检测失效的代价。如果想控制消费者处理消息的时间，

默认值：10000 (10s)，这个值必须设置在 broker configuration 中的 group.min.session.timeout.ms 与 group.max.session.timeout.ms 之间。