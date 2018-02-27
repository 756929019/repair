<%@ taglib uri="/WEB-INF/config/struts-html.tld" prefix="html"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" buffer="none" %>
<%@page import="org.water.common.Constants"%> 
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
	<head>
		<title>状态修改</title>

		<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mysystem.css">
		<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery-1.8.3.js"></script>


<script type="text/javascript">

$(document).ready(function()
		{
			
		});
		
	function submodify()
	{
		var params=$("#form1").serialize();
		
		$.ajax({
			type: "POST",
			url: "${pageContext.request.contextPath}/ErrorModifyAction.do?param=ErrorModify",
			data: encodeURI(params),
			dataType: "text",
			success: function(msg)
			{
				alert(msg);
			},
			error: function(msg)
			{
				alert(msg);
			}	
		});
	}
</script>
	</head>
	<body>
	<div>
    <div style="font-size:18px" align="center">
		状态修改
	</div>
	</div>
	<table align="center" style="width: 1020px">
	<tr>
	<td>
	 <fieldset style="width:99%">
    <legend>修改信息填写</legend>
    <form id="form1">
    <table align="center" width="75%">
    <tr>
    <td align="right">工单编号：</td>
    <td align="left">
    <input class="mytext" type="text" id="workid" name="workid"/>
    </td>
    </tr>
   <tr>
     <td align="right">修改原因：</td>
    <td align="left">
    <select id="modifyType" name="modifyType">
    <option value="1">手机故障造成的工单无法处理（工单状态改为预分派）</option>
    <option value="2">事务被死锁等原因造成的表FLAG字段出现多条0（FLAG为0数据选择废弃）</option>
    <option value="3">其它原因（工单状态修改）</option>
    </select>
    </td>
   </tr>
   <tr>
    <td align="right">状态：</td>
    <td align="left">
    <input class="mytext" type="text" id="status" name="status"/>
    </td>
     </tr>
  <tr>
  <td>&nbsp;</td>
  <td align="left">
  <input type="button" onclick="submodify();" value="提交"/>
  </td>
  </tr>
    </table>
    </form>
    </fieldset>
	</td>
	</tr>
	</table>
	
	</body>
</html>