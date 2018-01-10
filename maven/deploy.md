mvn clean deploy -P sonatype-oss-release -Darguments="gpg.passphrase=设置gpg设置密钥时候输入的Passphrase"

https://www.iteblog.com/archives/1807.html


    mvn deploy:deploy-file -DgroupId=<group-id> \
      -DartifactId=<artifact-id> \
      -Dversion=<version> \
      -Dpackaging=<type-of-packaging> \
      -Dfile=<path-to-file> \
      -DrepositoryId=<id-to-map-on-server-section-of-settings.xml> \
      -Durl=<url-of-the-repository-to-deploy>

```
mvn deploy:deploy-file –DgroupId=com.huacloud.jar –DartifactId=sqljdbc4 –Dversion=1.0.0 –Dpackaging=jar –Dfile=sqljdbc4.jar –DrepositoryId=snapshots –Durl=http://222.197.188.5:9000/nexus/content/repositories/snapshots
```

settings.xml中增加server

	  <server>
		<id>sonatype-nexus-snapshots</id>
		<username>edgar615</username>
		<password>xxxxx</password>
	  </server>
	  <server>
		<id>sonatype-nexus-staging</id>
		<username>edgar615</username>
		<password>xxxx</password>
	  </server>