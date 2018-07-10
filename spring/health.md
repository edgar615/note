http://blog.didispace.com/spring-boot-actuator-1/



**我基于spring-boot 2.0测试，有些用法与1.x已经不同，如果要所有的端点生效，需要使用配置**

```
management:
  endpoints:
    web:
      exposure:
        include: '*'
```

````
# ENDPOINTS WEB CONFIGURATION (WebEndpointProperties)
management.endpoints.web.exposure.include=health,info # Endpoint IDs that should be included or '*' for all.
management.endpoints.web.exposure.exclude= # Endpoint IDs that should be excluded.
management.endpoints.web.base-path=/actuator # Base path for Web endpoints. Relative to server.servlet.context-path or management.server.servlet.context-path if management.server.port is configured.
management.endpoints.web.path-mapping= # Mapping between endpoint IDs and the path that should expose the
````



在Spring Boot的众多Starter POMs中有一个特殊的模块，它不同于其他模块那样大多用于开发业务功能或是连接一些其他外部资源。它完全是一个用于暴露自身信息的模块，所以很明显，它的主要作用是用于监控与管理，它就是：`spring-boot-starter-actuator`。

`spring-boot-starter-actuator`模块的实现对于实施微服务的中小团队来说，可以有效地减少监控系统在采集应用指标时的开发量。当然，它也并不是万能的，有时候我们也需要对其做一些简单的扩展来帮助我们实现自身系统个性化的监控需求。下面，在本文中，我们将详解的介绍一些关于`spring-boot-starter-actuator`模块的内容，包括它的原生提供的端点以及一些常用的扩展和配置方式。

### 初识Actuator

下面，我们可以通过对快速入门中实现的Spring Boot应用增加`spring-boot-starter-actuator`模块功能，来对它有一个直观的认识。

在现有的Spring Boot应用中引入该模块非常简单，只需要在`pom.xml`的`dependencies`节点中，新增`spring-boot-starter-actuator`的依赖即可，具体如下：

```
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>

```

通过增加该依赖之后，重新启动应用。此时，我们可以在控制台中看到如下图所示的输出：

[![img](http://blog.didispace.com/assets/3-4.png)](http://blog.didispace.com/assets/3-4.png)

上图显示了一批端点定义，这些端点并非我们自己在程序中创建，而是由`spring-boot-starter-actuator`模块根据应用依赖和配置自动创建出来的监控和管理端点。通过这些端点，我们可以实时的获取应用的各项监控指标，比如：访问`/health`端点，我们可以获得如下返回的应用健康信息：

```
{
    "status" : "UP"
}

```

### 自定义健康检查

开启配置

```
management:
    endpoint:
          health:
            show-details: "ALWAYS"
```

方式1

```
@Component
public class HealthCheck implements HealthIndicator {
  
    @Override
    public Health health() {
        int errorCode = check(); // perform some specific health check
        if (errorCode != 0) {
            return Health.down()
              .withDetail("Error Code", errorCode).build();
        }
        return Health.up().build();
    }
     
    public int check() {
        // Our logic to check health
        return 1;
    }
}
```

方式2

```
@Component
public class DiskSpaceHealthIndicator extends AbstractHealthIndicator {
 
 
    private final FileStore fileStore;
    private final long thresholdBytes;
 
    @Autowired
    public DiskSpaceHealthIndicator(@Value("${health.filestore.path:${user.dir}}") String path,
                                    @Value("${health.filestore.threshold.bytes:10485760}") long thresholdBytes) throws IOException {
        fileStore = Files.getFileStore(Paths.get(path));
        this.thresholdBytes = thresholdBytes;
    }
 
    @Override
    protected void doHealthCheck(Health.Builder builder) throws Exception {
        long diskFreeInBytes = fileStore.getUnallocatedSpace();
        if (diskFreeInBytes >= thresholdBytes) {
            builder.up();
        } else {
            builder.down();
        }
    }
}
```

测试结果

```
{
    "status": "DOWN", 
    "details": {
        "diskSpace": {
            "status": "UP"
        }, 
        "healthCheck": {
            "status": "DOWN", 
            "details": {
                "Error Code": 1
            }
        }
    }
}
```



### 原生端点

通过在快速入门示例中添加`spring-boot-starter-actuator`模块，我们已经对它有了一个初步的认识。接下来，我们详细介绍一下`spring-boot-starter-actuator`模块中已经实现的一些原生端点。如果根据端点的作用来说，我们可以原生端点分为三大类：

- 应用配置类：获取应用程序中加载的应用配置、环境变量、自动化配置报告等与Spring Boot应用密切相关的配置类信息。
- 度量指标类：获取应用程序运行过程中用于监控的度量指标，比如：内存信息、线程池信息、HTTP请求统计等。
- 操作控制类：提供了对应用的关闭等操作类功能。

下面我们来详细了解一下这三类端点都分别可以为我们提供怎么样的有用信息和强大功能，以及我们如何去扩展和配置它们。

#### /autoconfig：

该端点用来获取应用的自动化配置报告，其中包括所有自动化配置的候选项。同时还列出了每个候选项自动化配置的各个先决条件是否满足。所以，该端点可以帮助我们方便的找到一些自动化配置为什么没有生效的具体原因。该报告内容将自动化配置内容分为两部分：

- `positiveMatches`中返回的是条件匹配成功的自动化配置
- `negativeMatches`中返回的是条件匹配不成功的自动化配置

```
{
    "positiveMatches": { // 条件匹配成功的
        "EndpointWebMvcAutoConfiguration": [
            {
                "condition": "OnClassCondition",
                "message": "@ConditionalOnClass classes found: javax.servlet.Servlet,org.springframework.web.servlet.DispatcherServlet"
            },
            {
                "condition": "OnWebApplicationCondition",
                "message": "found web application StandardServletEnvironment"
            }
        ],
        ...
    },
    "negativeMatches": {  // 条件不匹配成功的
        "HealthIndicatorAutoConfiguration.DataSourcesHealthIndicatorConfiguration": [
            {
                "condition": "OnClassCondition",
                "message": "required @ConditionalOnClass classes not found: org.springframework.jdbc.core.JdbcTemplate"
            }
        ],
        ...
    }
}

```
从如上示例中我们可以看到，每个自动化配置候选项中都有一系列的条件，比如上面没有成功匹配的`HealthIndicatorAutoConfiguration.DataSourcesHealthIndicatorConfiguration`配置，它的先决条件就是需要在工程中包含`org.springframework.jdbc.core.JdbcTemplate`类，由于我们没有引入相关的依赖，它就不会执行自动化配置内容。所以，当我们发现有一些期望的配置没有生效时，就可以通过该端点来查看没有生效的具体原因。

#### /beans

该端点用来获取应用上下文中创建的所有Bean。

** 返回的数据较多，这里就贴了**

如上示例中，我们可以看到在每个bean中都包含了下面这几个信息：

- bean：Bean的名称
- scope：Bean的作用域
- type：Bean的Java类型
- reource：class文件的具体路径
- dependencies：依赖的Bean名称

#### /configprops

该端点用来获取应用中配置的属性信息报告。从下面该端点返回示例的片段中，我们看到返回了关于该短信的配置信息，`prefix`属性代表了属性的配置前缀，`properties`代表了各个属性的名称和值。所以，我们可以通过该报告来看到各个属性的配置路径，比如我们要关闭该端点，就可以通过使用`endpoints.configprops.enabled=false`来完成设置。

```
{
    "contexts": {
        "spring-health": {
            "beans": {
                "management.trace.http-org.springframework.boot.actuate.autoconfigure.trace.http.HttpTraceProperties": {
                    "prefix": "management.trace.http", 
                    "properties": {
                        "include": [
                            "REQUEST_HEADERS", 
                            "RESPONSE_HEADERS", 
                            "COOKIE_HEADERS", 
                            "TIME_TAKEN"
                        ]
                    }
                }, 
                ...........
            }, 
            "parentId": null
        }
    }
}
```
#### /env

该端点与`/configprops`不同，它用来获取应用所有可用的环境属性报告。包括：环境变量、JVM属性、应用的配置配置、命令行中的参数。从下面该端点返回的示例片段中，我们可以看到它不仅返回了应用的配置属性，还返回了系统属性、环境变量等丰富的配置信息，其中也包括了应用还没有没有使用的配置。所以它可以帮助我们方便地看到当前应用可以加载的配置信息，并配合`@ConfigurationProperties`注解将它们引入到我们的应用程序中来进行使用。另外，为了配置属性的安全，对于一些类似密码等敏感信息，该端点都会进行隐私保护，但是我们需要让属性名中包含：password、secret、key这些关键词，这样该端点在返回它们的时候会使用`*`来替代实际的属性值。

```
{
    "activeProfiles": [ ], 
    "propertySources": [
        {
            "name": "server.ports", 
            "properties": {
                "local.management.port": {
                    "value": 9001
                }, 
                "local.server.port": {
                    "value": 9000
                }
            }
        }, 
        {
            "name": "commandLineArgs", 
            "properties": {
                "spring.output.ansi.enabled": {
                    "value": "always"
                }
            }
        }, 
        {
            "name": "servletContextInitParams", 
            "properties": { }
        }, 
        {
            "name": "systemProperties", 
            "properties": {
                "java.runtime.name": {
                    "value": "Java(TM) SE Runtime Environment"
                }, 
                "sun.boot.library.path": {
                    "value": "D:\\Program Files\\Java\\jdk1.8.0_121\\jre\\bin"
                }, 
                "java.vm.version": {
                    "value": "25.121-b13"
                }
            }
        }, 
        {
            "name": "systemEnvironment", 
            "properties": {
                "LOCALAPPDATA": {
                    "value": "C:\\Users\\Administrator\\AppData\\Local", 
                    "origin": "System Environment Property \"LOCALAPPDATA\""
                }
                
            }
        }, 
        {
            "name": "applicationConfig: [classpath:/application.yml]", 
            "properties": {
                "server.port": {
                    "value": 9000, 
                    "origin": "class path resource [application.yml]:2:11"
                }
            }
        }
    ]
}
```
#### /mappings

该端点用来返回所有Spring MVC的控制器映射关系报告。从下面的示例片段中，我们可以看该报告的信息与我们在启用Spring MVC的Web应用时输出的日志信息类似，其中`bean`属性标识了该映射关系的请求处理器，`method`属性标识了该映射关系的具体处理类和处理函数。

```
{
    "contexts": {
        "spring-health": {
            "mappings": {
                "dispatcherServlets": {
                    "dispatcherServlet": [
                        {
                            "handler": "ResourceHttpRequestHandler [locations=[class path resource [META-INF/resources/], class path resource [resources/], class path resource [static/], class path resource [public/], ServletContext resource [/], class path resource []], resolvers=[org.springframework.web.servlet.resource.PathResourceResolver@1d35316d]]", 
                            "predicate": "/**/favicon.ico", 
                            "details": null
                        }, 
                        {
                            "handler": "public java.lang.String com.github.edgar615.spring.health.Application.home()", 
                            "predicate": "{[/]}", 
                            "details": {
                                "handlerMethod": {
                                    "className": "com.github.edgar615.spring.health.Application", 
                                    "name": "home", 
                                    "descriptor": "()Ljava/lang/String;"
                                }, 
                                "requestMappingConditions": {
                                    "consumes": [ ], 
                                    "headers": [ ], 
                                    "methods": [ ], 
                                    "params": [ ], 
                                    "patterns": [
                                        "/"
                                    ], 
                                    "produces": [ ]
                                }
                            }
                        }, 
                        {
                            "handler": "public org.springframework.http.ResponseEntity<java.util.Map<java.lang.String, java.lang.Object>> org.springframework.boot.autoconfigure.web.servlet.error.BasicErrorController.error(javax.servlet.http.HttpServletRequest)", 
                            "predicate": "{[/error]}", 
                            "details": {
                                "handlerMethod": {
                                    "className": "org.springframework.boot.autoconfigure.web.servlet.error.BasicErrorController", 
                                    "name": "error", 
                                    "descriptor": "(Ljavax/servlet/http/HttpServletRequest;)Lorg/springframework/http/ResponseEntity;"
                                }, 
                                "requestMappingConditions": {
                                    "consumes": [ ], 
                                    "headers": [ ], 
                                    "methods": [ ], 
                                    "params": [ ], 
                                    "patterns": [
                                        "/error"
                                    ], 
                                    "produces": [ ]
                                }
                            }
                        }, 
                        {
                            "handler": "public org.springframework.web.servlet.ModelAndView org.springframework.boot.autoconfigure.web.servlet.error.BasicErrorController.errorHtml(javax.servlet.http.HttpServletRequest,javax.servlet.http.HttpServletResponse)", 
                            "predicate": "{[/error],produces=[text/html]}", 
                            "details": {
                                "handlerMethod": {
                                    "className": "org.springframework.boot.autoconfigure.web.servlet.error.BasicErrorController", 
                                    "name": "errorHtml", 
                                    "descriptor": "(Ljavax/servlet/http/HttpServletRequest;Ljavax/servlet/http/HttpServletResponse;)Lorg/springframework/web/servlet/ModelAndView;"
                                }, 
                                "requestMappingConditions": {
                                    "consumes": [ ], 
                                    "headers": [ ], 
                                    "methods": [ ], 
                                    "params": [ ], 
                                    "patterns": [
                                        "/error"
                                    ], 
                                    "produces": [
                                        {
                                            "mediaType": "text/html", 
                                            "negated": false
                                        }
                                    ]
                                }
                            }
                        }, 
                        {
                            "handler": "ResourceHttpRequestHandler [locations=[class path resource [META-INF/resources/webjars/]], resolvers=[org.springframework.web.servlet.resource.PathResourceResolver@3ac7a87f]]", 
                            "predicate": "/webjars/**", 
                            "details": null
                        }, 
                        {
                            "handler": "ResourceHttpRequestHandler [locations=[class path resource [META-INF/resources/], class path resource [resources/], class path resource [static/], class path resource [public/], ServletContext resource [/]], resolvers=[org.springframework.web.servlet.resource.PathResourceResolver@758b8600]]", 
                            "predicate": "/**", 
                            "details": null
                        }
                    ]
                }, 
                "servletFilters": [
                    {
                        "servletNameMappings": [ ], 
                        "urlPatternMappings": [
                            "/*"
                        ], 
                        "name": "requestContextFilter", 
                        "className": "org.springframework.boot.web.servlet.filter.OrderedRequestContextFilter"
                    }, 
                    {
                        "servletNameMappings": [ ], 
                        "urlPatternMappings": [
                            "/*"
                        ], 
                        "name": "webMvcMetricsFilter", 
                        "className": "org.springframework.boot.actuate.metrics.web.servlet.WebMvcMetricsFilter"
                    }, 
                    {
                        "servletNameMappings": [ ], 
                        "urlPatternMappings": [
                            "/*"
                        ], 
                        "name": "Tomcat WebSocket (JSR356) Filter", 
                        "className": "org.apache.tomcat.websocket.server.WsFilter"
                    }, 
                    {
                        "servletNameMappings": [ ], 
                        "urlPatternMappings": [
                            "/*"
                        ], 
                        "name": "httpPutFormContentFilter", 
                        "className": "org.springframework.boot.web.servlet.filter.OrderedHttpPutFormContentFilter"
                    }, 
                    {
                        "servletNameMappings": [ ], 
                        "urlPatternMappings": [
                            "/*"
                        ], 
                        "name": "hiddenHttpMethodFilter", 
                        "className": "org.springframework.boot.web.servlet.filter.OrderedHiddenHttpMethodFilter"
                    }, 
                    {
                        "servletNameMappings": [ ], 
                        "urlPatternMappings": [
                            "/*"
                        ], 
                        "name": "characterEncodingFilter", 
                        "className": "org.springframework.boot.web.servlet.filter.OrderedCharacterEncodingFilter"
                    }, 
                    {
                        "servletNameMappings": [ ], 
                        "urlPatternMappings": [
                            "/*"
                        ], 
                        "name": "httpTraceFilter", 
                        "className": "org.springframework.boot.actuate.web.trace.servlet.HttpTraceFilter"
                    }
                ], 
                "servlets": [
                    {
                        "mappings": [ ], 
                        "name": "default", 
                        "className": "org.apache.catalina.servlets.DefaultServlet"
                    }, 
                    {
                        "mappings": [
                            "/"
                        ], 
                        "name": "dispatcherServlet", 
                        "className": "org.springframework.web.servlet.DispatcherServlet"
                    }
                ]
            }, 
            "parentId": null
        }
    }
}
```
#### /info
该端点用来返回一些应用自定义的信息。默认情况下，该端点只会返回一个空的json内容。我们可以在`application.properties`配置文件中通过`info`前缀来设置一些属性，比如下面这样：

  ```
info:
    name: @project.artifactId@
    build:
        artifact:   @project.artifactId@
        name: @project.artifactId@
        version: @project.version@
        description: 这是一个测试用例
  ```

  再访问`/info`端点，我们可以得到下面的返回报告，其中就包含了上面我们在应用自定义的两个参数。

  ```
{
    "name": "spring-health", 
    "build": {
        "artifact": "spring-health", 
        "name": "spring-health", 
        "version": "0.0.1", 
        "description": "这是一个测试用例"
    }
}
  ```

配置项

```

# INFO CONTRIBUTORS (InfoContributorProperties)
management.info.build.enabled=true # Whether to enable build info.
management.info.defaults.enabled=true # Whether to enable default info contributors.
management.info.env.enabled=true # Whether to enable environment info.
management.info.git.enabled=true # Whether to enable git info.
management.info.git.mode=simple # Mode to use to expose git information.
```

自定义info

```
@Component
public class ExampleInfoContributor implements InfoContributor {

	@Override
	public void contribute(Info.Builder builder) {
		builder.withDetail("example",
											 Collections.singletonMap("key", "value"));
	}

}
```

输出

```
{
    "name": "spring-health", 
    "build": {
        "artifact": "spring-health", 
        "name": "spring-health", 
        "version": "0.0.1", 
        "description": "这是一个测试用例"
    }, 
    "example": {
        "key": "value"
    }
}
```



#### /metrics

该端点用来返回当前应用的各类重要度量指标，比如：内存信息、线程信息、垃圾回收信息等。

```
{
    "names": [
        "jvm.buffer.memory.used", 
        "jvm.memory.used", 
        "jvm.gc.memory.allocated", 
        "jvm.memory.committed", 
        "tomcat.global.error", 
        "tomcat.sessions.created", 
        "tomcat.sessions.expired", 
        "tomcat.global.sent", 
        "jvm.gc.max.data.size", 
        "logback.events", 
        "system.cpu.count", 
        "jvm.memory.max", 
        "jvm.buffer.total.capacity", 
        "jvm.buffer.count", 
        "jvm.threads.daemon", 
        "tomcat.global.received", 
        "process.start.time", 
        "tomcat.threads.config.max", 
        "tomcat.sessions.active.max", 
        "jvm.gc.live.data.size", 
        "process.cpu.usage", 
        "tomcat.threads.busy", 
        "tomcat.servlet.request", 
        "jvm.gc.pause", 
        "process.uptime", 
        "tomcat.cache.hit", 
        "tomcat.servlet.error", 
        "tomcat.servlet.request.max", 
        "tomcat.cache.access", 
        "tomcat.sessions.active.current", 
        "tomcat.global.request", 
        "system.cpu.usage", 
        "jvm.threads.live", 
        "jvm.classes.loaded", 
        "jvm.classes.unloaded", 
        "tomcat.global.request.max", 
        "jvm.threads.peak", 
        "tomcat.threads.current", 
        "jvm.gc.memory.promoted", 
        "tomcat.sessions.rejected", 
        "tomcat.sessions.alive.max"
    ]
}
```



自定义

```
@Component
public class SampleBean {

  private final Counter counter;

  public SampleBean(MeterRegistry registry) {
    this.counter = registry.counter("received.messages");
  }

  public void handleMessage(String message) {
    this.counter.increment();
    // handle message implementation
  }

}
```

`/metrics`端点可以提供应用运行状态的完整度量指标报告，这项功能非常的实用，但是对于监控系统中的各项监控功能，它们的监控内容、数据收集频率都有所不同，如果我们每次都通过全量获取报告的方式来收集，略显粗暴。所以，我们还可以通过`/metrics/{name}`接口来更细粒度的获取度量信息，比如我们可以通过访问`/metrics/jvm.memory.used来获取当前已用内存数量。

```
{
    "name": "jvm.memory.used", 
    "measurements": [
        {
            "statistic": "VALUE", 
            "value": 458705144
        }
    ], 
    "availableTags": [
        {
            "tag": "area", 
            "values": [
                "heap", 
                "nonheap"
            ]
        }, 
        {
            "tag": "id", 
            "values": [
                "Compressed Class Space", 
                "PS Old Gen", 
                "PS Survivor Space", 
                "Metaspace", 
                "PS Eden Space", 
                "Code Cache"
            ]
        }
    ]
}
```

通过tag参数，可以查看更详细的信息

```
/metrics/jvm.memory.used?tag=area:heap
/metrics/jvm.memory.used?tag=area:heap&tag=id:PS%20Survivor%20Space
```



自动上报

```
management.metrics.export.graphite.host=graphite.example.com
management.metrics.export.graphite.post=9004
//还有其他类型的上报
```

prometheus

```
scrape_configs:
  - job_name: 'spring'
	metrics_path: '/actuator/prometheus'
	static_configs:
	  - targets: ['HOST:PORT']
```

spring boot提供了Spring MVC Metrics、Spring WebFlux Metrics、RestTemplate Metrics、Spring Integration metrics、Spring Integration metrics、DataSource Metrics、RabbitMQ Metrics等等一些了度量指标，如果有需要可以查看文档

#### /health

该端点在一开始的示例中我们已经使用过了，它用来获取应用的各类健康指标信息。在`spring-boot-starter-actuator`模块中自带实现了一些常用资源的健康指标检测器。这些检测器都通过`HealthIndicator`接口实现，并且会根据依赖关系的引入实现自动化装配，比如用于检测磁盘的`DiskSpaceHealthIndicator`、检测DataSource连接是否可用的`DataSourceHealthIndicator`等。有时候，我们可能还会用到一些Spring Boot的Starter POMs中还没有封装的产品来进行开发，比如：当使用RocketMQ作为消息代理时，由于没有自动化配置的检测器，所以我们需要自己来实现一个用来采集健康信息的检测器。比如，我们可以在Spring Boot的应用中，为`org.springframework.boot.actuate.health.HealthIndicator`接口实现一个对RocketMQ的检测器类：

```
@Component
public class RocketMQHealthIndicator implements HealthIndicator {

    @Override
    public Health health() {
        int errorCode = check();
        if (errorCode != 0) {
          return Health.down().withDetail("Error Code", errorCode).build();
        }
        return Health.up().build();
    }

  	private int check() {
     	// 对监控对象的检测操作
  	}
}

```

通过重写`health()`函数来实现健康检查，返回的`Heath`对象中，共有两项内容，一个是状态信息，除了该示例中的`UP`与`DOWN`之外，还有`UNKNOWN`和`OUT_OF_SERVICE`，可以根据需要来实现返回；还有一个详细信息，采用Map的方式存储，在这里通过`withDetail`函数，注入了一个Error Code信息，我们也可以填入一下其他信息，比如，检测对象的IP地址、端口等。重新启动应用，并访问`/health`接口，我们在返回的JSON字符串中，将会包含了如下信息：

```
"rocketMQ": {
  "status": "UP"
}

```


```
management.health.db.enabled=true # Whether to enable database health check.
management.health.cassandra.enabled=true # Whether to enable Cassandra health check.
management.health.couchbase.enabled=true # Whether to enable Couchbase health check.
management.health.defaults.enabled=true # Whether to enable default health indicators.
management.health.diskspace.enabled=true # Whether to enable disk space health check.
management.health.diskspace.path= # Path used to compute the available disk space.
management.health.diskspace.threshold=0 # Minimum disk space, in bytes, that should be available.
management.health.elasticsearch.enabled=true # Whether to enable Elasticsearch health check.
management.health.elasticsearch.indices= # Comma-separated index names.
management.health.elasticsearch.response-timeout=100ms # Time to wait for a response from the cluster.
management.health.influxdb.enabled=true # Whether to enable InfluxDB health check.
management.health.jms.enabled=true # Whether to enable JMS health check.
management.health.ldap.enabled=true # Whether to enable LDAP health check.
management.health.mail.enabled=true # Whether to enable Mail health check.
management.health.mongo.enabled=true # Whether to enable MongoDB health check.
management.health.neo4j.enabled=true # Whether to enable Neo4j health check.
management.health.rabbit.enabled=true # Whether to enable RabbitMQ health check.
management.health.redis.enabled=true # Whether to enable Redis health check.
management.health.solr.enabled=true # Whether to enable Solr health check.
management.health.status.http-mapping= # Mapping of health statuses to HTTP status codes. By default, registered health statuses map to sensible defaults (for example, UP maps to 200).
management.health.status.order=DOWN,OUT_OF_SERVICE,UP,UNKNOWN # Comma-separated list of health statuses in order of severity.
```





#### /heapdump

该端点用来暴露程序运行中的内存信息。

#### /threaddump

该端点用来暴露程序运行中的线程信息

#### /auditevents

lists security audit-related events such as user login/logout. Also, we can filter by principal or type among others fields

与AuditApplicationEvent结合使用

http://www.baeldung.com/spring-boot-authentication-audit

#### /loggers

enables us to query and modify the logging level of our application

/loggers/{name}查看具体信息

#### /scheduledtasks  

provides details about every scheduled task within our application

#### /prometheus

returns metrics like the previous one, but formatted to work with a Prometheus server

没测

#### /sessions

/session

#### /shutdown 

performs a graceful shutdown of the application

- /trace：该端点用来返回基本的HTTP跟踪信息。默认情况下，跟踪信息的存储采用`org.springframework.boot.actuate.trace.InMemoryTraceRepository`实现的内存方式，始终保留最近的100条请求记录。它记录的内容格式如下：

  ```
  [
      {
          "timestamp": 1482570022463,
          "info": {
              "method": "GET",
              "path": "/metrics/mem",
              "headers": {
                  "request": {
                      "host": "localhost:8881",
                      "connection": "keep-alive",
                      "cache-control": "no-cache",
                      "user-agent": "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36",
                      "postman-token": "9817ea4d-ad9d-b2fc-7685-9dff1a1bc193",
                      "accept": "*/*",
                      "accept-encoding": "gzip, deflate, sdch",
                      "accept-language": "zh-CN,zh;q=0.8"
                  },
                  "response": {
                      "X-Application-Context": "hello:dev:8881",
                      "Content-Type": "application/json;charset=UTF-8",
                      "Transfer-Encoding": "chunked",
                      "Date": "Sat, 24 Dec 2016 09:00:22 GMT",
                      "status": "200"
                  }
              }
          }
      },
      ...
  ]

  ```

### 自定义endpoint

```
@Component
@Endpoint(id = "features")
public class FeaturesEndpoint {
 
    private Map<String, Feature> features = new ConcurrentHashMap<>();
 
    @ReadOperation
    public Map<String, Feature> features() {
        return features;
    }
 
    @ReadOperation
    public Feature feature(@Selector String name) {
        return features.get(name);
    }
 
    @WriteOperation
    public void configureFeature(@Selector String name, Feature feature) {
        features.put(name, feature);
    }
 
    @DeleteOperation
    public void deleteFeature(@Selector String name) {
        features.remove(name);
    }
 
    public static class Feature {
        private Boolean enabled;

        public Boolean getEnabled() {
            return enabled;
        }

        public void setEnabled(Boolean enabled) {
            this.enabled = enabled;
        }
    }
 
}
```

- *@ReadOperation – *it’ll map to HTTP *GET*
- *@WriteOperation* – it’ll map to HTTP *POST*
- *@DeleteOperation* – it’ll map to HTTP *DELETE*

### 基础endpoint

```
@Component
@EndpointWebExtension(endpoint = InfoEndpoint.class)
public class InfoWebEndpointExtension {
 
    private InfoEndpoint delegate;
 
    // standard constructor
 
    @ReadOperation
    public WebEndpointResponse<Map> info() {
        Map<String, Object> info = this.delegate.info();
        Integer status = getStatus(info);
        return new WebEndpointResponse<>(info, status);
    }
 
    private Integer getStatus(Map<String, Object> info) {
        // return 5xx if this is a snapshot
        return 200;
    }
}
```

内置 HealthIndicator 监控检测
CassandraHealthIndicator 	Checks that a Cassandra database is up.
DiskSpaceHealthIndicator 	Checks for low disk space.
DataSourceHealthIndicator 	Checks that a connection to DataSource can be obtained.
ElasticsearchHealthIndicator 	Checks that an Elasticsearch cluster is up.
JmsHealthIndicator 	Checks that a JMS broker is up.
MailHealthIndicator 	Checks that a mail server is up.
MongoHealthIndicator 	Checks that a Mongo database is up.
RabbitHealthIndicator 	Checks that a Rabbit server is up.
RedisHealthIndicator 	Checks that a Redis server is up.
SolrHealthIndicator 	Checks that a Solr server is up.