Scanner读取大文件

这种方案将会遍历文件中的所有行——允许对每一行进行处理，而不保持对它的引用

```
FileInputStream inputStream = null;
Scanner sc = null;
try {
  inputStream = new FileInputStream("big_file");
  sc = new Scanner(inputStream, "UTF-8");
  while (sc.hasNextLine()) {
    String line = sc.nextLine();
    System.out.println(line);
  }
  // note that Scanner suppresses exceptions
  if (sc.ioException() != null) {
    throw sc.ioException();
  }
} finally {
  if (inputStream != null) {
    inputStream.close();
  }
  if (sc != null) {
    sc.close();
  }
}
```
使用BufferedReader读取大文件

```
    File file = new File(filePath);
    BufferedReader reader = null;
    try {
      reader = new BufferedReader(new FileReader(file), 5 * 1024 * 1024);
      String tempString = null;
      while ((tempString = reader.readLine()) != null) {
        System.out.println(tempString);
      }
      reader.close();
    } catch (IOException e) {
      e.printStackTrace();
    } finally {
      if (reader != null) {
        try {
          reader.close();
        } catch (IOException e) {
          e.printStackTrace();
        }
      }
    }
```

使用BufferedWriter写大文件

```
File file = new File(filePath);
FileWriter fw = null;
try {
  if (!file.exists()) {
    file.createNewFile();
  }
  fw = new FileWriter(file.getAbsoluteFile());
  BufferedWriter bw = new BufferedWriter(fw);
  bw.write(fileContent);
  bw.close();
} catch (IOException e) {
  e.printStackTrace();
} finally {
  try {
    fw.close();
  } catch (IOException e) {
    e.printStackTrace();
  }
}
```