```
mvn install:install-file -Dfile=<path-to-file> -DgroupId=<group-id> \    -DartifactId=<artifact-id> -Dversion=<version> -Dpackaging=<packaging>

#示例
mvn install:install-file -DgroupId=com.taobao -DartifactId=sdk-java-auto-23343775 -Dversion=1.0.0 -Dfile=sdk-java-auto-23343775.jar -Dpackaging=jar
```

```
mvn install:install-file -Dfile=<path-to-file> -DpomFile=<path-to-pomfile>
```
如果也有pom文件的话，你可以使用下面的命令安装：

`mvn install:install-file -Dfile= -DpomFile=`

maven-install-plugin的2.5版本使安装过程更加好用，如果jar包是通过Maven构建的，它会在目录META-INF的子文件夹下创建一个pom.xml文件，这个Jar包会被默认读取。在这种情况下，你只需要这么做：

`mvn install:install-file -Dfile=`