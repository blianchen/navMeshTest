/*
* @author 白连忱 
* date Jan 22, 2010
*/
package org.blch.geom
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	/**
	 * Polygon
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0
	 */
	public class Polygon
	{
		public var vertexNmu:int;				//顶点数
		public var vertexV:Vector.<Vector2f>;	//顶点列表
		
		private var rect:Rectangle;		//矩形包围盒
		
		public function Polygon(vertexNmu:int, vertexV:Vector.<Vector2f>)
		{
			this.vertexNmu = vertexNmu;
			this.vertexV = vertexV;
		}
		
		/**
		 * 是否是简单多边形
		 * @return 
		 */		
		public function isSimplicity():Boolean {
			// 边数组
			var edges:Vector.<Line2D> = new Vector.<Line2D>();
			var len:int = vertexV.length-1;
			for (var i:int=0; i<len; i++) {
				edges.push(new Line2D(vertexV[i], vertexV[i+1]));
			}
			edges.push(new Line2D(vertexV[len], vertexV[0]));
			
			// 是否有内交点
			var itsPt:Vector2f = new Vector2f();	//返回的交点
			for each (var testLine:Line2D in edges) {
				for (var j:int=0; j<edges.length; j++) {
					if (!testLine.equals(edges[j])) {
						if (testLine.intersection(edges[j], itsPt) == LineClassification.SEGMENTS_INTERSECT) {
							//交点是两个线段的端点
							if ( itsPt.equals(testLine.getPointA()) || itsPt.equals(testLine.getPointB())
								|| itsPt.equals(edges[j].getPointA()) || itsPt.equals(edges[j].getPointB()) )  {
								;
							} else {
								return false;
							}
						}
					}
				}
			}
			
			return true;
		}
		
		/**
		 * 将多边形的顶点按逆时针排序
		 */		
		public function cw():void {
			if (this.isCW() == false) {	//如果为逆时针顺序， 反转为顺时针
				this.vertexV.reverse();
			}
		}
		
		/**
		 * clockwise
		 * @return true -- clockwise; false -- counter-clockwise
		 */		
		public function isCW():Boolean {
			if (vertexV == null || vertexV.length < 0) return false;
			
			//最上（y最小）最左（x最小）点， 肯定是一个凸点
			//寻找最上点
			var topPt:Vector2f = this.vertexV[0];
			var topPtId:int = 0;	//点的索引
			for (var i:int=1; i<vertexV.length; i++) {
				if (topPt.y > vertexV[i].y) {
					topPt = vertexV[i];
					topPtId = i;
				} else if (topPt.y == vertexV[i].y) { //y相等时取x最小
					if (topPt.x > vertexV[i].x) {
						topPt = vertexV[i];
						topPtId = i;
					}
				}
			}
			
			//凸点的邻点
			var lastId:int = topPtId-1>=0 ? topPtId-1 : vertexV.length-1;
			var nextId:int = topPtId+1>=vertexV.length ? 0 : topPtId+1;
			var last:Vector2f = vertexV[lastId];
			var next:Vector2f = vertexV[nextId];
			
			//判断
			var r:Number = multiply(last, next, topPt);
			if (r < 0) {
				return true;
//			} else if (r == 0) {
			//三点共线情况不存在，若三点共线则说明必有一点的y（斜线）或x（水平线）小于topPt
			}
			
			return false;
		}
		
		/**
		 * r=multiply(sp,ep,op),得到(sp-op)*(ep-op)的叉积 
		 * r>0:ep在矢量opsp的逆时针方向； 
		 * r=0：opspep三点共线； 
		 * r<0:ep在矢量opsp的顺时针方向 
		 * @param sp 
		 * @param ep 
		 * @param op 
		 * @return 
		 */		
		private function multiply(sp:Vector2f, ep:Vector2f, op:Vector2f):Number { 
			return((sp.x-op.x)*(ep.y-op.y)-(ep.x-op.x)*(sp.y-op.y)); 
		} 
		
		/**
		 * 返回矩形包围盒
		 * @return 
		 */		
		public function rectangle():Rectangle {
			if (vertexV == null || vertexV.length < 0) return null;
			
			if (rect != null) return rect;
			
			var lx:Number = vertexV[0].x;
			var rx:Number = vertexV[0].x;
			var ty:Number = vertexV[0].y;
			var by:Number = vertexV[0].y;
			
			var v:Vector2f;
			for (var i:int=1; i<vertexV.length; i++) {
				v = vertexV[i];
				if (v.x < lx) {
					lx = v.x;
				}
				if (v.x > rx) {
					rx = v.x;
				}
				if (v.y < ty) {
					ty = v.y;
				}
				if (v.y > by) {
					by = v.y;
				}
			}
			
			rect = new Rectangle(lx, rx-lx, ty, by-ty);
			return rect;
		}
		
		/**
		 * 合并两个多边形(Weiler-Athenton算法)
		 * @param polygon
		 * @return 
		 * 			null--两个多边形不相交，合并前后两个多边形不变
		 * 			Polygon--一个新的多边形
		 */		
		public function union(polygon:Polygon):Vector.<Polygon> {
			//包围盒不相交
			if (rectangle().intersection(polygon.rectangle()) == false) {
				return null;
			}
			
			//所有顶点和交点
			var cv0:Vector.<Node> = new Vector.<Node>();//主多边形
			var cv1:Vector.<Node> = new Vector.<Node>();//合并多边形
			//初始化
			var node:Node;
			for (var i:int=0; i<this.vertexV.length; i++) {
				node = new Node(this.vertexV[i], false, true);
				if (i > 0) {
					cv0[i-1].next = node;
				}
				cv0.push(node);
			}
			for (var j:int=0; j<polygon.vertexV.length; j++) {
				node = new Node(polygon.vertexV[j], false, false);
				if (j > 0) {
					cv1[j-1].next = node;
				}
				cv1.push(node);
			}
			
			//插入交点
			var insCnt:int = this.intersectPoint(cv0, cv1);
//			trace("cv0:", cv0);
//			var ttp:Node = cv0[0];
//			trace(ttp);
//			while (ttp.next != null) {
//				trace(ttp.next);
//				ttp = ttp.next;
//			}
//			trace("cv1:", cv1);
//			var ttp:Node = cv1[0];
//			trace(ttp);
//			while (ttp.next != null) {
//				trace(ttp.next);
//				ttp = ttp.next;
//			}
			
			//生成多边形
//			var rc:Vector.<Vector2f> = new Vector.<Vector2f>();
			if (insCnt > 0) {
				//顺时针序
				return linkToPolygon(cv0, cv1);
			} else {
				return null;
			}
			
			return null;
		}
		
		/**
		 * 生成多边形，顺时针序； 生成的内部孔洞多边形为逆时针序
		 * @param cv0
		 * @param cv1
		 * @return 合并后的结果多边形数组(可能有多个多边形)
		 */		
		private function linkToPolygon(cv0:Vector.<Node>, cv1:Vector.<Node>):Vector.<Polygon> {
			trace("linkToPolygon***linkToPolygon");
			//保存合并后的多边形数组
			var rtV:Vector.<Polygon> = new Vector.<Polygon>();
			
			//1. 选取任一没有被跟踪过的交点为始点，将其输出到结果多边形顶点表中．
			for each (var testNode:Node in cv0) {
				if (testNode.i == true && testNode.p == false) {
//					trace("测试点0", testNode);
					var rcNodes:Vector.<Vector2f> = new Vector.<Vector2f>();
					while (testNode != null) {
//						trace("测试点1", testNode);
						
						testNode.p = true;
						
						// 如果是交点
						if (testNode.i == true) {
							testNode.other.p = true;
							
							if (testNode.o == false) {		//该交点为进点（跟踪裁剪多边形边界）
								if (testNode.isMain == true) {		//当前点在主多边形中
									testNode = testNode.other;		//切换到裁剪多边形中
								}
							} else {					//该交点为出点（跟踪主多边形边界）
								if (testNode.isMain == false) {		//当前点在裁剪多边形中
									testNode = testNode.other;		//切换到主多边形中
								}
							}
						}
						
						rcNodes.push(testNode.v);  		////// 如果是多边形顶点，将其输出到结果多边形顶点表中
						
						if (testNode.next == null) {	//末尾点返回到开始点
							if (testNode.isMain) {
								testNode = cv0[0];
							} else {
								testNode = cv1[0];
							}
						} else {
							testNode = testNode.next;
						}
						
						//与首点相同，生成一个多边形
						if (testNode.v.equals(rcNodes[0])) break;
					}
					//提取
					rtV.push(new Polygon(rcNodes.length, rcNodes));
				}
			}
			
			trace("rtV", rtV);
			return rtV;
		}
		
		/**
		 * 生成交点，并按顺时针序插入到顶点表中
		 * @param cv0 （in/out）主多边形顶点表，并返回插入交点后的顶点表
		 * @param cv1 （in/out）合并多边形顶点表，并返回插入交点后的顶点表
		 * @return 交点数
		 */		
		private function intersectPoint(cv0:Vector.<Node>, cv1:Vector.<Node>):int {
			var insCnt:int = 0;		//交点数
			
			var findEnd:Boolean = false;
			var startNode0:Node = cv0[0];
			var startNode1:Node;
			var line0:Line2D;
			var line1:Line2D;
			var ins:Vector2f;
			var hasIns:Boolean;
			var result:int;		//进出点判断结果
			while (startNode0 != null) {		//主多边形
				if (startNode0.next == null) {  //最后一个点，跟首点相连
					line0 = new Line2D(startNode0.v, cv0[0].v);
				} else {
					line0 = new Line2D(startNode0.v, startNode0.next.v);
				}
				
				startNode1 = cv1[0];
				hasIns = false;
				
				while (startNode1 != null) {		//合并多边形
					if (startNode1.next == null) {
						line1 = new Line2D(startNode1.v, cv1[0].v);
					} else {
						line1 = new Line2D(startNode1.v, startNode1.next.v);
					}
					ins = new Vector2f();	//接受返回的交点
					//有交点
					if (line0.intersection(line1, ins) == LineClassification.SEGMENTS_INTERSECT) {
						//忽略交点已在顶点列表中的
						if (this.getNodeIndex(cv0, ins) == -1) {
							insCnt++;
							
							///////// 插入交点
							var node0:Node = new Node(ins, true, true);
							var node1:Node = new Node(ins, true, false);
							cv0.push(node0);
							cv1.push(node1);
							//双向引用
							node0.other = node1;
							node1.other = node0;
							//插入
							node0.next = startNode0.next;
							startNode0.next = node0;
							node1.next = startNode1.next;
							startNode1.next = node1;
							//出点
							if (line0.classifyPoint(line1.getPointB()) == PointClassification.RIGHT_SIDE) {
								node0.o = true;
								node1.o = true;
							}
							//TODO 线段重合
//							trace("交点****", node0);
							
							hasIns = true;		//有交点
							
							//有交点，返回重新处理
							break;
						}
					}
					startNode1 = startNode1.next;
				}
				//如果没有交点继续处理下一个边，否则重新处理该点与插入的交点所形成的线段
				if (hasIns == false) {
					startNode0 = startNode0.next;
				}
			}
			return insCnt;
		}
		
		/**
		 * 取得节点的索引(合并多边形用)
		 * @param cv
		 * @param node
		 * @return 
		 */		
		private function getNodeIndex(cv:Vector.<Node>, node:Vector2f):int {
			for (var i:int=0; i<cv.length; i++) {
				if (cv[i].v.equals(node)) {
					return i;
				}
			}
			return -1;
		}
		
		public function draw(g:Graphics):void {
			g.beginFill(0xff0000, .3);
			g.moveTo(vertexV[0].x, vertexV[0].y);
			
			for (var i:int=1; i<vertexV.length; i++) {
				g.lineTo(vertexV[i].x, vertexV[i].y);
			}
			
			g.lineTo(vertexV[0].x, vertexV[0].y);
			g.endFill();
		}
		
		public function toString():String {
			var rs:String =  "Polygon:";
			for (var i:int=0; i<this.vertexV.length; i++) {
				rs += " -> "+vertexV[i];
			}
			return rs;
		}
	}
}


import org.blch.geom.Vector2f;
/**
 * 顶点(合并多边形用)
 * @author blc
 */
class Node {
//	/** 原数组中的索引 */
//	public var index:int;
	/** 坐标点 */
	public var v:Vector2f;		//点
	/** 是否是交点 */
	public var i:Boolean;
	/** 是否已处理过 */
	public var p:Boolean = false;	
	/** 进点--false； 出点--true */
	public var o:Boolean = false;
	/** 交点的双向引用 */
	public var other:Node;	
	/** 点是否在主多边形中*/
	public var isMain:Boolean;
	
	/** 多边形的下一个点 */
	public var next:Node;
	
	public function Node(pt:Vector2f, isInters:Boolean, main:Boolean):void {
		this.v = pt;
		this.i = isInters;
		this.isMain = main;
	}
	
	public function toString():String {
		return v.toString() + "-->交点：" + i + "出点：" + o + "主：" + isMain + "处理：" + p;
	}
	
//	public function equals(node:Node):Boolean {
//		return v.equals(node.v);
//	}
}