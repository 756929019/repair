<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="org.water.common.Constants"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html style="font-family:微软雅黑">
<!-- <meta http-equiv="X-UA-Compatible" content="IE=7" /> -->
<head>
<title>自来水设施维修系统</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<meta name="description" content="" />
<meta name="author" content="stilearning" />
<link rel="shortcut icon" href="${pageContext.request.contextPath}/images/favicon.ico" type="image/x-icon" />

<script type="text/javascript"
	src="${pageContext.request.contextPath}/js/jquery-1.8.3.js"></script>
<script type="text/javascript"
	src="${pageContext.request.contextPath}/js/jquery.easyui.min.js"></script>
<script src="${pageContext.request.contextPath}/js/bootstrap.js"></script>
<script
	src="${pageContext.request.contextPath}/js/wysihtml5/wysihtml5-0.3.0.js"></script>
<script
	src="${pageContext.request.contextPath}/js/wysihtml5/bootstrap-wysihtml5.js"></script>

<script type="text/javascript" src="${pageContext.request.contextPath}/js/jPlayer/jquery.jplayer.min.js"></script>

<!-- 底层css -->
<link href="${pageContext.request.contextPath}/css/bootstrap.css"
	rel="stylesheet" />
<link
	href="${pageContext.request.contextPath}/css/bootstrap-responsive.css"
	rel="stylesheet" />
<link
	href="${pageContext.request.contextPath}/css/bootstrap-wysihtml5.css"
	rel="stylesheet" />
<!-- 框架css -->
<link href="${pageContext.request.contextPath}/css/stilearn.css"
	rel="stylesheet" />
<link
	href="${pageContext.request.contextPath}/css/stilearn-responsive.css"
	rel="stylesheet" />
<link href="${pageContext.request.contextPath}/css/stilearn-helper.css"
	rel="stylesheet" />
<link href="${pageContext.request.contextPath}/css/stilearn-icon.css"
	rel="stylesheet" />
<!-- 动画css -->
<link href="${pageContext.request.contextPath}/css/animate.css"
	rel="stylesheet" />

<link rel="stylesheet" type="text/css"
	href="${pageContext.request.contextPath}/css/ui/themes/bootstrap/easyui.css">
<!--字体图标 css -->
<link href="${pageContext.request.contextPath}/css/font-awesome.css"
	rel="stylesheet" />

<style type="text/css">
</style>

<script type="text/javascript">
var isPlay = false;
var userid = '${sessionScope.User.userId}';
var userName = '${sessionScope.User.userName}';
var unitid = '${sessionScope.User.departmentId}';
var department = '${sessionScope.User.department}';
var Digit = {}; 
	$(document).ready(function() {
		
		if(unitid=="11101" || unitid=="21101")
		{
			$(".group_show").show();
		}
		else{
			$(".group_show").hide();
		}
		
		if(unitid=="11108")
		{
			$("#LI_TW1020,#LI_TW1003,#LI_TW1013,#LI_TW1012,#LI_TW1008,.jc_show").hide();
			LinkPage("TW1014");
		}
		else{
			$("#LI_TW1020,#LI_TW1003,#LI_TW1013,#LI_TW1012,#LI_TW1008,.jc_show").show();
		}
		
		$("#str_username").html(userName);
		$("#str_userid").html(userid);
		$("#str_unitname").html(department);
		Date.prototype.Format = function (fmt) { //author: meizz 
		    var o = {
		        "M+": this.getMonth() + 1, //月份 
		        "d+": this.getDate(), //日 
		        "h+": this.getHours(), //小时 
		        "m+": this.getMinutes(), //分 
		        "s+": this.getSeconds(), //秒 
		        "q+": Math.floor((this.getMonth() + 3) / 3), //季度 
		        "S": this.getMilliseconds() //毫秒 
		    };
		    if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
		    for (var k in o)
		    if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
		    return fmt;
		};
		$("#lab_systime").html(new Date().Format("yyyy年MM月dd日"));
		
		$("#jplayer").jPlayer({ 
			  swfPath: "${pageContext.request.contextPath}/js/jPlayer/Jplayer.swf",
			  ready: function () { 
				$(this).jPlayer("setMedia", { 
					mp3: "${pageContext.request.contextPath}/sound/gdtx.mp3"
				}); 
			  }, 
			  supplied: "mp3" 
			});
		
		$.ajax({
			type : "POST",
			url : "${pageContext.request.contextPath}/mainAction.do?param=getmemnu",
			dataType : "json",
			success : function(data) {
				var ret = data.mydata;
				var head1 = "";
				var bflag = true;
				for ( var i = 0; i < ret.length; i++) {
					var modulecname = ret[i].modulecname;

					if (i == 0) {
						head1 += "<div title='";
      head1 += modulecname;
      head1 += "' selected='true' style='padding:10px;>";
					} else if (i == ret.length - 1) {
						head1 += "<div title='";
      head1 += modulecname;
      head1 += "'>";
					} else {
						head1 += "<div title='";
      head1 += modulecname;
      head1 += "' style='overflow:auto;'>";
					}

					var head2 = "";
					var functionsArray = ret[i].functions;
					for ( var j = 0; j < functionsArray.length; j++) {
						var funcname = functionsArray[j].funcname;
						var funlink = functionsArray[j].funlink;
						var index = funlink
								.indexOf('=');
						var id = funlink.substring(
								index + 1,
								funlink.length);
						if (bflag) {
							head2 += "<p><img src='img/leaf.gif' style='vertical-align: middle;'></img>";
							head2 += "<img src='img/leaf.gif' style='vertical-align: middle;'></img>&nbsp;";
							head2 += "<a href='#' onclick='addTab(\""
									+ id
									+ "\",\""
									+ funcname
									+ "\",\""
									+ funlink
									+ "\")'>";
							bflag = false; // ?? 最先加载的第一个子菜单图片显示不出，需要放两个图片
						} else {
							head2 += "<p>";
							head2 += "<img src='img/leaf.gif' style='vertical-align: middle;'></img>&nbsp;";
							head2 += "<a href='#' onclick='addTab(\""
									+ id
									+ "\",\""
									+ funcname
									+ "\",\""
									+ funlink
									+ "\")'>";
						}

						head2 += funcname;
						head2 += "</a></p>";
					}

					head2 += "</div>";

					head1 += head2;
				}
				//background:url('images/htmlbg.gif') repeat-x top left rgb(222, 240, 227);
				$("#menubody")
						.html(
								'<div class="easyui-accordion" style="background:#FFF" fit="true" border="false">'
										+ head1
										+ '</div>');
				$.parser.parse($("#menubody"));

				/* $("#caidantab").html('<div class="easyui-accordion" style="background:#FFF" fit="true" border="false">' + head1 + '</div>'); 
				$.parser.parse($("#caidantab")); */
				/* $("#renyuantab").html('<div class="easyui-accordion" fit="true" border="false">' + head1 + '</div>'); 
				$.parser.parse($("#renyuantab")); */
			},
			error : function(msg) {
				alert("获取系统菜单出错！");
			}
		});

		$.ajax({
			type : "POST",
			url : "${pageContext.request.contextPath}/mainAction.do?param=getworks",
			dataType : "json",
			success : function(data) {
				var ret = data.work;
				if(ret!=null)
					{
						for(var i=0;i<ret.length;i++)
							{
							ChangeWorkMsgList(ret[i]);
							}
					}
				InitServer();
			},
			error : function(msg) {
				alert("数据预装出错！");
				InitServer();
			}
		});
		
		WindowSizeChange();
		$(window).resize(function() {
			WindowSizeChange();
		});
	});
	function addTab(id, title, html) {
		if ($("#" + id).attr('id') === undefined) {
			$('#tab')
					.tabs(
							'add',
							{
								title : title,
								content : '<iframe id="'
										+ id
										+ '" src="${pageContext.request.contextPath}'
										+ html
										+ '" width="100%" height="100%" frameborder="0" marginwidth="0" marginheight="0"></iframe>',
								closable : true
							});
		} else {
			$('#tab').tabs('select', title);
		}
	}

	function LinkPage(id) {
		var params = "";
		if(id.indexOf("&")>-1)
			{
				//有参数
				params = id.substring(id.indexOf("&"));
				
				id=id.substring(0,id.indexOf("&"));
			}
		if($('#mainpage').attr("src").indexOf("param="+id)>-1)
			{
				if(id=="TW1003"&&params.indexOf("workid")>-1)
				{
					mainpage.window.searchId(params.substring(8));	
				}
				if(id=="TW1021"&&params.indexOf("workid")>-1)
				{
					mainpage.window.searchId(params.substring(8));	
				}
				if(id=="TW1020"&&params.indexOf("workid")>-1)
				{
					mainpage.window.searchId(params.substring(8));	
				}
				return;
			}
		$("li[id^='LI_']").attr("class", "");
		$('#LI_' + id).attr("class", "active");
		$('#mainpage').attr("src",
				"${pageContext.request.contextPath}/skipAction.do?param=" + id+params);
	}

	function GetIframeHeight()
	{
		return $("#mainpage").height();
	}
	
	function GetIframeWidth()
	{
		return $("#mainpage").width();
	}
	
	function WindowSizeChange() {
		
		var socket_div =  $("#socket_div").height(); 
		/* if ('WebSocket' in window) {
			socket_div = 26;
		} else if ('MozWebSocket' in window) {
			socket_div = 26;
		} else {
			socket_div = 0;
		} */
		socket_div = 0;
		
		var height = $(window).height();
		var mainpage_height = height - 67 - socket_div;
		$('#mainpage').attr("height", mainpage_height);
		
		//msg_list_panel_1
		
		var msg_list_panel_1_height = height - 67 - 63 - 39;
		if(navigator.userAgent.toLowerCase().match(/chrome/) != null)
			{
				msg_list_panel_1_height = height - 67 - 63 - 39;
			}
		else
			{
				if($.browser.msie) {  
				//IE浏览器
					msg_list_panel_1_height = height - 67 - 63 - 39;  
				}else if($.browser.opera) {  
				//opera浏览器
					msg_list_panel_1_height = height - 67 - 63 - 39;  
				}else if($.browser.mozilla) {  
				//火狐浏览器  
					msg_list_panel_1_height = height - 67 - 63 - 39;  
				}else if($.browser.safari) {  
				//safari浏览器
					msg_list_panel_1_height = height - 67 - 63 - 39;  
				} 
			}
		$('#msg_list_panel_1').css("height", msg_list_panel_1_height);
		$('#msg_list_panel_2').css("height", msg_list_panel_1_height-75);
		
		//ChangeWorkMsgList();
	}
	
	function ChangeWorkMsgList(jsondata)
	{
		work_msg_num_now = 0;
		var obj = null;
		if(typeof(jsondata) == "object" && Object.prototype.toString.call(jsondata).toLowerCase() == "[object object]" && !jsondata.length)
			{
			obj = jsondata;
			}
		else
			{
			obj = $.parseJSON(jsondata);
			}
		
		if(obj.type != "other"&&obj.type != "notice"&&obj.type != "del")
			{
			work_msg_num_now+=1;
			work_msg_list.push(obj);
			}
		else
			{
			other_msg_list.push(obj);
			}
		var isremove = false;
		//添加或者删除工单列表
		$('#msg_list_panel_2 > div').each(function(i){
			if(obj.type == "del")
				{
					if($.trim($(this).find("span").find("a").html())==obj.workid)
					{
						//新状态来时删除旧的状态
						$(this).remove();	
						isremove = true;
					}
				}
			else if(obj.type == "overtime"||obj.type == "finishtimeout"||obj.type == "timeout")
				{
					//超时类数据
					if($.trim($(this).find("span").find("a").html())==obj.workid&&$.trim($(this).find("input").val())=="0")
					{
						//新状态来时删除旧的状态
						$(this).remove();	
						isremove = true;
					}
				}
			else if(obj.type == "other"||obj.type == "notice")
				{
				
				}
			else
				{
					//状态类数据
					if($.trim($(this).find("span").find("a").html())==obj.workid&&$.trim($(this).find("input").val())=="1")
					{
						//新状态来时删除旧的状态
						$(this).remove();	
						isremove = true;
					}
				}
				if($.trim($(this).find("input").val())=="1"||$.trim($(this).find("input").val())=="0")
				{
				work_msg_num_now+=1;
				}
		});
		if(isremove)
			{
				work_msg_num_now-=1;
			}
		if(obj.type != "del")
			{
				$('#msg_list_panel_2').append(GetWorkHtml(obj));	
				//您有新消息
				$('#msg_no_'+obj.time).focus();
				if(isPlay==false&&work_msg_num_now>0)
					{
					$('#msg_play_span').show();
					$('#msg_play_btn').css("color","red");
					$('#jplayer').jPlayer('play');
					JGDV_open();
					isPlay = true;	
					}
			}
		if(work_msg_num_now==0)
			{
			StopPlay_Click();
			}
		if(obj.type != "other"&&obj.type != "notice" && obj.type != "overtime")
		{
			work_msg_num_all = work_msg_list.length;
			Complete_Num();
		}
	}
	var work_msg_list = [];
	var other_msg_list = [];
	
	var work_msg_num_all = 0;
	var work_msg_num_now = 0;
	var work_com_num = 0;
	var work_com_rate = 0.0;
	function Complete_Num()
	{
		$('#label_num').html(work_msg_num_now+"条");
		if(work_msg_num_all<1||work_msg_num_all<work_msg_num_now)
			{
				return;
			}
		work_com_num = work_msg_num_all - work_msg_num_now;
		//work_com_rate = (work_com_num/work_msg_num_all).toFixed(4) * 100;
		work_com_rate = (work_com_num/work_msg_num_all) * 100;//四色五入保留2位小数 
		$('#com_no').html(work_msg_num_now);
		$('#com_num').html(work_com_num);
		$('#com_rate').html(fixedNum(work_com_rate)+"%");
		$('#com_success_rate').css("width",work_com_rate+"%");
	}
	
	function fixedNum(num)
	{
		var str = num+"";
		if(str.indexOf(".")>-1)
			{
			if(str.length-str.indexOf(".")>3)
				{
					str = str.substring(0,str.indexOf(".")+3);	
				}
			}
		return str;
	}
	
	function StopPlay_Click()
    {
		$('#msg_play_btn').css("color","");
		$('#msg_play_span').hide();
		isPlay = false;
		$('#jplayer').jPlayer('stop');
		JGDV_close();
    }
	//警灯开关
	function  JGDV_open() {
		try{
			 document.getElementById("JDOcx").JGDV_opened();
          }catch(e){
           //alert(e.toString());
		  }
      }

	 function  JGDV_close() {
		try{
             document.getElementById("JDOcx").JGDV_closed();
          }catch(e){
            //alert(e.toString());
		  }
      }
	 
	function nav_page(type,workid)
	{
		if(type=="1")
		{
		LinkPage("TW1020&workid="+workid);
		}
		else if(type=="2"){
		LinkPage("TW1003&workid="+workid);
		}
		else if(type=="3")
		{
		LinkPage("TW1014");
		}
		else if(type=="4")
		{
		LinkPage("TW1021&workid="+workid);
		}
	}
	 
	function EmptyMsgList(str)
	{
		if(str=="bohui")
			{
			$("#badge_bohui").html("");
			_badge_bohui_list = new Array();
			$("#badge_bohui_info").html("");
			}
		else if(str=="hunei")
			{
			$("#badge_hunei").html("");
			_badge_hunei_list = new Array();
			$("#badge_hunei_info").html("");
			}
		else if(str=="jiedan")
			{
			$("#badge_jiedan").html("");
			_badge_jiedan_list = new Array();
			$("#badge_jiedan_info").html("");
			}
		else if(str=="jieguobohui")
			{
			$("#badge_jieguobohui").html("");
			_badge_jieguobohui_list = new Array();
			$("#badge_jieguobohui_info").html("");
			}
	}
	
	var _badge_bohui_list = new Array();
	var _badge_hunei_list = new Array();
	var _badge_jiedan_list = new Array();
	var _badge_jieguobohui_list = new Array();
	function GetWorkHtml(obj)
	{
		var _badge_bohui = 0;
		var _badge_hunei = 0;
		var _badge_jiedan = 0;
		var _badge_jieguobohui = 0;
		var _badge_bohui_str = _badge_bohui_list.toString();
		var _badge_hunei_str = _badge_hunei_list.toString();
		var _badge_jiedan_str = _badge_jiedan_list.toString();
		var _badge_jieguobohui_str = _badge_jieguobohui_list.toString();
		var _type="";
		if($.trim($("#badge_bohui").html())=="")
			{
			_badge_bohui = 0;
			}
		else
			{
			_badge_bohui = parseInt($.trim($("#badge_bohui").html()));
			}
		if($.trim($("#badge_hunei").html())=="")
			{
			_badge_hunei = 0;
			}
		else
			{
			_badge_hunei = parseInt($.trim($("#badge_hunei").html()));
			}
		if($.trim($("#badge_jiedan").html())=="")
			{
			_badge_jiedan = 0;
			}
		else
			{
			_badge_jiedan = parseInt($.trim($("#badge_jiedan").html()));
			}
		
		if($.trim($("#badge_jieguobohui").html())=="")
			{
			_badge_jieguobohui = 0;
			}
		else
			{
			_badge_jieguobohui = parseInt($.trim($("#badge_jieguobohui").html()));
			}
		
		var _title = "";
		var _icon_class = "";
		var _status = "2";//0超时类消息，1状态类消息，2其它类消息
		//不同种类--来单，驳回等
		switch (obj.type) {
		case "new"://来单
			
			//按钮提示数目，来单加1，点击归零
			
			_title += "来单";
			_status = "1";
			//只有来单区分信息类别
			//不同信息类别-催办督办常规
			switch (obj.infotype) {
			case "101"://常规
				_title += "-常规";
				
				//只有来单常规信息区分户内外网
				//不同业务类型-外网户内。。。
				switch (obj.worktype) {
				case "<%=Constants.TYPE_110000 %>":
					if('${sessionScope.User.isShowWW}'=='true')
						{
						_type="2";
						}
					else
						{
						_type="3";	
						}
					_title += "-外网";
					_icon_class = "icofont-certificate color-green";
					break;
				case "<%=Constants.TYPE_130000 %>":
					_type="2";
					_title += "-水费";
					_icon_class = "icofont-money color-green";
					break;
				case "<%=Constants.TYPE_170000 %>":
					_type="3";
					_title += "-二供";
					_icon_class = "icofont-user-md color-green";
					break;
				case "<%=Constants.TYPE_310000 %>":
					_type="3";
					_title += "-投诉";
					_icon_class = "icofont-warning-sign color-red";
					break;
				case "<%=Constants.TYPE_320000 %>":
					_type="3";
					_title += "-建议";
					_icon_class = "icofont-exclamation-sign color-green";
					break;
				case "<%=Constants.TYPE_330000 %>":
					_type="3";
					_title += "-表扬";
					_icon_class = "icofont-thumbs-up color-green";
					break;
				case "<%=Constants.TYPE_340000 %>":
					_type="3";
					_title += "-举报";
					_icon_class = "icofont-envelope color-green";
					break;
				case "<%=Constants.TYPE_410000 %>":
					_type="3";
					_title += "-督办";
					_icon_class = "typicn-group color-green";
					break;
				case "<%=Constants.TYPE_420000 %>":
					_type="3";
					_title += "-催办";
					_icon_class = "icofont-tags color-green";
					break;
				case "<%=Constants.TYPE_510000 %>":
					_type="3";
					_title += "-咨询";
					_icon_class = "icofont-comments color-green";
					break;
				case "<%=Constants.TYPE_610001 %>":
					_type="2";
					_title += "-户内大修";
					_icon_class = "icofont-home color-green";
					break;
				case "<%=Constants.TYPE_620002 %>":
					_type="2";
					_title += "-户内小修";
					_icon_class = "icofont-home color-green";
					break;
				case "<%=Constants.TYPE_620007 %>":
					_type="2";
					_title += "-水表维修";
					_icon_class = "icofont-dashboard color-green";
					break;
				case "<%=Constants.TYPE_630006 %>":
					_type="2";
					_title += "-水表扰动";
					_icon_class = "icofont-dashboard color-green";
					break;
				case "<%=Constants.TYPE_640005 %>":
					_type="2";
					_title += "-IC卡表";
					_icon_class = "icofont-dashboard color-green";
					break;
				case "<%=Constants.TYPE_650004 %>":
					_type="2";
					_title += "-水质";
					_icon_class = "icofont-beaker color-green";
					break;
				case "<%=Constants.TYPE_670003 %>":
					_type="2";
					_title += "-水压";
					_icon_class = "icofont-beaker color-green";
					break;
				}
				
				break;
			case "102"://督办
				_type="3";
				_title += "-督办";
				_icon_class = "typicn-group color-green";
				break;
			case "103"://催办
				_type="3";
				_title += "-催办";
				_icon_class = "icofont-tags color-green";
				break;
			}
			
			break;
		case "reject"://自报单驳回
			_type="1";
			_title += "自报单驳回";
			_icon_class = "icofont-remove-sign color-red";
			_status = "1";
			break;
		case "rejectresult"://结果驳回
			if(obj.worktype.substring(0,1)=="6"||obj.worktype=="130000")
				{
					_type="2";
				}
			else
				{
					_type="4";
					if(obj.worktype=="110000"&&'${sessionScope.User.isShowWW}'=='true')
					{
					_type="2";
					}
				}
			_title += "结果驳回";
			_icon_class = "icofont-remove color-red";
			_status = "1";
			break;
		case "back"://退单
			_type="2";
			_title += "退单";
			_icon_class = "typicn-back color-silver-dark";
			_status = "1";
			break;
		case "delayed"://延时
			_type="2";
			_title += "延时单";
			_icon_class = "typicn-time color-silver-dark";
			_status = "1";
			break;
		case "difficult"://疑难
			_type="2";
			_title += "疑难单";
			_icon_class = "typicn-unknown color-silver-dark";
			_status = "1";
			break;
		case "overtime"://即将超时未填写结果
			if(obj.worktype.substring(0,1)=="6"||obj.worktype=="130000")
			{
				_type="2";
			}
			else
			{
				_type="4";
				if(obj.worktype=="110000"&&'${sessionScope.User.isShowWW}'=='true')
				{
				_type="2";
				}
			}
			_title += "即将超时未填写结果";
			_icon_class = "icofont-time color-red";
			_status = "0";
			break;
		case "timeout"://预约超时
			_title += "预约超时";
			_type="2";
			_icon_class = "icofont-time color-red";
			_status = "0";
			break;
		case "finishtimeout"://完工超时（户内）
			_title += "完工超时";
			_type="2";
			_icon_class = "icofont-time color-red";
			_status = "0";
			break;
		case "dissatisfied"://客户不满意
			_title += "客户不满意";
			_icon_class = "icofont-user color-red";
			_status = "2";
			break;
		case "other"://其它类型消息
			_title+="消息";	
			_icon_class = "icofont-tag color-silver-dark";
			_status = "2";
			break;
		case "notice"://通知，长时间显示
			_title+="通知";
			_icon_class = "icofont-bullhorn color-silver-dark";
			_status = "2";
			break;
		}
		
		if(_type=="1")
			{
				if(_badge_bohui_str.indexOf(obj.workid)<0)
				{
					_badge_bohui+=1;
					_badge_bohui_list.push(obj.workid);
				}
			}
		else if(_type=="2")
			{
				if(_badge_hunei_str.indexOf(obj.workid)<0)
				{
				_badge_hunei+=1;
				_badge_hunei_list.push(obj.workid);
				}
			}
		else if(_type=="3")
			{
				if(_badge_jiedan_str.indexOf(obj.workid)<0)
				{
				_badge_jiedan+=1;
				_badge_jiedan_list.push(obj.workid);
				}
			}
		else if(_type=="4")
			{
				if(_badge_jieguobohui_str.indexOf(obj.workid)<0)
				{
				_badge_jieguobohui+=1;
				_badge_jieguobohui_list.push(obj.workid);
				}
			}
		
		if(_badge_jiedan>0)
			{
				$("#badge_jiedan").html(_badge_jiedan);
				$("#badge_jiedan_info").html(Badge_Info_List("3",_badge_jiedan_list));
			}
		else
			{
				$("#badge_jiedan").html("");
				$("#badge_jiedan_info").html("");
			}
		if(_badge_hunei>0)
			{
				$("#badge_hunei").html(_badge_hunei);
				$("#badge_hunei_info").html(Badge_Info_List("2",_badge_hunei_list));
			}
		else
			{
				$("#badge_hunei").html("");
				$("#badge_hunei_info").html("");
			}
		if(_badge_bohui>0)
			{
				$("#badge_bohui").html(_badge_bohui);
				$("#badge_bohui_info").html(Badge_Info_List("1",_badge_bohui_list));
			}
		else
			{
				$("#badge_bohui").html("");
				$("#badge_bohui_info").html("");
			}
		
		if(_badge_jieguobohui>0)
			{
				$("#badge_jieguobohui").html(_badge_jieguobohui);
				$("#badge_jieguobohui_info").html(Badge_Info_List("4",_badge_jieguobohui_list));
			}
		else
			{
				$("#badge_jieguobohui").html("");
				$("#badge_jieguobohui_info").html("");
			}
		var str = "";
		str+='<div class="task fade in" id="msg_no_';
		str+=obj.time;
		str+='">';
		str+='<i class="';
		str+=_icon_class;
		str+='" title="';
		str+=_title;
		str+='"></i>';
		if(obj.type=="other"||obj.type=="notice")
			{
			str+='<marquee style="margin-top: 0px;margin-bottom: -6px;padding: 0px;height: 16px;line-height:16px" direction="left" scrollamount="3" onmouseover="this.stop()" onmouseout="this.start()">';
				str+='<span class="task-desc">';
				str+=obj.content;
				str+='</span>';
				str+='</marquee>';
			}
		else
			{
				str+='<span class="task-desc">';
				str+='<a href="javascript:void(0);" onclick="nav_page(\'';
				str+= _type;
				str+='\',\'';
				str+= obj.workid;
				str+= '\')">';
				str+=obj.workid;
				str+='</a></span>';
			}
		str+='<input type="hidden" value="';
		str+=_status;
		str+='"/>';
		str+='<button data-dismiss="alert" class="close">&times;</button>';
		str+='</div>';
		return str;
	}
	
	function Badge_Info_List(type,list)
	{
		var str = '<ul class="sub-sidebar-form corner-top shadow-white">';
		str+='<li class="title muted">工单列表</li>';
		for(var i = 0;i<list.length;i++)
			{
			str+='<li><a href="javascript:void(0);" title="" class="corner-all" onclick="nav_page(\'';
			str+= type;
			str+='\',\'';
			str+= list[i];
			str+= '\')">';
			str+='<i class="icofont-file"></i> <span class="sidebar-text">';
			str+=list[i];
			str+='</span>';
			str+='</a></li>';
			}
			str+='</ul>';
		return str;
	}
	
	function ExitSystem(flag)
	{
		var str = "是否退出系统？";
		if(flag=="0")
			{
			str = "是否退出系统？";
			}
		else
			{
			str = "是否退出登录？";
			}
		if(confirm(str)) {
			$.ajax({
				type: "POST",
				url: "${pageContext.request.contextPath}/ExitAction.do",
				success: function(msg)
				{
					if(msg == "success")
					{
						//断开websocket
						disconnect();
						//登录或者关闭
						if(flag=="0")
							{
							window.parent.location.href = '${pageContext.request.contextPath}/index.jsp';
							}
						else
							{
							window.parent.location.href = '${pageContext.request.contextPath}/index.jsp';	
							}
					}
					else
					{
						alert("有错误发生,msg="+msg);
					}
				},
				error: function(msg){
					alert("msg="+msg);
				}
			});
		}
		
	}
</script>

</head>
<body>
	<div id="jplayer"></div>
	<!-- 警灯obj -->
	<object id="JDOcx" style="height: 0px;width: 0px" classid="clsid:C0F95327-381D-424D-B99E-3DB9C1375F3C"></object>
	<!-- section header -->
	<header class="header" > <!--nav bar helper-->
	<div style="position:absolute;width: 100%;height: 100%;">
	<div style="float: right;height: 45px;z-index: -1;position: relative;">
		<img src="${pageContext.request.contextPath}/img/test1.png">
	</div>
	</div>
	<div class="navbar-helper" style="position: relative;">
		
		
		<div class="row-fluid">
			<!--panel site-name-->
			<div class="span1">
				<div class="panel-sitename" style="height: 55px;min-width: 530px;margin-top: 3px;">
					<div style="height: 53px;float: left;position: relative;">
					<img src="${pageContext.request.contextPath}/images/water.png"
						style="height: 53px;width: 53px;" >
					</div>
					<div style="height: 55px;margin-left:10px;float: left;position: relative;">
					<img src="${pageContext.request.contextPath}/img/sheshiweihu.png">
					</div>
				</div>
			</div>
			<!--/panel name-->

			<div class="span8" style="display: none;">
				<h2 style="margin-left: -50px">
					
				</h2>
				<!--/panel search-->
			</div>
			
			<div class="span3" style="display: none;">
				<!--panel button ext-->
				<div class="panel-ext" style="display: none;">
					<div class="btn-group">
						<!--notification-->
							<a class="btn btn-danger btn-small" data-toggle="dropdown"
							href="#" title="3 notification">管理</a>
							<ul class="dropdown-menu" role="menu" aria-labelledby="dLabel">
							<li><a tabindex="-1" href="javascript:void(0);"
							onclick="LinkPage('TW1008');">人员管理</a></li>
							<li class="divider"></li>
							<li><a tabindex="-1" href="javascript:void(0);"
							onclick="LinkPage('TW1005');">排班管理</a></li>
							<li class="divider"></li>
							<li><a tabindex="-1" href="javascript:void(0);"
							onclick="LinkPage('TW1004');">区片管理</a></li>
						</ul>
					</div>
					<div class="btn-group">
					<a class="btn btn-inverse btn-small" href="javascript:void(0);"
							onclick="LinkPage('TW1010');"> 报表</a>
					</div>
					<div class="btn-group">
						<a class="btn btn-inverse btn-small" href="javascript:void(0);"
							onclick="LinkPage('TW1009');"> 台帐</a>
					</div>
					<div class="btn-group user-group">
						<a class="dropdown-toggle" data-toggle="dropdown" href="#"> <img
							class="corner-all" align="middle" src="img/120104197704086317.jpg" style="width: 45px;height: 45px"
							title="John Doe" alt="john doe" /> <!--this for display on PC device-->
							<button class="btn btn-small btn-inverse"></button> <!--this for display on tablet and phone device-->
						</a>
						<ul class="dropdown-menu dropdown-user" role="menu"
							aria-labelledby="dLabel">
							<li>
								<div class="media">
									<a class="pull-left" href="#"> <img class="img-circle"
										src="img/120104197704086317.jpg" title="profile" alt="profile" />
									</a>
									<div class="media-body description">
										<p>
											<strong id="lab_username"></strong>
										</p>
										<p class="muted" id="lab_userid"></p>
										<p id="lab_unitname"></p>
										<p class="action">
											<a class="link" href="javascript:void(0);">在线</a> - <a class="link" href="javascript:void(0);">设置</a>
										</p>
										<a href="javascript:void(0);" class="btn btn-primary btn-small btn-block">账户信息</a>
									</div>
								</div>
							</li>
							<li class="dropdown-footer">
								<div>
									<a class="btn btn-small pull-right elusive-off" href="javascript:void(0);" onclick="ExitSystem('1');">注销</a>
									<a class="btn btn-small" href="javascript:void(0);" onclick="ExitSystem('0');">退出系统</a>
								</div>
							</li>
						</ul>
					</div>
				</div>
				<!--panel button ext-->
			</div>
			
		</div>
		
	</div>
	
	
	<!--/nav bar helper--> </header>
	
	<!-- section content -->
	<section class="section">
	<div class="row-fluid">
		<!-- span side-left -->
		<div class="span1">
			<!--side bar-->
			<aside class="side-left">
			<ul class="sidebar">
				<li class="active" id="LI_TW1020">
					<!--always define class .first for first-child of li element sidebar left-->
					<a href="javascript:void(0);" onclick="LinkPage('TW1020');"
					title="自受理">
						<div class="badge badge-important" id="badge_bohui"></div>
						<div class="helper-font-24">
							<i class="icofont-phone"></i>
						</div> <span class="sidebar-text">自受理</span>
				</a>
				<div id="badge_bohui_info">
				</div>
				</li>
				<li id="LI_TW1003"><a href="javascript:void(0);"
					onclick="LinkPage('TW1003');" title="手机派单">
						<div class="badge badge-important" id="badge_hunei"></div>
						<div class="helper-font-24">
							<i class="icofont-magnet"></i>
						</div> <span class="sidebar-text">手机派单</span>
				</a>
				<div id="badge_hunei_info">
				</div>
				</li>
				<li id="LI_TW1014"><a href="javascript:void(0);"
					onclick="LinkPage('TW1014');" title="打印派单">
						<div class="badge badge-important" id="badge_jiedan"></div>
						<div class="helper-font-24">
							<i class="icofont-share"></i>
						</div> <span class="sidebar-text">打印派单</span>
				</a>
				<div id="badge_jiedan_info">
				</div>
				</li>
				<li id="LI_TW1021"><a href="javascript:void(0);"
					onclick="LinkPage('TW1021');" title="结果录入">
						<div class="badge badge-important" id="badge_jieguobohui"></div>
						<div class="helper-font-24">
							<i class="icofont-edit"></i>
						</div> <span class="sidebar-text">结果录入</span>
				</a>
				<div id="badge_jieguobohui_info">
				</div>
				</li>
				<li id="LI_TW1013"><a href="javascript:void(0);"
					onclick="LinkPage('TW1013');" title="开关闸信息">
						<div class="helper-font-24">
							<i class="icofont-wrench"></i>
						</div> <span class="sidebar-text">开关闸信息</span>
				</a></li>
				<li id="LI_TW1012"><a href="javascript:void(0);"
					onclick="LinkPage('TW1012');" title="维修记录">
						<div class="helper-font-24">
							<i class="icofont-columns"></i>
						</div> <span class="sidebar-text">维修记录</span>
				</a></li>
				<li id="LI_TW1006"><a href="javascript:void(0);"
					onclick="LinkPage('TW1006');" title="工单查询">
						<div class="helper-font-24">
							<i class="icofont-search"></i>
						</div> <span class="sidebar-text">工单查询</span>
				</a></li>
				<li id="LI_TW1008"><a href="javascript:void(0);"
					onclick="LinkPage('TW1008');" title="人员管理">
						<div class="helper-font-24">
							<i class="icofont-user-md"></i>
						</div> <span class="sidebar-text">人员管理</span>
				</a></li>
				<li id="LI_0000"><a href="javascript:void(0);"
					title="其它">
						<div class="helper-font-24">
							<i class="icofont-th-large"></i>
						</div> <span class="sidebar-text">其它</span>
				</a>
					<ul class="sub-sidebar corner-top shadow-silver-dark">
						<li class="jc_show"><a href="javascript:void(0);"
						onclick="LinkPage('TW1010');" title="报表">
								<div class="helper-font-24">
									<i class="icofont-bar-chart"></i>
								</div> <span class="sidebar-text">报表</span>
						</a></li>
						<li style="display: none;" class="group_show"><a href="javascript:void(0);"
						onclick="LinkPage('TW1015');" title="报表明细">
								<div class="helper-font-24">
									<i class="icofont-bar-chart"></i>
								</div> <span class="sidebar-text">报表明细</span>
						</a></li>
						<li><a href="javascript:void(0);"
						onclick="LinkPage('TW1009');" title="台帐">
								<div class="helper-font-24">
									<i class="icofont-reorder"></i>
								</div> <span class="sidebar-text">台帐</span>
						</a></li>
						<li class="divider"></li>
						<li class="jc_show"><a href="javascript:void(0);"
						onclick="LinkPage('TW1007');" title="用料">
								<div class="helper-font-24">
									<i class="icofont-briefcase"></i>
								</div> <span class="sidebar-text">用料</span>
						</a></li>
						<li class="divider"></li>
						<li class="jc_show"><a href="javascript:void(0);"
						onclick="LinkPage('TW1001');" title="地图">
								<div class="helper-font-24">
									<i class="icofont-map-marker"></i>
								</div> <span class="sidebar-text">地图</span>
						</a></li>
						<li class="jc_show"><a href="javascript:void(0);"
					onclick="LinkPage('TW1004');" title="区片管理">
						<div class="helper-font-24">
							<i class="icofont-sitemap"></i>
						</div> <span class="sidebar-text">区片管理</span>
						</a></li>
						<li class="jc_show" id="LI_TW1005"><a href="javascript:void(0);"
					onclick="LinkPage('TW1005');" title="排班管理">
						<div class="helper-font-24">
							<i class="icofont-table"></i>
						</div> <span class="sidebar-text">排班管理</span>
						</a></li>	
						 <li class="divider"></li>
						<li class="jc_show"><a href="javascript:void(0);"
						onclick="LinkPage('TW1016');" title="纠错">
								<div class="helper-font-24">
									<i class="icofont-remove-circle"></i>
								</div> <span class="sidebar-text">纠错</span>
						</a></li> 
						<li style="display: none;" class="group_show"><a href="javascript:void(0);"
						onclick="LinkPage('ErrorModify');" title="错误修改">
								<div class="helper-font-24">
									<i class="icofont-remove-circle"></i>
								</div> <span class="sidebar-text">错误修改</span>
						</a></li>

					</ul></li>
			</ul>
				<div style="z-index: 99;margin-top: 30px;width:45px;height:45px;margin-left: auto;margin-right: auto; color: #ffffff;text-align: center;">
					<a href="#" onclick="ExitSystem('1');" style="text-align: center;margin-left: 0px;" class="a-btn grd-white" rel="tooltip"
							title="退出登录"> <span></span> <span><i
									class="icofont-off color-silver-dark"></i></span> <span
								class="color-silver-dark"><i
									class="icofont-off color-red"></i></span>
					</a>
				</div>
				
			</aside>
			
			
						
			
			<!--/side bar -->
		</div>
		<!-- span side-left -->

		<!-- span content -->
		<div class="span9">
			<!-- content -->
			<div class="content">

				<div class="content-breadcrumb" id="socket_div">
					<jsp:include page="./WorkMsg.jsp"></jsp:include>
				</div>
				<!-- content-body -->
				<div class="content-body">

					<iframe id="mainpage" name="mainpage"
						src="${pageContext.request.contextPath}/skipAction.do?param=TW1020"
						width="100%" height="100%"
						style="min-height: 400px; max-height: 900px" frameborder="0"
						marginwidth="0" marginheight="0" scrolling="yes"></iframe>

				</div>

			</div>
			<!-- /content -->
		</div>
		<!-- /span content -->

		<!-- span side-right -->
		<div class="span1">
			<!-- side-right -->
			<aside class="side-right"> <!-- sidebar-right -->
			<div class="sidebar-right" style="height: 100%">
				<!--sidebar-right-header-->
				<div class="sidebar-right-header">
					<div class="sr-header-right">
						<!-- <h2>
							<span class="label label-info" id="label_num">0条</span>
						</h2> -->
					</div>
					<div class="sr-header-left">
						<p class="bold"><strong id="str_username"></strong>(<strong id="str_userid"></strong>)</p>
						<p><small class="muted" id="str_unitname"></small></p>
					</div>
				</div>
				<!--/sidebar-right-header-->
				<!--sidebar-right-control-->
				<div class="sidebar-right-control">
					<a href="javascript:void(0);" onclick="StopPlay_Click();" class="msg-volume-up" id="msg_play_btn">
						<div style="position: absolute;; width: 100px; height: 30px; padding-top: 10px; padding-left: 10px:  center;">
							<div class="helper-font-24"
								style="float: left; margin-left: 10px">
								<i class="icofont-volume-up"></i>
							</div>
							<span style="float: right;display: none;" id="msg_play_span">您有新消息</span>
						</div>
					</a>
				</div>
				<!-- /sidebar-right-control-->
				<!-- sidebar-right-content -->
				<div class="sidebar-right-content"
					style="padding: 0px; overflow: hidden;" id="msg_list_panel_1">

					<div class="tab-pane fade active in" style="overflow: hidden;height: 100%">
						<div class="side-task">
							<div class="task active">
								<span class="task-header"> <img src="img/loader_16.gif" />
									<strong>事项完成度</strong>
								</span> <span class="task-desc">完成<font id="com_num">0</font>条/<font id="com_rate">0%</font>/剩余<font id="com_no">0</font>条
								</span>
								<div class="progress progress-striped active" rel="tooltip"
									title="40%">
									<div class="bar bar-success" id="com_success_rate" style="width: 0%;"></div>
								</div>
							</div>
						</div>
						<div class="side-task" style="overflow-y: auto;overflow-x:hidden;"
							id="msg_list_panel_2">

						</div>
					
					</div>
					<!--/alternative 1-->

				</div>
				<!-- /sidebar-right-content -->
			</div>
			<!-- /sidebar-right --> </aside>
			<!-- /side-right -->
		</div>
		<!-- /span side-right -->
	</div>
	</section>
</body>
</html>
