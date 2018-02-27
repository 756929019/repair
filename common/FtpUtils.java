package org.water.common;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.util.Properties;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.net.ftp.FTPClient;

public class FtpUtils {

	/** 服务器地址 */
	private String host = "";

	/** 端口号 */
	private int port = 0;

	/** 用户名 */
	private String userName = "";

	/** 密码 */
	private String password = "";

	/** 权限目录 */
	private String path = "";

	/** 创建FTP对象 */
	private FTPClient ftp = new FTPClient();

	/**
	 * 登陆FTP服务器
	 * 
	 * */
	private boolean login() throws Exception {

		try {
			// 读取配置文件
			InputStream inputStream = null;
			Properties properties = new Properties();
			inputStream = getClass()
					.getResourceAsStream("ftpConfig.properties");
			// 配置文件存在
			if (inputStream != null) {
				properties.load(inputStream);
				// 服务器地址
				host = properties.getProperty("host");
				// 端口号
				port = Integer.parseInt(properties.getProperty("port"));
				// 用户名
				userName = properties.getProperty("userName");
				// 密码
				password = properties.getProperty("password");
				// 权限目录
				path = properties.getProperty("path");
				
				// 关闭文件流
				inputStream.close();
				
				// 连接FTP服务器
				ftp.connect(host, port);
				// 登陆FTP服务器
				return ftp.login(userName, password);
				// 配置文件不存在
			} else {
				return false;
			}
			// 文件读取中异常终止
		} catch (IOException e) {

			return false;
		}
	}
	
	/**
	 * 获取ftp根路径（用于显示图片）
	 * @param ip请求ip
	 * @return
	 */
	public String GetFtpHost(String ip)
	{
		boolean isIntranet = true;
		// 读取配置文件
		InputStream inputStream = null;
		Properties properties = new Properties();
		inputStream = getClass()
				.getResourceAsStream("ftpConfig.properties");
		// 配置文件存在
		if (inputStream != null) {
			try {
				properties.load(inputStream);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				return "";
			}
			isIntranet =IsIntranet(properties.getProperty("isIntranetIp"),ip);
			// 服务器地址
			if(isIntranet)
			{
				return "ftp:"+File.separator+File.separator+properties.getProperty("host")+File.separator+properties.getProperty("rootpath")+File.separator+properties.getProperty("path");
			}else
			{
				return "ftp:"+File.separator+File.separator+properties.getProperty("host2")+File.separator+properties.getProperty("rootpath")+File.separator+properties.getProperty("path");
			}
		} else {
			return "";
		}
	}
	
	private boolean IsIntranet(String intranetIp,String ip)
	{
		System.out.println(ip);
		boolean isIntranet = true;//默认内网（内网优先）
		if(StringUtils.isNotEmpty(intranetIp)&&StringUtils.isNotEmpty(intranetIp))
		{
			try
			{
			String[] intranetIps = intranetIp.split(",");
				if(intranetIps.length>0)
				{
					for(int i=0;i<intranetIps.length;i++)
					{
						if(ip.split(".").equals(intranetIps[i]))
						{
							//找到一个符合内网的就跳出，按照内网处理
							isIntranet = true;
							break;
						}
						else
						{
							//所有都不符合内网标准才按照外网
							isIntranet = false;
						}
					}
				}
			}
			catch(Exception e)
			{
				e.printStackTrace();
				isIntranet = true;
			}
		}
		return isIntranet;
	}
	/**
	 * 文件上传
	 * 
	 * @param is
	 *            InputStream 文件流
	 * @param remotePath
	 *            FTP相对保存路径（不包括文件名）
	 * @param fileName
	 *            上传文件名
	 * */
	public String upload(InputStream is, String remotePath, String fileName)
			throws Exception {
		try {
			// 文件名非空
			if (StringUtils.isNotBlank(fileName)) {
				// 登陆FTP
				login();
				// 本地文件流
				//InputStream input = is;
				// 进入权限目录
				ftp.changeWorkingDirectory(path);
				// 层级文件夹
				String[] pathArray = remotePath.split("/");
				// 循环创建文件夹
 				for (String subPath : pathArray) {
					// 文件夹不存在
					if (!ftp.changeWorkingDirectory(subPath)) {
						// 创建文件夹
						ftp.makeDirectory(subPath);
						// 进入新创建文件夹
						ftp.changeWorkingDirectory(subPath);
						// 文件夹存在
					} else {
						// 进入已存在文件夹
						ftp.changeWorkingDirectory(subPath);
					}
				}
				// 上传文件到FTP指定目录
				ftp.setControlEncoding("UTF-8");
				//ftp.enterLocalPassiveMode();
				ftp.setFileType(FTPClient.BINARY_FILE_TYPE);
				boolean result = ftp.storeFile(
						new String(fileName.getBytes("UTF-8"), "iso-8859-1"),
						is);
				// 关闭文件流
				//input.close();
				// 释放FTP服务器
				logout();
				if (result) {
					// 上传成功
					return File.separator + remotePath + File.separator + fileName;
				} else {
					return "";
				}
				// 本地路径为空
			} else {

				return "";
			}

			// 上传过程中异常终止
		} catch (IOException e) {
			return "";
		}
	}

	/**
	 * 文件下载
	 * 
	 * @param response
	 *            HttpServletResponse
	 * @param remotePath
	 *            FTP相对保存路径（包括文件名）
	 * */
	public boolean download(HttpServletResponse response, String remotePath)
			throws Exception {

		try {

			// FTP相对文件路径为空
			if (StringUtils.isNotEmpty(remotePath)) {

				// 下载文件名
				String fileName = remotePath.substring(remotePath
						.lastIndexOf("/") + 1);

				// 下载文件路径
				String filePath = remotePath.substring(0,
						remotePath.lastIndexOf("/"));

				// 登陆FTP服务器
				login();

				// 进入下载文件夹
				ftp.changeWorkingDirectory(filePath);

				// 下载文件流
				InputStream input = ftp.retrieveFileStream(path + "/"
						+ remotePath);

				// 本地保存设置
				response.addHeader(
						"Content-Disposition",
						"attachment; filename="
								+ URLEncoder.encode(fileName, "UTF8"));
				response.setContentType("application/octet-stream");

				// 向本地写文件
				ServletOutputStream output = response.getOutputStream();
				byte[] buffer = new byte[1204];
				int byteRead;
				while ((byteRead = input.read(buffer)) != -1) {
					output.write(buffer, 0, byteRead);
				}

				// 清除缓冲区
				output.flush();

				// 关闭文件输入输出流
				input.close();
				output.close();

				// 释放FTP服务器
				logout();

				return true;

				// FTP相对文件路径为空
			} else {

				return false;
			}

			// 下载过程异常终止
		} catch (IOException e) {

			return false;
		}
	}

	/**
	 * 文件删除
	 * 
	 * @param remotePath
	 *            FTP相对保存路径（包括文件名）
	 * */
	public boolean remove(String remotePath) throws Exception {

		try {

			// 文件保存路径非空
			if (StringUtils.isNotEmpty(remotePath)) {

				// 登陆FTP服务器
				login();

				// 删除文件夹
				ftp.changeWorkingDirectory(path);
				boolean result = ftp.deleteFile(remotePath);

				// 释放FTP服务器
				logout();

				return result;

				// 文件保存路径为空
			} else {

				return false;
			}

			// 文件删除过程中异常终止
		} catch (IOException e) {

			return false;
		}
	}

	/**
	 * 释放FTP服务器
	 * 
	 * */
	public boolean exist(String remotePath) throws Exception {

		// 登陆FTP服务器
		login();

		// 检查文件路径是否存在
		if (!ftp.changeWorkingDirectory(remotePath)) {

			// 释放FTP服务器
			logout();
			return false;

		} else {

			// 释放FTP服务器
			logout();
			return true;
		}
	}

	/**
	 * 释放FTP服务器
	 * 
	 * */
	private boolean logout() throws Exception {

		try {

			// 释放FTP服务器
			ftp.logout();

			return true;

			// 释放过程中异常终止
		} catch (IOException e) {

			return false;
		}
	}
}