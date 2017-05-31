/*
* @author 白连忱 
* date Jan 30, 2010
*/
package org.blch.findPath
{
	import org.blch.geom.Vector2f;
	
	/**
	 * ClassifyResult
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0
	 */
	public class ClassifyResult {
		public function ClassifyResult()
		{
		}
		/**
		 * 直线与cell（三角形）的关系 
		 */		
		public var result:int = PathResult.NO_RELATIONSHIP;
		/**
		 * 相交边的索引
		 */		
		public var side:int = 0;
		/**
		 * 下一个邻接cell的索引
		 */		
		public var cellIndex:int = -1;
		/**
		 * 交点
		 */		
		public var intersection:Vector2f = new Vector2f();
		
		public function toString():String {
			return result.toString() + " " + cellIndex;
		}
	}
}