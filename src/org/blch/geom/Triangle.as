/*
* @author 白连忱 
* date Jan 22, 2010
*/
package org.blch.geom
{
	import flash.display.Graphics;
	
	/**
	 * Triangle
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0
	 */
	public class Triangle
	{
		public static const EPSILON:Number = 0.000001;	//精度
		
		public static const SIDE_AB:int = 0;
		public static const SIDE_BC:int = 1;
		public static const SIDE_CA:int = 2;
		
		
		private var _pointA:Vector2f;
		private var _pointB:Vector2f;
		private var _pointC:Vector2f;
		
		private var _center:Vector2f;		//中心点
		private var _sides:Vector.<Line2D>; 	// 三角型的3个边
		
		private var dataCalculated:Boolean = false; //中心点是否已计算

		
		public function Triangle(p1:Vector2f=null, p2:Vector2f=null, p3:Vector2f=null) {
			this.pointA = p1.clone();
			this.pointB = p2.clone();
			this.pointC = p3.clone();

			dataCalculated = false;
		}
		
		public function setPoints(p1:Vector2f, p2:Vector2f, p3:Vector2f):void
		{
			this.pointA = p1.clone();
			this.pointB = p2.clone();
			this.pointC = p3.clone();
			
			dataCalculated = false;
		}
		
		/**
		 * 计算中心点（3个顶点的平均值） 
		 */
		protected function calculateData():void {
			if (_center == null)
				_center = pointA.clone();
			else 
				_center.setVector2f(pointA);
			
			_center.addLocal(pointB).addLocal(pointC).multLocal(1.0/3.0);
			
			//边
			if (_sides == null) {
				_sides = new Vector.<Line2D>();
			}
			_sides[SIDE_AB] = new Line2D(pointA, pointB); // line AB
			_sides[SIDE_BC] = new Line2D(pointB, pointC); // line BC
			_sides[SIDE_CA] = new Line2D(pointC, pointA); // line CA
			
			dataCalculated = true;
		}

		/**
		 * 根据i返回顶点
		 * @param i the index of the point.
		 * @return the point.
		 */
		public function getVertex(i:int):Vector2f {
			switch (i) {
				case 0: return pointA;
				case 1: return pointB;
				case 2: return pointC;
				default: return null;
			}
		}
		
		/**
		 * 根据i指定的索引设置三角形的顶点
		 * @param i the index to place the point.
		 * @param point the point to set.
		 */
		public function setVertex(i:int, point:Vector2f):void {
			switch (i) {
				case 0: pointA=point.clone(); break;
				case 1: pointB=point.clone(); break;
				case 2: pointC=point.clone(); break;
			}
			dataCalculated = false;
		}
		
		/**
		 * 取得指定索引的边(从0开始，顺时针)
		 * @param sideIndex
		 * @return 
		 */		
		public function getSide(sideIndex:int):Line2D {
			if(dataCalculated == false) {
				calculateData();
			}
			
			return sides[sideIndex];
		}
		
		/**
		 * 测试给定点是否在三角型中
		 * @param TestPoint
		 * @return 
		 */		
		public function isPointIn(testPoint:Vector2f):Boolean {
			if(dataCalculated == false) {
				calculateData();
			}
			
			// 点在所有边的右面
			var interiorCount:int = 0;
			for (var i:int=0; i < 3; i++) {
				if (sides[i].classifyPoint(testPoint, EPSILON) != PointClassification.LEFT_SIDE) {
					interiorCount++;
				}
			}
			return (interiorCount == 3);
		}
		
	
		public function clone():Triangle {
			return new Triangle(pointA.clone(), pointB.clone(), pointC.clone());
		}

		public function toString():String {
			return "Triangle:"+pointA+" -> "+pointB+" -> "+pointC;
		}
		
		public function draw(g:Graphics):void {
			g.moveTo(this.pointA.x, this.pointA.y);
			g.lineTo(this.pointB.x, this.pointB.y);
			g.lineTo(this.pointC.x, this.pointC.y);
			g.lineTo(this.pointA.x, this.pointA.y);
		}

		public function get pointA():Vector2f
		{
			return _pointA;
		}

		public function set pointA(value:Vector2f):void
		{
			_pointA = value;
		}

		public function get pointB():Vector2f
		{
			return _pointB;
		}

		public function set pointB(value:Vector2f):void
		{
			_pointB = value;
		}

		public function get pointC():Vector2f
		{
			return _pointC;
		}

		public function set pointC(value:Vector2f):void
		{
			_pointC = value;
		}

		/**
		 * 取得中心点
		 * @return 
		 */		
		public function get center():Vector2f
		{
			if(dataCalculated == false) {
				calculateData();
			}
			return _center;
		}

		public function get sides():Vector.<Line2D>
		{
			return _sides;
		}

	}
}