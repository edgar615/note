公司定义的消息格式，用于平台间交互

# 消息格式
消息格式为JSON格式，所有字符编码均为UTF-8格式。消息格式分为消息头和消息体。
<table>
<tr>
<th>字段</th>
<th>内容</th>
</tr>
<tr>
<td>head</td>
<td>JSON对象，表示消息头部各种属性</td>
</tr>
<tr>
<td>data</td>
<td>JSON对象，表示消息内容，通常为用户自定义消息内容</td>
</tr>
</table>
	

# 消息头
消息头字段定义了消息的ID，发送信道，接收信道，组信道，消息活动等各种信息。消息头字段是消息的关键内容。

<table>
<tr>
<th>字段</th>
<th>内容</th>
</tr>
<tr>
<td>from</td>
<td>消息发送者私有信道</td>
</tr>
<tr>
<td>to</td>
<td>消息接收者信道</td>
</tr>
<tr>
<td>group</td>
<td>消息发送者组信道</td>
</tr>
<tr>
<td>action</td>
<td>消息活动，用于区分不同的消息类型</td>
</tr>
<tr>
<td>id</td>
<td>消息id，唯一</td>
</tr>
<tr>
<td>timestamp</td>
<td>消息产生时间戳</td>
</tr>
<tr>
<td>sequence</td>
<td>分片消息序列号（可选）分片中第一条序列号为0，最后一条为-1</td>
</tr>
</table>

## 消息活动
消息活动有下面几种类型

- 消息：message
- 请求消息：request
- 请求回应：response
- 抢占式消息：signal
- 抢占式回应：ack
- 链路控制消息：control
- 链路控制回应：answer

# 消息内容
消息内容为JSON格式文本，如果消息中存在二进制数据需要进行base64编码为文本串。消息体的编码格式为UTF-8，对于不同的action，消息内容格式不同。

## 消息 message
单向消息，不需要接收方（或者是消息订阅方）回应

<table>
<tr>
<th>字段</th>
<th>内容</th>
</tr>
<tr>
<td>resource</td>
<td>资源标识（字符串）</td>
</tr>
<tr>
<td>content</td>
<td>请求参数（JSON对象）</td>
</tr>
</table>


## 请求消息 request
请求消息表示消息发送端向接收端发起一个功能请求，消息内容的格式：

<table>
<tr>
<th>字段</th>
<th>内容</th>
</tr>
<tr>
<td>resource</td>
<td>资源标识（字符串），唯一</td>
</tr>
<tr>
<td>operation</td>
<td>操作类型</td>
</tr>
<tr>
<td>content</td>
<td>请求参数（JSON对象）</td>
</tr>
</table>

request可以用来实现RPC调用，用resource表示接口，用operation表示方法，用content表示参数。

**其中operation也可以定义不同的类型，仅供参考，目前并未按照该表格实现**

<table>
<tr>
<th>operation</th>
<th>说明</th>
</tr>
<tr>
<td>create</td>
<td>创建</td>
</tr>
<tr>
<td>delete</td>
<td>删除</td>
</tr>
<tr>
<td>update</td>
<td>更新</td>
</tr>
<tr>
<td>upsert</td>
<td>更新或创建</td>
</tr>
<tr>
<td>find</td>
<td>查找指定对象</td>
</tr>
<tr>
<td>query</td>
<td>查询指定条件的对象</td>
</tr>
<tr>
<td>set</td>
<td>设置</td>
</tr>
<tr>
<td>version</td>
<td>请求服务器消息协议的版本</td>
</tr>
<tr>
<td>自定义字符串</td>
<td>自定义操作</td>
</tr>
</table>


## 请求回应 response
请求回应为请求消息的回应

<table>
<tr>
<th>字段</th>
<th>内容</th>
</tr>
<tr>
<td>result</td>
<td>0-成功 非0-失败</td>
</tr>
<tr>
<td>reply</td>
<td>回应所对应请求的消息ID</td>
</tr>
<tr>
<td>content</td>
<td>回应结果（JSON对象）</td>
</tr>
</table>

如果回应的result是非0，回应的结果应该事先约定好的错误格式

## 抢占式消息 signal

抢占式消息针对集群使用，消息发送者对一个集群发送组信道发送signal消息，集群中的任何可接受的服务应答响应。消息发送者任意选择一个集群实例发送其他消息。

<table>
<tr>
<th>字段</th>
<th>内容</th>
</tr>
<tr>
<td>action</td>
<td>抢占式活动</td>
</tr>
<tr>
<td>content</td>
<td>活动对应的请求数据，需要携带真实的请求有效验证的数据</td>
</tr>
</table>

## 抢占式回应 ack

<table>
<tr>
<th>isolate</th>
<th>0表示组应答，1表示孤立应答（不必等待其他应答）</th>
</tr>
<tr>
<td>priority</td>
<td>0-100之间的优先级（越大优先级越高）</td>
</tr>
<tr>
<td>compute</td>
<td>0-100之间的性能负载数据（越大服务计算负载越高）</td>
</tr>
<tr>
<td>time</td>
<td>0-100之间的时间负载数据（越大表示服务响应越慢）</td>
</tr>
<tr>
<td>io</td>
<td>0-100之间的IO负载数据（越大表示IO越慢）</td>
</tr>
<tr>
<td>payload</td>
<td>0-100之间的综合负载数据（越大表示服务负载越高）</td>
</tr>
</table>


## 链路控制消息（control）
链路控制消息表示信道间的链路参数设置。

<table>
<tr>
<th>字段</th>
<th>内容</th>
</tr>
<tr>
<td>command</td>
<td>控制命令</td>
</tr>
<tr>
<td>action</td>
<td>命令针对的活动（all表示全部活动）</td>
</tr>
<tr>
<td>content</td>
<td>控制参数</td>
</tr>
</table>


控制命令及参数如下表所示：

<table>
<tr>
<th>命令</th>
<th>参数</th>
<th>说明</th>
</tr>
<tr>
<td>timeout</td>
<td>时间（毫秒）</td>
<td>-1表示无超时控制	超时时间设置</td>
</tr>
<tr>
<td>retransmit</td>
<td>次数</td>
<td>-1表示不重传	重传次数设置</td>
</tr>
<tr>
<td>split</td>
<td>拆分后信道数目</td>
<td>将一个信道拆分为多个信道</td>
</tr>
<tr>
<td>join</td>
<td>合并后信道的名称</td>
<td>将多个信道和并为一个信道</td>
</tr>
<tr>
<td>fragment</td>
<td>分片阈值(单位KB)</td>
<td>超过阀值后消息将分片</td>
</tr>
</table>
