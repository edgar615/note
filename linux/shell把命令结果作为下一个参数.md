����1,ʹ��`

```
# echo `date`
Mon Jul 23 18:57:24 CST 2018
```

```
jmap -heap `ps -aux | grep iotp.server.id=device-service | grep -v grep | awk '{print $2}'`
```

����2��xargs

```
ps -aux | grep iotp.server.id=jpush | grep -v grep | awk '{print $2}' | xargs jmap -heap
```

```
`-0`����'\0'��ʶ�����

`-n`��һ�δ��ݼ�������

`-L`��һ�δ��ݼ��в���

`-I`����ʾ����ʹ��λ��
```

xargs�����Ǹ���������ݲ�����һ����������Ҳ����϶�������һ�����ߡ����ó�����׼��������ת���������в�����xargs�ܹ�����ܵ�����stdin������ת�����ض���������������xargsҲ���Խ����л�����ı�����ת��Ϊ������ʽ��������б䵥�У����б���С�xargs��Ĭ��������echo���ո���Ĭ�϶����������ζ��ͨ���ܵ����ݸ�xargs�����뽫��������кͿհף�����ͨ��xargs�Ĵ������кͿհ׽����ո�ȡ����xargs�ǹ��������������Ҫ���֮һ

xargs�����滻���ߣ���ȡ�����������¸�ʽ���������

����һ�������ļ������ж����ı����ݣ�

```
cat test.txt

a b c d e f g
h i j k l m n
o p q
r s t
u v w x y z
```

 �������뵥�������
 
```
cat test.txt | xargs

a b c d e f g h i j k l m n o p q r s t u v w x y z
```

-nѡ����������

```
cat test.txt | xargs -n3

a b c
d e f
g h i
j k l
m n o
p q r
s t u
v w x
y z
```

 -dѡ������Զ���һ���������

 ```
echo "nameXnameXnameXname" | xargs -dX

name name name name
```

 ���-nѡ��ʹ�ã�

```
echo "nameXnameXnameXname" | xargs -dX -n2

name name
name name
```

��ȡstdin������ʽ����Ĳ������ݸ�����

����һ������Ϊ sk.sh ��һ������������ļ�arg.txt��

```
#!/bin/bash
#sk.sh�������ݣ���ӡ�����в�����

echo $*
```

arg.txt�ļ����ݣ�

```
cat arg.txt

aaa
bbb
ccc
```
xargs��һ��ѡ��-I��ʹ��-Iָ��һ���滻�ַ���{}������ַ�����xargs��չʱ�ᱻ�滻������-I��xargs���ʹ�ã�ÿһ����������ᱻִ��һ�Σ�

```
cat arg.txt | xargs -I {} ./sk.sh -p {} -l

-p aaa -l
-p bbb -l
-p ccc -l

```
��������ͼƬ�ļ��� /data/images Ŀ¼�£�

```
ls *.jpg | xargs -n1 -I cp {} /data/images
```


xargs���findʹ��

��rm ɾ��̫����ļ�ʱ�򣬿��ܵõ�һ��������Ϣ��/bin/rm Argument list too long. ��xargsȥ����������⣺

```
find . -type f -name "*.log" -print0 | xargs -0 rm -f
```

xargs -0��\0��Ϊ�������

ͳ��һ��Դ����Ŀ¼������php�ļ���������

find . -type f -name "*.php" -print0 | xargs -0 wc -l

�������е�jpg �ļ�������ѹ�����ǣ�

find . -type f -name "*.jpg" -print | xargs tar -czvf images.tar.gz

xargs����Ӧ��

��������һ���ļ������˺ܶ���ϣ�����ص�URL�����ܹ�ʹ��xargs�����������ӣ�

cat url-list.txt | xargs wget -c
