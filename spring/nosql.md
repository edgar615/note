spring boot nosql配置
https://segmentfault.com/a/1190000004316584

cache

    spring.cache.cache-names
    指定要创建的缓存的名称，逗号分隔(若该缓存实现支持的话)

    spring.cache.ehcache.config
    指定初始化EhCache时使用的配置文件的位置指定.

    spring.cache.guava.spec
    指定创建缓存要使用的spec，具体详见CacheBuilderSpec.

    spring.cache.hazelcast.config
    指定初始化Hazelcast时的配置文件位置

    spring.cache.infinispan.config
    指定初始化Infinispan时的配置文件位置.

    spring.cache.jcache.config
    指定jcache的配置文件.

    spring.cache.jcache.provider
    指定CachingProvider实现类的全限定名.

    spring.cache.type
    指定缓存类型

mongodb

    spring.mongodb.embedded.features
    指定要开启的特性，逗号分隔.

    spring.mongodb.embedded.version
    指定要使用的版本，默认: 2.6.10

redis

    spring.redis.database
    指定连接工厂使用的Database index，默认为: 0

    spring.redis.host
    指定Redis server host，默认为: localhost

    spring.redis.password
    指定Redis server的密码

    spring.redis.pool.max-active
    指定连接池最大的活跃连接数，-1表示无限，默认为8

    spring.redis.pool.max-idle
    指定连接池最大的空闲连接数，-1表示无限，默认为8

    spring.redis.pool.max-wait
    指定当连接池耗尽时，新获取连接需要等待的最大时间，以毫秒单位，-1表示无限等待

    spring.redis.pool.min-idle
    指定连接池中空闲连接的最小数量，默认为0

    spring.redis.port
    指定redis服务端端口，默认: 6379

    spring.redis.sentinel.master
    指定redis server的名称

    spring.redis.sentinel.nodes
    指定sentinel节点，逗号分隔，格式为host:port.

    spring.redis.timeout
    指定连接超时时间，毫秒单位，默认为0

springdata

    spring.data.elasticsearch.cluster-name
    指定es集群名称，默认: elasticsearch

    spring.data.elasticsearch.cluster-nodes
    指定es的集群，逗号分隔，不指定的话，则启动client node.

    spring.data.elasticsearch.properties
    指定要配置的es属性.

    spring.data.elasticsearch.repositories.enabled
    是否开启es存储，默认为: true

    spring.data.jpa.repositories.enabled
    是否开启JPA支持，默认为: true

    spring.data.mongodb.authentication-database
    指定鉴权的数据库名

    spring.data.mongodb.database
    指定mongodb数据库名

    spring.data.mongodb.field-naming-strategy
    指定要使用的FieldNamingStrategy.

    spring.data.mongodb.grid-fs-database
    指定GridFS database的名称.

    spring.data.mongodb.host
    指定Mongo server host.

    spring.data.mongodb.password
    指定Mongo server的密码.

    spring.data.mongodb.port
    指定Mongo server port.

    spring.data.mongodb.repositories.enabled
    是否开启mongodb存储，默认为true

    spring.data.mongodb.uri
    指定Mongo database URI.默认:mongodb://localhost/test

    spring.data.mongodb.username
    指定登陆mongodb的用户名.

    spring.data.rest.base-path
    指定暴露资源的基准路径.

    spring.data.rest.default-page-size
    指定每页的大小，默认为: 20

    spring.data.rest.limit-param-name
    指定limit的参数名，默认为: size

    spring.data.rest.max-page-size
    指定最大的页数，默认为1000

    spring.data.rest.page-param-name
    指定分页的参数名，默认为: page

    spring.data.rest.return-body-on-create
    当创建完实体之后，是否返回body，默认为false

    spring.data.rest.return-body-on-update
    在更新完实体后，是否返回body，默认为false

    spring.data.rest.sort-param-name
    指定排序使用的key，默认为: sort

    spring.data.solr.host
    指定Solr host，如果有指定了zk的host的话，则忽略。默认为: http://127.0.0.1:8983/solr

    spring.data.solr.repositories.enabled
    是否开启Solr repositories，默认为: true

    spring.data.solr.zk-host
    指定zk的地址，格式为HOST:PORT.