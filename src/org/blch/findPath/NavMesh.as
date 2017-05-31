/*
* @author 白连忱 
* date Jan 25, 2010
*/
package org.blch.findPath
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import org.blch.geom.Line2D;
	import org.blch.geom.PointClassification;
	import org.blch.geom.Vector2f;
	import org.blch.util.Heap;
	
	/**
	 * NavMesh
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0
	 */
	public class NavMesh extends Sprite
	{
		public static const EPSILON:Number = 0.000001;	//精度
		
		// Path finding session ID. This Identifies each pathfinding session
		// so we do not need to clear out old data in the cells from previous sessions.
		private static var pathSessionId:int = 0;	
		
		private var m_CellVector:Vector.<Cell>;
		
		private var openList:Heap;
		private var closeList:Array;
		
		public function NavMesh(cellVector:Vector.<Cell>)
		{
			m_CellVector = cellVector;
			
			//
			openList = new Heap(m_CellVector.length, function(a:Cell, b:Cell):int { return b.f - a.f; });
			closeList = new Array();
		}
		
		public function getCell(index:int):Cell {
			return m_CellVector[index];
		}
		
		/**
		 * 找出给定点所在的三角型
		 * @param Point
		 * @return 
		 */		
		public function findClosestCell(pt:Vector2f):Cell {
			for each (var pCell:Cell in m_CellVector) {
				if (pCell.isPointIn(pt)) {
					return pCell;
				}
			}
			return null;
		}
		
		public function findPath(startPointPx:Point, endPointPx:Point):Array {
			
			var stime:int = getTimer();
			
			pathSessionId++;
			
			var startPos:Vector2f = new Vector2f(startPointPx.x, startPointPx.y);
			var endPos:Vector2f = new Vector2f(endPointPx.x, endPointPx.y);
			var startCell:Cell = findClosestCell(startPos);
			var endCell:Cell = findClosestCell(endPos);
			if (startCell == null || endCell == null) {
				trace("没有路径。");
				return null;
			}
			
			var outPath:Array;
			
			if (startCell == endCell) {
				outPath = [startPointPx, endPointPx];
			} else {
				outPath = buildPath(startCell, startPos, endCell, endPos);
			}
			
			trace("寻路时间：", getTimer()-stime);
			trace(outPath);
			//画路径线
			if (outPath != null && outPath.length > 1) {
//				trace("画路径线");
				this.graphics.lineStyle(2, 0xffff00);
				this.graphics.moveTo(outPath[0].x, outPath[0].y);
				for (var m:int=1; m<outPath.length; m++) {
					this.graphics.lineTo(outPath[m].x, outPath[m].y);
				}
			}
			
			return outPath;
		}
		
		/**
		 * 构建路径
		 * @param startCell
		 * @param startPos
		 * @param endCell
		 * @param endPos
		 * @return Point路径数组
		 */		
		public function buildPath(startCell:Cell, startPos:Vector2f, 
								  endCell:Cell, endPos:Vector2f):Array {
			openList.clear();
			closeList.length = 0;
			
			openList.put(endCell);
			endCell.f = 0;
			endCell.h = 0;
			endCell.isOpen = false;
			endCell.parent = null;
			endCell.sessionId = pathSessionId;
			
			var foundPath:Boolean = false;		//是否找到路径
			var currNode:Cell;				//当前节点
			var adjacentTmp:Cell = null;	//当前节点的邻接三角型
			while (openList.size > 0) {
//				trace(openList.size);
				// 1. 把当前节点从开放列表删除, 加入到封闭列表
				currNode = openList.pop();
				closeList.push(currNode);
//				trace(openList.size);
//				trace("*****", currNode);
				
				//路径是在同一个三角形内
				if (currNode == startCell) {
					foundPath = true;
					break;
				}
				
				// 2. 对当前节点相邻的每一个节点依次执行以下步骤:
				//所有邻接三角型
//				trace(currNode, currNode.index, currNode.links);
				var adjacentId:int;
				for (var i:int=0; i<3; i++) {
					adjacentId = currNode.links[i];
					// 3. 如果该相邻节点不可通行或者该相邻节点已经在封闭列表中,
					//    则什么操作也不执行,继续检验下一个节点;
					if (adjacentId < 0) {						//不能通过
						continue;
					} else {
						adjacentTmp = m_CellVector[adjacentId];
					}
					
					if (adjacentTmp != null) {
						if (adjacentTmp.sessionId != pathSessionId) {
							// 4. 如果该相邻节点不在开放列表中,则将该节点添加到开放列表中, 
							//    并将该相邻节点的父节点设为当前节点,同时保存该相邻节点的G和F值;
							adjacentTmp.sessionId = pathSessionId;
							adjacentTmp.parent = currNode;
							adjacentTmp.isOpen = true;
							
							//H和F值
							adjacentTmp.computeHeuristic(startPos);
							adjacentTmp.f = currNode.f + adjacentTmp.m_WallDistance[Math.abs(i - currNode.m_ArrivalWall)];
							
							//放入开放列表并排序
							openList.put(adjacentTmp);
							
							// remember the side this caller is entering from
							adjacentTmp.setAndGetArrivalWall(currNode.index);
						} else {
							// 5. 如果该相邻节点在开放列表中, 
							//    则判断若经由当前节点到达该相邻节点的G值是否小于原来保存的G值,
							//    若小于,则将该相邻节点的父节点设为当前节点,并重新设置该相邻节点的G和F值
							if (adjacentTmp.isOpen) {//已经在openList中
								if (currNode.f + adjacentTmp.m_WallDistance[Math.abs(i - currNode.m_ArrivalWall)] < adjacentTmp.f) {
									adjacentTmp.f = currNode.f;
									adjacentTmp.parent = currNode;
									
									// remember the side this caller is entering from
									adjacentTmp.setAndGetArrivalWall(currNode.index);
								}
							} else {//已在closeList中
								adjacentTmp = null;
								continue;
							}
						}
					}
				}
			}
			
			//由网格路径生成Point数组路径
			if (foundPath) {
//				trace(closeList);
				return getPath(startPos, endPos);
			} else {
				return null;
			}
		}
		
		/**
		 * 路径经过的网格
		 * @return 
		 */		
		private function getCellPath():Vector.<Cell> {
			var pth:Vector.<Cell> = new Vector.<Cell>();
			
			var st:Cell = closeList[closeList.length-1];
			pth.push(st);
						
			while (st.parent != null) {
//				trace("&&&&&", st.parent);
				this.graphics.beginFill(0x0000ff, 0.2);
				st.draw(this.graphics);
				this.graphics.endFill();
				
				pth.push(st.parent);
				st = st.parent;
			}
			
			this.graphics.beginFill(0x0000ff, 0.2);
			st.draw(this.graphics);
			this.graphics.endFill();
			
			trace(pth);
			return pth;
		}
		
		/**
		 * 根据经过的三角形返回路径点(下一个拐角点法)
		 * @param start 
		 * @param end 
		 * @return Point数组
		 */		
		private function getPath(start:Vector2f, end:Vector2f):Array {
			//经过的三角形
			var cellPath:Vector.<Cell> = getCellPath();
			//没有路径
			if (cellPath == null || cellPath.length == 0) {
				return null;
			}
			
			//保存最终的路径（Point数组）
			var pathArr:Array = new Array();
			
			//开始点
			pathArr.push(start.toPoint());	
			//起点与终点在同一三角形中
			if (cellPath.length == 1) {		
				pathArr.push(end.toPoint());	//结束点
				return pathArr;
			}
			
			//获取路点
			var wayPoint:WayPoint = new WayPoint(cellPath[0], start);
			while (!wayPoint.position.equals(end)) {
				wayPoint = this.getFurthestWayPoint(wayPoint, cellPath, end);
				pathArr.push(wayPoint.position);
			}
			
//			pathArr.push(end.toPoint());
			return pathArr;
		}
		
		/**
		 * 下一个拐点
		 * @param wayPoint 当前所在路点
		 * @param cellPath 网格路径
		 * @param end 终点
		 * @return 
		 */		
		private function getFurthestWayPoint(wayPoint:WayPoint, cellPath:Vector.<Cell>, end:Vector2f):WayPoint {
			var startPt:Vector2f = wayPoint.position;	//当前所在路径点
			var cell:Cell = wayPoint.cell;
			var lastCell:Cell = cell;
			var startIndex:int = cellPath.indexOf(cell);	//开始路点所在的网格索引
			var outSide:Line2D = cell.sides[cell.m_ArrivalWall];	//路径线在网格中的穿出边
			var lastPtA:Vector2f = outSide.getPointA();
			var lastPtB:Vector2f = outSide.getPointB();
			var lastLineA:Line2D = new Line2D(startPt, lastPtA);
			var lastLineB:Line2D = new Line2D(startPt, lastPtB);
			var testPtA:Vector2f, testPtB:Vector2f;		//要测试的点
			for (var i:int=startIndex+1; i<cellPath.length; i++) {
				cell = cellPath[i];
				outSide = cell.sides[cell.m_ArrivalWall];
				if (i == cellPath.length-1) {
					testPtA = end;
					testPtB = end;
				} else {
					testPtA = outSide.getPointA();
					testPtB = outSide.getPointB();
				}
				
				if (!lastPtA.equals(testPtA)) {
					if (lastLineB.classifyPoint(testPtA, EPSILON) == PointClassification.RIGHT_SIDE) {
						//路点
						return new WayPoint(lastCell, lastPtB);
					} else {
						if (lastLineA.classifyPoint(testPtA, EPSILON) != PointClassification.LEFT_SIDE) {
							lastPtA = testPtA;
							lastCell = cell;
							//重设直线
							lastLineA.setPointB(lastPtA);
//							lastLineB.setPointB(lastPtB);
						}
					}
				}
				
				if (!lastPtB.equals(testPtB)) {
					if (lastLineA.classifyPoint(testPtB, EPSILON) == PointClassification.LEFT_SIDE) {
						//路径点
						return new WayPoint(lastCell, lastPtA);
					} else {
						if (lastLineB.classifyPoint(testPtB, EPSILON) != PointClassification.RIGHT_SIDE) {
							lastPtB = testPtB;
							lastCell = cell;
							//重设直线
//							lastLineA.setPointB(lastPtA);
							lastLineB.setPointB(lastPtB);
						}
					}
				}
			}
			return new WayPoint(cellPath[cellPath.length-1], end);	//终点
		}
		
//		/**
//		 * 射线法
//		 * @param start
//		 * @param end
//		 * @return 
//		 */		
//		private function getPath(start:Vector2f, end:Vector2f):Array {
//			var pathArr:Array = new Array();
//			var cellPath:Vector.<Cell> = getCellPath();
//			//没有路径
//			if (cellPath == null || cellPath.length == 0) {
//				return null;
//			}
//			
//			//开始点
//			pathArr.push(start.toPoint());	
//			
//			if (cellPath.length == 1) {		//起点与终点在同一三角形中
//				pathArr.push(end.toPoint());	//结束点
//				return pathArr;
//			}
//			trace("ssss", start, end);
//			
//			var wayPoint:WayPoint = new WayPoint(cellPath[0], start);
//			while (true) {
//				trace("wayPoint.position", wayPoint.position);
//				wayPoint = this.getFurthestWayPoint(wayPoint, cellPath, start, end);
//				pathArr.push(wayPoint.position.toPoint());
//				trace("====", wayPoint.position, end);
//if (wayPoint.position.equals(end)) {
//	break;
//}
//			}
//			
////			pathArr.push(end.toPoint());
//			return pathArr;
//		}
//		
//		// : GetFurthestVisibleWayPoint
//		// ----------------------------------------------------------------------------------------
//		//
//		// Find the furthest visible waypoint from the VantagePoint provided. This
//		// is used to
//		// smooth out irregular paths.
//		//
//		// -------------------------------------------------------------------------------------://
////		private var nextWayCellIndex:Cell;
//		public function getFurthestWayPoint(currWayPoint:WayPoint, cellPath:Vector.<Cell>,
//											start:Vector2f, end:Vector2f):WayPoint {
//			if (currWayPoint.cell == cellPath[cellPath.length-1]) {
//				return new WayPoint(cellPath[cellPath.length-1], end);
//			}
//
//			var i:int = cellPath.indexOf(currWayPoint.cell);
//			
////			var visibleWaypoint:WayPoint = currWayPoint;
////			var visibleCell:Cell = visibleWaypoint.cell;
////			var visiblePosition:Vector2f = visibleWaypoint.position;
//			var testCell:Cell = cellPath[++i];
//			var testPosition:Vector2f;
//			while (true) {
//				trace("getFurthestWayPoint", i);
//				if (i == cellPath.length-1) {
//					testPosition = end;
//				} else {
//					testPosition = testCell.m_WallMidpoint[testCell.m_ArrivalWall];
//				}
//				
//				if (!lineOfSightTest(currWayPoint.cell, currWayPoint.position, testPosition)) {
//					//				System.out.println(" WAY IND was:" + i);
//					if (start.equals(currWayPoint.position)) {
//						return new WayPoint(currWayPoint.cell, currWayPoint.cell.m_WallMidpoint[currWayPoint.cell.m_ArrivalWall]);
//					} else {
//						return new WayPoint(testCell, testPosition);
//					}
//				}
////				visibleCell = testCell;
////				visiblePosition = testPosition;
//				
//				if (i == cellPath.length-1) {
//					break;
//				}
//				testCell = cellPath[++i];
//			}
//			//		System.out.println(" WAY IND was:" + i);
//			// the last
//			return new WayPoint(testCell, testPosition);
//		}
//		
//		// : LineOfSightTest
//		// ----------------------------------------------------------------------------------------
//		//
//		// Test to see if two points on the mesh can view each other
//		//
//		// -------------------------------------------------------------------------------------://
//		// FIXME EndCell is the last visible cell?
//		private function lineOfSightTest(startCell:Cell, startPos:Vector2f, endPos:Vector2f):Boolean {
//			var motionPath:Line2D = new Line2D(startPos, endPos);
//			
////			var testCell:Cell = startCell;
//			var result:ClassifyResult = startCell.classifyPathToCell(motionPath);
//			while (result.result == PathResult.EXITING_CELL) {
//				trace("lineOfSightTest", result.cellIndex);
//				if (result.cellIndex == -1)// hit a wall, so the point is not visible
//					return false;
//				result = m_CellVector[result.cellIndex].classifyPathToCell(motionPath);
//			}
//			
//			return (result.result == PathResult.ENDING_CELL);
////			return result;
//		}
	}
}