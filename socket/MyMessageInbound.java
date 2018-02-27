package org.water.socket;

import java.io.DataInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.UnknownHostException;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.util.Date;

import org.apache.catalina.websocket.MessageInbound;
import org.apache.catalina.websocket.WsOutbound;
import org.water.model.P_login;
import org.water.model.SocketClient;

@SuppressWarnings("deprecation")
public class MyMessageInbound extends MessageInbound {

	//记录当前客户端信息
	private SocketClient sc = null;

	//记录用户信息
	public MyMessageInbound(String ip, P_login user) {
		sc = new SocketClient();
		sc.setIp(ip);
		sc.setUser(user);
		sc.setLogintime(new Date());
		/*
		 * if (StringUtils.isEmpty(ip)) { for (SocketClient v :
		 * CommonSocket.vector) { try { CharBuffer buffer =
		 * CharBuffer.wrap("服务器发来的测试消息" + CommonSocket.vector.size());
		 * v.getMi().getWsOutbound().writeTextMessage(buffer); } catch
		 * (IOException e) { System.out.println("===>当有用户连接时发消息异常"); } } }
		 */
	}

	@Override
	protected void onBinaryMessage(ByteBuffer arg0) throws IOException {
		// TODO Auto-generated method stub
		System.out.println("===>MyMessageInbound：onBinaryMessage[参数：arg0="
				+ arg0 + "]");
	}

	@Override
	protected void onTextMessage(CharBuffer message) throws IOException {
		System.out.println(CommonSocket.GetLogSystemTime());
		System.out.println("===>MyMessageInbound：onTextMessage[参数：message="
				+ message.toString() + "]");
		Socket socket;
		String msg = "";
		try {
			// 向服务器利用Socket发送信息
			socket = new Socket(CommonSocket.socketConfig.getHost(),
					Integer.valueOf(CommonSocket.socketConfig.getPort()));
			PrintWriter output = new PrintWriter(socket.getOutputStream());

			output.write(message.toString());
			output.flush();

			// 这里是接收到Server的信息
			DataInputStream input = new DataInputStream(socket.getInputStream());
			byte[] b = new byte[1024];
			input.read(b);
			// Server返回的信息
			msg = new String(b).trim();

			output.close();
			input.close();
			socket.close();
		} catch (UnknownHostException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		// 往浏览器发送信息
		CharBuffer cb = CharBuffer.wrap(new StringBuilder(msg));
		getWsOutbound().writeTextMessage(cb);
	}

	@Override
	protected void onClose(int status) {
		System.out.println(CommonSocket.GetLogSystemTime());
		System.out.print("===>MyMessageInbound：onClose[参数：status=" + status
				+ "]");
		CommonSocket.vector.remove(sc);
		System.out.println("===>断开连接IP：" + this.sc.getIp());
		System.out.println("===>连接数：" + CommonSocket.vector.size());
	}

	@Override
	protected void onOpen(WsOutbound outbound) {
		System.out.println(CommonSocket.GetLogSystemTime());
		System.out.println("===>MyMessageInbound：onOpen[参数：outbound=" + outbound
				+ "]");
		if (sc != null) {
			sc.setMi(this);
			CommonSocket.vector.add(sc);
			System.out.println("===>建立连接IP：" + this.sc.getIp());
			System.out.println("===>连接数：" + CommonSocket.vector.size());
			
			/*SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");
			SimpleDateFormat sdf1 = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			SocketMsg smsg = new SocketMsg();
			smsg.setLevel("4");
			smsg.setType("notice");
			smsg.setContent("登录信息(工号："+sc.getUser().getUserId()+" 所属部门："+sc.getUser().getDepartment()+" IP:"+sc.getIp()+" 登录时间："+sdf1.format(new Date())+")");
			smsg.setTime(sdf.format(new Date()));
			CommonSocket.pushMsg(smsg, sc);*/
		} else {
			System.out.println("===>当有用户连接时发消息异常！");
		}

	}

}
