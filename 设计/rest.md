参考github的API设计的Rest API文档，公司所有的API都应该遵循这个方案

https://developer.github.com/v3
https://github.com/bolasblack/http-api-guide#user-content-http-%E5%8D%8F%E8%AE%AE

# HTTP动词

- GET（SELECT）：从服务器取出资源（一项或多项），完成请求后返回状态码 200 OK；完成请求后需要返回被请求的资源详细信息。
- POST（CREATE）：在服务器创建一个资源，创建完成后返回状态码 201 Created；完成请求后需要返回被创建的资源详细信息
- PUT（UPDATE）：用于完整的替换资源或者创建指定身份的资源，比如创建 id 为 123 的某个资源, 如果是创建了资源，则返回 201 Created;如果是替换了资源，则返回 202 Accepted;完成请求后需要返回被修改的资源详细信息.**对于没有修改属性的请求，请确保Content-Length的请求头设置为0**
- PATCH（UPDATE）：使用部分JSON数据更新资源的部分属性。例如，发行资源具有标题和主体属性。补丁请求可以接受一个或多个属性来更新资源。
- DELETE（DELETE）：从服务器删除某个资源。完成请求后返回状态码 204 No Content
- HEAD：用于只获取请求某个资源返回的头信息。
- OPTIONS：用于获取资源支持的所有 HTTP 方法。

# 状态码
## 请求成功

- 200 OK : 请求执行成功并返回相应数据，如 GET 成功
- 201 Created : 对象创建成功并返回相应资源数据，如 POST 成功；创建完成后响应头中应该携带头标 Location ，指向新建资源的地址
- 202 Accepted : 接受请求，但无法立即完成创建行为，比如其中涉及到一个需要花费若干小时才能完成的任务。返回的实体中应该包含当前状态的信息，以及指向处理状态监视器或状态预测的指针，以便客户端能够获取最新状态。
- 204 No Content : 请求执行成功，不返回相应资源数据，如 PATCH ， DELETE 成功

## 重定向
重定向的新地址都需要在响应头 Location 中返回

- 301 Moved Permanently : 被请求的资源已永久移动到新位置
- 302 Found : 请求的资源现在临时从不同的 URI 响应请求
- 303 See Other : 对应当前请求的响应可以在另一个 URI 上被找到，客户端应该使用 GET 方法进行请求
- 307 Temporary Redirect : 对应当前请求的响应可以在另一个 URI 上被找到，客户端应该保持原有的请求方法进行请求

## 条件请求

- 304 Not Modified : 资源自从上次请求后没有再次发生变化，主要使用场景在于实现数据缓存
- 409 Conflict : 请求操作和资源的当前状态存在冲突。主要使用场景在于实现并发控制
- 412 Precondition Failed : 服务器在验证在请求的头字段中给出先决条件时，没能满足其中的一个或多个。主要使用场景在于实现并发控制

## 客户端错误
- 400 Bad Request : 请求体包含语法错误
- 401 Unauthorized : 需要验证用户身份，如果服务器就算是身份验证后也不允许客户访问资源，应该响应 403 Forbidden 。如果请求里有 Authorization 头，那么必须返回一个 WWW-Authenticate 头
- 403 Forbidden : 服务器拒绝执行
- 404 Not Found : 找不到目标资源
- 405 Method Not Allowed : 不允许执行目标方法，响应中应该带有 Allow 头，内容为对该资源有效的 HTTP 方法
- 406 Not Acceptable : 服务器不支持客户端请求的内容格式，但响应里会包含服务端能够给出的格式的数据，并在 Content-Type 中声明格式名称
- 410 Gone : 被请求的资源已被删除，只有在确定了这种情况是永久性的时候才可以使用，否则建议使用 - 404 Not Found
- 413 Payload Too Large : POST 或者 PUT 请求的消息实体过大
- 415 Unsupported Media Type : 服务器不支持请求中提交的数据的格式
- 422 Unprocessable Entity : 请求格式正确，但是由于含有语义错误，无法响应
- 428 Precondition Required : 要求先决条件，如果想要请求能成功必须满足一些预设的条件

服务端错误

- 500 Internal Server Error : 服务器遇到了一个未曾预料的状况，导致了它无法完成对请求的处理。
- 501 Not Implemented : 服务器不支持当前请求所需要的某个功能。
- 502 Bad Gateway : 作为网关或者代理工作的服务器尝试执行请求时，从上游服务器接收到无效的响应。
- 503 Service Unavailable : 由于临时的服务器维护或者过载，服务器当前无法处理请求。这个状况是临时的，并且将在一段时间以后恢复。如果能够预计延迟时间，那么响应中可以包含一个 Retry-After 头用以标明这个延迟时间（内容可以为数字，单位为秒；或者是一个 HTTP 协议指定的时间格式）。如果没有给出这个 Retry-After 信息，那么客户端应当以处理 500 响应的方式处理它。

501 与 405 的区别是：405 是表示服务端不允许客户端这么做，501 是表示客户端或许可以这么做，但服务端还没有实现这个功能

# 身份认证

用户登录后会返回一个token，如：

	eyJ0eXAiOiJKV1QiLA0KICJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJqb2UiLA0KICJleHAiOjEzMDA4MTkzODAsDQogImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlfQ.dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk

服务调用方拿到token之后，在调用要求安全认证的接口时，需要在请求头上加上Authorization: Bearer <token>，否则服务端会将请求视为非法请求。


# 日期显示
日期格式采用ISO 8601建议的格式
https://zh.wikipedia.org/wiki/ISO_8601

年由4位数字组成YYYY，月、日用两位数字表示：MM、DD。只使用数字为基本格式。使用短横线"-"间隔开年、月、日为扩展格式。

## 日期
年为4位数，月为2位数，月中的日为2位数，例如，日期（2017年4月27日）可表示为**2017-04-27 **

## 时间
只使用数字为基本格式。使用冒号":"间隔开小时、分、秒的为扩展格式。小时、分和秒都用2位数表示。

对于当地时间15时27分46秒，表示为**15:27:46**

对协调世界时的时间最后加一个大写字母Z,如UTC时间下午2点30分5秒表示为**14:30:05Z**

其他时区用实际时间加时差表示，当时的UTC+8时间表示为**22:30:05+08:00或223005+0800，也可以简化成223005+08**

## 日期和时间的组合
日期和时间合并表示时，要在时间前面加一大写字母T，如要表示北京时间2004年5月3日下午5点30分8秒，可以写成**2004-05-03T17:30:08+08:00**

## 时间段
如果要表示某一作为一段时间间隔，前面加一大写字母P，但时间段后都要加上相应的代表时间的大写字母。如在一年三个月五天六小时七分三十秒内，可以写成**P1Y3M5DT6H7M30S**。

## 时间间隔
从一个时间开始到另一个时间结束，或者从一个时间开始持续一个时间间隔，要在前后两个时间（或时间间隔）之间放置斜线符"/"。格式为：

	<start>/<end>
	<start>/<duration>
	<duration>/<end>
	<duration>

例如**1985-04-12/1986-01-01**，**1985-04-12/P6M**, **2007-03-01T13:00:00Z/2008-05-11T15:30:00Z**

## 循环时间

前面加上一大写字母R，格式为：

    R【循环次数】【/开始时间】/时间间隔【/结束时间】

如要从2004年5月6日北京时间下午1点起时间间隔半年零5天3小时循环，且循环3次，可以表示为R3/2004-05-06T13:00:00+08:00/P0Y6M5DT3H0M0S。

如以1年2个月为循环间隔，无限次循环，最后循环终止于2025年1月1日，可表示为R/P1Y2M/20250101

# 分页

# 限流

# 响应头

x-request-id : 1eda8723-5b94-48e5-bb35-ecd7b10490c3
x-response-time : 15ms
x-server-time: 2017-04-27T18:19:28+08:00

# 参数
许多API都有一些可选参数。对于GET请求，在路径中未包含的参数都可以作为HTTP查询字符串参数传递：

	curl -i "https://api.github.com/repos/vmg/redcarpet/issues?state=closed"

对于POST, PATCH, PUT, 和DELETE请求，URL中不包含的参数应该被编码为JSON，通过请求体传递，请求头的Content-Type 应该指定为 'application/json':

	curl -i -u username -d '{"scopes":["public_repo"]}' https://api.github.com/authorizations


# 查询
## 参数
<table>
<tr>
<th>名称</th>
<th>类型</th>
<th>描述</th>
</tr>
<tr>
<td>q</td>
<td>string</td>
<td>查询条件</td>
</tr>
<tr>
<td>sort</td>
<td>string</td>
<td>排序字段</td>
</tr>
<tr>
<td>order</td>
<td>string</td>
<td>排序顺序，默认值desc</td>
</tr>
</table>

## 查询条件q的格式

- foo:bar foo=bar的条件
- stars>10 
- stars:>=10
- created:>=2012-04-30
- created:>2012-04-29
- stars:"10 .. *"
- created:"2012-04-30 .. * "
- stars:"10 .. 50"
- created:"2012-04-30 .. 2012-07-04"
- stars:"<10"
- stars:"<= 9"
- created:<2012-07-05
- created:<=2012-07-04
- stars:"* .. 10"
- created:"* .. 2012-04-30"
- stars:"1 .. 10"
- created:"2012-04-30 .. 2012-07-04"
- -language:javascript

多个条件用+组合