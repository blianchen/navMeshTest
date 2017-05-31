/*
* @author 白连忱 
* date Feb 12, 2010
*/
package org.blch.findPath
{
	import org.blch.geom.Vector2f;
	
	/**
	 * WayPoint
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0
	 */
	public class WayPoint {
		
		public var position:Vector2f;
		public var cell:Cell;
		
		public function WayPoint(cell:Cell, position:Vector2f)
		{
			this.cell = cell;
			this.position = position;
		}
	}
}