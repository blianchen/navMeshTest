/*
* @author 白连忱 
* date Jan 22, 2010
*/
package org.blch.findPath
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import org.blch.geom.Line2D;
	import org.blch.geom.LineClassification;
	import org.blch.geom.PointClassification;
	import org.blch.geom.Triangle;
	import org.blch.geom.Vector2f;
	
	/**
	 * 寻路用的单元格（三角形）
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0
	 */
	public class Cell extends Triangle
	{
		private var _index:int;				//在数组中的索引值
		private var _links:Vector.<int>;		// 与该三角型连接的三角型索引， -1表示改边没有连接
		
		public  var sessionId:int;
		public var f:int;
		public var h:int;
		public var isOpen:Boolean = false;
		public var parent:Cell;
		
		public var m_ArrivalWall:int; // the side we arrived through.
		public var m_WallMidpoint:Vector.<Vector2f>; // 每个边的中点
		public var m_WallDistance:Vector.<Number>; // the distances between each wall midpoint of sides (0-1, 1-2, 2-0)
		
		public function Cell(p1:Vector2f=null, p2:Vector2f=null, p3:Vector2f=null) {
			super(p1, p2, p3);
			
			init();
		}

		
		/**
		 * 计算中心点（3个顶点的平均值） 
		 */

		public function get links():Vector.<int>
		{
			return _links;
		}

		public function set links(value:Vector.<int>):void
		{
			_links = value;
		}

		private function init():void {
			links = new Vector.<int>();
			links.push(-1);
			links.push(-1);
			links.push(-1);
			
			//
			calculateData();
			
			m_WallMidpoint = new Vector.<Vector2f>();
			m_WallDistance = new Vector.<Number>();
			// compute the midpoint of each cell wall
			m_WallMidpoint[0] = new Vector2f((pointA.x + pointB.x) / 2.0, (pointA.y + pointB.y) / 2.0);
			m_WallMidpoint[1] = new Vector2f((pointC.x + pointB.x) / 2.0, (pointC.y + pointB.y) / 2.0);
			m_WallMidpoint[2] = new Vector2f((pointC.x + pointA.x) / 2.0, (pointC.y + pointA.y) / 2.0);
			
			// compute the distances between the wall midpoints
			var wallVector:Vector2f;
			wallVector = m_WallMidpoint[0].subtract(m_WallMidpoint[1]);
			m_WallDistance[0] = wallVector.length();
			
			wallVector = m_WallMidpoint[1].subtract(m_WallMidpoint[2]);
			m_WallDistance[1] = wallVector.length();
			
			wallVector = m_WallMidpoint[2].subtract(m_WallMidpoint[0]);
			m_WallDistance[2] = wallVector.length();
		}

		/**
		 * 获得两个点的相邻三角型
		 * @param pA
		 * @param pB
		 * @param caller
		 * @return 如果提供的两个点是caller的一个边, 返回true
		 */		
		private function requestLink(pA:Vector2f, pB:Vector2f, caller:Cell):Boolean {
			if (pointA.equals(pA)) {
				if (pointB.equals(pB)) {
					links[SIDE_AB] = caller.index;
					return (true);
				} else if (pointC.equals(pB)) {
					links[SIDE_CA] = caller.index;
					return (true);
				}
			} else if (pointB.equals(pA)) {
				if (pointA.equals(pB)) {
					links[SIDE_AB] = caller.index;
					return (true);
				} else if (pointC.equals(pB)) {
					links[SIDE_BC] = caller.index;
					return (true);
				}
			} else if (pointC.equals(pA)) {
				if (pointA.equals(pB)) {
					links[SIDE_CA] = caller.index;
					return (true);
				} else if (pointB.equals(pB)) {
					links[SIDE_BC] = caller.index;
					return (true);
				}
			}
			
			// we are not adjacent to the calling cell
			return (false);
		}
		
		/**
		 * 取得指定边的相邻三角型的索引
		 * @param side
		 * @return 
		 */		
		private function getLink(side:int):int {
			return links[side];
		}
		
		/**
		 * 检查并设置当前三角型与cellB的连接关系（方法会同时设置cellB与该三角型的连接）
		 * @param cellB
		 */		
		public function checkAndLink(cellB:Cell):void {
			if (getLink(SIDE_AB) == -1 && cellB.requestLink(pointA, pointB, this)) {
				setLink(SIDE_AB, cellB);
			} else if (getLink(SIDE_BC) == -1 && cellB.requestLink(pointB, pointC, this)) {
				setLink(SIDE_BC, cellB);
			} else if (getLink(SIDE_CA) == -1 && cellB.requestLink(pointC, pointA, this)) {
				setLink(SIDE_CA, cellB);
			}
		}
		
		/**
		 * 设置side指定的边的连接到caller的索引
		 * @param side
		 * @param caller
		 */		
		private function setLink(side:int, caller:Cell):void {
			links[side] = caller.index;
		}
		
		/**
		 * 记录路径从上一个节点进入该节点的边（如果从终点开始寻路即为穿出边）
		 * @param index	路径上一个节点的索引
		 */		
		public function setAndGetArrivalWall(index:int):int {
			if (index == links[0]) {
				m_ArrivalWall = 0;
				return 0;
			} else if (index == links[1]) {
				m_ArrivalWall = 1;
				return 1;
			} else if (index == links[2]) {
				m_ArrivalWall = 2;
				return 2;
			}
			return -1;
		}
		
		/**
		 * 计算估价（h）  Compute the A* Heuristic for this cell given a Goal point
		 * @param goal
		 */		
		public function computeHeuristic(goal:Vector2f):void {
			// our heuristic is the estimated distance (using the longest axis delta) 
			// between our cell center and the goal location
			
			var XDelta:Number = Math.abs(goal.x - center.x);
			var YDelta:Number = Math.abs(goal.y - center.y);
			
//			h = Math.max(XDelta, YDelta);
			h = XDelta + YDelta;
		}
		
		/**
		 * 测试直线与该cell（三角形）的关系
		 * @param motionPath
		 * @return ClassifyResult对象
		 */		
//		public function classifyPathToCell(motionPath:Line2D):ClassifyResult {
//			 trace("Cell:"+this);
//			 trace("     Path:"+motionPath);
//			var interiorCount:int = 0;	//记录点在三角形三边右面的次数，如果==3则说明点在三角形内部
//			var result:ClassifyResult = new ClassifyResult();
//			
//			// 分别检测直线与三角形的三个边
//			for (var i:int = 0; i < 3; ++i) {
//				////////////////////////////////////////////
//				// 由于三角形的边是顺时针方向，如果点在所有边的右面则是在三角形内部；
//				// 如果点在任何一边左面则点在三角形外面
//				////////////////////////////////////////////
//				var end:int = sides[i].classifyPoint(motionPath.getPointB(), EPSILON);
//				// 直线的 终点 不在边的 右面
//				if (end != PointClassification.RIGHT_SIDE) { //	&& end != Line2D.POINT_CLASSIFICATION.ON_LINE) {
//					//  而且 直线的 起点 不在边的 左面
//					if (sides[i].classifyPoint(motionPath.getPointA(), EPSILON) != PointClassification.LEFT_SIDE) {
//						if (end == PointClassification.ON_LINE) {
//							result.cellIndex = _links[i];
//							result.side = i;
//							result.result = PathResult.ENDING_CELL;
//							trace("exits this cell");
//							return result;
//						}
//						// 检测是否与边相交，并保存交点到result
//						var intersectResult:int = motionPath.intersection(sides[i], result.intersection);
//						if (intersectResult == LineClassification.SEGMENTS_INTERSECT || intersectResult == LineClassification.A_BISECTS_B) {
//							// 记录下一个邻接三角形的索引（如果没有则为-1）和相交的边
//							result.cellIndex = _links[i];
//							result.side = i;
//							result.result = PathResult.EXITING_CELL;
//							trace("exits this cell");
//							return result;
//						}
//					}
//				} else {
//					// 点在三角形右面，增加计数
//					interiorCount++;
//				}
//			}
//			
//			// 点在所有边的右面，即点在三角形内部
//			if (interiorCount == 3) {
//				// System.out.println(" ends within this cell");
//				result.result = PathResult.ENDING_CELL;
//				return result;
//			}
//			// System.out.println("No intersection with this cell at all");
//			// 没有任何关系
//			return result;
//			// return (PATH_RESULT.NO_RELATIONSHIP);
//		}

		/**
		 * 绘制网格索引
		 * @param sp
		 */		
		public function drawIndex(sp:Sprite):void {
			var tf:TextFormat = new TextFormat();
			tf.color = 0x00ff00;
			tf.bold = true;
			tf.size = 16;
			var txt:TextField = new TextField();
			txt.mouseEnabled = false;
			txt.defaultTextFormat = tf;
			txt.autoSize = TextFormatAlign.LEFT;
			txt.text = this._index.toString();
			txt.x = this.center.x;
			txt.y = this.center.y;
			sp.addChild(txt);
		}
		
		public function get index():int
		{
			return _index;
		}

		public function set index(value:int):void
		{
			_index = value;
		}
	}
}