配置项

```
spring:
  cloud:
    consul:
      host: 192.168.1.221
      port: 8500
      discovery:
        #启用服务发现?
        enabled: true
        #注册服务时使用的标签
        tags: foo=bar, baz
        #注册管理服务时使用的标签
        managementTags: foo=bar, baz
        #服务名称
        serviceName: ${spring.application.name}
        #唯一的服务实例ID
        instanceId: ${spring.application.name}:${vcap.application.instance_id:${spring.application.instance_id:${random.value}}}
        #服务实例区
        instanceZone: test
        #调用健康检查的备用服务器路径
        healthCheckPath: ${management.contextPath}/health
        #自定义运行状况检查网址以覆盖默认值
        healthCheckUrl: /check
        #执行健康检查的频率(e.g.10s)
        healthCheckInterval: 15s
        #健康检查超时时间(e.g.10s)
        healthCheckTimeout: 10s
        #访问服务时使用的IP地址（必须设置preferIpAddress使用
        ipAddress: 127.0.0.1
        #访问服务器时使用的主机名
        #在注册时使用ip地址而不是主机名
        preferIpAddress: true
        hostname: edgar-pc
        #端口注册服务（默认为侦听端口（8500））
        port: 9000
        #端口注册管理服务（默认为管理端口）
        managementPort: 9000
        #是使用http还是https注册服务
        scheme: http
        managementSuffix: .do
        #我们将如何确定使用地址的来源
        preferAgentAddress: false
        catalogServicesWatchDelay: 10
        catalogServicesWatchTimeout: 10
        #服务实例区域来自元数据。这允许更改元数据标签名称。
        defaultZoneMetadataName: zone
        # 服务地图->在服务器列表中查询的标签。
        # 这允许通过单个标签过滤服务。
        serverListQueryTags:
          foo: bar
        #如果没有在serverListQueryTags中列出，请在服务列表中查询标签。
        defaultQueryTag: test=test
        #将“passing”参数添加到v1healthserviceserviceName。这会将健康检查推送到服务器
        queryPassing: true
        #是否在consul中注册
        register: true
        #是否进行健康检查（一般在开发中使用）
        registerHealthCheck: true
        #在服务注册期间抛出异常，如果为true，否则为log
        failFast: true
#        lifecycle:
```
