/*
* @author 白连忱 
* date Jan 30, 2010
*/
package org.blch.findPath
{
	
	/**
	 * PathResult
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0
	 */
	public class PathResult {
		public static const NO_RELATIONSHIP:int = 0; 	// the path does not cross this cell
		public static const ENDING_CELL:int = 1; 		// the path ends in this cell
		public static const EXITING_CELL:int = 2;
		
		public function PathResult()
		{
		}
	}
}