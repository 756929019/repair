<%@ taglib uri="/WEB-INF/config/struts-html.tld" prefix="html"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" buffer="none" %>
<%@page import="org.water.common.Constants"%> 
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
	<head>
		<title>报表明细</title>

		<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/ui/themes/bootstrap/easyui.css">
		<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/ui/themes/icon.css">
		<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/mysystem.css">
		
		<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery-2.1.3.js"></script>
		<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.easyui.min.js"></script>
		<script type="text/javascript" src="${pageContext.request.contextPath}/js/easyui-lang-zh_CN.js"></script>
<style type="text/css">
.select {
			width: 157px;
		}
		.select2 {
			width: 157px;
		} 
</style>
<script type="text/javascript">
var sysDate = new Date();
var Year = 2014;//获取完整的年份(4位)
var lmonth = 1;//获取当前月份(0-11,0代表1月)
var month = 1;
var date = 1;//获取当前日(1-31)
var unitid = '${sessionScope.User.departmentId}';
$(document).ready(function()
		{
			Year = sysDate.getFullYear();//获取完整的年份(4位)
			lmonth = sysDate.getMonth();//获取当前月份(0-11,0代表1月)
			month = parseInt(lmonth)+1;
			date = sysDate.getDate();//获取当前日(1-31)
			/* if(date<26)
				{
					lmonth = parseInt(lmonth)-1;
					month = parseInt(month)-1;
				} */
			InitDate();
				var dic_dummy1 = {"value": ""+'<%=Constants.GROUP_CODE %>'+"", "text": "集团热线中心 ", "selected": "selected"};
				var dic_dummy2 = {"value": ""+'<%=Constants.VEOLIA_CODE %>'+"", "text": "津滨威立雅客服中心", "selected": "selected"};
				var dic_dummy3 = {"value": ""+'<%=Constants.JINNAN_CODE %>'+"", "text": "津南水务公司", "selected": "selected"};
				var dic_dummy4 = {"value": ""+'<%=Constants.JINGHAI_CODE %>'+"", "text": "静海水务公司", "selected": "selected"};
				var dic_dummy5 = {"value": ""+'<%=Constants.TANGGU_CODE %>'+"", "text": "塘沽水务公司", "selected": "selected"};
			//受理部门
				$.ajax({
				type: "POST",
				url: "${pageContext.request.contextPath}/dicAction.do?param=GETUSERCHARGEDEPART",
				dataType: "json",
				success: function(data)
				{
					var ret = data.mydata;
					$('#chargedepart').empty();
					$('#chargedepart').append('<option value="">请选择</option>');
					if(ret!=null)
						{
							if(unitid=="<%=Constants.GROUP_CODE %>")
							{
								ret.unshift(dic_dummy5);
								ret.unshift(dic_dummy4);
								ret.unshift(dic_dummy3);
								ret.unshift(dic_dummy2);
								ret.unshift(dic_dummy1);
							}
							else if(unitid=="<%=Constants.VEOLIA_CODE %>")
							{
								ret.unshift(dic_dummy2);	
							}
							else if(unitid=="<%=Constants.JINNAN_CODE %>")
							{
								ret.unshift(dic_dummy3);	
							}
							else if(unitid=="<%=Constants.JINGHAI_CODE %>")
							{
								ret.unshift(dic_dummy4);		
							}
							else if(unitid=="<%=Constants.TANGGU_CODE %>")
							{
								ret.unshift(dic_dummy5);		
							}
							for(var i = 0; i < ret.length; i++)
							{
								var text = ret[i].text;
								var value = ret[i].value;
								if(unitid=="<%=Constants.GROUP_CODE %>")
								{
								if(value.indexOf("211")!=0||value=="21101")
								$('#chargedepart').append('<option value="'+value+'">'+text+'</option>');
								}
								if(unitid=="<%=Constants.VEOLIA_CODE %>")
								{
								$('#chargedepart').append('<option value="'+value+'">'+text+'</option>');	
								}
							}
						}
				},
				error: function(msg)
				{
					setTimeout(function() { 
						window.parent.addTab("error", "出错页面", '/skipAction.do?param=error');
					}, 5); 
				}
			});
		});

		function excelBtn_Click()
	    {
			var starttime = $('#starttime1').datetimebox('getValue');	
	        var endtime = $('#endtime1').datetimebox('getValue');
	        var reportid = $('#report1').val();
	        var chargedepart = $('#chargedepart').val();
	        var chargedepartname = encodeURI(encodeURI($('#chargedepart').find("option:selected").text()));
	        if(reportid==""||reportid==null||reportid==undefined||starttime==""||endtime==""||chargedepart=="")
        	{
        	alert("请选择明细并填写开始时间和结束时间、单位！");
        	return;
        	}

	        //user = encodeURI(encodeURI('${sessionScope.User.userName}'));
			//unit = encodeURI(encodeURI('${sessionScope.User.department}'));
			//unitid = encodeURI(encodeURI('${sessionScope.User.departmentId}'));
			if(unitid==null||unitid=="")
				{
				alert("会话失效，请重新登录！");
				return;
				}
	        window.open("${pageContext.request.contextPath}/TW1015Action.do?param=report&starttime="+starttime+"&endtime="+endtime+"&reportid="+reportid+"&chargedepart="+chargedepart+"&chargedepartname="+chargedepartname, "newwindow", "height=700, width=1200, top=" + (window.screen.height-700)/2 + ", left=" + (window.screen.width-1200)/2 + ", toolbar=no, menubar=no, scrollbars=no, resizable=yes, location=no, status=no");
	        /* 
			$("#formP").attr("action", "${pageContext.request.contextPath}/TW1009Action.do?param=report&starttime="+starttime+"&endtime="+endtime+"&reportid="+reportid);
			$("#formP").attr("method", "post");
			$("#formP").submit(); */
	        //window.location.href = "${pageContext.request.contextPath}/TW1009Action.do?param=report&starttime="+starttime+"&endtime="+endtime+"&reportid="+reportid;
	    }
		function report_change()
		{
			/* var reportid = $('#report1').val();
			 switch(reportid)
		        {
		        case "1":
		        case "2":
		        	InitDate();
		        	break;
		        } */
			InitDate();
		}
		function InitDate()
		{
			var reportid = $('#report1').val();
			if(lmonth==0)
    		{
    		$('#starttime1').datetimebox('setValue',(parseInt(Year)-1)+'-12-01 00:00:00');	
    		}
    	else if(lmonth==-1)
    		{
    		$('#starttime1').datetimebox('setValue',(parseInt(Year)-1)+'-11-01 00:00:00');	
    		}
    	else
    		{
    		$('#starttime1').datetimebox('setValue',Year+'-'+lmonth+'-'+'01 00:00:00');
    		}

    		$('#endtime1').datetimebox('setValue',Year+'-'+month+'-'+'01 00:00:00');	
		}
</script>
	</head>
	<body>
	<table align="center">
	<tr>
	<td>
	 <fieldset style="width:100%">
    <legend>报表明细</legend>
    <form id="formP"></form>
    <form>
    <table align="center" width="520">
    <tr  style="word-spacing: normal;height: 30px">
	    <td rowspan="5">
	    	<select style="height: 500px;width: 250px" onchange="report_change()" size="12" name="report1" id="report1">
	    	<option value="1">超时已办结（按单位）</option>
	    	<option value="2">超时未办结（按单位）</option>
	    	</select>
	    </td>
	    </tr>
	    <tr style="word-spacing: normal;height: 30px">
	    <td align="right">
	    <span>开始时间：</span></td>
	    <td align="left">
	    <input class="easyui-datetimebox" id="starttime1" name="starttime1" type="text" style="width: 150px" />
	    </td>
	    </tr>
	    <tr style="word-spacing: normal;height: 30px">
	    <td align="right">
	    <span>结束时间：</span></td>
	    <td align="left">
	    <input class="easyui-datetimebox" id="endtime1" name="endtime1" type="text" style="width: 150px" />
	    </td>
	    </tr>
	    <tr style="word-spacing: normal;height: 30px" id="serviceman">
	    <td align="right">
	    <span>单位：</span></td>
	    <td align="left">
	    <select name="chargedepart" id="chargedepart" style="width: 150px">
	    </select>
	    </td>
	    </tr>
	    <tr style="height: 360px">
	    <td align="center" colspan="2">
              <a id="excelBtn" class="easyui-linkbutton" data-options="iconCls: 'icon-excel'" href="javascript:void(0)" onclick="excelBtn_Click();">导出EXCEL</a>
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