<%@ page contentType="text/html; charset=UTF-8" language="java" pageEncoding="UTF-8" import="java.util.*,java.text.*,java.io.*,java.sql.*" errorPage="" %>
<%@ page import="java.net.*,java.util.regex.*" %>
<!%@ page import="chances.epg.commons.utils.JSONUtils"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="userId" value="${EPG_USER_SESSION.userId}" scope="request"/>
<c:set var="usertoken" value="${EPG_USER_SESSION.usertoken}" scope="request"/>
<%
String ctype = request.getParameter("ctype");
String ccode = request.getParameter("ccode");
String cname = request.getParameter("cname");
String cstatus = request.getParameter("cstatus");
String iserr = request.getParameter("iserr");
String isSitcom = request.getParameter("issitcom");

String userId = (String) request.getAttribute("userId");
//String tempName = (String) session.getAttribute("TemplateName");

HashMap rsMap = new HashMap();
String rsData = "";

long currTime = System.currentTimeMillis();
String acceptTime = new SimpleDateFormat("yyyyMMddHHmmss").format(currTime).toString();
String acceptDate = new SimpleDateFormat("yyyy:MM:dd:HH").format(currTime).toString();
String acceptDate2 = new SimpleDateFormat("yyyy:MM:dd").format(currTime).toString();
if (null!=ctype && "h".equals(ctype)) {
    StringBuffer sb = new StringBuffer();
    sb.append("0E");
    sb.append("|"+ userId);
    sb.append("|"+ acceptTime);
    sb.append("|vod_verify_"+ ctype.trim());
    sb.append("|"+ ccode);
    sb.append(","+ cname);
    sb.append(","+ acceptDate);
    sb.append(","+ cstatus);
    sb.append(","+ isSitcom);
    sb.append("|分时校验|lt-df|0");
    rsData = sb.toString();
} else if (null!=ctype && "d".equals(ctype)) {
    StringBuffer sb = new StringBuffer();
    sb.append("0E");
    sb.append("|"+ userId);
    sb.append("|"+ acceptTime);
    sb.append("|vod_verify_"+ ctype.trim());
    sb.append("|"+ ccode);
    sb.append(","+ cname);
    sb.append(","+ acceptDate2);
    sb.append(","+ cstatus);
    sb.append(","+ isSitcom);
    sb.append("|全天校验|lt-df|0");
    rsData = sb.toString();
} else if (null!=ctype && "e".equals(ctype)) {
    StringBuffer sb = new StringBuffer();
    sb.append("0E");
    sb.append("|"+ userId);
    sb.append("|"+ acceptTime);
    sb.append("|vod_verify_"+ ctype.trim());
    sb.append("|"+ ccode);
    sb.append(","+ cname);
    sb.append(","+ acceptDate2);
    sb.append(","+ cstatus);
    sb.append(","+ isSitcom);
    sb.append("|异常校验|lt-df|0");
    rsData = sb.toString();
} else {}

if (false=="".equals(rsData)) {// && "1".equals(iserr)
    // System.out.println("autoCheck|PostData::"+ rsData);
    // 0E|2015112002|20160524131952|vod_verify_h|内容Code,内容名称,YYYY:MM:DD:HH24,激活,可播放|分时校验|dx|0
    //测试环境：http://222.217.77.11:8007
	//现网环境：http://222.217.77.10:8007
    String res = this.getRequest("http://222.217.77.11:8007/", rsData);
    System.out.println(res);
    //System.out.println("autoCheck|httpRsMap::"+ JSONUtils.fromObject(httpRsMap));
    //int rsCode = (Integer) httpRsMap.get("RSCODE");
    //String rsMsg = (String) httpRsMap.get("RSMSG");
    //rsMap.put("RSCODE", rsCode);
    //rsMap.put("RSMSG", rsMsg);
    rsMap.put("RSRES", res);
}
rsMap.put("USERID", userId);
rsMap.put("RSDATA", rsData);

out.clear();
//out.print(JSONUtils.fromObject(rsMap));
out.print(rsMap);
out.flush();
%>

<%!
public String getRequest(String url,String data) {
	String output;
	StringBuffer resultSb = new StringBuffer();
	BufferedReader br = null;
	HttpURLConnection conn = null;
	try {
		URL aUrl = new URL(url);
		conn = (HttpURLConnection) aUrl.openConnection();
		conn.setConnectTimeout(3000);
		conn.setReadTimeout(3000);
		conn.setRequestMethod("POST");
		// 设置是否向HttpURLConnection输出
        conn.setDoOutput(true);
        // 设置是否从httpUrlConnection读入
        conn.setDoInput(true);
		conn.setRequestProperty("Content-Type", "application/json;charset=utf-8");
		conn.setUseCaches(false);
		
		BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(conn.getOutputStream(), "UTF-8"));
        writer.write(data);
        writer.close();
		
		br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
		while ((output = br.readLine()) != null) {
			resultSb.append(output);
		}
	} catch (MalformedURLException e) {
		e.printStackTrace();
	} catch (IOException e) {
		e.printStackTrace();
	} catch (Exception e) {
		e.printStackTrace();
	} finally {
		try {
			if (br != null) {
				br.close();
			}
			if(null != conn) {
				conn.disconnect();
			}
		} catch (Exception e2) {
			e2.printStackTrace();
		}
	}

	String result =  resultSb.toString();
	return result;
}
%>