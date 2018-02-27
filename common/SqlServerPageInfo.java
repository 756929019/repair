package org.water.common;

public class SqlServerPageInfo extends PageInfo
{
	/**                                                                     
	 * 获取分页SQL                                                          
	 * @return                                                              
	 */   
	public String getSql()
	{
		this.doPage();
		StringBuffer sqlBuffer = new StringBuffer();
		if (0 <= beginNum)
		{
			sqlBuffer.append("SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY ");
			sqlBuffer.append(this.getOrderName());
			sqlBuffer.append(" ");
			sqlBuffer.append(this.getOrderType());
			sqlBuffer.append(")  AS RowNum, * FROM (");
			sqlBuffer.append(this.getStrOLDSQL());
			sqlBuffer.append(") b ) AS T WHERE T.RowNum>");
			sqlBuffer.append(beginNum);
			sqlBuffer.append(" and T.RowNum<= ");
			sqlBuffer.append(endNum);
			sqlBuffer.append(" ORDER BY ");
			sqlBuffer.append(this.getOrderName());
			sqlBuffer.append(" ");
			sqlBuffer.append(this.getOrderType());
			sqlBuffer.append(" OPTION (QUERYTRACEON 8649)");
		}
		else
		{
			sqlBuffer.append(this.getStrSQL());
		}
		return sqlBuffer.toString();
	}
}