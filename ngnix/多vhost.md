# 简单的方法

http://nginx.org/en/docs/http/server_names.html

```
    server {		
        listen       80;
        server_name  "~^(?<name>\w+)\.example\.com$";
		root /alidata/nginx/content/$name;
		#access_log /alidata/nginx/log/$name/access.log; #不起作用
		#error_log  /alidata/nginx/log/$name/error.log; #不起作用

        # Load configuration files for the default server block.
        #include /etc/nginx/default.d/*.conf;

        location / {
		   index  index.html;
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }

```





# 完整复杂的方法

http模块中增加一行

```
include /alidata/nginx/vhost/*.conf;
```

在vhost目录下增加www.conf, admin.conf shop.conf分别设置

www.conf

```
server {
	listen       80 #default_server;
	#listen       [::]:80 default_server;
	server_name  www.example.com;
	root         /alidata/nginx/content;

	# Load configuration files for the default server block.
	#include /etc/nginx/default.d/*.conf;

	location / {
	   root /alidata/nginx/content;
	   index  index.html;
	}

	error_page 404 /404.html;
		location = /40x.html {
	}

	error_page 500 502 503 504 /50x.html;
		location = /50x.html {
	}
}
```

admin.conf

```
server {
	listen       80;
	#listen       [::]:80;
	server_name  admin.tabaosmart.com;
	root         /alidata/nginx/admin;

	# Load configuration files for the default server block.
	include /etc/nginx/default.d/*.conf;

	location / {
	   root /alidata/nginx/admin;
	   index  index.html;
	}

	error_page 404 /404.html;
		location = /40x.html {
	}

	error_page 500 502 503 504 /50x.html;
		location = /50x.html {
	}
}
```

shop.conf

```
server {
	listen       80;
	#listen       [::]:80;
	server_name  shop.tabaosmart.com;
	root         /alidata/nginx/shop;

	# Load configuration files for the default server block.
	include /etc/nginx/default.d/*.conf;

	location / {
	   root /alidata/nginx/shop;
	   index  index.html;
	}

	error_page 404 /404.html;
		location = /40x.html {
	}

	error_page 500 502 503 504 /50x.html;
		location = /50x.html {
	}
}
```

