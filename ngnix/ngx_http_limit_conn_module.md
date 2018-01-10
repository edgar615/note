http://www.ttlsa.com/nginx/nginx-limited-connection-number-ngx_http_limit_conn_module-module/

http://www.dnsdizhi.com/post-189.html

### 前言

我们经常会遇到这种情况，服务器流量异常，负载过大等等。对于大流量恶意的攻击访问，会带来带宽的浪费，服务器压力，影响业务，往往考虑对同一个ip的连接数，并发数进行限制。下面说说ngx_http_limit_conn_module 模块来实现该需求。该模块可以根据定义的键来限制每个键值的连接数，如同一个IP来源的连接数。并不是所有的连接都会被该模块计数，只有那些正在被处理的请求（这些请求的头信息已被完全读入）所在的连接才会被计数。

### ngx_http_limit_conn_module指令解释

limit_conn_zone
语法: limit_conn_zone $variable zone=name:size;
默认值: none
配置段: http
该指令描述会话状态存储区域。键的状态中保存了当前连接数，键的值可以是特定变量的任何非空值（空值将不会被考虑）。$variable定义键，zone=name定义区域名称，后面的limit_conn指令会用到的。size定义各个键共享内存空间大小。如：
```
limit_conn_zone $binary_remote_addr zone=addr:10m;
```

注释：客户端的IP地址作为键。注意，这里使用的是$binary_remote_addr变量，而不是$remote_addr变量。
$remote_addr变量的长度为7字节到15字节，而存储状态在32位平台中占用32字节或64字节，在64位平台中占用64字节。
$binary_remote_addr变量的长度是固定的4字节，存储状态在32位平台中占用32字节或64字节，在64位平台中占用64字节。
1M共享空间可以保存3.2万个32位的状态，1.6万个64位的状态。
如果共享内存空间被耗尽，服务器将会对后续所有的请求返回 503 (Service Temporarily Unavailable) 错误。
limit_zone 指令和limit_conn_zone指令同等意思，已经被弃用，就不再做说明了。

limit_conn_log_level
语法：limit_conn_log_level info | notice | warn | error
默认值：error
配置段：http, server, location
当达到最大限制连接数后，记录日志的等级。

limit_conn
语法：limit_conn zone_name number
默认值：none
配置段：http, server, location
指定每个给定键值的最大同时连接数，当超过这个数字时被返回503 (Service Temporarily Unavailable)错误。如：

```
limit_conn_zone $binary_remote_addr zone=addr:10m;
server {
    location /www.ttlsa.com/ {
        limit_conn addr 1;
    }
}
```

同一IP同一时间只允许有一个连接。
当多个 limit_conn 指令被配置时，所有的连接数限制都会生效。比如，下面配置不仅会限制单一IP来源的连接数，同时也会限制单一虚拟服务器的总连接数：
```
limit_conn_zone $binary_remote_addr zone=perip:10m;
limit_conn_zone $server_name zone=perserver:10m;
server {
    limit_conn perip 10;
    limit_conn perserver 100;
}
```

**limit_conn指令可以从上级继承下来。**

limit_conn_status
语法: limit_conn_status code;
默认值: limit_conn_status 503;
配置段: http, server, location
该指定在1.3.15版本引入的。指定当超过限制时，返回的状态码。默认是503。

limit_rate
语法：limit_rate rate
默认值：0
配置段：http, server, location, if in location
对每个连接的速率限制。参数rate的单位是字节/秒，设置为0将关闭限速。 按连接限速而不是按IP限制，因此如果某个客户端同时开启了两个连接，那么客户端的整体速率是这条指令设置值的2倍。

> limit_rate 100k; //是对每个连接限速100k。这里是对连接限速，而不是对IP限速！如果一个IP允许两个并发连接，那么这个IP就是限速limit_rate * 2

​	

### 完整实例配置
```
http {
	limit_conn_zone $binary_remote_addr zone=limit:10m;
	limit_conn_log_level info;

	server {
		location  ^~ /download/ {  
			limit_conn limit 4;
			limit_rate 200k;
			alias /data/www.ttlsa.com/download/;
                }
	}
}
```

### 注意事项

ngx_http_limit_conn_module 模块虽说可以解决当前面临的并发问题，但是会引入另外一些问题的。如前端如果有做LVS或反代，而我们后端启用了该模块功能，那不是非常多503错误了？这样的话，可以在前端启用该模块，要么就是设置白名单