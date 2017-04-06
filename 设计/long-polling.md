http://blog.csdn.net/moshengtan/article/details/12093005

# 轮询
客户端定时向服务器发送Ajax请求，服务器接到请求后马上返回响应信息并关闭连接。
优点：后端程序编写比较容易。
缺点：请求中有大半是无用，浪费带宽和服务器资源。实例：适于小型应用。

# 长轮询
客户端向服务器发送Ajax请求，服务器接到请求后hold住连接，直到有新消息才返回响应信息并关闭连接，客户端处理完响应信息后再向服务器发送新的请求。
优点：在无消息的情况下不会频繁的请求。
缺点：服务器hold连接会消耗资源。实例：WebQQ、Hi网页版、Facebook IM

![](http://s9.51cto.com/wyfs01/M02/2F/EF/wKioJlJIG4jiJ2xnAABdwFfNoxc793.jpg) 