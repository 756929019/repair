package org.water.socket;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Date;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.commons.lang.StringUtils;
import org.water.common.Constants;
import org.water.dao.DaoController;
import org.water.dao.DaoIn;
import org.water.dao.DaoOut;
import org.water.dao.TimedTaskS01Dao;
import org.water.model.SocketMsg;

public class SocketServer implements ServletContextListener {

	private SocketThread socketThread;
	private TimedTaskThread timedTaskThread;
	public static JSONArray timedTask;
	
	@Override
	public void contextDestroyed(ServletContextEvent arg0) {
		System.out.println("contextDestroyed开始："+CommonSocket.GetLogSystemTime());
		if (socketThread != null && socketThread.isInterrupted()) {
			socketThread.closeServerSocket();
			socketThread.interrupt();
		}

		if (timedTaskThread != null && timedTaskThread.isInterrupted()) {
			timedTaskThread.destroyTimedTask();
			timedTaskThread.interrupt();
		}
		System.out.println("contextDestroyed结束："+CommonSocket.GetLogSystemTime());
	}

	@Override
	public void contextInitialized(ServletContextEvent arg0) {
		// ServletContext servletContext = arg0.getServletContext();
		CommonSocket cs = new CommonSocket();
		cs.InitSocketConfigInfo();
		System.out.println("contextInitialized开始："+CommonSocket.GetLogSystemTime());
		if (timedTaskThread == null) {
			System.out.println("===>开始启动定时任务线程");
			timedTaskThread = new TimedTaskThread();
			timedTaskThread.start();
		}
		
		System.out.println("===>服务加载完成,开始启动Socket线程");
		if (socketThread == null) {
			socketThread = new SocketThread();
			socketThread.start();
		}
		System.out.println("contextInitialized结束："+CommonSocket.GetLogSystemTime());
	}

	private class PServer implements Runnable {

		private Socket socket;

		public PServer(Socket sock) {
			socket = sock;
			new Thread(this).start();
		}

		public void run() {
			System.out.println(CommonSocket.GetLogSystemTime());
			System.out.println("一个客户端连接ip:" + socket.getInetAddress());
			try {
				// 读取客户端数据
				DataInputStream input = new DataInputStream(
						socket.getInputStream());
				// 向客户端发送数据
				DataOutputStream out = new DataOutputStream(
						socket.getOutputStream());

				// 读取客户端数据
				int firstChar = input.read();// 只有读取一次后
												// available才可以使用，但是获取的大小不包含第一次读取的数据
				int size = input.available();//
				byte[] bt = new byte[size + 1];// 声明一个完整长度的字节数组
				bt[0] = (byte) firstChar;// 数组第一位赋值
				input.read(bt, 1, size);// 数组后面的数据赋值

				String msg = new String(bt, 0, size + 1, "UTF-8");// 转换字节数组为字符串
				System.out.println(msg);
				JSONObject json = JSONObject.fromObject(msg);
				SocketMsg smsg = new SocketMsg();
				if (json.containsKey("dbhost")) {
					// 数据库触发器发来的消息
					smsg.setUnitid(json.get("unitid").toString());
					smsg.setTime(json.get("time").toString());
					smsg.setNum("1");
					smsg.setStatus(json.get("status").toString());
					smsg.setTab(json.get("tabname")
							.toString().toUpperCase());
					smsg.setWorkid(json.get("callinfoid").toString());
					smsg.setWorktype(json.get("worktype").toString());
					smsg.setInfotype(json.get("infotype").toString());
					smsg.setFinishtime(json.get("finishtime").toString());
					smsg.setContent(json.get("memo").toString());
					if ("T_WORKPROCESSINFO".equals(json.get("tabname")
							.toString().toUpperCase())) {
						if ("3".equals(json.get("status").toString())) {
							// 来单
							smsg.setType("new");
							smsg.setLevel("1");
						} else if ("2".equals(json.get("status").toString())) {
							
							// 自报驳回
							if(json.get("callinfoid").toString().length()==17)
							{
								if("8".equals(json.get("callinfoid").toString().substring(14,15))
										||"9".equals(json.get("callinfoid").toString().substring(14,15)))
								{
									//集团威立雅不再查询，直接发送删除消息
									smsg.setType("del");
									smsg.setLevel("3");
								}
								else
								{
									//根据受理人找到受理单位，对受理单位是自报驳回，对承办单位是删除
									String unit = CommonSocket.GetUserUnit(json.get("callinfoid").toString().substring(14));
									if(json.get("unitid").toString().equals(unit))
									{
										//同一部门只发自报驳回
										smsg.setType("reject");
										smsg.setLevel("3");
									}
									else
									{
										//直接发送一条删除的消息
										SocketMsg smsg_del = smsg;
										smsg_del.setType("del");
										smsg_del.setLevel("3");
										CommonSocket.pushMsg(smsg);
										
										//对受理单位发送驳回，
										smsg.setUnitid(unit);
										smsg.setType("reject");
										smsg.setLevel("3");
									}
								}
							}
							else
							{
								//12319直接发送删除消息
								smsg.setType("del");
								smsg.setLevel("3");
							}
							
						} else if ("12".equals(json.get("status").toString())) {
							// 结果驳回
							smsg.setType("rejectresult");
							smsg.setLevel("2");
						} else if ("5".equals(json.get("status").toString())) {
							// 已经接收的工单是否加入工单即将超时未填写结果计时器
							if(!Constants.INFORMATIONTYPE_102.equals(json.get("infotype").toString()))
							{
								//非督办/	
							timedTaskThread.addTimedTask(json);
							}
							//删除来单消息
							smsg.setType("del");
						} else if ("6".equals(json.get("status").toString())||"7".equals(json.get("status").toString())||"9".equals(json.get("status").toString())||"13".equals(json.get("status").toString())) {
							// 已经最终审核的单子，页面去掉该单子消息
							if("1".equals(json.get("finish").toString()))
							{
								smsg.setType("del");
							}
							if("7".equals(json.get("status").toString())||"9".equals(json.get("status").toString()))
							{
								// 已经填写结果的工单是即将超时未填写结果计时器中取消
								timedTaskThread.deleteTimedTask(json.get(
										"callinfoid").toString());
								
								smsg.setType("del");
							}
						}
						else if ("4".equals(json.get("status").toString())||"10".equals(json.get("status").toString())) {
							//
							smsg.setType("del");
						}
					} else if ("MAP_WORKORDER".equals(json.get("tabname")
							.toString().toUpperCase())) {
						if ("9".equals(json.get("status").toString())) {
							// 退单
							smsg.setType("back");
							smsg.setLevel("2");
						} else if ("11".equals(json.get("status").toString())) {
							// 疑难
							smsg.setType("difficult");
							smsg.setLevel("2");
						} else if ("12".equals(json.get("status").toString())) {
							// 延期
							smsg.setType("delayed");
							smsg.setLevel("2");
						}else if ("2".equals(json.get("status").toString())||"6".equals(json.get("status").toString())||"7".equals(json.get("status").toString())) {
							//
							smsg.setType("del");
						}
					}
				} else {
					smsg = (SocketMsg) JSONObject.toBean(json, SocketMsg.class);
				}
				int num = 0;
				if(StringUtils.isNotEmpty(smsg.getType()))
				{
					num = CommonSocket.pushMsg(smsg);
				}
				// 发送收到消息通知
				String s = "发送" + num + "条消息";
				out.write(s.getBytes("UTF-8"));
				out.flush();
				input.close();
				out.close();
				socket.close();
			} catch (Exception e) {
				System.out.println(CommonSocket.GetLogSystemTime());
				System.out.println("服务器PServer run 异常: " + e.getMessage());
			}
		}
	}

	private class TimedTaskThread extends Thread {
		private JSONArray TaskWorks;
		private JSONObject json;
		private SocketMsg smsg;

		public TimedTaskThread() {
			// this.servletContext = servletContext;
			if (TaskWorks == null) {
				try {
					this.TaskWorks = new JSONArray();
					this.InitTimedTask();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}

		@SuppressWarnings("static-access")
		public void run() {
			try {
				System.out.println("===>定时任务线程开启完成");
				while (!this.isInterrupted()) {
					Date sysdate = new Date();
					
					//判断在晚八点之后，直接睡眠720分
					if(StringUtils.isNotEmpty(CommonSocket.socketConfig.getTime())&&StringUtils.isNotEmpty(CommonSocket.socketConfig.getMinute())&&CommonSocket.BetweenTime(sysdate,CommonSocket.socketConfig.getTime()))
					{
						this.sleep(1000*60*Integer.valueOf(CommonSocket.socketConfig.getMinute()));
					}
					else
					{
						for (int i = 0; i < this.TaskWorks.size(); i++) {
							this.json = this.TaskWorks.getJSONObject(i);
							// 判断是否到时间
							if (CommonSocket.WillTimeOut(json.get("finishtime").toString(),sysdate)) {
								this.smsg = new SocketMsg();
								smsg.setUnitid(json.get("unitid").toString());
								smsg.setTime(json.get("time").toString());
								smsg.setNum("1");
								smsg.setType("overtime");
								smsg.setLevel("2");
								smsg.setWorkid(json.get("callinfoid").toString());
								smsg.setWorktype(json.get("worktype").toString());
								smsg.setInfotype(json.get("infotype").toString());
								smsg.setFinishtime(json.get("finishtime").toString());
								smsg.setContent(json.get("memo").toString());
								CommonSocket.pushMsg(this.smsg);
								//int num = CommonSocket.pushMsg(this.smsg);
								//System.out.println("成功发送" + num + "条定时任务");
							}
						}
					
						this.sleep(1000*60*5);
					}
				}
			} catch (Exception ex) {
				System.out.println(CommonSocket.GetLogSystemTime());
				System.out.println("TimedTaskThread err:" + ex.getMessage());
			}
		}

		/**
		 * 加载数据库中的二级数据到内存中
		 */
		private void InitTimedTask()
		{
			//预装任务集
			System.out.println("预装任务集开始");
			try {
				DaoIn in = new DaoIn();
				DaoOut out = DaoController.execute(TimedTaskS01Dao.class, in);
				if(out!=null&&out.getResultRowSize()>0)
				{
					JSONArray arr = (JSONArray)out.getData();
					for(int i = 0;i<arr.size();i++)
					{
						this.addTimedTask(arr.get(i));
					}
					System.out.println("预装任务集完成,任务数："+arr.size());
				}
			} catch (Exception e) {
				System.out.println(CommonSocket.GetLogSystemTime());
				System.out.println("InitTimedTask err 定时任务初始化数据失败");
				e.printStackTrace();
			}
		}
		
		/**
		 * 删除定时任务工单
		 * @param workid
		 */
		public void deleteTimedTask(String workid) {
			try {
				if (TaskWorks != null) {
					for (int i = 0; i < TaskWorks.size(); i++) {
						this.json = this.TaskWorks.getJSONObject(i);
						if (workid.equals(json.get("callinfoid").toString())) {
							TaskWorks.remove(i);
							break;
						}
					}
				}
				SocketServer.timedTask = TaskWorks;
			} catch (Exception ex) {
				System.out.println(CommonSocket.GetLogSystemTime());
				System.out.println("deleteTimedTask err:" + ex.getMessage());
			}
		}

		/**
		 * 添加定时任务工单信息
		 * @param obj
		 */
		public void addTimedTask(Object obj) {
			try {
				this.deleteTimedTask(((JSONObject)obj).get("callinfoid").toString());
				
				if (TaskWorks != null) {
					TaskWorks.add(obj);
				} else {
					TaskWorks = new JSONArray();
					TaskWorks.add(obj);
				}
				SocketServer.timedTask = TaskWorks;
			} catch (Exception ex) {
				System.out.println(CommonSocket.GetLogSystemTime());
				System.out.println("addTimedTask err:" + ex.getMessage());
			}
		}

		/**
		 * 销毁定时任务
		 */
		public void destroyTimedTask() {
			try {
				TaskWorks = null;
				json = null;
				smsg = null;
			} catch (Exception ex) {
				System.out.println(CommonSocket.GetLogSystemTime());
				System.out.println("destroyTimedTask err:" + ex.getMessage());
			}
		}
	}

	private class SocketThread extends Thread {
		private Integer count = 0;
		// private ServletContext servletContext;
		private ServerSocket serverSocket;

		public SocketThread() {
			// this.servletContext = servletContext;
			/*try {
				//netstat -abn 
				//TSKILL processid
				Process pro = java.lang.Runtime.getRuntime().exec("netstat -abn");
				System.out.println(pro.getOutputStream());
				InputStreamReader ir = new InputStreamReader(
						pro.getInputStream());
	            LineNumberReader input = new LineNumberReader(ir);
	 
	            String line;
	            while ((line = input.readLine()) != null) {
	                System.out.println(line);
	            }
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}*/
			if (serverSocket == null) {
				try {
					this.serverSocket = new ServerSocket(
							Integer.valueOf(CommonSocket.socketConfig.getPort()));
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}

		public void run() {
			try {
				System.out.println("===>Socket线程开启完成,开始监听端口:"
						+ CommonSocket.socketConfig.getPort());
				while (!this.isInterrupted()) {
					Socket socket = serverSocket.accept();
					count++;
					System.out.println("Server SocketThread start:" + count);
					if (socket != null) {
						/*
						 * SocketClient client = new SocketClient();
						 * client.setSocket(socket);
						 * client.setServletContext(servletContext);
						 * clientlist.add(client);
						 * //最后该客户端只有两个，一个是处理客户端消息的servlet，一个是发布工单信息的服务器
						 */
						new PServer(socket);// 处理消息
						// pushMsg(socket);// 发消息给所有用户
					}
				}
			} catch (Exception ex) {
				System.out.println(CommonSocket.GetLogSystemTime());
				System.out.println("SocketThread err:" + ex.getMessage());
			}
		}

		public void closeServerSocket() {
			try {
				if (serverSocket != null && !serverSocket.isClosed()) {
					CommonSocket.vector = null;
					serverSocket.close();
				}

			} catch (Exception ex) {
				System.out.println(CommonSocket.GetLogSystemTime());
				System.out.println("SocketThread err:" + ex.getMessage());
			}
		}
	}
}
