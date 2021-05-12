<%@page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="chances.epg.commons.log.EpgLogFactory"%>
<%@page import="org.apache.commons.lang3.StringUtils"%>
<%@page import="chances.epg.commons.utils.URLUtils"%>
<%@page import="chances.epg.commons.utils.HttpUtils"%>
<%@page import="chances.epg.config.EpgSiteContext"%>
<%@page import="chances.epg.commons.utils.RequestUtils"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="chances.epg.commons.utils.JSONUtils"%>
<%@page import="java.io.IOException"%>
<%@page import="java.net.MalformedURLException"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.OutputStreamWriter"%>
<%@page import="java.net.HttpURLConnection"%>
<%@page import="java.net.URL"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="org.slf4j.Logger"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String siteCode = RequestUtils.getParameter(request, "siteCode", "yunyingzhandian3");
// EpgSiteContext siteContext = EpgSiteContext.get(application, siteCode);
Logger logger = EpgLogFactory.getSystemLogger();
String contentID = RequestUtils.getParameter(request, "contentID", "");
String userId = RequestUtils.getParameter(request, "userId", "");
String token = RequestUtils.getParameter(request, "userToken", "");

String startTime = RequestUtils.getParameter(request, "startTime", "");
String endTime = RequestUtils.getParameter(request, "endTime", "");
String contentType = RequestUtils.getParameter(request, "contentType", "");

// String authUrl = siteContext.getString("vod.play.url");
String authUrl = "http://121.31.12.182:8004/getVODPlayUrl";
if(contentType.equals("channel")){
	authUrl = "http://121.31.12.182:8004/getChannelPlayUrl";
}else if(contentType.equals("schedule")){
	authUrl = "http://121.31.12.182:8004/getPlayBackUrl";
}
if(contentType.equals("channel")){
	authUrl = URLUtils.appendParam(authUrl, "channelCode", contentID);
}else if(contentType.equals("schedule")){
	authUrl = URLUtils.appendParam(authUrl, "channelCode", contentID);
	authUrl = URLUtils.appendParam(authUrl, "startTime", startTime);
	authUrl = URLUtils.appendParam(authUrl, "endTime", endTime);
}else{
	authUrl = URLUtils.appendParam(authUrl, "contentID", contentID);
}
authUrl = URLUtils.appendParam(authUrl, "userId", userId);
authUrl = URLUtils.appendParam(authUrl, "token", token);
authUrl = URLUtils.appendParam(authUrl, "clientIP", RequestUtils.getRemoteIpAddr(request));
logger.debug("authUrl={}",authUrl);
String result = getRequest(authUrl);
logger.debug("play result={}",result);
out.clear();
if(StringUtils.isNotBlank(result)) {
	out.println(result);
} else {
	Map<String,String> playResult = new HashMap<String,String>();
	playResult.put("result","-99");
	out.println(JSONUtils.fromObject(playResult));
}
out.flush();
%>
<%!
public static String getRequest(String url) {
	String output;
	StringBuffer resultSb = new StringBuffer();
	BufferedReader br = null;
	HttpURLConnection conn = null;
	try {
		URL aUrl = new URL(url);
		conn = (HttpURLConnection) aUrl.openConnection();
		conn.setReadTimeout(3000);
		conn.setRequestMethod("GET");
		conn.setRequestProperty("Content-Type", "application/json;charset=utf-8");
		conn.setUseCaches(false);
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