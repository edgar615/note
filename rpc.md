# RPC框架
RPC的全称是Remote Procedure Call,它是一种进程间通信方式．允许像调用本地服务一样调用远程服务．

它的特点：
* 简单：RPC概念对语义十分清晰和简单，这样建立分布式计算就更容易
* 高效：过程调用看起来十分简单而且高效
* 通用：再单机计算中过程往往是不同算法和API，跨进程调用最重要对是通用对通信机制

RPC框架对目标就是让远程过程（服务）调用更加简单，透明，RPC框架负责屏蔽底层对传输方式（TCP或者UDP）,序列化方式（XML/JSON/二进制）和通信细节．框架使用者只需要了解谁再什么位置提供类什么样对远程服务接口即可，开放者不需要关系底层通信细节和调用过程．

RPC框架的职责要向[调用方]和[服务提供方]屏蔽各种复杂性：
(1) 让调用方感觉就像调用本地函数一样
(2)让服务提供方感觉就像实现一个本地函数一样来实现服务

整个RPC框架又分为Client和Server两个部分

调用方 -->c.1.函数+入参 ->字节流 --> c.2发送字节流 -> s.1收到字节流--> s.2字节流 ->函数+入参 --> s.3本地调用 -->s.4结果->字节流  -->s.5发送字节流 -->c.3收到字节流 -->c.4 字节流 ->出参

# 最简单的RPC框架实现
一个简单的RPC框架包括三个部分

* 服务提供者：提供服务接口定义和服务提供
* 服务发布者：运行在RPC服务端，负责将本地服务发布成远程服务，供本地消费者调用
* 本地服务代理：通过远程代理调用远程服务提供者，然后将结果返回给本地消费者

**接口定义**

	public interface EchoService {

	  String echo(String ping);
	}

**接口实现**

	public class EchoServiceImpl implements EchoService {
	  @Override
	  public String echo(String ping) {
	    return "pong : " + ping;
	  }
	}

**服务发布者**

	public class RpcExporter {
	  private static Executor executor =
	      Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());

	  public static void export(String host, int port) throws IOException {
	    ServerSocket serverSocket =  new ServerSocket();
	    serverSocket.bind(new InetSocketAddress(host, port));
	    while (true) {
	      executor.execute(new ExporterTask(serverSocket.accept()));
	    }
	  }
	}

	public class ExporterTask implements Runnable {

	  private final Socket socket;

	  public ExporterTask(Socket socket) {
	    this.socket = socket;
	  }

	  public Object load(Class<?> serviceClass) {
	    return ServiceLoader.load(serviceClass).iterator().next();
	  }

	  @Override
	  public void run() {
	    ObjectInputStream is = null;
	    ObjectOutputStream os = null;

	    try {
	      is = new ObjectInputStream(socket.getInputStream());
	      String interfaceName = is.readUTF();
	      Class<?> service = Class.forName(interfaceName);
	      String methodName = is.readUTF();
	      Class<?>[] parameterTypes = (Class<?>[]) is.readObject();
	      Object[] args = (Object[]) is.readObject();
	      Method method = service.getMethod(methodName, parameterTypes);
	      Object result = method.invoke(load(service), args);
	      os = new ObjectOutputStream(socket.getOutputStream());
	      os.writeObject(result);
	    } catch (Exception e) {
	      e.printStackTrace();
	    } finally {
	      //close
	    }
	  }
	}
	
**本地服务代理**

	public class RpcImporter<S> {

	  public S importer(final Class<?> serviceClass, final InetSocketAddress addr) {
	    return (S) Proxy.newProxyInstance(serviceClass.getClassLoader(),
		new Class[]{serviceClass},
		new InvocationHandler() {
		  @Override
		  public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
		    Socket socket = null;
		    ObjectOutputStream os = null;
		    ObjectInputStream is = null;
		    try {
		      socket = new Socket();
		      socket.connect(addr);
		      os = new ObjectOutputStream(socket.getOutputStream());
		      os.writeUTF(serviceClass.getName());
		      os.writeUTF(method.getName());
		      os.writeObject(method.getParameterTypes());
		      os.writeObject(args);
		      is = new ObjectInputStream(socket.getInputStream());
		      return is.readObject();
		    } finally {
		      //close
		    }
		  }
		});
	  }
	}

服务发布者和客户端对本地服务代理通过socket连接.
本地服务代理将接口调用转换为JDK的动态代理，在动态代理中实现接口对远程调用

**测试代码**

	public class Main {
	  public static void main(String[] args) {
	    new Thread(new Runnable() {
	      @Override
	      public void run() {
		try {
		  RpcExporter.export("localhost", 8080);
		} catch (IOException e) {
		  e.printStackTrace();
		}
	      }
	    }).start();
	  }
	}

	public class RpcTest {

	  public static void main(String[] args) {
	    EchoService echoService = (EchoService) new RpcImporter().importer(EchoService.class, new InetSocketAddress("localhost", 8080));
	    System.out.println(echoService.echo("edgar"));
	  }
	}

**参考资料：**
分布式服务框架原理与实践　第一章 

# 序列化
**主要内容都来自架构师之路的文章**
**序列化**： 将数据结构或对象转换成二进制串的过程
**反序列化**：将在序列化过程中所生成的二进制串转换成数据结构或者对象的过程

序列化协议一般采用成熟的协议，比如xml，json，protobuf等协议，当然也可以自己定义二进制协议

关于序列化和反序列化对更多内容可以参考[架构师之路 微服务架构之RPC-client序列化细节](https://mp.weixin.qq.com/s?__biz=MjM5ODYxMDA5OQ==&mid=2651959558&idx=1&sn=610f06c6d62a5c22311d27cf40f758ef&pass_ticket=b2RI7W%2Fa2jhi65jfYffl5vAc0Jq5IWFLDEqARastytzS1DnpW3b3pEvyxPF2urcB)

# 异步调用
前面对例子中本地服务代理调用远程服务提供者我们使用的是同步调用．当服务调用者远程调用服务提供者提供的服务时需要阻塞着等待调用结果．

关于异步调用对更多内容可以参考 [同步和异步](微服务/同步和异步)

# vert.x的RPC实现
Vert.x的 Service Proxy组件可以用于进行异步RPC通信(基于Eventbus实现)