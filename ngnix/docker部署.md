镜像选择nginx:1.13.8-alpine
```
docker pull nginx:1.13.8-alpine
```

启动，映射端口、映射html路径
```
docker run --name nginx -p 9001:80 -v /dev/nginx/content:/usr/share/nginx/html:ro -d nginx:1.13.8-alpine
```

自定义配置
```
docker run --name nginx -p 9001:80 -v /dev/nginx/content:/usr/share/nginx/html:ro -v /dev/nginx/nginx.conf:/etc/nginx/nginx.conf:ro -d nginx:1.13.8-alpine
```

用下面的命令可以导出官方配置
```
docker cp nginx:/etc/nginx/nginx.conf /dev/nginx/nginx.conf
```
官方默认的配置
```
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
```

在项目中做的修改
```
    upstream om_service {
	      server 172.17.0.3:9000;
    }
    server {
		 listen 0.0.0.0:80;
		 server_name www.edgar615.com;
		 charset utf-8;		

               access_log /var/log/nginx/server1.access.log;
               error_log /var/log/nginx/server1.error.log;

		location ^~ /api/backend/v1 {
            rewrite '^/api/backend/v1/(.*)$' /v1/$1 break;
		    proxy_pass  http://om_service;
		    proxy_set_header   Host             $host;
		    proxy_set_header   X-Real-IP        $remote_addr;
		    proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
		}
		location / {
			root /usr/share/nginx/html;
		}
    }
```