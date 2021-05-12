<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.io.IOException"%>
<%@page import="java.net.MalformedURLException"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.OutputStreamWriter"%>
<%@page import="java.net.HttpURLConnection"%>
<%@page import="java.net.URL"%>
<%@page import="java.io.BufferedReader"%>
<c:set var="userId" value="${EPG_USER_SESSION.userId}" scope="request"></c:set>
<c:set var="usertoken" value="${EPG_USER_SESSION.usertoken}" scope="request"></c:set>

<%
out.clear();
out.println("{\"result\": \"0\",\"desc\": \"获取内容成功\",\"playUrl\": \"http://182.245.29.133:8088/ovt/201612/20161206/90000001000000020954122312238935/90000001000000020954122312238935.m3u8\"}");
//out.println("{\"result\": \"-99\"}");
out.flush();
%>
