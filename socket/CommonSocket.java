package org.water.socket;

import java.io.IOException;
import java.io.InputStream;
import java.nio.CharBuffer;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Properties;
import java.util.Vector;

import net.sf.json.JSONObject;

import org.apache.commons.lang.StringUtils;
import org.water.dao.DaoController;
import org.water.dao.DaoIn;
import org.water.dao.DaoOut;
import org.water.dao.T_UserS02Dao;
import org.water.model.SocketClient;
import org.water.model.SocketConfig;
import org.water.model.SocketMsg;

public class CommonSocket {

	public static enum MsgType {
		newwork, // 来单
		reject, // 自报单驳回
		rejectresult, // 结果驳回
		back, // 退单
		delayed, // 延时
		difficult, // 疑难
		overtime, // 即将超时未填写结果（其它）
		timeout, // 预约超时
		finishtimeout, // 完工超时（户内）
		other, // 其它类型消息
		notice,
	}

	// 用来存放MessageInbound的对象，每一次连接都放个对象进去，方便对连接进行管理
	public static Vector<SocketClient> vector = new Vector<SocketClient>();

	// socket配置文件信息，系统初始化InitSocketConfigInfo
	public static SocketConfig socketConfig = new SocketConfig();

	// 加载socket配置文件信息
	protected void InitSocketConfigInfo() {
		SocketConfig sc = new SocketConfig();
		InputStream is = null;
		Properties prop = new Properties();
		try {
			is = this.getClass().getResourceAsStream("socket.properties");
			prop.load(is);

			sc.setHost(prop.getProperty("host"));
			sc.setPort(prop.getProperty("port"));
			sc.setWeb_host_i(prop.getProperty("web_host_i"));
			sc.setWeb_host_o(prop.getProperty("web_host_o"));
			sc.setWeb_port(prop.getProperty("web_port"));
			sc.setProject(prop.getProperty("project"));
			sc.setServlet(prop.getProperty("servlet"));
			sc.setTime(prop.getProperty("time"));
			sc.setMinute(prop.getProperty("minute"));
		} catch (Exception ex) {
			ex.printStackTrace();
		} finally {
			if (is != null) {
				try {
					is.close();
				} catch (Exception e) {
				}
			}
		}
		CommonSocket.socketConfig = sc;
	}

	@SuppressWarnings("deprecation")
	public static int pushMsg(SocketMsg msg) {
		// 消息处理
		if (msg == null) {
			return 0;
		} else {
			// 可以考虑时间，级别属性值为空时重新设置默认值
			if (StringUtils.isEmpty(msg.getTime())
					|| StringUtils.isEmpty(msg.getType())) {
				return 0;
			}
		}
		boolean flag = false;
		int num = 0;
		if(CommonSocket.vector==null||CommonSocket.vector.size()<1)
		{
			System.out.println("CommonSocket.vector size is 0");
			return 0;
		}
		/*else
		{
			System.out.println("CommonSocket.vector size is "+CommonSocket.vector.size());
		}*/
		for (SocketClient v : CommonSocket.vector) {
			try {
				if (StringUtils.isEmpty(msg.getUnitid())
						&& StringUtils.isEmpty(msg.getUserid())) {
					flag = true;
				} else if (StringUtils.isNotEmpty(msg.getUnitid())) {
					if (StringUtils.isNotEmpty(msg.getUserid())) {
						if (msg.getUnitid().equals(
								v.getUser().getDepartmentId())
								&& msg.getUserid().equals(
										v.getUser().getUserId())) {
							// 单位id用户id不为空，都匹配才能发送
							flag = true;
						} else {
							flag = false;
						}
					} else {
						if (v.getUser().getIsAdmin()) {
							if (v.getUser().getSubordinateUnitsSqlStr()
									.contains(msg.getUnitid())) {
								flag = true;
							} else {
								flag = false;
							}
						} else {
							if (msg.getUnitid().equals(
									v.getUser().getDepartmentId())) {
								// 单位id不为空，匹配才能发送
								flag = true;
							} else {
								flag = false;
							}
						}
					}
				} else {
					// 单位id空，用户id不为空
					flag = false;
				}

				if (flag) {
					num++;
					CharBuffer buffer = CharBuffer.wrap(JSONObject.fromObject(
							msg).toString());
					v.getMi().getWsOutbound().writeTextMessage(buffer);
				}

			} catch (Exception e) {
				System.out.println("===>当有用户连接时发消息异常:"+e.getMessage());
			}
		}
		return num;
	}

	@SuppressWarnings("deprecation")
	public static int pushMsg(SocketMsg msg, SocketClient sc) {
		// 消息处理
		if (msg == null) {
			return 0;
		} else {
			// 可以考虑时间，级别属性值为空时重新设置默认值
			if (StringUtils.isEmpty(msg.getTime())
					|| StringUtils.isEmpty(msg.getLevel())
					|| StringUtils.isEmpty(msg.getType())) {
				return 0;
			}
		}
		if (sc == null || sc.getMi() == null) {
			return 0;
		}

		int num = 0;
		try {
			num++;
			CharBuffer buffer = CharBuffer.wrap(JSONObject.fromObject(msg)
					.toString());
			sc.getMi().getWsOutbound().writeTextMessage(buffer);
		} catch (IOException e) {
			System.out.println("===>当有用户连接时发消息异常");
			num = 0;
		}
		return num;
	}

	/**
	 * 判断是否即将超时
	 * 
	 * @param finishtime
	 * @param date
	 * @return
	 */
	public static boolean WillTimeOut(String finishtime, Date sysdate) {
		boolean rs = false;
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		try {
			// DATEADD(hh," + m_TimeNum + ",getdate())>=FINISHTIME and
			// DATEDIFF(HH,FINISHTIME,GETDATE())>0
			if (CommonSocket.TimeAddHour(sysdate, 1).after(
					sdf.parse(finishtime))
					&& sysdate.before(sdf.parse(finishtime))) {
				// 系统时间加一小时在超时时间之后 并且 系统时间在超时时间之前
				// 即将超时，且，未超时
				rs = true;
			}

		} catch (ParseException e) {
			e.printStackTrace();
		}
		return rs;
		// 直接用服务器时间，不再用数据库服务器时间，每次取
	}

	/**
	 * 判断是否在当天晚八点之后
	 * 
	 * @param finishtime
	 * @param date
	 * @return
	 */
	public static boolean BetweenTime(Date sysdate, String time) {
		boolean rs = false;
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		SimpleDateFormat sdf1 = new SimpleDateFormat("yyyy-MM-dd");

		if (StringUtils.isEmpty(time)) {
			time = "20:00";
		}
		String time1 = "";
		try {
			time1 = sdf1.format(sysdate) + " " + time + ":00";
		} catch (Exception e) {
			e.printStackTrace();
		}

		try {
			if (sysdate.after(sdf.parse(time1))) {
				rs = true;
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return rs;
		// 直接用服务器时间，不再用数据库服务器时间，每次取
	}

	public static Date TimeAddHour(Date date, int hour) {
		Calendar c = Calendar.getInstance();
		c.setTime(date);
		c.add(Calendar.HOUR, hour);
		return c.getTime();
	}

	public static String GetLogSystemTime() {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss:SSS");
		return "TIME:" + sdf.format(new Date());
	}

	public static String GetUserUnit(String userid) {
		String unit = "";
		DaoIn in = new DaoIn();
		in.setData(userid);
		DaoOut out = null;
		try {
			out = DaoController.execute(T_UserS02Dao.class, in);
		} catch (Exception e) {
			e.printStackTrace();
		}
		if (out != null && out.getResultRowSize() > 0) {
			unit = (String) out.getData();
		}
		return unit;
	}
}
