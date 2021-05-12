<%@ page contentType="text/html; charset=UTF-8" language="java" pageEncoding="UTF-8" import="java.util.*,java.text.*,java.io.*,java.sql.*" errorPage="" %>
<%@ page import="java.net.*,java.util.regex.*" %>
<%!
/**
*读取conf/config.properties配置文件
*/
public String readPropConfig(String key,String path){
	Properties properties = new Properties();
	// 使用InPutStream流读取properties文件
	BufferedReader bufferedReader = null;
	try {
		File file = new File(path+"/conf/config.properties");
		bufferedReader = new BufferedReader(new FileReader(file));
	} catch (FileNotFoundException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
	try {
		properties.load(bufferedReader);
	} catch (IOException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
	// 获取key对应的value值
	String value = properties.getProperty(key);
	return value;
}
%>