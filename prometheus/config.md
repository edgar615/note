
参数类型


    <boolean>: a boolean that can take the values true or false
    <duration>: a duration matching the regular expression [0-9]+(ms|[smhdwy])
    <labelname>: a string matching the regular expression [a-zA-Z_][a-zA-Z0-9_]*
    <labelvalue>: a string of unicode characters
    <filename>: a valid path in the current working directory
    <host>: a valid string consisting of a hostname or IP followed by an optional port number
    <path>: a valid URL path
    <scheme>: a string that can take the values http or https
    <string>: a regular string
    <secret>: a regular string that is a secret, such as a password

# 全局配置

	global:
	  # How frequently to scrape targets by default.
	  # 默认执行scrape的频率，默认值1m
	  [ scrape_interval: <duration> | default = 1m ]
	
	  # How long until a scrape request times out.
	  # 执行scrape的超时时间 默认值10秒
	  [ scrape_timeout: <duration> | default = 10s ]
	
	  # How frequently to evaluate rules.
	  # 执行rules的评论 默认值1m	
	  [ evaluation_interval: <duration> | default = 1m ]
	
	  # The labels to add to any time series or alerts when communicating with
	  # external systems (federation, remote storage, Alertmanager).
	  # 默认的label
	  external_labels:
	    [ <labelname>: <labelvalue> ... ]
	
	# Rule files specifies a list of globs. Rules and alerts are read from
	# all matching files.
	rule_files:
	  [ - <filepath_glob> ... ]
	
	# A list of scrape configurations.
	scrape_configs:
	  [ - <scrape_config> ... ]
	
	# Alerting specifies settings related to the Alertmanager.
	alerting:
	  alert_relabel_configs:
	    [ - <relabel_config> ... ]
	  alertmanagers:
	    [ - <alertmanager_config> ... ]
	
	# Settings related to the experimental remote write feature.
	remote_write:
	  [ - <remote_write> ... ]
	
	# Settings related to the experimental remote read feature.
	remote_read:
	  [ - <remote_read> ... ]

# <scrape_config>
scrape_config用来定义scrape的目标和参数。一般情况下一个scrape配置知指定一个工作。

目标（target）可以通过static_configs静态配置参数，也可以使用服务发现机制动态配置

relabel_configs允许在scrape之前修改任何目标和标签

	# The job name assigned to scraped metrics by default.
	# scrape的名称，必须唯一
	job_name: <job_name>
	
	# How frequently to scrape targets from this job.
	[ scrape_interval: <duration> | default = <global_config.scrape_interval> ]
	
	# Per-scrape timeout when scraping this job.
	[ scrape_timeout: <duration> | default = <global_config.scrape_timeout> ]
	
	# The HTTP resource path on which to fetch metrics from targets.
	# 获取目标的度量指标的HTTP路径
	[ metrics_path: <path> | default = /metrics ]
	
	# honor_labels controls how Prometheus handles conflicts between labels that are
	# already present in scraped data and labels that Prometheus would attach
	# server-side ("job" and "instance" labels, manually configured target
	# labels, and labels generated by service discovery implementations).
	#
	# If honor_labels is set to "true", label conflicts are resolved by keeping label
	# values from the scraped data and ignoring the conflicting server-side labels.
	#
	# If honor_labels is set to "false", label conflicts are resolved by renaming
	# conflicting labels in the scraped data to "exported_<original-label>" (for
	# example "exported_instance", "exported_job") and then attaching server-side
	# labels. This is useful for use cases such as federation, where all labels
	# specified in the target should be preserved.
	#
	# Note that any globally configured "external_labels" are unaffected by this
	# setting. In communication with external systems, they are always applied only
	# when a time series does not have a given label yet and are ignored otherwise.
	# 修复label的冲突
	[ honor_labels: <boolean> | default = false ]
	
	# Configures the protocol scheme used for requests.
	# 协议
	[ scheme: <scheme> | default = http ]
	
	# Optional HTTP URL parameters.
	# http参数
	params:
	  [ <string>: [<string>, ...] ]
	
	# Sets the `Authorization` header on every scrape request with the
	# configured username and password.
	# basic安全认证
	basic_auth:
	  [ username: <string> ]
	  [ password: <secret> ]
	
	# Sets the `Authorization` header on every scrape request with
	# the configured bearer token. It is mutually exclusive with `bearer_token_file`.
	# bearer token认证
	[ bearer_token: <secret> ]
	
	# Sets the `Authorization` header on every scrape request with the bearer token
	# read from the configured file. It is mutually exclusive with `bearer_token`.
	[ bearer_token_file: /path/to/bearer/token/file ]
	
	# Configures the scrape request's TLS settings.
	tls_config:
	  [ <tls_config> ]
	
	# Optional proxy URL.
	[ proxy_url: <string> ]
	
	# List of Azure service discovery configurations.
	azure_sd_configs:
	  [ - <azure_sd_config> ... ]
	
	# List of Consul service discovery configurations.
	consul_sd_configs:
	  [ - <consul_sd_config> ... ]
	
	# List of DNS service discovery configurations.
	dns_sd_configs:
	  [ - <dns_sd_config> ... ]
	
	# List of EC2 service discovery configurations.
	ec2_sd_configs:
	  [ - <ec2_sd_config> ... ]
	
	# List of OpenStack service discovery configurations.
	openstack_sd_configs:
	  [ - <openstack_sd_config> ... ]
	
	# List of file service discovery configurations.
	file_sd_configs:
	  [ - <file_sd_config> ... ]
	
	# List of GCE service discovery configurations.
	gce_sd_configs:
	  [ - <gce_sd_config> ... ]
	
	# List of Kubernetes service discovery configurations.
	kubernetes_sd_configs:
	  [ - <kubernetes_sd_config> ... ]
	
	# List of Marathon service discovery configurations.
	marathon_sd_configs:
	  [ - <marathon_sd_config> ... ]
	
	# List of AirBnB's Nerve service discovery configurations.
	nerve_sd_configs:
	  [ - <nerve_sd_config> ... ]
	
	# List of Zookeeper Serverset service discovery configurations.
	serverset_sd_configs:
	  [ - <serverset_sd_config> ... ]
	
	# List of Triton service discovery configurations.
	triton_sd_configs:
	  [ - <triton_sd_config> ... ]
	
	# List of labeled statically configured targets for this job.
	static_configs:
	  [ - <static_config> ... ]
	
	# List of target relabel configurations.
	relabel_configs:
	  [ - <relabel_config> ... ]
	
	# List of metric relabel configurations.
	metric_relabel_configs:
	  [ - <relabel_config> ... ]
	
	# Per-scrape limit on number of scraped samples that will be accepted.
	# If more than this number of samples are present after metric relabelling
	# the entire scrape will be treated as failed. 0 means no limit.
	[ sample_limit: <int> | default = 0 ]

## <tls_config>
TLS连接的配置

	# CA certificate to validate API server certificate with.
	[ ca_file: <filename> ]
	
	# Certificate and key files for client cert authentication to the server.
	[ cert_file: <filename> ]
	[ key_file: <filename> ]
	
	# ServerName extension to indicate the name of the server.
	# http://tools.ietf.org/html/rfc4366#section-3.1
	[ server_name: <string> ]
	
	# Disable validation of the server certificate.
	[ insecure_skip_verify: <boolean> ]

服务发现的部分只看了consul、file、static，其他因为工作中不会用到

## consul_sd_configs

Consul SD configurations allow retrieving scrape targets from Consul's Catalog API.

The following meta labels are available on targets during relabeling:

    __meta_consul_address: the address of the target
    __meta_consul_dc: the datacenter name for the target
    __meta_consul_node: the node name defined for the target
    __meta_consul_service_address: the service address of the target
    __meta_consul_service_id: the service ID of the target
    __meta_consul_service_port: the service port of the target
    __meta_consul_service: the name of the service the target belongs to
    __meta_consul_tags: the list of tags of the target joined by the tag separator

配置

	# The information to access the Consul API. It is to be defined
	# as the Consul documentation requires.

	server: <host>
	[ token: <secret> ]
	[ datacenter: <string> ]
	[ scheme: <string> ]
	[ username: <string> ]
	[ password: <secret> ]

	# A list of services for which targets are retrieved. If omitted, all services
	# are scraped.
	services:
	  [ - <string> ]
	
	# The string by which Consul tags are joined into the tag label.
	[ tag_separator: <string> | default = , ]

Note that the IP number and port used to scrape the targets is assembled as <__meta_consul_address>:<__meta_consul_service_port>. However, in some Consul setups, the relevant address is in __meta_consul_service_address. In those cases, you can use the relabel feature to replace the special __address__ label.

## <dns_sd_config>

A DNS-based service discovery configuration allows specifying a set of DNS domain names which are periodically queried to discover a list of targets. The DNS servers to be contacted are read from /etc/resolv.conf.

This service discovery method only supports basic DNS A, AAAA and SRV record queries, but not the advanced DNS-SD approach specified in RFC6763.

During the relabeling phase, the meta label __meta_dns_name is available on each target and is set to the record name that produced the discovered target.

	# A list of DNS domain names to be queried.
	names:
	  [ - <domain_name> ]
	
	# The type of DNS query to perform.
	[ type: <query_type> | default = 'SRV' ]
	
	# The port number used if the query type is not SRV.
	[ port: <number>]
	
	# The time after which the provided names are refreshed.
	[ refresh_interval: <duration> | default = 30s ]
	
	Where <domain_name> is a valid DNS domain name. Where <query_type> is SRV, A, or AAAA.

##  <file_sd_config>

File-based service discovery provides a more generic way to configure static targets and serves as an interface to plug in custom service discovery mechanisms.

It reads a set of files containing a list of zero or more <static_config>s. Changes to all defined files are detected via disk watches and applied immediately. Files may be provided in YAML or JSON format. Only changes resulting in well-formed target groups are applied.

The JSON file must contain a list of static configs, using this format:

	[
	  {
	    "targets": [ "<host>", ... ],
	    "labels": {
	      "<labelname>": "<labelvalue>", ...
	    }
	  },
	  ...
	]

As a fallback, the file contents are also re-read periodically at the specified refresh interval.

Each target has a meta label __meta_filepath during the relabeling phase. Its value is set to the filepath from which the target was extracted.

	# Patterns for files from which target groups are extracted.
	files:
	  [ - <filename_pattern> ... ]
	
	# Refresh interval to re-read the files.
	[ refresh_interval: <duration> | default = 5m ]

Where <filename_pattern> may be a path ending in .json, .yml or .yaml. The last path segment may contain a single * that matches any character sequence, e.g. my/path/tg_*.json.

## <static_config>

A static_config allows specifying a list of targets and a common label set for them. It is the canonical way to specify static targets in a scrape configuration.

	# The targets specified by the static config.
	targets:
	  [ - '<host>' ]
	
	# Labels assigned to all metrics scraped from the targets.
	labels:
	  [ <labelname>: <labelvalue> ... ]

##  <relabel_config> 
