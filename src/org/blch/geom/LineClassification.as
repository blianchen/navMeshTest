/*
* @author 白连忱 
* date Jan 22, 2010
*/
package org.blch.geom
{
	
	/**
	 * LineClassification
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0
	 */
	public final class LineClassification
	{
		public static const COLLINEAR:int = 0;			// both lines are parallel and overlap each other
		public static const LINES_INTERSECT:int = 1;	// lines intersect, but their segments do not
		public static const SEGMENTS_INTERSECT:int = 2;	// both line segments bisect each other
		public static const A_BISECTS_B:int = 3;		// line segment B is crossed by line A
		public static const B_BISECTS_A:int = 4;		// line segment A is crossed by line B
		public static const PARALELL:int = 5;			// the lines are paralell

		
		public function LineClassification()
		{
		}
	}
}