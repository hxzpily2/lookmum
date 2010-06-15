package com.lookmum.view 
{
	import com.lookmum.events.InteractiveComponentEvent;
	import com.lookmum.util.ModalManager;
	import com.lookmum.view.Component;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Phil Douglas
	 */
	public class Button extends Component
	{
		protected const FRAME_ROLL_OVER:String = 'rollOver';
		protected const FRAME_ROLL_OUT:String = 'rollOut';
		protected const FRAME_PRESS:String = 'press';
		protected const FRAME_DISABLE:String = 'disable';
		
		protected var isMouseOutside:Boolean = false;
		
		public function Button(target:MovieClip) 
		{
			super(target);
			buttonMode = true;
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp );
			doEnable();
		}
		protected function getHitspot():MovieClip
		{
			return target;
		}
		/**
		 * A Boolean value that indicates whether a movie clip is enabled.
		 */
		override public function get enabled():Boolean { return super.enabled; }
		
		override public function set enabled(value:Boolean):void 
		{
			//also set mouseenabled to the same value
			if (value) {
				doEnable();
			}else {
				ModalManager.getInstance().unregisterComponent(this);
				this.doDisable();
			}
		}
		protected function doEnable():void {
			ModalManager.getInstance().registerComponent(this, this.doDisable);
			target.gotoAndStop(FRAME_ROLL_OUT);
			buttonMode = true;
			tabEnabled = true;
			mouseEnabled = true;
			super.enabled = true;
			mouseChildren = true;
			this.dispatchEvent(new InteractiveComponentEvent(InteractiveComponentEvent.ENABLE));
		}
		protected function doDisable():void {
			buttonMode = false;
			tabEnabled = false;
			mouseEnabled = false;
			super.enabled = false;
			mouseChildren = false;
			target.gotoAndStop(FRAME_DISABLE);
			this.dispatchEvent(new InteractiveComponentEvent(InteractiveComponentEvent.DISABLE));
		}
		
		//{region animations
		
		protected function onRollOver(e:MouseEvent):void 
		{
			if (!enabled) return;
			target.gotoAndStop(FRAME_ROLL_OVER);
		}
		
		protected function onRollOut(e:MouseEvent):void 
		{
			isMouseOutside = true;
			if (!enabled) return;
			target.gotoAndStop(FRAME_ROLL_OUT);
		}
		
		protected function onMouseDown(e:MouseEvent):void 
		{
			if (!enabled) return;
			target.gotoAndStop(FRAME_PRESS);
			getHitspot().stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		protected function onMouseUp(e:MouseEvent):void 
		{
			if (!enabled) return;
			target.gotoAndStop(FRAME_ROLL_OVER);
			if (isMouseOutside) 
			{
				isMouseOutside = false;
				if (getHitspot().stage)  getHitspot().stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				target.gotoAndStop(FRAME_ROLL_OUT);
				dispatchEvent(new InteractiveComponentEvent(InteractiveComponentEvent.MOUSE_UP_OUTSIDE, true));
			}
		}
		
		override public function destroy():void 
		{
			if(getHitspot().stage) getHitspot().stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp) ;
			
			super.destroy();
			
		}
	}

}