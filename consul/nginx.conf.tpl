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

	{{range services}} {{$name := .Name}} {{$service := service .Name}}
	upstream {{$name}} {
	  zone upstream-{{$name}} 64k;
	  {{range $service}}server {{.Address}}:{{.Port}};
	  {{end}}
	} {{end}}

    server {
		 listen 0.0.0.0:80;
		 server_name www.edgar615.com;
		 charset utf-8;		

	   access_log /var/log/nginx/server1.access.log;
	   error_log /var/log/nginx/server1.error.log;

		{{range services}} {{$name := .Name}}
		  location /{{$name}} {
			rewrite /{{$name}}/(.*) /$1 break;
			proxy_pass http://{{$name}};
		  }
		{{end}}
		location / {
			root /usr/share/nginx/html;
		}
    }
}

