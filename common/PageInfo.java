package org.water.common;

import java.util.ArrayList;
import java.util.List;

@SuppressWarnings("unchecked")
public abstract class PageInfo 
{
	 /** 当前页数*/  
    private int pageIndex;
    
    /** 每页显示记录条数*/  
	private int pageSize;
	
	/** SQL语句 */  
	private String strSQL = ""; 
	
	/** 原来的SQL语句 */  
	private String strOLDSQL = ""; 
	
	/** 设置SQL文的字段�?*/  
	private int fieldNum; 
    
	/** 开始记录数*/  
	protected int beginNum = 0;   
	    
	/** 结束记录数*/  
	protected int endNum;  
	
	/** 排序字段名称 */  
	private String orderName; 
	 
	/** 排序字段类型 */  
	private String orderType; 
	
	/** 记录总数 */  
	private int totals;
	
	/** 总页数*/  
    private int totalPage;
    
    /** 返回数据集*/ 
    private List list = new ArrayList(); 
    
    /**  
     * 构造  
     */  
    public PageInfo()   
    {   
    	
    }  
    
	/**
	 * 获取分页SQL 抽象方法，子类实体
	 * 
	 * @return String sql
	 */
	public abstract String getSql();

    /*
     * 计算开始记录数和结束记录数                                                             
     *                                                                                  
     */                                                                                 
    public void doPage()                                                                
    {
    	// 计算总页数                                                                  
        this.setTotalPage((this.totals + this.pageSize - 1) / this.pageSize);         
                                                                                       
        if (pageIndex > totalPage)                                                         
        {
        	pageIndex = 1;                                                               
        }                                                                               
        // 计算开始记录数                                                              
        this.beginNum = (this.getPageIndex() - 1) * this.pageSize;                     
        // 计算结束记录数                                                              
        this.endNum = (beginNum + pageSize) < totals ? beginNum + pageSize : totals;
    }
    
    /**                                                          
     * 设置排序SQL  
     *                                                           
     * @param sql 原始sql                                        
     */                                                          
    public void setOrderSql(String sql)                          
    {       
    	this.strOLDSQL = sql;
        if (null != this.orderName && !"".equals(this.orderName))
        {                                                        
            sql += " order by " + this.orderName;                
            sql += " " + this.orderType;                         
        }                                                        
                                                                 
        this.strSQL = sql;                                     
    }   
    
    /**                                                                
     * 获取查询总记录数的SQL                                          
     *                                                                
     * @return String 查询总记录数的SQL                               
     */                                                               
    public String getTotalSql()                                       
    {
        StringBuffer stringBuffer = new StringBuffer();               
        stringBuffer.append("select count(*) as recordCount from ("); 
        stringBuffer.append(this.strOLDSQL);                             
        stringBuffer.append(") tableName");                           
        stringBuffer.append(" OPTION (QUERYTRACEON 8649)");                               
        return stringBuffer.toString();                               
    }                                                                 

    public int getBeginNum()
	{
		return beginNum;
	}

	public void setBeginNum(int beginNum)
	{
		this.beginNum = beginNum;
	}

	public int getEndNum()
	{
		return endNum;
	}

	public void setEndNum(int endNum)
	{
		this.endNum = endNum;
	}

	/**
	 * @return the strOLDSQL
	 */
	public String getStrOLDSQL() {
		return strOLDSQL;
	}

	/**
	 * @param strOLDSQL the strOLDSQL to set
	 */
	public void setStrOLDSQL(String strOLDSQL) {
		this.strOLDSQL = strOLDSQL;
	}

	public String getStrSQL()
	{
		return strSQL;
	}
	
	public void setStrSQL(String strSQL)
	{
		this.strSQL = strSQL;
	}

	public String getOrderName()
	{
		return orderName;
	}

	public void setOrderName(String orderName)
	{
		this.orderName = orderName;
	}

	public String getOrderType()
	{
		return orderType;
	}

	public void setOrderType(String orderType)
	{
		this.orderType = orderType;
	}

	public int getTotals()
	{
		return totals;
	}

	public void setTotals(int totals)
	{
		this.totals = totals;
	}

	public int getPageSize()
	{
		return pageSize;
	}

	public void setPageSize(int pageSize)
	{
		this.pageSize = pageSize;
	}

	public int getTotalPage()
	{
		return totalPage;
	}

	public void setTotalPage(int totalPage)
	{
		this.totalPage = totalPage;
	}

	public int getPageIndex()
	{
		return pageIndex;
	}

	public void setPageIndex(int pageIndex)
	{
		if (pageIndex < 1)
		{
			pageIndex = 1;
		}

		this.pageIndex = pageIndex;
	}
	
	public int getFieldNum()
	{
		return fieldNum;
	}

	public void setFieldNum(int fieldNum)
	{
		this.fieldNum = fieldNum;
	}

	public List getList()
	{
		return list;
	}

	public void setList(List list)
	{
		this.list = list;
	}
	
}
