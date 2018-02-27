package org.water.common;

import java.io.InputStream;
import java.sql.Connection;
import java.util.Properties;

import org.apache.commons.lang.StringUtils;

import com.microsoft.sqlserver.jdbc.SQLServerConnectionPoolDataSource;
import com.microsoft.sqlserver.jdbc.SQLServerException;

/** 连接池管理类 */
public class SQLServerDBPool {

	private String username = "sa"; // 用户名
	private String password = "1234"; // 密码
	private String host = "192.168.5.88"; // Server地址
	private String instance = "";
	private String database = "TapWaterJT";
	private String port = "1433";
	private SQLServerConnectionPoolDataSource ocpds;

	// 只产生一个连接池
	public static final SQLServerDBPool poolConn = new SQLServerDBPool();

	// 私有构造函数
	private SQLServerDBPool() {
		getConnectionInfo();
		setOraConnPoolDataSource();
	}

	// 获取连接设置
	private void getConnectionInfo() {
		InputStream is = null;
		Properties prop = new Properties();
		try {
			is = this.getClass().getResourceAsStream("databaseconf.properties");
			prop.load(is);

			username = prop.getProperty("username");
			password = prop.getProperty("password");
			host = prop.getProperty("host");
			instance = prop.getProperty("instance");
			database = prop.getProperty("database");
			port = prop.getProperty("port");
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
	}

	// create连接
	private SQLServerConnectionPoolDataSource setOraConnPoolDataSource() {
		try {
			ocpds = new SQLServerConnectionPoolDataSource();
			if (StringUtils.isEmpty(instance)) {
				ocpds.setURL("jdbc:sqlserver://" + host + ":" + port
						+ ";DatabaseName=" + database);
			} else {
				ocpds.setURL("jdbc:sqlserver://" + host + ";instanceName="
						+ instance + ";DatabaseName=" + database);
			}
			ocpds.setUser(username);
			ocpds.setPassword(password);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		return ocpds;
	}

	// 获取连接
	public Connection getConnection() {
		try {
			return ocpds.getConnection();
		} catch (SQLServerException e) {
			return null;
		}
	}
}