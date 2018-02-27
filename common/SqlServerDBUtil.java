package org.water.common;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.Reader;
import java.io.StringReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class SqlServerDBUtil
{
	private Connection conn = null;
    private Statement stmt = null;            
    private PreparedStatement pstmt = null; 
    ResultSet rs = null;
    private boolean isAutoCommit;
    
    public int incrementKey;

    public SqlServerDBUtil()
    {
    	conn = SQLServerDBPool.poolConn.getConnection();
    }

    public SqlServerDBUtil(boolean isAnalysis) {
    	conn = SQLServerAnalysisDBPool.poolConn.getConnection();
    }

    public SqlServerDBUtil(String type) {
    	if("IC".equals(type))
    	{
    		conn = SQLServerICDBPool.poolConn.getConnection();
    	}
    	else if("VLY".equals(type))
    	{
    		conn = SQLServerVLYDBPool.poolConn.getConnection();
    	}
    	else if("JH".equals(type))
    	{
    		conn = SQLServerJHDBPool.poolConn.getConnection();
    	}
    	else if("JN".equals(type))
    	{
    		conn = SQLServerJNDBPool.poolConn.getConnection();
    	}
    	else if("TG".equals(type))
    	{
    		conn = SQLServerTGDBPool.poolConn.getConnection();
    	}
    	else if("DG".equals(type))
    	{
    		conn = SQLServerDGDBPool.poolConn.getConnection();
    	}
    	else
    	{
    		conn = SQLServerDBPool.poolConn.getConnection();
    	}
    }
    
    /**
     * executeQuery操作，用于数据查询，主要是Select
     * @param sql 查询字段
     * @return 数据
     * @throws SQLException 捕捉错误
     */
	public ResultSet executeQuery(String sql) throws SQLException
	{
		rs = null;
		try
		{
			stmt = conn.createStatement(/*ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE*/);
			rs = stmt.executeQuery(sql);
		} 
		catch (SQLException ex)
		{
			ex.printStackTrace();
			throw ex;
		}
		return rs;
	}
	
	/**
	 * 获取系统时间
	 * @return
	 * @throws SQLException
	 * @throws ParseException 
	 */
	public Date getSysDate() throws SQLException, ParseException
	{
		Date date = null;
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		try
		{
			stmt = conn.createStatement();
			rs = stmt.executeQuery("SELECT GETDATE()");
			if(rs.next())
			{
				date = sdf.parse(rs.getString(1));
			}
		} 
		catch (SQLException ex)
		{
			ex.printStackTrace();
			throw ex;
		}
		return date;
	}
	 /**
     * executeUpdate操作，用于数据更新，主要是Update，Insert
     * @param sql 查询字段
     * @throws SQLException 捕捉错误
     */
	public int executeUpdate(String sql) throws SQLException
	{
		int count = 0;
		try
		{
			stmt = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
			count = stmt.executeUpdate(sql);
		} 
		catch (SQLException ex)
		{
			ex.printStackTrace();
			throw ex;
		}
		return count;
	}
	
	/**
     * executeUpdate操作，用于数据更新，主要是Update，Insert
     * @param sql 查询字段
     * @throws SQLException 捕捉错误
     */
	public int[] executeUpdatePstmtBatch() throws SQLException
	{
		int count[];
		try
		{
			count = pstmt.executeBatch();
			/*ResultSet rs = pstmt.getGeneratedKeys();
			while (rs.next())
			{
				incrementKey = rs.getInt(1);
			}*/
		} 
		catch (SQLException ex)
		{
			ex.printStackTrace();
			throw ex;
		}
		return count;
		
	}
	
	// 准备PreparedStatement
	public PreparedStatement pstmt(String str_sql) 
	{
        this.pstmt = null;
        try 
        {
            this.pstmt = conn.prepareStatement(str_sql, Statement.RETURN_GENERATED_KEYS);
        }
        catch (SQLException ex) 
        {
            ex.printStackTrace();
        }
        return this.pstmt;
    }
	
	/**
     * executeQueryPstmt操作,只用于PreparedStatement
     * 注意: 必须先调用pstmt()设置sql然后调用setXXX()方法设置参数,调用该方法
     * @throws SQLException 捕捉错误
     */
	public ResultSet executeQueryPstmt() throws SQLException
	{
		rs = null;
		try
		{
			rs = pstmt.executeQuery();
		} 
		catch (SQLException ex)
		{
			ex.printStackTrace();
			throw ex;
		}
		return rs;
	}
	
	/**
     * executeUpdatePstmt操作,只用于PreparedStatement
     * 注意: 必须先调用pstmt()设置sql然后调用setXXX()方法设置参数,调用该方法
     * @throws SQLException 捕捉错误
     */
	public int executeUpdatePstmt() throws SQLException
	{
		int count = 0;
		try
		{
			count = pstmt.executeUpdate();
			ResultSet rs = pstmt.getGeneratedKeys();
			while (rs.next())
			{
				incrementKey = rs.getInt(1);
			}
		} 
		catch (SQLException ex)
		{
			ex.printStackTrace();
			throw ex;
		}
		return count;
	}
	
	/**
     * 设置PrepareStatement，并同时其清空参数列表
     *
     * @param sql SQL语句
     * @throws SQLException SQL异常
     */
    public void setPrepareStatement(String sql) throws SQLException 
    {
        this.clearParameters();
        this.pstmt = this.conn.prepareStatement(sql);
    }

	/**
     * 清空PrepareStatement中的参数�?
     *
     * @throws SQLException 
     */
    public void clearParameters() throws SQLException 
    {
        if (null != this.pstmt) 
        {
            pstmt.clearParameters();
        }
    }

    // 开启事务
	public void beginTrans() throws SQLException
	{
		try
		{
			isAutoCommit = conn.getAutoCommit();
			conn.setAutoCommit(false);
		} 
		catch (SQLException ex)
		{
			ex.printStackTrace();
			throw ex;
		}
	}

	// 提交事务
	public void commit() throws SQLException
	{
		try
		{
			conn.commit();
			conn.setAutoCommit(isAutoCommit);
		} 
		catch (SQLException ex)
		{
			ex.printStackTrace();
			throw ex;
		}
	}

	// 事务回滚
	public void rollback()
	{
		try
		{
			conn.rollback();
			conn.setAutoCommit(isAutoCommit);
		} 
		catch (SQLException ex)
		{
			ex.printStackTrace();
		}
	}
	
	/**
     * 判断是否为自动提�?
     * @return boolean�?
     * @throws SQLException 
     */
    public boolean isAutoCommit() throws SQLException 
    {
        boolean result = false;
        try 
        {
            result = conn.getAutoCommit();
        }
        catch (SQLException ex) 
        {
            ex.printStackTrace();
            throw ex;
        }
        return result;
    }

	/*
     * CLOB Insert
     * inSql : Insert SQL语句或UPDATE语句
     * querySql : select SQL语句
     */
	@SuppressWarnings("deprecation")
	public void clobInsert(String inSql, String querySql, String s)	throws Exception
	{
		try
		{
			this.isAutoCommit = false;
			this.beginTrans();
			this.executeUpdate(inSql);
			rs = null;
			rs = this.executeQuery(querySql);
			while (rs.next())
			{
				oracle.sql.CLOB clob = (oracle.sql.CLOB) rs.getClob(1);
				BufferedWriter out = new BufferedWriter(clob.getCharacterOutputStream());
				// BufferedReader in = new BufferedReader(new FileReader(s)); //File
				Reader in = new StringReader(s);                              //Text
				int c;
				while ((c = in.read()) != -1)
				{
					out.write(c);
				}
				in.close();
				out.close();
			}
			this.commit();
		} 
		catch (Exception ex)
		{
			this.rollback();
			throw ex;
		}
	}
	
	/*
     *  CLOB数据的读取，将CLOB字段的内容读出返回String
     *  querySql: select clobfiled from table where ....
     *  filename:生成的文件包含路径
     *
     */
	public String clobReadForString(String querySql, String field) throws Exception
	{
		String s = "";
		try
		{
			String str;
			this.isAutoCommit = false;
			this.beginTrans();
			rs = null;
			rs = this.executeQuery(querySql);
			while (rs.next())
			{
				oracle.sql.CLOB clob = (oracle.sql.CLOB) rs.getClob(field);
				BufferedReader in = new BufferedReader(clob.getCharacterStream());
				StringBuffer buffer = new StringBuffer();
				while ((str = in.readLine()) != null)
				{
					buffer.append(str).append("\n");
				}
				s = buffer.toString();
				in.close();
			}
			this.commit();
		} 
		catch (Exception ex)
		{
			this.rollback();
			throw ex;
		}
		return s;
	}
	
   /*
    *  CLOB数据的读取，将CLOB字段的内容读出并插入到某个文件中
    *  querySql: select clobfiled from table where ....
    *  filename:生成的文件包含路径
    *
    */
	public void clobReadForFile(String querySql, String filename) throws Exception
	{
		try
		{
			this.isAutoCommit = false;
			this.beginTrans();
			rs = null;
			rs = this.executeQuery(querySql);
			while (rs.next())
			{
				oracle.sql.CLOB clob = (oracle.sql.CLOB) rs.getClob(1);
				BufferedReader in = new BufferedReader(clob.getCharacterStream());
				BufferedWriter out = new BufferedWriter(new FileWriter(filename));
				int c;
				while ((c = in.read()) != -1)
				{
					out.write(c);
				}
				out.close();
				in.close();
			}
			this.commit();
		} catch (Exception ex)
		{
			this.rollback();
			throw ex;
		}
	}

	/*
     * BLOB  Insert
     * infile: 要插入的文件件包含路径
     *
     */
	@SuppressWarnings("deprecation")
	public void blobInsert(String upSql, String querySql, String infile) throws Exception
	{
		try
		{
			this.isAutoCommit = false;
			this.beginTrans();
			this.executeUpdate(upSql);
			rs = null;
			rs = this.executeQuery(querySql);
			while (rs.next())
			{
				oracle.sql.BLOB blob = (oracle.sql.BLOB) rs.getBlob(1);
				BufferedOutputStream out = new BufferedOutputStream(blob.getBinaryOutputStream());
				BufferedInputStream in = new BufferedInputStream(new FileInputStream(infile));
				int c;
				while ((c = in.read()) != -1)
				{
					out.write(c);
				}
				in.close();
				out.close();
			}
			this.commit();
		} 
		catch (Exception ex)
		{
			this.rollback();
			throw ex;
		}
	}

    /*
     * BLOB Read
     * outfile: 输出的文件名,包含路径
     *
     */
    public void blobRead(String querySql, String outfile) throws Exception 
	{
		try
		{
			this.isAutoCommit = false;
			this.beginTrans();
			rs = null;
			rs = this.executeQuery(querySql);
			while (rs.next())
			{
				oracle.sql.BLOB blob = (oracle.sql.BLOB) rs.getBlob(1);
				// 以二进制形式输出  
				BufferedOutputStream out = new BufferedOutputStream(new FileOutputStream(outfile));
				BufferedInputStream in = new BufferedInputStream(blob.getBinaryStream());
				int c;
				while ((c = in.read()) != -1)
				{
					out.write(c);
				}
				in.close();
				out.close();
			}
			this.commit();
		} 
		catch (Exception ex)
		{
			this.rollback();
			throw ex;
		}
	}
    
    /**
     * pstmt设置数据类型
     *
     * @param index 索引
     * @param value 字符串
     * @throws SQLException SQL异常
     */
	public void setString(int index, String value) throws SQLException
	{
		pstmt.setString(index, value);
	}
	public void setInt(int index, int value) throws SQLException
	{
		pstmt.setInt(index, value);
	}
	public void setBoolean(int index, boolean value) throws SQLException
	{
		pstmt.setBoolean(index, value);
	}
	public void setDouble(int index, Double value) throws SQLException
	{
		pstmt.setDouble(index, value);
	}
	public void setDate(int index, String date) throws SQLException
	{
		if (null != date && !"".equals(date) && !"null".equals(date))
			pstmt.setDate(index, java.sql.Date.valueOf(date));
		else
			pstmt.setDate(index, null);
	}
	public void setTimestamp(int index, String date) throws SQLException
	{
		if (null != date && !"".equals(date) && !"null".equals(date))
			pstmt.setTimestamp(index, java.sql.Timestamp.valueOf(date));
		else
			pstmt.setDate(index, null);
	}
	public void setLong(int index, long value) throws SQLException
	{
		pstmt.setLong(index, value);
	}
	public void setFloat(int index, float value) throws SQLException
	{
		pstmt.setFloat(index, value);
	}
	public void setBytes(int index, byte[] value) throws SQLException
	{
		pstmt.setBytes(index, value);
	}
	public void addBatch() throws SQLException
	{
		pstmt.addBatch();
	}
	

	// 释放资源
	public void close()
	{
		if (rs != null)
		{
			try
			{
				rs.close();
				rs = null;
			} 
			catch (Exception e)
			{
				e.printStackTrace();
			}
		}
		
		if (stmt != null)
		{
			try
			{
				stmt.close();
				stmt = null;
			} 
			catch (Exception e)
			{
				e.printStackTrace();
			}
		}
		
		if (pstmt != null)
		{
			try
			{
				pstmt.close();
				pstmt = null;
			} 
			catch (Exception e)
			{
				e.printStackTrace();
			}
		}
		
		if (conn != null)
		{
			try
			{
				conn.close();
				conn = null;
			} 
			catch (Exception e)
			{
				e.printStackTrace();
			}
		}
	}

}
