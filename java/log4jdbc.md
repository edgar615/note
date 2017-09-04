http://log4jdbc.brunorozendo.com/

https://github.com/candrews/log4jdbc-spring-boot-starter

https://blog.gmem.cc/log4jdbc

	#下面的配置仅仅记录ERROR级别的日志，开发时可以适当改为DEBUG
	#只记录执行的SQL语句，PreparedStatement的输入参数自动替换“?”
	log4j.logger.jdbc.sqlonly=ERROR
	#记录执行的SQL语句，并统计其消耗时间
	log4j.logger.jdbc.sqltiming=ERROR
	#记录所有JDBC的调用（针对ResultSet的除外）
	log4j.logger.jdbc.audit=ERROR
	#记录针对ResultSet的所用JDBC调用
	log4j.logger.jdbc.resultset=ERROR
	#记录数据库连接的打开和关闭，可以用于监控连接泄漏
	log4j.logger.jdbc.connection=ERROR


此外，你可以 log4jdbc.properties这个文件中设置下表的配置项，来改变log4jdbc的行为：

<table style="width: 100%;" cellspacing="0" cellpadding="0" border="1">
<tbody>
<tr>
<td style="text-align: center;"><b>配置项</b></td>
<td style="width: 90px; text-align: center;"><b>默认值</b></td>
<td style="text-align: center;"><b>描述</b></td>
<td style="width: 90px; text-align: center;"><b>开始版本</b></td>
</tr>
<tr>
<td>log4jdbc.drivers</td>
<td></td>
<td>一个或者多个JDBC驱动的全限定类名，逗号分隔，一般用不到该配置</td>
<td>1.0</td>
</tr>
<tr>
<td>log4jdbc.auto.load.popular.drivers</td>
<td>true</td>
<td>如果设置为false，则不会自动加载上表所属的常用驱动类</td>
<td>1.2beta2</td>
</tr>
<tr>
<td>log4jdbc.debug.stack.prefix</td>
<td></td>
<td>部分或者全部的包名称，通常填写和你的应用有关的包，如果不填写，真实调用JDBC的类名称会显示在日志中——通常是连接池的类</td>
<td>1.0</td>
</tr>
<tr>
<td>log4jdbc.sqltiming.warn.threshold</td>
<td></td>
<td>指定一个毫秒数，如果执行的SQL语句超过此时间，jdbc.sqltiming则会以WARN级别记录日志</td>
<td>1.1beta1</td>
</tr>
<tr>
<td>log4jdbc.sqltiming.error.threshold</td>
<td></td>
<td>指定一个毫秒数，如果执行的SQL语句超过此时间，jdbc.sqltiming则会以ERROR级别记录日志</td>
<td>1.1beta1</td>
</tr>
<tr>
<td>log4jdbc.dump.booleanastruefalse</td>
<td>false</td>
<td>是否把日志中的布尔值显示为true/false，大部分数据库默认是显示为1/0</td>
<td>1.2alpha1</td>
</tr>
<tr>
<td>log4jdbc.dump.sql.maxlinelength</td>
<td>90</td>
<td>日志中SQL语句每行最大的字符数，超过了则自动换行</td>
<td>1.2alpha1</td>
</tr>
<tr>
<td>log4jdbc.dump.fulldebugstacktrace</td>
<td>false</td>
<td>是否显示完整的调用堆栈</td>
<td>1.2alpha1</td>
</tr>
<tr>
<td>log4jdbc.dump.sql.select</td>
<td>true</td>
<td>如果设置为false，则不输出select语句到日志</td>
<td>1.2alpha1</td>
</tr>
<tr>
<td>log4jdbc.dump.sql.insert</td>
<td>true</td>
<td>如果设置为false，则不输出insert语句到日志</td>
<td>1.2alpha1</td>
</tr>
<tr>
<td>log4jdbc.dump.sql.update</td>
<td>true</td>
<td>如果设置为false，则不输出update语句到日志</td>
<td>1.2alpha1</td>
</tr>
<tr>
<td>log4jdbc.dump.sql.delete</td>
<td>true</td>
<td>如果设置为false，则不输出delete语句到日志</td>
<td>1.2alpha1</td>
</tr>
<tr>
<td>log4jdbc.dump.sql.create</td>
<td>true</td>
<td>如果设置为false，则不输出create语句到日志</td>
<td>1.2alpha1</td>
</tr>
<tr>
<td>log4jdbc.dump.sql.addsemicolon</td>
<td>false</td>
<td>是否自动在SQL语句后面加分号;</td>
<td>1.2alpha1</td>
</tr>
<tr>
<td>log4jdbc.trim.sql</td>
<td>true</td>
<td>是否清除SQL头尾的空白符</td>
<td>1.2beta2</td>
</tr>
<tr>
<td>log4jdbc.trim.sql.extrablanklines</td>
<td>true</td>
<td>是否包含多余的空白行</td>
<td>1.2</td>
</tr>
</tbody>
</table>