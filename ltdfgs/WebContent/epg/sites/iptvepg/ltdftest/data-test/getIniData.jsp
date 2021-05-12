<%@ page contentType="text/html; charset=UTF-8" language="java" pageEncoding="UTF-8" import="java.util.*,java.text.*,java.io.*,java.sql.*" errorPage="" %>
<%@ page import="java.net.*,java.util.regex.*" %>
<%!
/**
  * 读取数据文件数据
 */
public HashMap readConfig(String path) {
    //System.out.println("readConfig："+ path);
    HashMap rsMap = new HashMap();
    int rsCode = -1;
    String rsMsg = null;
    ArrayList rsList = new ArrayList();
    long lastModifyTime = 0L;
    long fileSize = 0L;
    
    if (null==path || "".equals(path.trim())) {
        rsCode = 0x0900304;
        rsMsg = "数据文件地址为空";
    } else {
        InputStreamReader isr = null;
        BufferedReader br = null;
        try {
            File file = new File(path);
            if (true==file.exists() && true==file.isFile()) {
                lastModifyTime = file.lastModified();
                fileSize = file.length();
                //String modifyTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(lastModifyTime).toString();
                //System.out.println("lastModifyTime："+ modifyTime +" , fileSize："+ fileSize);

                isr = new InputStreamReader(new FileInputStream(file), "UTf-8");
                br = new BufferedReader(isr);
                String rl = null;
                // Pattern p = Pattern.compile("(\\d{32})");
                while ((rl = br.readLine())!=null) {
                    /* Matcher m = p.matcher(rl);
                    if (true==m.find() && null!=m.group(1)) {
                        rsList.add(m.group(1));
                    } */
                    // 00000001000000010000000096983529|《魔法森林大冒险》 第12集 嘴巴里的小仙子HD|1|爱上电视|热播动画‰动作冒险
                    if (null!=rl && !"".equals(rl.trim())) {
                        String[] iniDatas = rl.split("\\|", 6);
                        String vc = iniDatas.length>0 ? iniDatas[0] : "";
                        String vn = iniDatas.length>1 ? iniDatas[1] : "";
                        String vs = iniDatas.length>2 ? iniDatas[2] : "";
                        String cp = iniDatas.length>3 ? iniDatas[3] : "";
                        String vt = iniDatas.length>4 ? iniDatas[4] : "";
                        String cpId = vc.substring(0, 8);

                        HashMap cmap = new HashMap();
                        cmap.put("NAME", vn);
                        cmap.put("CODE", vc);
                        cmap.put("STATUS", vs);
                        cmap.put("CPID", cpId);
                        cmap.put("CPNAME", cp);
                        cmap.put("TYPES", vt.replaceAll("‰", "/"));
                        rsList.add(cmap);
                    }
                }
                if (null!=rsList && false==rsList.isEmpty()) {
                    rsCode = 0;
                    rsMsg = "success";
                } else {
                    rsCode = 0x0900304;
                    rsMsg = "暂无数据";
                }
            } else {
                rsCode = 0x0900318;
                rsMsg = "数据文件不存在";
                //System.out.println("数据文件不存在："+ path);
            }
        } catch (Exception e) {
            //e.printStackTrace();
            rsCode = 0x0900317;
            rsMsg = "数据文件读取异常";
        } finally {
            try {
                if (null!=br) { br.close();}
                if (null!=isr) { isr.close();}
            } catch (Exception e) {
                //e.printStackTrace();
            }
        }
    }

    rsMap.put("RSCODE", rsCode);
    rsMap.put("RSMSG", rsMsg);
    rsMap.put("RSDATA", rsList);
    rsMap.put("MODIFYTIME", lastModifyTime);
    rsMap.put("FILESIZE", fileSize);
    return rsMap;
}
%>
<%
long currTimeMillis = System.currentTimeMillis();
HashMap rsMap = new HashMap();
int rsCode = -1;
String rsMsg = null;
String iniPath = null;

String iniFile = null;
String realPath = request.getSession().getServletContext().getRealPath("/");
//System.out.println(realPath);
//System.out.println("autoCheck|"+ new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(currTimeMillis).toString());

String type = request.getParameter("type");
String status = request.getParameter("status");
if (null!=type && "d".equals(type.trim().toLowerCase())) { //全天校验
    iniFile = "dx_"+ new SimpleDateFormat("yyyy-MM-dd").format(currTimeMillis-24*60*60*1000).toString() +".txt";
} else if (null!=type && "h".equals(type.trim().toLowerCase())) { //分时校验
    //约定在凌晨3点切换核验前一天数据
    Calendar c = Calendar.getInstance();
    c.setTimeInMillis(currTimeMillis);
    int hour = c.get(Calendar.HOUR_OF_DAY); // 获取24小时制中的小时
    if (hour==3) {
        iniFile = "dx_"+ new SimpleDateFormat("yyyy-MM-dd").format(currTimeMillis-24*60*60*1000).toString() +".txt";
    } else {
        iniFile = "dx_"+ new SimpleDateFormat("yyyy-MM-dd_HH").format(currTimeMillis-60*60*1000).toString() +".txt";
    }
} else if (null!=type && "e".equals(type.trim().toLowerCase())) { //异常校验
    iniFile = "dx_"+ new SimpleDateFormat("yyyy-MM-dd").format(currTimeMillis-24*60*60*1000).toString() +"_e.txt";
} else {}
// iniFile = "dx_2020-11-25_e.txt"; //测试文件
// iniFile = "dx_2020-12-test.txt"; //测试文件
 iniFile = "dx_2021-03-11_23.txt"; //测试文件 

String sessionId = (String) session.getId();
String userId = (String) session.getAttribute("USERID");
//String tempName = (String) session.getAttribute("TemplateName");
//tempName = "gdtestHD2";
// System.out.println("autoCheck|IniData::"+ userId +","+ tempName +","+ iniFile +","+ sessionId);
if (null!=iniFile) {
    iniFile = "static-data/"+ iniFile;
    rsMap.put("INIFILE", iniFile);
    //if (null==userId) {
        iniPath = realPath + iniFile;
    //} else {
        //iniPath = realPath +"jsp/"+ tempName +"/"+ iniFile;
    //}
    //System.out.println("autoCheck|"+ iniPath);
    HashMap codeMap = readConfig(iniPath);
    //System.out.println("autoCheck|"+ JSONObject.fromObject(codeMap));
    long lastModifyTime = (Long) codeMap.get("MODIFYTIME");
    long fileSize = (Long) codeMap.get("FILESIZE");
    rsMap.put("MODIFYTIME", lastModifyTime);
    rsMap.put("FILESIZE", fileSize);
    rsCode = (Integer) codeMap.get("RSCODE");
    rsMsg = (String) codeMap.get("RSMSG");
    if (rsCode==0 && (null==status || !"1".equals(status.trim()))) { //如果只检测文件状态，则不进行下面读取节目数据
        ArrayList codeList = (ArrayList) codeMap.get("RSDATA");
        rsMap.put("RSDATA", codeList);
        rsMap.put("TOTAL", null==codeList || codeList.isEmpty() ? 0 : codeList.size());
    }
} else {
    rsCode = 0x0100404;
    rsMsg = "数据文件异常";
}

long currTimeMillisE = System.currentTimeMillis();
rsMap.put("RSCODE", rsCode);
rsMap.put("RSMSG", rsMsg);
rsMap.put("USERID", userId);
rsMap.put("SYSTEMTIME", currTimeMillisE);
rsMap.put("RUNTIME", currTimeMillisE-currTimeMillis);
// System.out.println("autoCheck|"+ JSONObject.fromObject(rsMap));

out.clear();
//out.print(JSONUtils.fromObject(rsMap));
out.print("{\"TOTAL\":20, \"RSCODE\":0, \"FILESIZE\":"+rsMap.get("FILESIZE")+", \"RSDATA\":[{\"TYPES\":\"横图媒资测试/特别节目1\", \"CODE\":\"00000021000000012021031102350157\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210311\"}, {\"TYPES\":\"横图媒资测试/特别节目2\", \"CODE\":\"00000021000000012021031002346929\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210310\"},{\"TYPES\":\"横图媒资测试/特别节目3\", \"CODE\":\"00000021000000012021031102350158\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210311\"}, {\"TYPES\":\"横图媒资测试/特别节目4\", \"CODE\":\"00000021000000012021031002346930\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210310\"},{\"TYPES\":\"横图媒资测试/特别节目5\", \"CODE\":\"00000021000000012021031102350159\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210311\"}, {\"TYPES\":\"横图媒资测试/特别节目6\", \"CODE\":\"00000021000000012021031002346931\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210310\"},{\"TYPES\":\"横图媒资测试/特别节目7\", \"CODE\":\"00000021000000012021031102350160\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210311\"}, {\"TYPES\":\"横图媒资测试/特别节目8\", \"CODE\":\"00000021000000012021031002346932\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210310\"},{\"TYPES\":\"横图媒资测试/特别节目9\", \"CODE\":\"00000021000000012021031102350161\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210311\"}, {\"TYPES\":\"横图媒资测试/特别节目10\", \"CODE\":\"00000021000000012021031002346933\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210310\"},{\"TYPES\":\"横图媒资测试/特别节目11\", \"CODE\":\"00000021000000012021031102350162\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210311\"}, {\"TYPES\":\"横图媒资测试/特别节目12\", \"CODE\":\"00000021000000012021031002346934\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210310\"},{\"TYPES\":\"横图媒资测试/特别节目13\", \"CODE\":\"00000021000000012021031102350163\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210311\"}, {\"TYPES\":\"横图媒资测试/特别节目14\", \"CODE\":\"00000021000000012021031002346935\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210310\"},{\"TYPES\":\"横图媒资测试/特别节目15\", \"CODE\":\"00000021000000012021031102350164\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210311\"}, {\"TYPES\":\"横图媒资测试/特别节目16\", \"CODE\":\"00000021000000012021031002346936\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210310\"},{\"TYPES\":\"横图媒资测试/特别节目17\", \"CODE\":\"00000021000000012021031102350165\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210311\"}, {\"TYPES\":\"横图媒资测试/特别节目18\", \"CODE\":\"00000021000000012021031002346937\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210310\"},{\"TYPES\":\"横图媒资测试/特别节目19\", \"CODE\":\"00000021000000012021031102350166\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210311\"}, {\"TYPES\":\"横图媒资测试/特别节目20\", \"CODE\":\"00000021000000012021031002346938\", \"STATUS\":1, \"CPID\":\"00000021\", \"CPNAME\":\"广西广电新媒体\", \"NAME\":\"开启新征程 续写新辉煌——2021全国两会特别节目20210310\"}], \"RUNTIME\":2, \"INIFILE\":\"static-data/dx_2021-03-11_23.txt\", \"SYSTEMTIME\":1620360556790, \"USERID\":null, \"RSMSG\":\"success\", \"MODIFYTIME\":1620359447507}");
out.flush();
%>