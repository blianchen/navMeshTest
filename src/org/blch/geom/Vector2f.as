/*
* @author 白连忱 
* date Jan 20, 2010
*/
package org.blch.geom
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * Vector2f
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 10.0
	 */
	public class Vector2f
	{
		private var _x:Number;
		private var _y:Number;

		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			_x = value;
		}

		public function get y():Number
		{
			return _y;
		}

		public function set y(value:Number):void
		{
			_y = value;
		}

		
		public function Vector2f(x:Number=0, y:Number=0)
		{
			this.x = x;
			this.y = y;
		}
		
		public function setVector2f(vec:Vector2f):void
		{
			this.x = vec.x;
			this.y = vec.y;
		}
		
		/**
		 * <code>getAngle</code> returns (in radians) the angle represented by
		 * this Vector2f as expressed by a conversion from rectangular coordinates (<code>x</code>,&nbsp;<code>y</code>)
		 * to polar coordinates (r,&nbsp;<i>theta</i>).
		 * 
		 * @return the angle in radians. [-pi, pi)
		 */
		public function getAngle():Number
		{
			return -Math.atan2(y, x);
		}
		
		/**
		 * <code>length</code> calculates the magnitude of this vector.
		 * 
		 * @return the length or magnitude of the vector.
		 */
		public function length():Number {
			return Math.sqrt(lengthSquared());
		}
		
		/**
		 * <code>lengthSquared</code> calculates the squared value of the
		 * magnitude of the vector.
		 * 
		 * @return the magnitude squared of the vector.
		 */
		public function lengthSquared():Number
		{
			return x * x + y * y;
		}
		
		/**
		 * <code>distanceSquared</code> calculates the distance squared between
		 * this vector and vector v.
		 *
		 * @param v the second vector to determine the distance squared.
		 * @return the distance squared between the two vectors.
		 */
		public function distanceSquared(v:Vector2f):Number
		{
			var dx:Number = x - v.x;
			var dy:Number = y - v.y;
			return Number (dx * dx + dy * dy);
		}
		
		/**
		 * <code>negate</code> returns the negative of this vector. All values are
		 * negated and set to a new vector.
		 * 
		 * @return the negated vector.
		 */
		public function negate():Vector2f {
			return new Vector2f(-x, -y);
		}
		
		/**
		 * <code>negateLocal</code> negates the internal values of this vector.
		 * 
		 * @return this.
		 */
		public function negateLocal():Vector2f {
			x = -x;
			y = -y;
			return this;
		}
		
		/**
		 * <code>add</code> adds a provided vector to this vector creating a
		 * resultant vector which is returned. If the provided vector is null, null
		 * is returned.
		 * 
		 * @param vec
		 *            the vector to add to this.
		 * @return the resultant vector.
		 */
		public function add(vec:Vector2f):Vector2f {
			if (null == vec) {
//				logger.warning("Provided vector is null, null returned.");
				return null;
			}
			return new Vector2f(x + vec.x, y + vec.y);
		}
		
		/**
		 * <code>addLocal</code> adds a provided vector to this vector internally,
		 * and returns a handle to this vector for easy chaining of calls. If the
		 * provided vector is null, null is returned.
		 * 
		 * @param vec
		 *            the vector to add to this vector.
		 * @return this
		 */
		public function addLocal(vec:Vector2f):Vector2f {
			if (null == vec) {
//				logger.warning("Provided vector is null, null returned.");
				return null;
			}
			x += vec.x;
			y += vec.y;
			return this;
		}
		
		/**
		 * <code>subtract</code> subtracts the values of a given vector from those
		 * of this vector creating a new vector object. If the provided vector is
		 * null, an exception is thrown.
		 * 
		 * @param vec
		 *            the vector to subtract from this vector.
		 * @return the result vector.
		 */
		public function subtract(vec:Vector2f):Vector2f {
			return new Vector2f(x - vec.x, y - vec.y);
		}
		
		/**
		 * <code>subtractLocal</code> subtracts a provided vector to this vector
		 * internally, and returns a handle to this vector for easy chaining of
		 * calls. If the provided vector is null, null is returned.
		 * 
		 * @param vec
		 *            the vector to subtract
		 * @return this
		 */
		public function subtractLocal(vec:Vector2f):Vector2f {
			if (null == vec) {
//				logger.warning("Provided vector is null, null returned.");
				return null;
			}
			x -= vec.x;
			y -= vec.y;
			return this;
		}
		
		/**
		 * <code>dot</code> calculates the dot product of this vector with a
		 * provided vector. If the provided vector is null, 0 is returned.
		 * 
		 * @param vec
		 *            the vector to dot with this vector.
		 * @return the resultant dot product of this vector and a given vector.
		 */
		public function dot(vec:Vector2f):Number {
			if (null == vec) {
//				logger.warning("Provided vector is null, 0 returned.");
				return 0;
			}
			return x * vec.x + y * vec.y;
		}
		
		/**
		 * <code>mult</code> multiplies this vector by a scalar. The resultant
		 * vector is returned.
		 * 
		 * @param scalar
		 *            the value to multiply this vector by.
		 * @return the new vector.
		 */
		public function mult(scalar:Number):Vector2f {
			return new Vector2f(x * scalar, y * scalar);
		}
		
		/**
		 * <code>multLocal</code> multiplies this vector by a scalar internally,
		 * and returns a handle to this vector for easy chaining of calls.
		 * 
		 * @param scalar
		 *            the value to multiply this vector by.
		 * @return this
		 */
		public function multLocal(scalar:Number):Vector2f {
			x *= scalar;
			y *= scalar;
			return this;
		}
		
		/**
		 * <code>multLocal</code> multiplies a provided vector to this vector
		 * internally, and returns a handle to this vector for easy chaining of
		 * calls. If the provided vector is null, null is returned.
		 * 
		 * @param vec
		 *            the vector to mult to this vector.
		 * @return this
		 */
		public function multLocalV(vec:Vector2f):Vector2f {
			if (null == vec) {
//				logger.warning("Provided vector is null, null returned.");
				return null;
			}
			x *= vec.x;
			y *= vec.y;
			return this;
		}
		
		/**
		 * Multiplies this Vector2f's x and y by the scalar and stores the result in
		 * product. The result is returned for chaining. Similar to
		 * product=this*scalar;
		 * 
		 * @param scalar
		 *            The scalar to multiply by.
		 * @param product
		 *            The vector2f to store the result in.
		 * @return product, after multiplication.
		 */
		public function multV(scalar:Number, product:Vector2f):Vector2f {
			if (null == product) {
				product = new Vector2f();
			}
			
			product.x = x * scalar;
			product.y = y * scalar;
			return product;
		}
		
		/**
		 * <code>divide</code> divides the values of this vector by a scalar and
		 * returns the result. The values of this vector remain untouched.
		 * 
		 * @param scalar
		 *            the value to divide this vectors attributes by.
		 * @return the result <code>Vector</code>.
		 */
		public function divide(scalar:Number):Vector2f {
			return new Vector2f(x / scalar, y / scalar);
		}
		
		/**
		 * <code>divideLocal</code> divides this vector by a scalar internally,
		 * and returns a handle to this vector for easy chaining of calls. Dividing
		 * by zero will result in an exception.
		 * 
		 * @param scalar
		 *            the value to divides this vector by.
		 * @return this
		 */
		public function divideLocal(scalar:Number):Vector2f {
			x /= scalar;
			y /= scalar;
			return this;
		}
		
		/**
		 * <code>normalize</code> returns the unit vector of this vector.
		 * 
		 * @return unit vector of this vector.
		 */
		public function normalize():Vector2f {
			var length:Number = length();
			if (length != 0) {
				return divide(length);
			}
			
			return divide(1);
		}
		
		/**
		 * <code>normalizeLocal</code> makes this vector into a unit vector of
		 * itself.
		 * 
		 * @return this.
		 */
		public function normalizeLocal():Vector2f {
			var length:Number = length();
			if (length != 0) {
				return divideLocal(length);
			}
			
			return divideLocal(1);
		}
		
		
		
		/**
		 * <code>smallestAngleBetween</code> returns (in radians) the minimum
		 * angle between two vectors. It is assumed that both this vector and the
		 * given vector are unit vectors (iow, normalized).
		 * 
		 * @param otherVector a unit vector to find the angle against
		 * @return the angle in radians.
		 */
		public function smallestAngleBetween(otherVector:Vector2f):Number {
			var dotProduct:Number = dot(otherVector);
			var angle:Number = Math.acos(dotProduct);
			return angle;
		}
		
		/**
		 * <code>angleBetween</code> returns (in radians) the angle required to
		 * rotate a ray represented by this vector to lie colinear to a ray
		 * described by the given vector. It is assumed that both this vector and
		 * the given vector are unit vectors (iow, normalized).
		 * 
		 * @param otherVector
		 *            the "destination" unit vector
		 * @return the angle in radians.
		 */
		public function angleBetween(otherVector:Vector2f):Number {
			var angle:Number = Math.atan2(otherVector.y, otherVector.x) - Math.atan2(y, x);
			return angle;
		}
		
//		/**
//		 * <code>cross</code> calculates the cross product of this vector with a
//		 * parameter vector v.
//		 * 
//		 * @param v
//		 *            the vector to take the cross product of with this.
//		 * @return the cross product vector.
//		 */
//		public function cross(Vector2f v):Vector3f {
//			return new Vector3f(0, 0, determinant(v));
//		}
		
		/**
		 * Sets this vector to the interpolation by changeAmnt from this to the
		 * finalVec this=(1-changeAmnt)*this + changeAmnt * finalVec
		 * 确定两个指定点之间的点。 参数 changeAmnt 确定新的内插点相对于参数 pt1 和 pt2 指定的两个端点所处的位置。
		 * @param finalVec
		 *            The final vector to interpolate towards
		 * @param changeAmnt
		 *            An amount between 0.0 - 1.0 representing a percentage change
		 *            from this towards finalVec
		 */
		public function interpolate(finalVec:Vector2f, changeAmnt:Number):void {
			this.x = (1 - changeAmnt) * this.x + changeAmnt * finalVec.x;
			this.y = (1 - changeAmnt) * this.y + changeAmnt * finalVec.y;
		}
		
		/**
		 * <code>zero</code> resets this vector's data to zero internally.
		 */
		public function zero():void
		{
			x = y = 0;
		}
		
		/**
		 * Saves this Vector2f into the given float[] object.
		 * 
		 * @param floats
		 *            The float[] to take this Vector2f. If null, a new float[2] is created.
		 * @return The array, with X, Y float values in that order
		 */
		public function toArray(v:Vector.<Number>):Vector.<Number>
		{
			if (v == null) {
				v = new Vector.<Number>();
			}
			v[0] = x;
			v[1] = y;
			return v;
		}
		
		
		public function rotateAroundOrigin(angle:Number, cw:Boolean):void
		{
			if (cw)
				angle = -angle;
			
			var newX:Number = Math.cos(angle) * x - Math.sin(angle) * y;
			var newY:Number = Math.sin(angle) * x + Math.cos(angle) * y;
			x = newX;
			y = newY;
		}
		
		public function equals(vec:Vector2f, epsilon:Number=0.000001):Boolean
		{
			return Math.abs(x-vec.x) < epsilon	&& Math.abs(y-vec.y) < epsilon;
		}
		
		public function clone():Vector2f {
			return new Vector2f(x, y);
		}
		
		public function toPoint():Point {
			return new Point(x, y);
		}
		
		
		public function draw(sp:Sprite):void {
			var tf:TextFormat = new TextFormat();
			tf.color = 0x000000;
			tf.size = 10;
			var txt:TextField = new TextField();
			txt.mouseEnabled = false;
			txt.defaultTextFormat = tf;
			txt.autoSize = TextFieldAutoSize.LEFT;
			txt.x = x;
			txt.y = y;
			txt.text = toString();
			sp.addChild(txt);
		}
		
		public function toString():String{
			return "("+x+","+y+")";
		}
	}
}