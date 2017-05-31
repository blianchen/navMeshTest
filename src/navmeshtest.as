/*
* @author 白连忱 
* date Jan 20, 2010
*/
package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.blch.findPath.Cell;
	import org.blch.findPath.NavMesh;
	import org.blch.geom.Delaunay;
	import org.blch.geom.Polygon;
	import org.blch.geom.Triangle;
	import org.blch.geom.Vector2f;
	
	
	/**
	 * navmeshtest
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0
	 */
	[SWF(width="800", height="520", frameRate="25")]
	public class navmeshtest extends Sprite
	{
		private var polygonV:Vector.<Polygon>;		//所有多边形
		private var triangleV:Vector.<Triangle>; 	//生成的Delaunay三角形
		
		private var cellV:Vector.<Cell>;		//已生成的寻路数据
		
		private var lineSp:Sprite;
		private var polySp:Sprite;
		
		public function navmeshtest()
		{
//			var lin:Line2D = new Line2D(new Vector2f(700,500), new Vector2f(20,20));
//			trace(lin.classifyPoint(new Vector2f(20,500), 0.0));
			
			polygonV = new Vector.<Polygon>();
			
			polySp = new Sprite();
			this.addChild(polySp);
			
			//边框
			lineSp = new Sprite();
			this.addChild(lineSp);
			lineSp.graphics.beginFill(0xdddddd, 0.5);
			lineSp.graphics.lineStyle(3, 0xaaaaaa);
			lineSp.graphics.drawRect(20, 20, 680, 480);
			lineSp.graphics.endFill();
			
//			sp.graphics.beginFill(0xff0000, 0.5);
//			sp.graphics.lineStyle(3, 0xaaaaaa);
			lineSp.addEventListener(MouseEvent.CLICK, drawLine);
			
			
			//边框多边形
			var v0:Vector.<Vector2f> = new Vector.<Vector2f>();
			v0.push(new Vector2f(20, 20));
			v0.push(new Vector2f(700, 20));
			v0.push(new Vector2f(700, 500));
			v0.push(new Vector2f(20, 500));
			var poly0:Polygon = new Polygon(v0.length, v0);
			polygonV.push(poly0);
			
			//按钮
			var tf:TextFormat = new TextFormat();
			tf.size = 14;
			tf.color = 0xff0000;
			tf.bold = true;
			var txtBtn:TextField = new TextField();
			txtBtn.defaultTextFormat = tf;
			txtBtn.autoSize = TextFieldAutoSize.LEFT;
			txtBtn.background = true;
			txtBtn.backgroundColor = 0xffff00;
			txtBtn.text = "Create Delaunay";
			txtBtn.x = 720;
			txtBtn.y = 50;
			this.addChild(txtBtn);
			txtBtn.addEventListener(MouseEvent.CLICK, buildTriangle);
			txtBtn.addEventListener(MouseEvent.CLICK, findPath);
		}
		
		private var drawPath:Vector.<Vector2f> = new Vector.<Vector2f>();
		private function drawLine(e:MouseEvent):void {
			
			var vt:Vector2f = new Vector2f(e.localX, e.localY);
			
			if (drawPath.length == 0) {
				lineSp.graphics.moveTo(vt.x, vt.y);
				drawPath.push(vt);
				
				vt.draw(this);
			} else {
				if (vt.distanceSquared(drawPath[0]) < 100) {
					vt = drawPath[0];
					var pl:Polygon = new Polygon(drawPath.length, drawPath);
					pl.cw();
					polygonV.push(pl);
					
//					trace("isCW:", pl.isCW());
//					trace("isSimplicity:", pl.isSimplicity());
					
					polySp.graphics.beginFill(0xff0000, .5);
					pl.draw(polySp.graphics);
					polySp.graphics.endFill();
					
					drawPath = new Vector.<Vector2f>();
				} else {
					drawPath.push(vt);
					
					vt.draw(this);
				}
				
				lineSp.graphics.lineTo(vt.x, vt.y);
			}
			
		}
		
		/**
		 * 合并
		 */		
		private function unionAll():void {
			for (var n:int=1; n<polygonV.length; n++) {
				var p0:Polygon = polygonV[n];
				for (var m:int=1; m<polygonV.length; m++) {
					var p1:Polygon = polygonV[m];
//					trace("p0", p0.isCW(), p0);
//					trace("p1", p1.isCW(), p1);
					if (p0 != p1 && p0.isCW() && p1.isCW()) {
						var v:Vector.<Polygon> = p0.union(p1);	//合并
						
						if (v != null && v.length > 0) {
							trace("delete");
							polygonV.splice(polygonV.indexOf(p0), 1);
							polygonV.splice(polygonV.indexOf(p1), 1);

							for each (var pv:Polygon in v) {
								polygonV.push(pv);
							}
							
							n = 1;	//重新开始
							break;
						}
					}
				}
			}
			//绘图
			polySp.graphics.lineStyle(3, 0xaaaaaa);
			for (var k:int=1; k<polygonV.length; k++) {
				var ptmp:Polygon = polygonV[k];
				ptmp.draw(polySp.graphics);
			}
		}
		
		/**
		 * 构建网格
		 * @param e
		 */		
		private function buildTriangle(e:MouseEvent):void {
			//合并
			this.unionAll();
			
			init();
			
			var d:Delaunay = new Delaunay();
			triangleV = d.createDelaunay(polygonV);
			
			lineSp.graphics.lineStyle(1, 0xff0000);
			for each (var t:Triangle in triangleV) {
				t.draw(lineSp.graphics);
			}
			
			//构建寻路数据
			cellV = new Vector.<Cell>();
			var trg:Triangle;
			var cell:Cell;
			for (var j:int=0; j<triangleV.length; j++) {
				trg = triangleV[j];
				cell = new Cell(trg.getVertex(0), trg.getVertex(1), trg.getVertex(2));
				cell.index = j;
				cellV.push(cell);
				
				cell.drawIndex(this);
			}
			linkCells(cellV);
			
//			for each (var ct:Cell in cellV) {
//				trace("Link:", ct.index, "--", ct.links);
//			}
		}
		
		/**
		 * 寻路
		 * @param e
		 */		
		private function findPath(e:MouseEvent):void {
			lineSp.removeEventListener(MouseEvent.CLICK, drawLine);
			lineSp.addEventListener(MouseEvent.CLICK, setFindPath);
		}
		
		private var startPtSign:Boolean = false;
		private var startPt:Point;
		private var endPt:Point;
		private function setFindPath(e:MouseEvent):void {
			if (startPtSign) {
				endPt = new Point(e.localX, e.localY);
				startPtSign = false;
				
				lineSp.graphics.beginFill(0xff0000);
				lineSp.graphics.drawCircle(endPt.x, endPt.y, 3);
				lineSp.graphics.endFill();
				
				var nav:NavMesh = new NavMesh(cellV);
				lineSp.addChild(nav);
				nav.findPath(startPt, endPt);
			} else {
				startPt = new Point(e.localX, e.localY);
				startPtSign = true;
				
				lineSp.graphics.beginFill(0x00ff00);
				lineSp.graphics.drawCircle(startPt.x, startPt.y, 3);
				lineSp.graphics.endFill();
			}
		}
		
		/**
		 * 搜索单元网格的邻接网格，并保存链接数据到网格中，以提供给寻路用
		 * @param pv
		 */		
		public function linkCells(pv:Vector.<Cell>):void {
			for each (var pCellA:Cell in pv) {
				for each (var pCellB:Cell in pv) {
					if (pCellA != pCellB) {
						pCellA.checkAndLink(pCellB);
					}
				}
			}
		}
		
		private function init():void {
			
			
//			var v0:Vector.<Vector2f> = new Vector.<Vector2f>();
//			v0.push(new Vector2f(173,53));
//			v0.push(new Vector2f(283,142));
//			v0.push(new Vector2f(288,248));
//			v0.push(new Vector2f(201,210));
//			v0.push(new Vector2f(81,234));
//			v0.push(new Vector2f(116,89));
//			var poly0:Polygon = new Polygon(v0.length, v0);
//			polygonV.push(poly0);
//			
//			var v1:Vector.<Vector2f> = new Vector.<Vector2f>();
//			v1.push(new Vector2f(362,268));
//			v1.push(new Vector2f(208,334));
//			v1.push(new Vector2f(385,371));
//			v1.push(new Vector2f(478,334));
//			v1.push(new Vector2f(486,259));
//			v1.push(new Vector2f(400,330));
//			var poly1:Polygon = new Polygon(v1.length, v1);
//			polygonV.push(poly1);
			
			
			lineSp.graphics.lineStyle(3, 0x00ffff);
			for each (var t:Polygon in polygonV) {
				trace(t);
				t.draw(lineSp.graphics);
			}
		}
	}
}


