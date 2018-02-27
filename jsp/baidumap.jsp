<%@ taglib uri="/WEB-INF/config/struts-html.tld" prefix="html"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" buffer="none" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
	<head>
		<title>map</title>

		<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/ui/themes/bootstrap/easyui.css">
		<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/ui/themes/icon.css">
		
		<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery-1.8.3.js"></script>
		<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.easyui.min.js"></script>
		<script type="text/javascript">
    // 标注点数组  
    var BASEDATA = [
        { name: "王某某", tel: "北苑路01号", lng: "117.188657",lat:"39.141778", status: 1 ,count:1},
        { name: "奥某某", tel: "北苑路02号", lng: "117.201145", lat: "39.158700", status: 1, count: 2 },
        { name: "李某某", tel: "北苑路03号", lng: "117.202838", lat: "39.151135", status: 1, count: 3 },
        { name: "王某某", tel: "北苑路04号", lng: "117.212622", lat: "39.146907", status: 0, count: 4 },
        { name: "奥某某", tel: "北苑路05号", lng: "117.205046", lat: "39.139829", status: 1, count: 5 },
        { name: "李某某", tel: "北苑路06号", lng: "117.215155", lat: "39.149274", status: 1, count: 6 },
        { name: "王某某", tel: "北苑路07号", lng: "117.208061", lat: "39.140255", status: 0, count: 7 },
        { name: "奥某某", tel: "北苑路08号", lng: "117.207571", lat: "39.145484", status: 1, count: 8 },
        { name: "李某某", tel: "北苑路09号", lng: "117.220428", lat: "39.152075", status: 1, count: 9 },
        { name: "王某某", tel: "北苑路10号", lng: "117.215309", lat: "39.147942", status: 1, count: 10 },
        { name: "奥某某", tel: "北苑路11号", lng: "117.208107", lat: "39.157945", status: 0, count: 11 },
        { name: "李某某", tel: "北苑路12号", lng: "117.196516", lat: "39.137798", status: 1, count: 12 },
        { name: "宋某某", tel: "北苑路13号", lng: "117.203347", lat: "39.143518", status: 1, count: 13 } 
    ];

    var SelectorPolygon;
    var arrayObj;
    var isDraw = false;
    var arrayArea = new Array();

    var styleOptions = {
        strokeColor: "red",    //边线颜色。
        fillColor: "white",      //填充颜色。当参数为空时，圆形将没有填充效果。
        strokeWeight: 3,       //边线的宽度，以像素为单位。
        strokeOpacity: 0.8,    //边线透明度，取值范围0 - 1。
        fillOpacity: 0.6,      //填充的透明度，取值范围0 - 1。
        strokeStyle: 'dashed' //边线的样式，solid或dashed。
    };

    var styleOptions2 = {
        strokeColor: "blue",    //边线颜色。
        fillColor: "green",      //填充颜色。当参数为空时，圆形将没有填充效果。
        strokeWeight: 1,       //边线的宽度，以像素为单位。
        strokeOpacity: 0.6,    //边线透明度，取值范围0 - 1。
        fillOpacity: 0.1,      //填充的透明度，取值范围0 - 1。
        strokeStyle: 'solid' //边线的样式，solid或dashed。
    };

    var map;
    var myIcon;
    $(document).ready(function () {
        //页面载入时
        	$('#userinfo').window('close'); 
			$('#workinfo').window('close'); 
			$('#divSaveArea').window('close');
			// 百度地图API功能
			map = new BMap.Map("container");            // 创建Map实例
			//var point = new BMap.Point(117.1969,39.1428);    // 创建点坐标
			//map.centerAndZoom(point,15);                     // 初始化地图,设置中心点坐标和地图级别。
			map.centerAndZoom("天津",12);                     // 初始化地图,设置中心点坐标和地图级别。
			map.enableScrollWheelZoom();                            //启用滚轮放大缩小
			
			map.addControl(new BMap.ScaleControl()); // 添加比例尺控件
		    map.addControl(new BMap.OverviewMapControl()); //添加缩略地图控件
		    map.addControl(new BMap.MapTypeControl());//添加地图类型控件
		    
		    map.addEventListener("click", function (e) {
		        if (isDraw) {
		            var point = new BMap.Point(e.point.lng, e.point.lat);
		            arrayObj.push(point);
		        }
		    });
		    
		    myIcon = new BMap.Icon("${pageContext.request.contextPath}/images/mario.gif", new BMap.Size(32, 32), {//小车图片
		        imageOffset: new BMap.Size(0, 0)//图片的偏移量。为了是图片底部中心对准坐标点。
		    });

		// 所有人员定位
		$("#btnLocationAll").click(function () {
			$.ajax({
				type: "post",
				url: "${pageContext.request.contextPath}/BaiduMapAction.do?action=locationAll",
				dataType: "json",
				success: function (data) {
					doLocationAll(data);
				},
				error: function () {
					$.messager.alert("信息提示", "人员位置信息读取失败！", "error");
				}
			});
		});

		// 创建区片
		$("#btnSave").click(function () {
			$.ajax({
				type: "post",
				url: "${pageContext.request.contextPath}/BaiduMapAction.do?action=saveArea",
				dataType: "json",
				success: function (data) {
					if (data.result == "success") {
						$.messager.alert("信息提示", "区片信息保存成功！", "info");
					} else {
						$.messager.alert("信息提示", "区片信息保存失败！", "error");
					}
				},
				error: function () {
					$.messager.alert("信息提示", "区片信息保存失败！", "error");
				}
			});
		});
		
		// 显示轨迹
		$("#btnShowRoute").click(function () {
			$.ajax({
				type: "post",
				url: "${pageContext.request.contextPath}/BaiduMapAction.do?action=showRoute",
				dataType: "json",
				success: function (data) {
					if (data.result == "success") {
						doShowRoute(data);
					} else {
						$.messager.alert("信息提示", "轨迹信息读取失败！", "error");
					}
				},
				error: function () {
					$.messager.alert("信息提示", "轨迹信息读取失败！", "error");
				}
			});
		});
    });

    // 编写自定义函数，创建标注   
    function addMarker(point, index) {
        var marker = new BMap.Marker(point, { icon: myIcon });
        map.addOverlay(marker);

        //标注点击事件
        marker.addEventListener("click", function () {
            var opts = {
                width: 250,     // 信息窗口宽度   
                height: 60,     // 信息窗口高度   
                title: ""  // 信息窗口标题
            }
            var infoWindow = new BMap.InfoWindow("移动设备：18900000001<br/>人员名称：王小二<br/>定位时间：2013-05-12 13:10:10", opts);  // 创建信息窗口对象
            marker.openInfoWindow(infoWindow, this.point);      // 打开信息窗口
        });
    }

    //************************************
    //随机添加标注点
    //************************************
    function doLocationAll(data) {
        map.clearOverlays();
        //读取本地数据
        for (var i = 0; i < data.length; i++) {
            var point = new BMap.Point(data[i].lng,data[i].lat);
            addMarker(point);
        }
    };


    //************************************
    //定位和标注
    //************************************
    function doLocation() {
        map.clearOverlays();

        //定位
        var point = new BMap.Point(117.210823, 39.14303);
        map.centerAndZoom(point, 15);
        var marker = new BMap.Marker(point);
        map.addOverlay(marker);


        //移除标注
        marker.addEventListener("click", function () {
            //            map.removeOverlay(marker);
            //            marker.dispose();
            var opts = {
                width: 250,     // 信息窗口宽度   
                height: 60,     // 信息窗口高度   
                title: ""  // 信息窗口标题
            }
            var infoWindow = new BMap.InfoWindow("移动设备：18900000001<br/>人员名称：王小二<br/>定位时间：2013-05-12 13:10:10", opts);  // 创建信息窗口对象
            marker.openInfoWindow(infoWindow, this.point);      // 打开信息窗口
        });
    }

    var pts;
    //************************************
    //显示路径
    //************************************
    function doShowRoute(data) {
        map.clearOverlays();

        var array = new Array;
        for (var i = 0 ; i < data.length; i++) {
        	array.push(data[i].lng, data[i].lat);
        }
        //驾驶路线图
//         var point1 = new BMap.Point(117.191266, 39.130889);
//         var point2 = new BMap.Point(117.196296, 39.133296);
//         var point3 = new BMap.Point(117.201902, 39.137606);
//         var point4 = new BMap.Point(117.200321, 39.15238);
        //手动绘制路线图
        if (polyline != null) {
            map.removeOverlay(polyline);
        }
//         var polyline = new BMap.Polyline([
//         new BMap.Point(117.191266, 39.130889),
//         new BMap.Point(117.196296, 39.133296),
//         new BMap.Point(117.201902, 39.137606),
//         new BMap.Point(117.200321, 39.15238)], { strokeColor: "blue", strokeWeight: 2, strokeOpacity: 0.5 });
        var polyline = new BMap.Polyline(array, { strokeColor: "blue", strokeWeight: 2, strokeOpacity: 0.5 });
        map.addOverlay(polyline);
        addArrow(polyline, 8, Math.PI / 7);

        pts = polyline.getPath();
        setTimeout(function(){
            map.setViewport([point1, point2, point3, point4]);
            //调剂到最佳视野        
        }, 1000);
    };

    

    //************************************
    //路径回放
    //************************************
    function doPlayRoute() {
        var paths = pts.length;//获得有几个点
        var carMk = new BMap.Marker(pts[0], { icon: myIcon });
        map.addOverlay(carMk);
        i = 0;
        function resetMkPoint(i) {
            carMk.setPosition(pts[i]);
            if (i < paths) {
                setTimeout(function () {
                    i++;
                    resetMkPoint(i);
                }, 500);
            }
            else {
                map.removeOverlay(carMk);
            }
        }
        setTimeout(function () {
            resetMkPoint(1);
        }, 100)
    };

    //************************************
    //添加手绘方向箭头
    //************************************
    function addArrow(polyline, length, angleValue) { //绘制箭头的函数
        var linePoint = polyline.getPath(); //线的坐标串
        var arrowCount = linePoint.length;

        for (var i = 1; i < arrowCount; i++) { //在拐点处绘制箭头
            var pixelStart = map.pointToPixel(linePoint[i - 1]);
            var pixelEnd = map.pointToPixel(linePoint[i]);
            var angle = angleValue; //箭头和主线的夹角
            var r = length; // r/Math.sin(angle)代表箭头长度
            var delta = 0; //主线斜率，垂直时无斜率
            var param = 0; //代码简洁考虑
            var pixelTemX, pixelTemY; //临时点坐标
            var pixelX, pixelY, pixelX1, pixelY1; //箭头两个点

            if (pixelEnd.x - pixelStart.x == 0) { //斜率不存在是时
                pixelTemX = pixelEnd.x;
                if (pixelEnd.y > pixelStart.y) {
                    pixelTemY = pixelEnd.y - r;
                }
                else {
                    pixelTemY = pixelEnd.y + r;
                }
                //已知直角三角形两个点坐标及其中一个角，求另外一个点坐标算法
                pixelX = pixelTemX - r * Math.tan(angle);
                pixelX1 = pixelTemX + r * Math.tan(angle);
                pixelY = pixelY1 = pixelTemY;
            }
            else  //斜率存在时
            {
                delta = (pixelEnd.y - pixelStart.y) / (pixelEnd.x - pixelStart.x);
                param = Math.sqrt(delta * delta + 1);

                if ((pixelEnd.x - pixelStart.x) < 0) //第二、三象限
                {
                    pixelTemX = pixelEnd.x + r / param;
                    pixelTemY = pixelEnd.y + delta * r / param;
                }
                else//第一、四象限
                {
                    pixelTemX = pixelEnd.x - r / param;
                    pixelTemY = pixelEnd.y - delta * r / param;
                }
                //已知直角三角形两个点坐标及其中一个角，求另外一个点坐标算法
                pixelX = pixelTemX + Math.tan(angle) * r * delta / param;
                pixelY = pixelTemY - Math.tan(angle) * r / param;

                pixelX1 = pixelTemX - Math.tan(angle) * r * delta / param;
                pixelY1 = pixelTemY + Math.tan(angle) * r / param;
            }

            var pointArrow = map.pixelToPoint(new BMap.Pixel(pixelX, pixelY));
            var pointArrow1 = map.pixelToPoint(new BMap.Pixel(pixelX1, pixelY1));
            var Arrow = new BMap.Polyline([
                pointArrow,
                linePoint[i],
                pointArrow1
                ], { strokeColor: "red", strokeWeight: 3, strokeOpacity: 1.0 }
            );
            map.addOverlay(Arrow);
            Arrow.addEventListener("click", function (e) {
                var opts = {
                    width: 250,     // 信息窗口宽度
                    height: 60,     // 信息窗口高度
                    title: ""  // 信息窗口标题
                }
                var infoWindow = new BMap.InfoWindow("移动设备：18900000001<br/>人员名称：王小二<br/>定位时间：2013-05-12 13:10:10", opts);//创建信息窗口对象
                markerPoint.openInfoWindow(infoWindow, this.point);//打开信息窗口
            });
        }
    }

    //************************************
    //拉框放大
    //************************************
    function doRectangleZoom(){
        var myDrag = new BMapLib.RectangleZoom(map, {
            followText: "拖拽鼠标进行操作"
        });
        myDrag.open();//开启拉框放大
    }

    //************************************
    //自定义图层
    //************************************
    function doCreateCustomLayer() {
        isDraw = true;
        arrayObj = new Array();
//        var tileLayer = new BMap.TileLayer({ isTransparentPng: true });
        //        map.addTileLayer(tileLayer);
        
        //绘制多边形
        drawingManager = new BMapLib.DrawingManager(map, {
            isOpen: true, //是否开启绘制模式
            enableDrawingTool: false, //是否显示工具栏
            drawingType: BMAP_DRAWING_POLYGON,
            drawingToolOptions: {
                anchor: BMAP_ANCHOR_TOP_RIGHT, //位置
                offset: new BMap.Size(5, 5), //偏离值
                scale: 0.8 //工具栏缩放比例
            },
            polygonOptions: styleOptions2 //多边形的样式
        });

        drawingManager.setDrawingMode(BMAP_DRAWING_POLYGON);

        //添加鼠标绘制工具监听事件，用于获取绘制结果
        drawingManager.addEventListener('overlaycomplete', overlaycomplete2);
    }

    //回调获得覆盖物信息
    var overlaycomplete2 = function (e) {
        ShowSaveBox();
    };


    //************************************
    //显示选定图层
    //************************************
    function doShowCustomLayer(areaName) {

        //获取当前区片
        var data = Array();
        for (var i = 0; i < arrayArea.length; i++) {
            if (arrayArea[i].name == areaName) {
                data = arrayArea[i].data;
                //显示区片
                var polygon = new BMap.Polygon(data, { strokeColor: "blue", strokeWeight: 1, strokeOpacity: 0.6, fillColor: "green", fillOpacity: 0.1 });
                map.addOverlay(polygon);
                break;
            }
        }
    }

    //************************************
    //拉框搜索(当前默认为矩形框，选择不可)
    //************************************
    //BMAP_DRAWING_MARKER 画点 
    //BMAP_DRAWING_CIRCLE 画圆 
    //BMAP_DRAWING_POLYLINE 画线 
    //BMAP_DRAWING_POLYGON 画多边形 
    //BMAP_DRAWING_RECTANGLE 画矩形 
    var drawingManager;
    function doSearchInRectangle() {
        //实例化鼠标绘制工具
        drawingManager = new BMapLib.DrawingManager(map, {
            isOpen: true, //是否开启绘制模式
            enableDrawingTool: false, //是否显示工具栏
            drawingType: BMAP_DRAWING_RECTANGLE,
            drawingToolOptions: {
                anchor: BMAP_ANCHOR_TOP_RIGHT, //位置
                offset: new BMap.Size(5, 5), //偏离值
                scale: 0.8 //工具栏缩放比例
            },
            circleOptions: styleOptions, //圆的样式
            polygonOptions: styleOptions, //多边形的样式
            rectangleOptions: styleOptions //矩形的样式
        });

        drawingManager.setDrawingMode(BMAP_DRAWING_RECTANGLE);

        //添加鼠标绘制工具监听事件，用于获取绘制结果
        drawingManager.addEventListener('overlaycomplete', overlaycomplete);
    }

    //回调获得覆盖物信息
    var overlaycomplete = function (e) {
        SelectorPolygon = e.overlay
        map.clearOverlays();
        doLocalSearch();
        drawingManager.isOpen = false;
    };

    //************************************
    //查询本地数据
    //************************************
    function doLocalSearch() {
        for (var i = 0; i < 13; i++) {
            var point = new BMap.Point(BASEDATA[i].lng, BASEDATA[i].lat);
            if (BMapLib.GeoUtils.isPointInPolygon(point, SelectorPolygon)) {
                addMarker(point);
            }
        }
        map.removeOverlay(SelectorPolygon);
    }

    //************************************
    //清除地图所有覆盖物
    //************************************
    function doClear() {
        map.clearOverlays();
    }

    //************************************
    //测距
    //************************************
    function doDistance() {
        var myDis = new BMapLib.DistanceTool(map);
        myDis.open();
    }

    //************************************
    //弹出窗口
    //************************************

    function ShowSaveBox() {
        //$("#divSaveArea").dialog();
        $('#divSaveArea').window('open');
    }

    function doSave() {
        var areaName = txtAreaName.value;
        txtAreaName.value = "";

        $('#divSaveArea').window('close');
        map.clearOverlays();
        arrayArea.push({ name: areaName, data: arrayObj });
        //清空数组
//        for (var i = arrayObj.length; i > 0; i--) {
//            arrayObj.pop();
//        }
        AddAreaGrid(areaName);
    }

    

    //点击人员列表定位
    function doLocationPerson(i) {
        map.clearOverlays();
        var point = new BMap.Point(BASEDATA[i].lng, BASEDATA[i].lat);
        map.centerAndZoom(point, 15);
        //var marker = new BMap.Marker(point);
        var marker = new BMap.Marker(point, { icon: myIcon });
        map.addOverlay(marker);
    }

    function doLoadData() {
        AddTableRow();
    }

    function AddTableRow() {
        var oTable = document.getElementById("tblUsers");

        for (var i = 0; i < BASEDATA.length; i++) {
            var oTr = oTable.insertRow();
            //定位Button
            var oTd1 = oTr.insertCell();
            oTd1.innerHTML = "<input type='button' value='定位' onclick='doLocationPerson(" + i + ");'/>";
            var oTd2 = oTr.insertCell();
            //状态
            var sta;
            if (BASEDATA[i].status == 1) {
                sta = "在线";
            }
            else {
                sta = "离线";
            }
            oTd2.innerHTML = sta;
            //姓名
            var oTd3 = oTr.insertCell();
            oTd3.innerHTML = BASEDATA[i].name;
            //任务数
            var oTd4 = oTr.insertCell();
            oTd4.innerHTML = BASEDATA[i].count;
            //移动设备
            var oTd5 = oTr.insertCell();
            oTd5.innerHTML = BASEDATA[i].tel;
        }
    }


    //添加区片
    function CreateArea() {

    }

    function ShowArea() {

    }

    function AddAreaGrid(name) {
        var oTable = document.getElementById("tblArea");
        var oTr = oTable.insertRow();
        //区片名称
        var oTd1 = oTr.insertCell();
        oTd1.innerHTML = name;
        //定位Button
        var oTd2 = oTr.insertCell();
        oTd2.innerHTML = "<input type='button' value='显示区片' onclick='doShowCustomLayer(" + name + ");'/>";
    }

    function doShowAllCustomLayer() {
    	map.clearOverlays();
        for (var i = 0; i < arrayArea.length; i++) {
            //显示区片
            var polygon = new BMap.Polygon(arrayArea[i].data, { strokeColor: "blue", strokeWeight: 1, strokeOpacity: 0.6, fillColor: "green", fillOpacity: 0.1 });
            map.addOverlay(polygon);
        }
    }

</script>

		<script type="text/javascript" src="http://api.map.baidu.com/api?v=2.0&ak=249f028d0eb0b27f17b7aa69ddbb386e"></script>
		
		<script type="text/javascript" src="http://api.map.baidu.com/library/RectangleZoom/1.2/src/RectangleZoom_min.js"></script>
		<script type="text/javascript" src="http://api.map.baidu.com/library/SearchInRectangle/1.2/src/SearchInRectangle_min.js"></script>
		<script type="text/javascript" src="http://api.map.baidu.com/library/DistanceTool/1.2/src/DistanceTool_min.js"></script>
		<script type="text/javascript" src="http://api.map.baidu.com/library/GeoUtils/1.2/src/GeoUtils_min.js"></script>
		<link rel="stylesheet" href="http://api.map.baidu.com/library/DrawingManager/1.4/src/DrawingManager_min.css" />
		<script type="text/javascript" src="http://api.map.baidu.com/library/DrawingManager/1.4/src/DrawingManager_min.js"></script>
	
	</head>
	<body>
	 <div style="width: 1200px;height: 700px;padding:0px;" class="easyui-layout"> 
	 	<div data-options="region:'center',title:'地图'" style="padding:0px;overflow:hidden">  
			<div id="container" style="width: 100%;height: 100%"></div>
		</div>
		 <!--右侧控制面板-->
        <div id="adv2" data-options="region:'east',iconCls:'icon-reload',title:'操作',split:true"  style="width:300px;padding:0px;overflow:hidden">
            <div class="easyui-tabs" style="width:100%;height:100%;" fit="true" data-options="fit:true,plain:true">
                <div id="tab1" title="工单分派">
                    <div>
                    <input type="button" id="btnDistance" onclick="doDistance();" value="测距"/><br/>
                    <input type="button" id="btnLocation" onclick="doLocation();" value="定位"/>
                    <input type="button" id="btnLocationAll" onclick="doLocationAll();" value="所有人员定位"/><br/>
                    <input type="button" id="Button6" onclick="doSearchInRectangle();" value="拉框搜索"/><br/>
                    <input type="button" id="Button3" onclick="doClear();" value="清除所有"/><br/>
                    <input type="button" id="btnLoadData" onclick="doLoadData();" value="读取数据"/>
                    </div>
                    <div style="height:420px;overflow:scroll">
                        <table id="tblUsers">
                            <tr>
                                <td>操作</td>
                                <td>状态</td>
                                <td>人员名称</td>
                                <td>任务数</td>
                                <td>移动设备</td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div id="tab2" title="工单轨迹">
                    <input type="button" id="btnShowRoute" onclick="doShowRoute();" value="显示轨迹"/>
                    <input type="button" id="btnPlayRoute" onclick="doPlayRoute();" value="轨迹回放"/><br/>
                    <input type="button" id="btnClear2" onclick="doClear();" value="清除所有"/>
                </div>
                <div id="tab3" title="区片信息">
                    <div>
                        <input type="button" id="Button1" onclick="doCreateCustomLayer();" value="创建区片"/>
                        <input type="button" id="Button2" onclick="doShowAllCustomLayer();" value="显示所有区片"/><br/>
                        <input type="button" id="Button5" onclick="doClear();" value="清除所有"/>
                    </div>
                    <div style="height:420px;overflow:scroll">
                        <table id="tblArea">
                            <tr>
                                <td>区片名称</td>
                                <td>操作</td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div id="tab4" title="其他">
                    <!--input type="button" id="btnRectangleZoom" onclick="doRectangleZoom();" value="拉框放大"/-->
                    <input type="button" id="btnSearchInRectangle" onclick="doSearchInRectangle();" value="拉框搜索"/><br/>
                    <input type="button" id="btnClear" onclick="doClear();" value="清除所有"/>
                </div>
            </div>
        </div>
       
        
		
	</div>
	<div style="width: 100%;height: 100%">
		 <div id="divSaveArea" class="easyui-window" data-options="iconCls:'icon-info',closable:true,closed:true,resizable:false,minimizable:false,maximizable:false,inline:true,top:10,left:220" title="区片信息保存" style="width:200px;height:150px">
            <p>区域名称：</p>
            <input type="text" id="txtAreaName"/>
            <input type="button" id="btnSave" value="保存" onclick="doSave();"/>
        </div>
		<div id="userinfo" class="easyui-window" title="人员信息" style="width:200px;height:150px;z-index: 999;float: left;margin: 200,10,02,20"   
        data-options="iconCls:'icon-info',closable:true,closed:true,resizable:false,minimizable:false,maximizable:false,inline:true,top:10,left:220">   
  
			<table>
			<tr>
				<td>所属部门：</td>
				<td><span id="parent"></span></td>			
			</tr>
			<tr>
				<td>姓名：</td>
				<td><span id="username"></span></td>			
			</tr>
			<tr>
				<td>工号：</td>
				<td><span id="userid"></span></td>			
			</tr>
			<tr>
				<td>工单信息：</td>
				<td></td>			
			</tr>
			</table>
		</div> 
		<div id="workinfo" class="easyui-window" title="工单信息" style="width:200px;height:150px;z-index: 999;float: left;margin: 200,10,02,20"   
        data-options="iconCls:'icon-info',closable:true,closed:true,resizable:false,minimizable:false,maximizable:false,inline:true,top:10,left:220">   
  
			<table>
			<tr>
				<td>工单类型：</td>
				<td><span id="parentwork"></span></td>			
			</tr>
			<tr>
				<td>工单号：</td>
				<td><span id="worknum"></span></td>			
			</tr>
			<tr>
				<td>工单信息：</td>
				<td></td>			
			</tr>
			</table>
		</div> 
		</div>
	</body>
</html>
