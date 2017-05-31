/*
* @author 白连忱 
* date Jan 20, 2010
*/
package org.blch.geom
{
	/**
	 * Line2D
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0
	 */
	public class Line2D
	{
		private var pointA:Vector2f;	// Endpoint A of our line segment
		private var pointB:Vector2f;	// Endpoint B of our line segment
		
		private var m_Normal:Vector2f;	// 'normal' of the ray. 
		// a vector pointing to the right-hand side of the line when viewed from PointA towards PointB
		private var m_NormalCalculated:Boolean = false; // normals are only calculated on demand
		
		
		public function Line2D(pointA:Vector2f=null, pointB:Vector2f=null)
		{
			this.pointA = pointA.clone();
			this.pointB = pointB.clone();
			m_NormalCalculated = false;
		}

		
		public function setPointA(point:Vector2f):void
		{
			this.pointA = point.clone();
			m_NormalCalculated = false;
		}
		
		public function setPointB(point:Vector2f):void
		{
			this.pointB = point.clone();
			m_NormalCalculated = false;
		}
		
		private function setPoints(pointA:Vector2f, pointB:Vector2f):void
		{
			this.pointA = pointA.clone();
			this.pointB = pointB.clone();
			m_NormalCalculated = false;
		}
		
		private function getNormal():Vector2f
		{
			if (!m_NormalCalculated)
			{
				computeNormal();
			}
			
			return (m_Normal);
		}

		/**
		 * 给定点到直线的带符号距离，从a点朝向b点，右向为正，左向为负
		 */
		public function signedDistance(point:Vector2f):Number
		{
			if (!m_NormalCalculated)
			{
				computeNormal();
			}
			
			var v2f:Vector2f = point.subtract(pointA);
			var testVector:Vector2f = new Vector2f(v2f.x, v2f.y);
			
			return testVector.dot(m_Normal); 
			
		}
		
		/**
		 * 判断点与直线的关系，假设你站在a点朝向b点，
		 * 则输入点与直线的关系分为：Left, Right or Centered on the line
		 * @param point 点
		 * @param epsilon 精度值
		 * @return 
		 */		
		public function classifyPoint(point:Vector2f, epsilon:Number=0.000001):int 
		{
			var result:int = PointClassification.ON_LINE;
			var distance:Number = signedDistance(point);
			
			if (distance > epsilon)
			{
				result = PointClassification.RIGHT_SIDE;
			}
			else if (distance < -epsilon)
			{
				result = PointClassification.LEFT_SIDE;
			}
			
			return result;
		}
		
		/**
		 * 判断两个直线关系
		 * this line A = x0, y0 and B = x1, y1
		 * other is A = x2, y2 and B = x3, y3
		 * @param other 另一条直线
		 * @param pIntersectPoint (out)返回两线段的交点
		 * @return 
		 */
		public function intersection(other:Line2D, pIntersectPoint:Vector2f=null):int
		{
			var denom:Number = (other.pointB.y-other.pointA.y)*(this.pointB.x-this.pointA.x)
				-
				(other.pointB.x-other.pointA.x)*(this.pointB.y-this.pointA.y);
			
			var u0:Number = (other.pointB.x-other.pointA.x)*(this.pointA.y-other.pointA.y)
				-
				(other.pointB.y-other.pointA.y)*(this.pointA.x-other.pointA.x);
			
			var u1:Number = (other.pointA.x-this.pointA.x)*(this.pointB.y-this.pointA.y)
				-
				(other.pointA.y-this.pointA.y)*(this.pointB.x-this.pointA.x);
			
			//if parallel
			if(denom == 0.0) {
				//if collinear
				if(u0 == 0.0 && u1 == 0.0)
					return LineClassification.COLLINEAR;
				else 
					return LineClassification.PARALELL;
			} else {
				//check if they intersect
				u0 = u0/denom;
				u1 = u1/denom;
				
				var x:Number = this.pointA.x + u0*(this.pointB.x - this.pointA.x);
				var y:Number = this.pointA.y + u0*(this.pointB.y - this.pointA.y);
				
				if (pIntersectPoint != null)
				{
					pIntersectPoint.x = x; //(m_PointA.x + (FactorAB * Bx_minus_Ax));
					pIntersectPoint.y = y; //(m_PointA.y + (FactorAB * By_minus_Ay));
				}
				
				// now determine the type of intersection
				if ((u0 >= 0.0) && (u0 <= 1.0) && (u1 >= 0.0) && (u1 <= 1.0))
				{
					return LineClassification.SEGMENTS_INTERSECT;
				}
				else if ((u1 >= 0.0) && (u1 <= 1.0))
				{
					return (LineClassification.A_BISECTS_B);
				}
				else if ((u0 >= 0.0) && (u0 <= 1.0))
				{
					return (LineClassification.B_BISECTS_A);
				}
				
				return LineClassification.LINES_INTERSECT;
				
			}
		}
		
		public function getPointA():Vector2f
		{
			return (pointA);
		}
		
		
		public function getPointB():Vector2f
		{
			return (pointB);
		}
		
		/**
		 * 直线长度
		 * @return 
		 */		
		public function length():Number
		{
			var xdist:Number = pointB.x-pointA.x;
			var ydist:Number = pointB.y-pointA.y;
			
			xdist *= xdist;
			ydist *= ydist;
			
			return Number (Math.sqrt(xdist + ydist));
		}
		
		/**
		 * 直线方向
		 * @return 
		 */		
		public function getDirection():Vector2f
		{
			var pt:Vector2f = pointB.subtract(pointA);
			var direction:Vector2f = new Vector2f(pt.x, pt.y);
			return direction.normalize();
		}
		
		/**
		 * 计算法线
		 */		
		private function computeNormal():void
		{
			// Get Normailized direction from A to B
			m_Normal = getDirection();
			
//			// Rotate by -90 degrees to get normal of line
			// Rotate by +90 degrees to get normal of line
			var oldYValue:Number = m_Normal.y;
			m_Normal.y = m_Normal.x;
			m_Normal.x = -oldYValue;
			m_NormalCalculated = true;
		}
		
		/**
		 * 线段是否相等 （忽略方向）
		 * @param line
		 * @return 
		 */		
		public function equals(line:Line2D):Boolean {
			return ( pointA.equals(line.getPointA()) && pointB.equals(line.getPointB()) ) ||
				( pointA.equals(line.getPointB()) && pointB.equals(line.getPointA()) );
		}
		
		public function clone():Line2D {
			return new Line2D(pointA.clone(), pointB.clone());
		}

		public function toString():String{
			return "Line:"+pointA+" -> "+pointB;
		}
	}
}
