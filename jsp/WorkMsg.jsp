<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<script type="text/javascript">
var web_host;
var web_port;
var project;
var servlet;
var intervalId = null;
var readyState = 0;
var resetnum = 0;//socket重连次数，超过5次依然未连接上，提示退出系统，连接成功清零
	function InitServer() {
		/* window.onunload= function(){
			disconnect();	
		}; */
		$.ajax({
			type : "POST",
			url : "${pageContext.request.contextPath}/mainAction.do?param=GetServerConfig",
			dataType : "json",
			success : function(data) {
				var ret = data.socketconfig;
				if(ret!=null)
					{
					web_host = ret.web_host;
					web_port = ret.web_port;
					project = ret.project;
					servlet = ret.servlet;
					startServer();
					}
				else
					{
						alert("消息服务器配置信息获取失败！");
					}
			},
			error : function(msg) {
				alert("获取系统菜单出错！");
			}
		});
	}
	var ws = null;
	function startServer() {
		resetnum++;
		if(resetnum>5)
			{
				StopTimer();
				alert('与服务器连接断开，系统尝试重连失败，将不能正常接收提醒消息，请尝试退出系统重新登录!');
				return;
			}
		try {
			var url = "ws://"+web_host+":"+web_port+"/"+project+"/"+servlet;
			if ('WebSocket' in window) {
				ws = new WebSocket(url);
			} else if ('MozWebSocket' in window) {
				ws = new MozWebSocket(url);
			} else {
				alert('浏览器不支持WebSocket,系统将不能正常接收提醒消息!');
				//是否考虑加定时刷新
				return;
			}
			ws.onopen = function() {
				//alert('Opened!');
				readyState = 1;
				//alert("连接成功");
				resetnum = 0;
				StopTimer();
			};
			// 收到服务器发送的文本消息, event.data表示文本内容  
			ws.onmessage = function(event) {
				//AnasysisMsg(event.data);
				ChangeWorkMsgList(event.data);
			};
			ws.onclose = function() {
				readyState = 0;
				//alert('与服务器连接断开，系统将不能正常接收提醒消息，请尝试退出系统重新登录!');
				//服务器主动断开连接，尝试重连
				StartTimer();
			};
			ws.onerror = function() {
				readyState = 0;
				alert('错误，该错误可能导致系统不能正常接收提醒消息，请尝试退出系统重新登录!');
				//可能服务器或者网络出现问题，不再做定时重连
				//StartTimer();
			};
		} catch (e) {
			alert(e);
		}
	}
	
	function StartTimer()
	{
		StopTimer();
		intervalId = window.setInterval("startServer()",1000*30);//30秒重连一次
	}
	
	function StopTimer()
	{
		if(intervalId!=null)
		{
			window.clearInterval(intervalId);
		}
	}
	
	function HideMsg()
	{
		var i=0;
		$("#mymarquee").children().each(function(i){
			if($(this).is(":hidden"))
				{
					i++;
				}
			 });
		if(i==$("#mymarquee").children().length)
			{
				$("#msg_marquee").hide();
			}
	}
	
	function AnasysisMsg(data)
	{
		var jsondata = $.parseJSON(data);
		
		$("#msg_marquee").show();
		if("notice"==jsondata.type)
			{
			//通知，长时间显示
			$("."+jsondata.type+"_class").show();
			var color = "";
			switch(jsondata.level)
			{
			case "1":
				color = "red";
				break;
			case "2":
				color = "#ffae00";
				break;
			case "3":
				color = "blue";
				break;
			case "4":
				default :
					color = "#000000";
			}
			$("."+jsondata.type+"_class").append('<font style="color:'+color+'">'+jsondata.content+'</font>');	
			}
		else if("other"==jsondata.type)
			{
			//及时消息
			$("."+jsondata.type+"_class").show();
			$("#"+jsondata.type+"_content").html(jsondata.content);	
			
			switch(jsondata.level)
			{
			case "1":
				$("#"+jsondata.type+"_content").css("color","red");
				break;
			case "2":
				$("#"+jsondata.type+"_content").css("color","#ffae00");
				break;
			case "3":
				$("#"+jsondata.type+"_content").css("color","blue");
				break;
			case "4":
				default :
				$("#"+jsondata.type+"_content").css("color","#000000");
			}
			
			}
		else
			{
			$("."+jsondata.type+"_class").show();
			$("#"+jsondata.type+"_num").html(jsondata.num);	
			switch(jsondata.level)
			{
			case "1":
				$("."+jsondata.type+"_class").css("color","red");
				$("#"+jsondata.type+"_num").css("color","red");
				break;
			case "2":
				$("."+jsondata.type+"_class").css("color","#ffae00");
				$("#"+jsondata.type+"_num").css("color","#ffae00");
				break;
			case "3":
				$("."+jsondata.type+"_class").css("color","blue");
				$("#"+jsondata.type+"_num").css("color","blue");
				break;
			case "4":
				default :
				$("."+jsondata.type+"_class").css("color","#000000");
				$("#"+jsondata.type+"_num").css("color","#000000");
			}
			}
		/* switch (jsondata.type) {
		case "new_num"://来单
			break;
		case "reject_num"://自报单驳回
			break;
		case "rejectresult_num"://结果驳回
			break;
		case "back_num"://退单
			break;
		case "delayed_num"://延时
			break;
		case "difficult_num"://疑难
			break;
		case "delayed_num"://即将超时未填写结果
			break;
			//timeout//预约超时
			//finishtimeout//完工超时（户内）
			//other//其它类型消息
		} */
	}
	
	//发送信息  
	function sendMessage() {
		var textMessage = "testmsg";

		if (ws != null && textMessage != "") {
			ws.send(textMessage);
		}
	}

	//关闭WebSocket连接 
	function disconnect() {
		if (ws != null) {
			ws.close();
			ws = null;
		}
	}

	function linkTab(tag) {
		var str = "";
		switch (tag) {
		case 1:
			str = "new";
			$('#tab').tabs('select', 0);
			break;
		case 2:
			str = "reject";
			$('#tab').tabs('select', 0);
			break;
		case 4:
			str = "back";
			$('#tab').tabs('select', 0);
			break;
		case 5:
			str = "delayed";
			$('#tab').tabs('select', 0);
			break;
		case 6:
			str = "difficult";
			$('#tab').tabs('select', 0);
			break;
		case 3:
			str = "rejectresult";
			$('#tab').tabs('select', 1);
			break;
		case 7:
			str = "delayed";
			$('#tab').tabs('select', 2);
			break;
		}
		$("."+str+"_class").hide();
		$("#"+str+"_num").html("0");
		HideMsg();
	}
</script>

<div style="height: 23px;display: none;border:1px solid #CDCDCD" id="msg_marquee">
	<marquee width="98%" height="23px" direction="left" scrollamount="3" style="margin-top: 2px;"
		onmouseover="this.stop()" onmouseout="this.start()" id="mymarquee">
		<a href="javascript:void(0)" onclick="linkTab(1)" class="new_class" style="display: none;font-weight: bold;">您有<span id="new_num">1</span>条新工单未处理</a>&nbsp;&nbsp;&nbsp;
		<a href="javascript:void(0)" onclick="linkTab(2)" class="reject_class" style="display: none;font-weight: bold;">您有<span id="reject_num">2</span>条驳回自报单未处理</a>&nbsp;&nbsp;&nbsp;
		<a href="javascript:void(0)" onclick="linkTab(3)" class="rejectresult_class" style="display: none;font-weight: bold;">您有<span id="rejectresult_num">2</span>条新的结果驳回未处理</a>&nbsp;&nbsp;&nbsp;
		<a href="javascript:void(0)" onclick="linkTab(4)" class="back_class" style="display: none;font-weight: bold;">您有<span id="back_num">3</span>条新的退单工单未处理</a>&nbsp;&nbsp;&nbsp;
		<a href="javascript:void(0)" onclick="linkTab(5)" class="delayed_class" style="display: none;font-weight: bold;">您有<span id="delayed_num">2</span>条新的延时工单未处理</a>&nbsp;&nbsp;&nbsp;
		<a href="javascript:void(0)" onclick="linkTab(6)" class="difficult_class" style="display: none;font-weight: bold;">您有<span id="difficult_num">2</span>条新的疑难工单未处理</a>&nbsp;&nbsp;&nbsp;
		<a href="javascript:void(0)" onclick="linkTab(7)" class="overtime_class" style="display: none;font-weight: bold;">您有<span id="overtime_num">5</span>条即将超时未填写结果的工单</a>&nbsp;&nbsp;&nbsp;
		<span class="other_class" id="other_content" style="display: none;"></span>
		<span class="notice_class" style="display: none;height: 23px"></span>
	</marquee>
	<!-- <input type="button" value="send" onclick="sendMessage();" />
	<input type="button" value="close" onclick="disconnect();" /> -->
</div>
