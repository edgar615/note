# HealthCheck

#　快速入门

	HealthChecks hc = HealthChecks.create(vertx);

	hc.register("my-procedure", future -> future.complete(Status.OK()));

	HealthCheckHandler healthCheckHandler = HealthCheckHandler.createWithHealthChecks(hc);

	Router router = Router.router(vertx);
	router.get("/ping").handler(healthCheckHandler);

	vertx.createHttpServer()
	.requestHandler(router::accept)
	.listen(8080);
	
上面对例子首先创建类一个HealthChecks对象，这个对象用来注册和注销应用．
接着创建一个HealthCheckHandler对象绑定到`/ping`这个地址上．

	curl localhost:8080/ping
	{"checks":[{"id":"my-procedure","status":"UP"}],"outcome":"UP"}
	
我们也可以通过HealthCheckHandler在任何时候来注册和注销应用

    HealthCheckHandler healthCheckHandler = HealthCheckHandler.create(vertx);

	Router router = Router.router(vertx);
	router.get("/health").handler(healthCheckHandler);

	healthCheckHandler.register("my-procedure", future -> {
	future.complete(Status.OK());
	});
	
测试

	curl localhost:8080/health
	{"checks":[{"id":"my-procedure","status":"UP"}],"outcome":"UP"}

## Procedure
Procedure是一个通过某些方面来推断当前系统是否健康的函数．它只报告一个状态(Status)，用来表明健康检查是成功还是失败，这个函数不能被阻塞．

注册一个Procedure时，我们需要提供一个名称，和一个执行健康检查的函数

	HealthChecks register(String name, Handler<Future<Status>> procedure)

- 如果future失败，健康状态被认为KO
- 如果future成功，但是没有任何状态，健康状态被认为OK
- 如果future成功，状态被标记为OK，健康状态被认为OK
- 如果future成功，状态被标记为KO，健康状态被认为KO

Status也可以包含一些额外的信息

	healthCheckHandler.register("my-procedure-name", future -> {
	future.complete(Status.OK(new JsonObject().put("available-memory", "2mb")));
	});

	healthCheckHandler.register("my-second-procedure-name", future -> {
	future.complete(Status.KO(new JsonObject().put("load", 99)));
	});

输出

	 curl localhost:8080/health
	{
	    "checks": [
		{
		    "id": "my-procedure-name", 
		    "status": "UP", 
		    "data": {
		        "available-memory": "2mb"
		    }
		}, 
		{
		    "id": "my-second-procedure-name", 
		    "status": "DOWN", 
		    "data": {
		        "load": 99
		    }
		}
	    ], 
	    "outcome": "DOWN"
	}	
	
Procedures也可以用组来划分，将procedure的名字按照树型结构构造

	curl localhost:8080/health
	{
	    "checks": [
		{
		    "id": "a-group", 
		    "status": "DOWN", 
		    "checks": [
		        {
		            "id": "a-second-group", 
		            "status": "DOWN", 
		            "checks": [
		                {
		                    "id": "my-second-procedure-name", 
		                    "status": "DOWN"
		                }
		            ]
		        }, 
		        {
		            "id": "my-procedure-name", 
		            "status": "UP"
		        }
		    ]
		}
	    ], 
	    "outcome": "DOWN"
	}
	
## HTTP响应和JSON格式化
如果没有注册procedure，HTTP响应为204 - NO CONTENT,表明系统的状态是UP但是没有procedure被执行．响应不包含任何有效载荷．

	curl -i http://localhost:8080/health
	HTTP/1.1 204 No Content
	Content-Type: application/json;charset=UTF-8
	Content-Length: 0

如果注册了procedure，可能对响应码：

- 200 : Everything is fine
- 503 : At least one procedure has reported a non-healthy state
- 500 : One procedure has thrown an error or has not reported a status in time

200

	curl -i http://localhost:8080/health
	HTTP/1.1 200 OK
	Content-Type: application/json;charset=UTF-8
	Content-Length: 63

	{"checks":[{"id":"my-procedure","status":"UP"}],"outcome":"UP"}
	
	curl -i http://localhost:8080/health
	HTTP/1.1 200 OK
	Content-Type: application/json;charset=UTF-8
	Content-Length: 207

	{
	    "checks": [
		{
		    "id": "a-group", 
		    "status": "UP", 
		    "checks": [
		        {
		            "id": "a-second-group", 
		            "status": "UP", 
		            "checks": [
		                {
		                    "id": "my-second-procedure-name", 
		                    "status": "UP"
		                }
		            ]
		        }, 
		        {
		            "id": "my-procedure-name", 
		            "status": "UP"
		        }
		    ]
		}
	    ], 
	    "outcome": "UP"
	}
	
503

	curl -i http://localhost:8080/health
	HTTP/1.1 503 Service Unavailable
	Content-Type: application/json;charset=UTF-8
	Content-Length: 215

	{
	    "checks": [
		{
		    "id": "a-group", 
		    "status": "DOWN", 
		    "checks": [
		        {
		            "id": "a-second-group", 
		            "status": "DOWN", 
		            "checks": [
		                {
		                    "id": "my-second-procedure-name", 
		                    "status": "DOWN"
		                }
		            ]
		        }, 
		        {
		            "id": "my-procedure-name", 
		            "status": "UP"
		        }
		    ]
		}
	    ], 
	    "outcome": "DOWN"
	}

500

	curl -i http://localhost:8080/health
	HTTP/1.1 500 Internal Server Error
	Content-Type: application/json;charset=UTF-8
	Content-Length: 279

	{
	    "checks": [
		{
		    "id": "a-group", 
		    "status": "DOWN", 
		    "checks": [
		        {
		            "id": "a-second-group", 
		            "status": "DOWN", 
		            "checks": [
		                {
		                    "id": "my-second-procedure-name", 
		                    "status": "DOWN"
		                }
		            ]
		        }, 
		        {
		            "id": "my-procedure-name", 
		            "status": "DOWN", 
		            "data": {
		                "procedure-execution-failure": true, 
		                "cause": "Timeout"
		            }
		        }
		    ]
		}
	    ], 
	    "outcome": "DOWN"
	}

outcome属性表明健康检查对总体结果UP或者DOWN

checks属性表明所有procedure对检查结果

如果一个procedure抛出一个异常，报告了一个异常，JSON结果会再data属性里说明异常信息

	curl -i http://localhost:8080/health
	HTTP/1.1 503 Service Unavailable
	Content-Type: application/json;charset=UTF-8
	Content-Length: 252

	{
	    "checks": [
		{
		    "id": "a-group", 
		    "status": "DOWN", 
		    "checks": [
		        {
		            "id": "a-second-group", 
		            "status": "DOWN", 
		            "checks": [
		                {
		                    "id": "my-second-procedure-name", 
		                    "status": "DOWN"
		                }
		            ]
		        }, 
		        {
		            "id": "my-procedure-name", 
		            "status": "DOWN", 
		            "data": {
		                "cause": "undefined error"
		            }
		        }
		    ]
		}
	    ], 
	    "outcome": "DOWN"
	}

如果procedure在检查报告之前超时，会显示Timeout

	curl -i http://localhost:8080/health
	HTTP/1.1 500 Internal Server Error
	Content-Type: application/json;charset=UTF-8
	Content-Length: 279

	{
	    "checks": [
		{
		    "id": "a-group", 
		    "status": "DOWN", 
		    "checks": [
		        {
		            "id": "a-second-group", 
		            "status": "DOWN", 
		            "checks": [
		                {
		                    "id": "my-second-procedure-name", 
		                    "status": "DOWN"
		                }
		            ]
		        }, 
		        {
		            "id": "my-procedure-name", 
		            "status": "DOWN", 
		            "data": {
		                "procedure-execution-failure": true, 
		                "cause": "Timeout"
		            }
		        }
		    ]
		}
	    ], 
	    "outcome": "DOWN"
	}
	
## JDBC健康检查

	    healthCheckHandler.register("datasource", future -> {
	      jdbcClient.getConnection(ar -> {
		if (ar.succeeded()) {
		  ar.result().close();
		  future.complete(Status.OK());
		} else {
		  future.fail(ar.cause());
		}
	      });
	    });
	    
输出

	curl -i http://localhost:8080/health
	HTTP/1.1 200 OK
	Content-Type: application/json;charset=UTF-8
	Content-Length: 61

	{"checks":[{"id":"datasource","status":"UP"}],"outcome":"UP"}

## Service availability

	handler.register("my-service",
	  future -> HttpEndpoint.getClient(discovery,
	    (rec) -> "my-service".equals(rec.getName()),
	    client -> {
	      if (client.failed()) {
		future.fail(client.cause());
	      } else {
		client.result().close();
		future.complete(Status.OK());
	      }
	    }));

## Event bus

	handler.register("receiver",
	  future ->
	    vertx.eventBus().send("health", "ping", response -> {
	      if (response.succeeded()) {
		future.complete(Status.OK());
	      } else {
		future.complete(Status.KO());
	      }
	    })
	);
	
## Authentication安全验证
AuthProvider用来校验web请求的权限

## 将健康检查暴露到eventbus

	HealthChecks hc = HealthChecks.create(vertx);

	hc.register("my-procedure", future -> future.complete(Status.OK()));

	vertx.eventBus().consumer("health",
		message -> hc.invoke(message::reply));

# 原理
## Procedure

	public interface Procedure {

	  void check(Handler<JsonObject> resultHandler);

	}

Procedure的check方法用于检查应用的健康状态

## DefaultProcedure

	  @Override
	  public void check(Handler<JsonObject> resultHandler) {
	    Future<Status> future = Future.<Status>future()
	      .setHandler(ar -> {
		if (ar.cause() instanceof ProcedureException) {
		  resultHandler.handle(StatusHelper.onError(name, (ProcedureException) ar.cause()));
		} else {
		  resultHandler.handle(StatusHelper.from(name, ar));
		}
	      });

	    if (timeout >= 0) {
	      vertx.setTimer(timeout, l -> {
		if (!future.isComplete()) {
		  future.fail(new ProcedureException("Timeout"));
		}
	      });
	    }

	    try {
	      handler.handle(future);
	    } catch (Exception e) {
	      future.fail(new ProcedureException(e));
	    }
	  }