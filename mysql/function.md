http://www.jianshu.com/p/0ff862270838

http://blog.jobbole.com/87351

http://itbilu.com/database/mysql/Nye1nX0Bb.html

存储过程和自定义函数是事先经过编译并存储在数据库中的一段SQL语句的集合。相对普通查询优点：

    可以简化应用开发人员的工作,可重用。
    减少数据库与应用服务器之间的数据传输。
    提高了数据处理的效率。
    安全性提高。由于存储过程也可以使用权限控制，而且参数化的存储过程可以防止SQL注入攻击，也在一定程度上保证了安全性。

存储过程与函数的区别在于函数必须有返回值，而存储过程没有，存储过程的参数可以使用in(输入)，out(输出)，inout(输入输出)，而函数的参数只能是in类型。

# 存储过程
## 语法

	CREATE
    [DEFINER = { user | CURRENT_USER }]
    PROCEDURE sp_name ([proc_parameter[,...]])
    [characteristic ...] routine_body

参数说明

- **sp_name**  存储过程名，可以是任何合法的MySQL标识符
- **[proc_parameter]**  参数列表，可选。其形式为`[ IN | OUT | INOUT ] param_name type`，其中in表示输入参数，out表示输出参数，inout表示既可以输入也可以输出；param_name表示参数名称；type表示参数的类型，可以是任何合法的MySQL数据类型
- **characteristic** 存储过程特性描述，取值在下面描述
- **routine_body** - 程序体，即：包含在BEGIN...END中的，要执行的SQL语句

**characteristic** 的取值

	characteristic: 
	    LANGUAGE SQL 
	  | [NOT] DETERMINISTIC 
	  | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA } 
	  | SQL SECURITY { DEFINER | INVOKER } 
	  | COMMENT 'string' 
	routine_body: 
	    Valid SQL procedure statement or statements


- COMMENT 注释信息
- LANGUAGE 指明routine_body部分由SQL组成。注：SQL是LANGUAGE特性的唯一值
- [NOT] DETERMINISTIC 指明存储过程执行的结果是否确定。DETERMINISTIC 表示结果是确定的，即：每次执行存储过程时，相同的输入会得到相同的输出。NOT DETERMINISTIC表示结果是不确定的，即：相同的输入可能得到不同的输出。默认为 NOT DETERMINISTIC。
- CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA 指明子程序使用SQL语句的限制，默认为CONTAINS SQL
	- CONTAINS SQL - 表明子程序包含SQL语句，但是不包含读写数据的语句
    - NO SQL - 表明子程序不包含SQL语句
    - READS SQL DATA - 说明子程序包含读数据的语句
    - MODIFIES SQL DATA - 子程序包含写数据的语句
- SQL SECURITY { DEFINER | INVOKER } - 执行权限。DEFINER表示定义者调用，INVOKER表示拥有调用权限都可以执行

## 创建

	DELIMITER //
	CREATE PROCEDURE Proc (OUT param1 INT)
	BEGIN
		SELECT
			count(*)
		FROM
			device ;
		END//
	
	DELIMITER ;

`DELIMITER //`语句的作用是将MYSQL的结束符设置为//，因为MYSQL默认的语句结束符为分号;，为了避免与存储过程中SQL语句结束符相冲突，需要使用DELIMITER 改变存储过程的结束符，并以`END //`结束存储过程。

存储过程定义完毕之后再使用`DELIMITER ;` 恢复默认结束符。DELIMITER 也可以指定其他符号为结束符

## 调用
存储过程定义后，可以使用CALL来调用存储过程。可以客户端单独调用，也可以在SQL语名或另一个存储过程中调用。

	CALL Proc(@a)

存储过程的结果会保持在@a变量里，可以通过SELECT @a查询变量

## 删除

	DROP PROCEDURE Proc

## 查看状态

	SHOW PROCEDURE STATUS like 'Proc'

## 查看定义

	SHOW CREATE PROCEDURE Proc

# 函数
## 语法

	CREATE
    [DEFINER = { user | CURRENT_USER }]
    FUNCTION sp_name ([func_parameter[,...]])
    RETURNS type
    [characteristic ...] routine_body

创建一个函数，sp_name表示函数名。函数的定义与存储过程定义非常相似，只是以下两个参数略有不同：

- func_parameter 函数参数列表，其形式如下：
	- param_name type  param_name : 参数名  type : 参数类型，可以是任何合法的MySQL数据类型
- RETURNS type 表示函数的返回值类型

## 创建

	DELIMITER //
	CREATE FUNCTION getName (id INT) RETURNS VARCHAR (64) RETURN (
		SELECT
			NAME
		FROM
			device
		WHERE
			id = id
	) ;//
	DELIMITER ;

## 调用
定义函数后，可以通过SELECT语句来调用函数：

	select getName(1)

## 删除

	DROP  FUNCTION  getName; 

## 查看状态

	SHOW FUNCTION STATUS like 'getName'

## 查看定义

	SHOW CREATE FUNCTION getName

如果在存储函数中的RETURN语句返回一个类型不同于函数的RETURNS子句中指定类型的值，返回值将被强制转换为恰当的类型。
例如，如果一个函数返回一个SET或ENUM值，但是RETURN语句返回一个整数，对于SET成员集的相应ENUM成员，从函数返回的值是字符串。

# 函数与存储过程的区别

- 功能不同：函数实现的功能针对性比较强，而存储过程实现的功能要复杂一此。存储过程，可以执行包括修改表等一系列数据库操作；而自定义函数不能用于执行一组修改全局数据库状态的操作。
- 返回值方式及类型不同：存储过程通过参数返回值，返回值类型可以是记录集；而函数只能返回值或者表对象。函数只能返回一个变量；而存储过程可以返回多个(通过多个返回参数实现)。
- 参数类型不同：存储过程的参数可以有IN、OUT、INOUT三种类型，而函数只能有IN类型。存储过程返回类型不是必须的，而函数需要返回类型，且函数体中必须包含一个有效的RETURN语句。
- 适用范围不同：存储过程一般是作为一个独立的部分来执行，而函数可以作为查询语句的一个部分来调用(如：SELECT中)。由于函数可以返回一个表对象，因此它可以在查询语句中FROM关键字的后面。 SQL语句中不可用存储过程，而可以使用函数。

# 变量
变量可以在子程序中声明并使用，这些变量的作用范围是在BEGIN…END程序中
## 定义变量

	DECLARE var_name[,varname]...date_type [DEFAULT VALUE];

var_name为局部变量的名称。DEFAULT VALUE子句给变量提供一个默认值。值除了可以被声明为一个常数外，还可以被指定为一个表达式。如果没有DEFAULT子句，初始值为NULL

	DECLARE MYPARAM INT DEFAULT 100;

## 赋值
定义变量之后，为变量赋值可以改变变量的默认值，MYSQL中使用SET语句为变量赋值

	SET var_name=expr[,var_name=expr]...

在存储过程中的SET语句是一般SET语句的扩展版本。被SET的变量可能是子程序内的变量，或者是全局服务器变量，如系统变量或者用户变量

	DECLARE var1,var2,var3 INT;
	SET var1=10,var2=20;
	SET var3=var1+var2;

MYSQL中还可以通过SELECT…INTO为一个或多个变量赋值

	DECLARE NAME CHAR(50);
	DECLARE id DECIMAL(8,2);
	SELECT id,NAME INTO id ,NAME FROM t3 WHERE id=2;


存储过程还有很多细节需要处理，因为在实际工作中我很少会用到存储过程所以没做学习，可以直接查看
http://blog.jobbole.com/87351

# 定义条件和处理程序
特定条件需要特定处理。这些条件可以联系到错误，以及子程序中的一般流程控制。定义条件是事先定义程序执行过程中遇到的问题，处理程序定义了在遇到这些问题时候应当采取的处理方式，并且保证存储过程或函数在遇到警告或错误时能继续执行。这样可以增强存储程序处理问题的能力，避免程序异常停止运行

## 定义条件

	DECLARE condition_name CONDITION FOR[condition_type]
	[condition_type]:
	SQLSTATE[VALUE] sqlstate_value |mysql_error_code

- condition_name：表示条件名称
- condition_type：表示条件的类型
- sqlstate_value和mysql_error_code都可以表示mysql错误

sqlstate_value为长度5的字符串错误代码，mysql_error_code为数值类型错误代码，例如：ERROR1142(42000)中，sqlstate_value的值是42000，mysql_error_code的值是1142

这个语句指定需要特殊处理条件。他将一个名字和指定的错误条件关联起来。这个名字随后被用在定义处理程序的DECLARE HANDLER语句中，定义ERROR1148(42000)错误，名称为command_not_allowed。

	//方法一：使用sqlstate_value
	DECLARE command_not_allowed CONDITION FOR SQLSTATE '42000'
	 
	//方法二：使用mysql_error_code
	DECLARE command_not_allowed CONDITION FOR SQLSTATE 1148

## 定义处理程序
MySQL中可以使用DECLARE关键字来定义处理程序。其基本语法如下：