## 按照aglio

	npm install -g aglio

## 默认主题

	aglio -i input.apib -o output.html

## 三列布局
个人感觉看起来不好

	aglio -i input.apib --theme-template triple -o output.html

## 修改颜色

	aglio --theme-variables slate -i input.apib -o output.html

## 自定义样式

	aglio --theme-style default --theme-style ./my-style.less -i input.apib -o output.html

## 自定义布局

	aglio --theme-template /path/to/template.jade -i input.apib -o output.html

## Custom theme engine
aglio -t my-engine -i input.apib -o output.html

## Run a live preview server on http://localhost:3000/
aglio -i input.apib -s

## 在命令行打印结果 (useful for piping)
aglio -i input.apib -o -

## Disable condensing navigation links
aglio --no-theme-condense -i input.apib -o output.html

## 全屏显示
aglio --theme-full-width -i input.apib -o output.html

## Set an explicit file include path and read from stdin
aglio --include-path /path/to/includes -i - -o output.html

## Output verbose error information with stack traces
aglio -i input.apib -o output.html --verbose

## 使用docker

With Docker

You can choose to use the provided Dockerfile to build yourself a repeatable and testable environment:

1. Build the image with docker build -t aglio .
2. Run aglio inside a container with docker run -t aglio You can use the -v switch to dynamically mount the folder that holds your API blueprint:


	docker run -v $(pwd):/tmp -t aglio -i /tmp/input.apib -o /tmp/output.html

# apib格式
目前仅支持API Blueprint format 1A.

https://github.com/apiaryio/api-blueprint/blob/master/API%20Blueprint%20Specification.md

https://blog.callmewhy.com/2014/06/05/blueprint-tutorial/

http://devlu.me/2016/05/05/write-restful-api-doc-with-apiblueprint/

## Metadata 元数据
这元数据区域的 key-values 是为了渲染工具定义的，如： 

	FORMAT: 1A  是指明 API BluePrint 的版本， 
	HOST: https://api.example.com 指明了这个api 的 HOST 部分，还可以增加通用前缀部分

## API名称

	# 这里写API的名称
	紧接着的这行写详细说明，支持markdown语法

示例

	# API Title
	[Markdown](http://daringfireball.net/projects/markdown/syntax) **formatted** description.
	
	## Subtitle
	Also Markdown *formatted*. This also includes automatic "smartypants" formatting -- hooray!
	
	> "A quote from another time and place"
	Another paragraph. Code sample:
	
	```http
	Authorization: bearer 5262d64b892e8d4341000001
	```
	
	And some code with no highlighting:
	
	```no-highlight
	Foo bar baz
	```
	
	1. A list
	2. Of items
	3. Can be
	4. Very useful
	
	Here is a table:
	
	ID | Name | Description
	--:| ---- | -----------
	 1 | Foo  | I am a foo.
	 8 | Bar  | I am a bar.
	15 | Baz  | I am a baz.
	
	::: note
	## Extensions
	Some non-standard Markdown extensions are also supported, such as this informational container, which can also contain **formatting**. Features include:
	
	* Informational block fenced with `::: note` and `:::`
	* Warning block fenced with `::: warning` and `:::`
	* [x] GitHub-style checkboxes using `[x]` and `[ ]`
	* Emoji support :smile: :ship: :cake: using `:smile:` ([cheat sheet](http://www.emoji-cheat-sheet.com/))
	
	These extensions may change in the future as the [CommonMark specification](http://spec.commonmark.org/) defines a [standard extension syntax](https://github.com/jgm/CommonMark/wiki/Proposed-Extensions).
	:::


## 资源组

	# Group 在# Group 的后面写资源组的名称，通常同一类接口或者同一个资源可以被分为一个组，注意空格
	紧接着的这行可以对组进行描述，支持markdown语法		

	## Resource 1 [/resource1] 资源名称，资源地址使用[]包裹，地址是相对路径
	紧接着的这行可以对资源进行描述，支持markdown语法
	
	 ...
	
	# Group Authors
	Resources in this groups are related to **ACME Blog** authors.
	
	## Resource 2 [/resource2]
	
	 ...

## 资源
方法1：

	# <URI template>

方法2 

	# <identifier> [<URI template>]

方法3

	# <HTTP request method> <URI template>

方法4

	# <identifier> [<HTTP request method> <URI template>]

资源最少应该包括一个嵌套部分，如：
URI参数(URI parameters section)，资源属性(Attributes section)，Model section,其他

## Resource model 
定义了可选的media type

	+ Model (<media type>)

示例

	# My Resource [/resource]
	
	+ Model (text/plain)
	
	        Hello World
	
	## Retrieve My Resource [GET]
	
	+ Response 200
	
	    [My Resource][]

## Schema section
Specifies a validation schema for the HTTP message-body of parent payload section.

示例

	## Retrieve a Message [GET]
	
	+ Response 200 (application/json)
	    + Body
	
	            {"message": "Hello world!"}
	
	    + Schema
	
	            {
	                "$schema": "http://json-schema.org/draft-04/schema#",
	                "type": "object",
	                "properties": {
	                    "message": {
	                        "type": "string"
	                    }
	                }
	            }


## Action section
定义http方法

	## <HTTP request method>
	
或者

	## <identifier> [<HTTP request method>]

或者
	
	## <identifier> [<HTTP request method> <URI template>]

示例

	# Blog Posts [/posts{?limit}]
	 ...
	
	## Retrieve Blog Posts [GET]
	Retrieves the list of **ACME Blog** posts.
	
	+ Parameters
	    + limit (optional, number) ... Maximum number of posts to retrieve
	
	+ Response 200
	
	        ...
	
	## Create a Post [POST]
	
	+ Attributes
	
	        ...
	
	+ Request
	
	        ...
	
	+ Response 201
	
	        ...
	
	## Delete a Post [DELETE /posts/{id}]
	
	+ Parameters
	    + id (string) ... Id of the post
	
	+ Response 204

示例： Example Multiple Transaction Examples

	# Resource [/resource]
	## Create Resource [POST]
	
	+ request A
	
	        ...
	
	+ response 200
	
	        ...
	
	+ request B
	
	        ...
	
	+ response 200
	
	        ...
	
	+ response 500
	
	        ...
	
	+ request C
	
	        ...
	
	+ request D
	
	        ...
	
	+ response 200
	
	        ...

## Request
One HTTP request-message example – payload.

	+ Request <identifier> (<Media Type>)

示例

	+ Request Create Blog Post (application/json)
	
	        { "message" : "Hello World." }

## Response 
One HTTP response-message example – payload.

	+ Response <HTTP status code> (<Media Type>)

示例

	+ Response 201 (application/json)
	
	            { "message" : "created" }

## URI parameters
Discussion of URI parameters in the scope of the parent section.

	+ Parameters

示例

	+ <parameter name>: `<example value>` (<type> | enum[<type>], required | optional) - <description>
	
	    <additional description>
	
	    + Default: `<default value>`
	
	    + Members
	        + `<enumeration value 1>`
	        + `<enumeration value 2>`
	        ...
	        + `<enumeration value N>`


- <parameter name> is the parameter name as written in Resource Section's URI (e.g. "id").
- <description> is any optional Markdown-formatted description of the parameter.
- <additional description> is any additional optional Markdown-formatted description of the parameter.
- <default value> is an optional default value of the parameter – a value that is used when no value is explicitly set (optional parameters only).
- <example value> is an optional example value of the parameter (e.g. 1234).
- <type> is the optional parameter type as expected by the API (e.g. "number", "string", "boolean"). "string" is the default.
- Members is the optional enumeration of possible values. <type> should be surrounded by enum[] if this is present. For example, if enumeration values are present for a parameter whose type is number, then enum[number] should be used instead of number to.
- <enumeration value n> represents an element of enumeration type.
- required is the optional specifier of a required parameter (this is the default)
- optional is the optional specifier of an optional parameter.

示例

	# GET /posts/{id}
	
	+ Parameters
	    + id - Id of a post.
	
	+ Parameters
	    + id (number) - Id of a post.
	
	+ Parameters
	    + id: `1001` (number, required) - Id of a post.
	
	+ Parameters
	    + id: `1001` (number, optional) - Id of a post.
	        + Default: `20`
	
	+ Parameters
	    + id (enum[string])
	
	        Id of a Post
	
	        + Members
	            + `A`
	            + `B`
	            + `C`

## Attributes 

	+ Attributes (object)

### Resource Attributes 
示例

	# Blog Post [/posts/{id}]
	Resource representing **ACME Blog** posts.
	
	+ Attributes
	    + id (number)
	    + message (string) - The blog post article
	    + author: john@appleseed.com (string) - Author of the blog post

### Action Attributes 
示例

	## Create a Post [POST]
	
	+ Attributes
	    + message (string) - The blog post article
	    + author: john@appleseed.com (string) - Author of the blog post
	
	+ Request (application/json)
	
	+ Request (application/yaml)
	
	+ Response 201

### Payload Attributes
示例

	## Retrieve a Post [GET]
	
	+ Response 200 (application/json)
	
	    + Attributes (object)
	        + message (string) - Message to the world
	
	    + Body
	
	            { "message" : "Hello World." }

## Headers 

示例

	+ Headers
	
	        Accept-Charset: utf-8
	        Connection: keep-alive
	        Content-Type: multipart/form-data, boundary=AaB03x

## Body

示例 

	+ Body
	
	        {
	            "message": "Hello"
	        }

## Data Structures
示例

	# Data Structures
	
	## Message (object)
	
	+ text (string) - text of the message
	+ author (Author) - author of the message
	
	## Author (object)
	
	+ name: John
	+ email: john@appleseed.com

示例1

	# User [/user]
	
	+ Attributes (Author)
	
	# Data Structures
	
	## Author (object)
	
	+ name: John
	+ email: john@appleseed.com

示例2

	# User [/user]
	
	+ Attributes
	    + name: John
	    + email: john@appleseed.com
	
	# Data Structures
	
	## Author (User)

## Relation 

	+ Relation: <link relation identifier>

示例

	# Task [/tasks/{id}]
	
	+ Parameters
	    + id
	
	## Retrieve Task [GET]
	
	+ Relation: task
	+ Response 200
	
	        { ... }
	
	## Delete Task [DELETE]
	
	+ Relation: delete
	+ Response 204