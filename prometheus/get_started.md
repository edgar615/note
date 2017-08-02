https://blog.eood.cn/prometheus-grafana-monitoring
http://cjting.me/linux/use-prometheus-to-monitor-server/
https://zhuanlan.zhihu.com/p/24811652

prometheus

介绍先不描述

# 安装
官方提供了docker镜像，可以直接使用。我们这里使用二进制包安装

1.解压

	tar xvfz prometheus-*.tar.gz
	cd prometheus-*

Prometheus通过HTTP的endpoint来收集目标上的度量值。由于Prometheus也通过同样的方式暴露数据，所以它也可以收集和监控自己的健康情况。

基础配置文件 prometheus.yml


	# my global config
	global:
	  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
	  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
	  # scrape_timeout is set to the global default (10s).
	
	  # Attach these labels to any time series or alerts when communicating with
	  # external systems (federation, remote storage, Alertmanager).
	  external_labels:
	      monitor: 'codelab-monitor'
	
	# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
	rule_files:
	  # - "first.rules"
	  # - "second.rules"
	
	# A scrape configuration containing exactly one endpoint to scrape:
	# Here it's Prometheus itself.
	scrape_configs:
	  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
	  - job_name: 'prometheus'
	
	    # metrics_path defaults to '/metrics'
	    # scheme defaults to 'http'.
	
	    static_configs:
	      - targets: ['localhost:9090']

2. 启动

	./prometheus -config.file=prometheus.yml

浏览器打开http://localhost:9090访问prometheus

http://localhost:9090/metrics显示了prometheus自己的度量指标