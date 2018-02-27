package org.water.util;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import javax.servlet.ServletInputStream;

import org.apache.commons.lang.StringUtils;
import org.water.common.Constants;
import org.water.common.FtpUtils;
import org.water.common.SqlServerDBUtil;

import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;

public class CommonUtil {

	public static String readAndroidJson(ServletInputStream servletInputStream) {
		StringBuffer sb = new StringBuffer("");
		String result = "";
		try {
			BufferedReader br = new BufferedReader(new InputStreamReader(
					servletInputStream, "utf-8"));
			String temp;
			while ((temp = br.readLine()) != null) {
				sb.append(temp);
			}
			br.close();
			result = sb.toString();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}
	
	/**
	 * 日期加减分钟
	 * @param date
	 * @param renewalsdata
	 * @return
	 */
	public static Date AddMinute(Date date,int renewalsdata)
	{
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);
		calendar.add(Calendar.MINUTE, renewalsdata);
		date = calendar.getTime();
		return date;
	}
	/**
		 * 日期加减小时
		 * @param date
		 * @param renewalsdata
		 * @return
		 */
	public static Date AddHour(Date date,int renewalsdata)
		{
			Calendar calendar = Calendar.getInstance();
			calendar.setTime(date);
			calendar.add(Calendar.HOUR, renewalsdata);
			date = calendar.getTime();
			return date;
		}
	/**
	 * 日期加减月
	 * @param date
	 * @param renewalsdata
	 * @return
	 */
	public static Date AddMonth(Date date,int renewalsdata)
	{
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);
		calendar.add(Calendar.MONTH, renewalsdata);
		date = calendar.getTime();
		return date;
	}
	public static long DateDiff(Date date,Date date1)
	{
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);
		Calendar calendar1 = Calendar.getInstance();
		calendar1.setTime(date1);
		long str=calendar.getTimeInMillis()-calendar1.getTimeInMillis();
		long min = str/(1000);
		return min;
	}
	
	public static String GenerateImageToFtp(String imgStr,String fileName)
	{//对字节数组字符串进行Base64解码并生成图片
		if (imgStr == null) //图像数据为空
			return null;
		BASE64Decoder decoder = new BASE64Decoder();
		try 
		{
			//Base64解码
			byte[] b = decoder.decodeBuffer(imgStr);
			for(int i=0;i<b.length;++i)
			{
				if(b[i]<0)
				{//调整异常数据
					b[i]+=256;
				}
			}
			FtpUtils ftp = new FtpUtils();
			InputStream is = new ByteArrayInputStream(b);
			SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");
			
			String path = ftp.upload(is, sdf.format(new Date()), fileName);
			//File.separator+
			if(StringUtils.isEmpty(path))
			{
				System.out.println("imgstr:"+imgStr);
				System.out.println("fileName:"+fileName);
			}
			return path;
		} 
		catch (Exception e) 
		{
			System.out.println("imgstr:"+imgStr);
			System.out.println("fileName:"+fileName);
			e.printStackTrace();
			return null;
		}
	}
	
	public static String GetImageStr() 
	{
		//将图片文件转化为字节数组字符串，并对其进行Base64编码处理 
		String imgFile = "F:\\logo.jpg";//待处理的图片 
		InputStream in = null;
		 byte[] data = null; //读取图片字节数组 
		try
		 { 
		in = new FileInputStream(imgFile); 
		data = new byte[in.available()];
		 in.read(data);
		 in.close(); 
		} 
		catch (IOException e) 
		{
		 e.printStackTrace(); } //对字节数组Base64编码 
		BASE64Encoder encoder = new BASE64Encoder();
		return encoder.encode(data);//返回Base64编码过的字节数组字符串 
	}
	
	public static String GenerateImage(String imgStr,String fileName,String path)
	{//对字节数组字符串进行Base64解码并生成图片
		if (imgStr == null) //图像数据为空
			return null;
		BASE64Decoder decoder = new BASE64Decoder();
		try 
		{
			//Base64解码
			byte[] b = decoder.decodeBuffer(imgStr);
			for(int i=0;i<b.length;++i)
			{
				if(b[i]<0)
				{//调整异常数据
					b[i]+=256;
				}
			}
			//生成jpeg图片
			String relativePath = path;
			String imgFilePath = relativePath+File.separator+fileName;//新生成的图片
			OutputStream out = new FileOutputStream(imgFilePath);  
			out.write(b);
			out.flush();
			out.close();
			return File.separator+"UploadFiles"+File.separator+fileName;
		} 
		catch (Exception e) 
		{
			return null;
		}
	}
	
	public static String GetWorkNums(String workid,Date sysdate,String depid,SqlServerDBUtil db) throws SQLException
	{
		String worknum="";
		try
		{

		SimpleDateFormat sdf = new SimpleDateFormat("dd");
		SimpleDateFormat sdf1 = new SimpleDateFormat("yyyyMM");
		int num = 0;
		
		String time = sdf.format(sysdate);
		String m_Time = "";
		String m_WorkTime = "";
		if (Integer.valueOf(time)>=26)
		{
			m_WorkTime = sdf1.format(CommonUtil.AddMonth(sysdate, 1));
			m_Time = sdf1.format(sysdate) + "26000000";
		}
		if (Integer.valueOf(time) < 26)
		{
			m_WorkTime = sdf1.format(sysdate);
			m_Time = sdf1.format(CommonUtil.AddMonth(sysdate, -1)) + "26000000";
		}
		String condition = "";
		String worktype = "";
		StringBuffer sql = new StringBuffer();
		sql.append("SELECT F_NEW_WORKTYPE,F_WORKORDERNO FROM T_CALLINFO WHERE F_FLAG = '0' AND F_CALLINFOID = '");
		sql.append(workid);
		sql.append("'");
		db.pstmt(sql.toString());
		ResultSet rs = db.executeQueryPstmt();
		String oldworkno = "";
		while (rs.next()) {
			worktype = rs.getString("F_NEW_WORKTYPE");
			oldworkno = rs.getString("F_WORKORDERNO");
		}
		if(StringUtils.isNotEmpty(oldworkno))
		{
			//该条工单已经有小编号，属于多次下派，不再生成
			return "";
		}
		/* switch (Integer.valueOf(worktype))
		{
			case 110000:
			case 120000:
			case 150000:
			case 160000:
				condition = "F_WORKTYPE in ('110000','120000','150000','160000')";
				break;
			case 140000:
				condition = "F_WORKTYPE='140000'";
				break;
			case 130000:
				condition = "F_WORKTYPE='130000'";
				break;
			case 310000:
			case 320000:
			case 330000:
			case 340000:
			case 410000:
				condition = "F_WORKTYPE in ('310000','320000','330000','340000','410000')";
				break;
			case 170000:
				condition = "F_WORKTYPE ='170000'";
				break;
			default:
				condition = "1=1";
				break;
		}*/
		switch (Integer.valueOf(worktype))
		{
			case 610001:
			case 620002:
			case 620007:
			case 630006:
			case 640005:
			case 650004:
			case 670003:
			case 110000:
			case 130000:
				condition = "1=1";	
				//condition = "F_NEW_WORKTYPE IN ('610001','620002','620007','630006','640005','650004','670003','110000','130000')";
					break;
			default:
				condition = "1=1";
				break;
		}
		sql = new StringBuffer();
		sql.append("SELECT max(CAST(SUBSTRING(F_WORKORDERNO,7,4) AS INT)) FROM T_CALLINFO WHERE F_FLAG = '0' AND F_CHARGEDEPART = '"+depid+"' AND ");
	  sql.append(condition);
	  
		sql.append(" AND SUBSTRING(F_WORKORDERNO,0,7)='");
	  sql.append(m_WorkTime);
	  sql.append("'");
	  
	  sql.append(" AND F_RECEIVETIME>'");
	  sql.append(m_Time);
	  sql.append("'");
	  //sql.append("' group by F_WORKORDERNO having LEN(MAX(F_WORKORDERNO))=10 order by F_WORKORDERNO desc");
	  db.pstmt(sql.toString());
	  rs = db.executeQueryPstmt();
		if (rs.next()) {
			num = rs.getInt(1);
		}
		else
		{
			num=0;
		}
		num=num+1;
		worknum = m_WorkTime + ConvertID(num, 4);
		System.out.println(sql.toString());
		System.out.println("GetWorkNums->callinfoid:"+workid+"->date:"+sysdate.toString()+"->worktype:"+worktype+"->worknum:"+worknum);
		
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		return worknum;
	}
	
	public static String GetFlowID(String workid,Date sysdate,SqlServerDBUtil db) throws SQLException 
	{
		String flowid = "";
		String worktype = "";
		try
		{
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
		String condition = "";
		
		StringBuffer sql = new StringBuffer();
		sql.append("SELECT F_WORKTYPE FROM T_CALLINFO WHERE F_FLAG = '0' AND F_CALLINFOID = '");
		sql.append(workid);
		sql.append("'");
		db.pstmt(sql.toString());
		ResultSet rs = db.executeQueryPstmt();
		
		while (rs.next()) {
			worktype = rs.getString("F_WORKTYPE");
		}
		switch (Integer.valueOf(worktype))
		{
			case 110000:
			case 120000:
			case 150000:
			case 160000:
				condition = "f_worktype in ('110000','120000','150000','160000')";
				break;
			case 140000:
				condition = "f_worktype='140000'";
				break;
			case 130000:
				condition = "f_worktype='130000'";
				break;
			case 310000:
			case 320000:
			case 330000:
			case 340000:
			case 410000:
				condition = "f_worktype in ('310000','320000','330000','340000','410000')";
				break;
			case 170000:
				condition = "f_worktype ='170000'";
				break;
			default:
				condition = "1=1";
				break;
		}
		
		int num = 0;
		//按照老系统写的逻辑，感觉编号规则有误，暂时不清楚在哪用到编号
		sql = new StringBuffer();
		sql.append("SELECT max(f_flowid) FROM T_CALLINFO WHERE convert(varchar(20),getdate(),112)=substring(f_flowid,7,8) and f_flag='0' AND ");
		sql.append(condition);
		db.pstmt(sql.toString());
		rs = db.executeQueryPstmt();
		if (rs.next()) {
			sql = new StringBuffer();
			sql.append("SELECT max(CAST(SUBSTRING(f_flowid,15,4) AS INT)) FROM T_CALLINFO WHERE convert(varchar(20),getdate(),112)=substring(f_flowid,7,8) and f_flag='0' AND ");
			sql.append(condition);
			db.pstmt(sql.toString());
			rs = db.executeQueryPstmt();
			if (rs.next()) 
			{
				num = rs.getInt(1)+1;
			}
			else
			{
				num = 1;
			}
		}
		else
		{
			num = 1;
		}
		flowid = sdf.format(sysdate) + ConvertID(num, 4);
		System.out.println("==>flowid"+flowid);
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		return worktype + flowid;
	}
	
	/**
	 * 获取工单号
	 * @param systime系统时间
	 * @param userid受理人工号
	 * @param db
	 * @return
	 */
	public static String GetWorkId(Date systime,String userid,SqlServerDBUtil db)
    {
		if(systime==null)
		{
			return "";
		}
		if(StringUtils.isEmpty(userid))
		{
			return "";
		}
		try
		{
			SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
			String workid = sdf.format(systime)+userid;
			
			StringBuffer sql = new StringBuffer();
			sql.append("SELECT COUNT(F_CALLINFOID) COU FROM T_CALLINFO");
			sql.append(" WHERE F_FLAG=0 AND F_CALLINFOID = ?");
	
			db.pstmt(sql.toString());
			db.setString(1, workid);
			ResultSet rs = db.executeQueryPstmt();
			if(rs.next())
			{
				if(rs.getInt("COU")>0)
				{
					//工单信息表找到该工单，返回空
					workid = "";
				}
			}
			return workid;
		}
		catch (Exception e) {
			e.printStackTrace();
			return "";
		}
    }
	
	/**
	 * 获取当前工单最适合的维修师傅
	 * @param ChargeDepartment承办部门
	 * @param New_WorkType工单类型
	 * @param InformationType信息类别
	 * @param New_ReachType导出类型
	 * @param FdateTime预约时间yyyy-MM-dd HH:mm:ss
	 * @param systime系统时间yyyy-MM-dd HH:mm:ss
	 * @param AreaId区片id
	 * @param db
	 * @return
	 */
	public static String GetWorkServiceMan(String ChargeDepartment,String New_WorkType, String InformationType,String New_ReachType, String FdateTime, Date systime, String AreaId,SqlServerDBUtil db)
	{
		 try{
			if(Constants.GROUP_CODE.equals(ChargeDepartment)||Constants.VEOLIA_CODE.equals(ChargeDepartment)||Constants.JINGHAI_CODE.equals(ChargeDepartment)||Constants.JINNAN_CODE.equals(ChargeDepartment))
			{
				return "";//不是小修二级单位，不需要
			}
			if(!Constants.INFORMATIONTYPE_101.equals(InformationType))
			{
				return "";//非常规信息，不需要
			}
			if(!Constants.TYPE_610001.equals(New_WorkType)
					&&!Constants.TYPE_620002.equals(New_WorkType)
					&&!Constants.TYPE_670003.equals(New_WorkType)
					&&!Constants.TYPE_650004.equals(New_WorkType)
					&&!Constants.TYPE_640005.equals(New_WorkType)
					&&!Constants.TYPE_630006.equals(New_WorkType)
					&&!Constants.TYPE_620007.equals(New_WorkType)
					&&!Constants.TYPE_110000.equals(New_WorkType)
					&&!Constants.TYPE_130000.equals(New_WorkType))
			{
				return "";//非户内外网水费，不需要
			}
			String servicetype = "";
			if(Constants.TYPE_110000.equals(New_WorkType))
			{
				//外网
				servicetype = "2";
			}
			else if(Constants.TYPE_130000.equals(New_WorkType))
			{
				//水费
				servicetype = "3";
			}
			else
			{
				//户内
				servicetype = "1";
			}
			
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			SimpleDateFormat sdf_ym = new SimpleDateFormat("yyyy-MM");
			SimpleDateFormat sdf_d = new SimpleDateFormat("dd");
			String ServiceManId = "";
			if ("01".equals(New_ReachType) || "03".equals(New_ReachType))
			{
				//预约到场或者安排到场,用预约时间，及时到场用系统时间
				systime =sdf.parse(FdateTime);
			}
			
			String ym = sdf_ym.format(systime);
			
			String day = sdf_d.format(systime);
			if ("0".equals(day.substring(0, 1)))
			{
				day = day.substring(1);
			}
			
			StringBuffer paibanSql = new StringBuffer();
			paibanSql.append("SELECT distinct T.PERSON_ID");
			paibanSql.append(" FROM T_NEW_SCHEDULING T");
			paibanSql.append(" WHERE T.SCHEDULING_DATE = '");
			paibanSql.append(ym);
			paibanSql.append("'");
			paibanSql.append(" AND T.COMPANY_ID = '");
			paibanSql.append(ChargeDepartment);
			paibanSql.append("'");
			paibanSql.append(" AND T.DAY");
			paibanSql.append(day);
			paibanSql.append(" is not null and DAY");
			paibanSql.append(day);
			paibanSql.append(" <> ''");
			
			//及时到场用户找到当前区片在线用户中,其它到场类型找到预约时间排班用户
			//第一步条件，当前工单承办单位下的员工，排班的员工，非领导员工，当前工单工种，当前区片，未完成（含预分派）工单数最少，及时导出工单要求员工在线
			StringBuffer sql = new StringBuffer();
			sql.append(" SELECT T1.PERSON_ID,Isnull(T2.cou,'0') COU from (");
			sql.append(paibanSql);
			sql.append(") T1");
			sql.append(" left join ");
			sql.append("(SELECT ServiceManID,COUNT(*) cou from MAP_WORKORDER Where WorkStatus <> '9' and WorkStatus <> '7' and WorkStatus <> '11' and WorkStatus <> '12' GROUP BY ServiceManID) AS T2 on T1.PERSON_ID = T2.ServiceManID ");
			sql.append(" left join ");
			sql.append(" MAP_SERVICEMAN T3 ON T1.PERSON_ID = T3.PersonID ");
			sql.append(" where T3.F_FLAG = '0' AND T3.IsLeader <> '2' AND T3.WORKTYPE LIKE '%,");
			sql.append(servicetype);
			sql.append(",%'");
			if(StringUtils.isNotEmpty(AreaId))
			{
				sql.append(" AND T3.AreaID = '");
				sql.append(AreaId);
				sql.append("'");
			}
			
			if ("02".equals(New_ReachType))
			{
				//及时到场找到在线的
				sql.append(" AND T3.Status = '1' ");
			}
			sql.append(" order by  COU ");

			db.pstmt(sql.toString());
			ResultSet rs = db.executeQueryPstmt();
			if(rs.next())
			{
				ServiceManId = rs.getString("PERSON_ID");
			}
			
			if (StringUtils.isEmpty(ServiceManId))
			{
				sql = new StringBuffer();
				if ("02".equals(New_ReachType))
				{
					//及时到场
					//第二步条件，当前工单承办单位下的员工，非领导员工，当前工单工种，未完成（含预分派）工单数最少，及时导出工单要求员工在线
					//比第一步去掉排班限制，在线限制改为首选在线，去掉区片限制
					sql.append("select PersonID,Status,SignStatus,isnull(t2.cou,'0') cou from MAP_SERVICEMAN t1 left join (select ServiceManID,count(*) cou from MAP_WORKORDER Where WorkStatus <> '9' and WorkStatus <> '7' and WorkStatus <> '11' and WorkStatus <> '12' group by ServiceManID) t2 on t1.PersonID=t2.ServiceManID  where  t1.F_FLAG = '0' AND t1.IsLeader <> '2' AND t1.WORKTYPE LIKE '%," + servicetype + ",%' AND t1.CompanyID = '" + ChargeDepartment + "' order by Status desc,cou asc");
				}
				else if ("01".equals(New_ReachType) || "03".equals(New_ReachType))
				{
					//预约
					//第二步条件，当前工单承办单位下的员工，排班的员工，非领导员工，当前工单工种，当前区片，未完成（含预分派）工单数最少，及时导出工单要求员工在线
					//比第一步 去掉区片限制
					sql.append("select PersonID,Status,SignStatus,isnull(t2.cou,'0') cou from (" + paibanSql + ") t left join MAP_SERVICEMAN t1 ON t.PERSON_ID = t1.PersonID left join (select ServiceManID,count(*) cou from MAP_WORKORDER Where WorkStatus <> '9' and WorkStatus <> '7' and WorkStatus <> '11' and WorkStatus <> '12' group by ServiceManID) t2 on t1.PersonID=t2.ServiceManID  where t1.F_FLAG = '0' AND t1.IsLeader <> '2' AND t1.WORKTYPE LIKE '%," + servicetype + ",%' AND t1.CompanyID = '" + ChargeDepartment + "' order by cou asc");
				}
				
				db.pstmt(sql.toString());
				rs = db.executeQueryPstmt();
				if(rs.next())
				{
					ServiceManId = rs.getString("PersonID");
				}
				
				if (StringUtils.isEmpty(ServiceManId))
				{
					//第三步，当前承办部门，当前工单工种，非领导，首选在线
					sql = new StringBuffer();
					sql.append("select PersonID,Status from MAP_SERVICEMAN where F_FLAG = '0' AND IsLeader <> '2' AND WORKTYPE LIKE '%," + servicetype + ",%' AND CompanyID = '" + ChargeDepartment + "' order by Status desc");

					db.pstmt(sql.toString());
					rs = db.executeQueryPstmt();
					if(rs.next())
					{
						ServiceManId = rs.getString("PersonID");
					}
				}
			}
			
			//如果到此还未找到合适的员工，不再查找
			return ServiceManId;
		}
		catch(Exception ex)
		{
			 ex.printStackTrace();
			 return "";
		}
	}
	
	/**
	 * 获取老工单类型
	 * @param newtype
	 * @param db
	 * @return
	 */
	public static String GetOldWorkType(String newtype,SqlServerDBUtil db)
    {
		if(newtype==null)
		{
			return "";
		}
		try
		{
			String oldtype = "";
			
			StringBuffer sql = new StringBuffer();
			sql.append("SELECT F_OLDTYPE FROM NEW_WORKTYPE");
			sql.append(" WHERE F_FLAG=0 AND F_NEWTYPE = ?");
	
			db.pstmt(sql.toString());
			db.setString(1, newtype);
			ResultSet rs = db.executeQueryPstmt();
			if(rs.next())
			{
				oldtype = rs.getString("F_OLDTYPE");
			}
			return oldtype;
		}
		catch (Exception e) {
			e.printStackTrace();
			return "";
		}
    }
	
	/**
	 * 获取二级字典
	 * @param worktype
	 * @param db
	 * @return
	 */
	public static String GetSecondClass(String worktype,SqlServerDBUtil db)
    {
		if(worktype==null)
		{
			return "";
		}
		try
		{
			String second = "";
			
			StringBuffer sql = new StringBuffer();
			sql.append("SELECT F_VALUE FROM DIC_WORKTYPE");
			sql.append(" WHERE F_FLAG=0 AND F_PARENTID = ?");
	
			db.pstmt(sql.toString());
			db.setString(1, worktype);
			ResultSet rs = db.executeQueryPstmt();
			if(rs.next())
			{
				second = rs.getString("F_VALUE");
			}
			return second;
		}
		catch (Exception e) {
			e.printStackTrace();
			return "";
		}
    }
	
	public static String ConvertID(int num,int len)
	{
		String str = num+"";
		while(str.length() < len)
		{
			str = "0"+str;
		}
		return str;
	}
}
