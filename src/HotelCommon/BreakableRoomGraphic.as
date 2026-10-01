package HotelCommon
{
   import FGKit.Graphics.MovieClipEx;
   import FGKit.Graphics.MovieClipGraphic;
   import FGKit.Utils;
   import flash.display.BitmapData;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;

   public class BreakableRoomGraphic extends MovieClipGraphic
   {

      private var m_smokeAlphas:Array;

      private var m_smokeFrames:Array;

      private var s_smokeMC:MovieClipEx;

      public function BreakableRoomGraphic()
      {
         this.s_smokeMC = new MovieClipEx(new MegaSmoke());
         super();
      }

      override public function IsUpdatable() : Boolean
      {
         return true;
      }

      override public function Update(param1:Number) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         super.Update(param1);
         var _loc2_:BreakableBehaviour = GetEntity().GetBehaviourByClass(BreakableBehaviour) as BreakableBehaviour;
         var _loc3_:int = this.s_smokeMC.GetRawClip().totalFrames;
         if(this.m_smokeFrames == null)
         {
            this.m_smokeFrames = [];
            this.m_smokeAlphas = [];
            _loc4_ = 0;
            while(_loc4_ < _loc2_.GetBreakPositions().length)
            {
               this.m_smokeFrames.push(Number(Utils.RandomInt(1,_loc3_)));
               this.m_smokeAlphas.push(!!_loc2_.IsBroken(_loc4_) ? 1 : (true, true, 0));
               _loc4_++;
            }
         }
         _loc4_ = 0;
         while(true)
         {
            if(_loc4_ >= this.m_smokeFrames.length)
            {
               break;
            }
            this.m_smokeFrames[_loc4_] += param1 * 30;
            if(int(this.m_smokeFrames[_loc4_]) > _loc3_)
            {
               this.m_smokeFrames[_loc4_] -= _loc3_;
            }
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < this.m_smokeAlphas.length)
         {
            _loc5_ = !!_loc2_.IsBroken(_loc4_) ? (true, true, Number(1)) : Number(0);
            this.m_smokeAlphas[_loc4_] = Utils.AdvanceNumber(this.m_smokeAlphas[_loc4_],_loc5_,param1);
            _loc4_++;
         }
      }

      // V2: hook so that subclasses can draw the room body differently
      // (the Industrial Laundry draws a widened version of the Laundry)
      protected function RenderBody(param1:BitmapData, param2:Matrix, param3:Matrix) : void
      {
         super.Render(param1,param2,param3);
      }

      override public function Render(param1:BitmapData, param2:Matrix, param3:Matrix) : void
      {
         var _loc7_:Matrix = null;
         this.RenderBody(param1,param2,param3);
         var _loc4_:BreakableBehaviour;
         if((_loc4_ = GetEntity().GetBehaviourByClass(BreakableBehaviour) as BreakableBehaviour) == null || this.m_smokeAlphas == null)
         {
            return;
         }
         var _loc5_:Array = _loc4_.GetBreakPositions();
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_.length)
         {
            if(this.m_smokeAlphas[_loc6_] > 0)
            {
               _loc7_ = Utils.Concat(param2,param3);
               Utils.PreTranslateMatrix(_loc5_[_loc6_].x,_loc5_[_loc6_].y,_loc7_);
               this.s_smokeMC.Render(param1,this.m_smokeFrames[_loc6_],_loc7_,true,new ColorTransform(1,1,1,this.m_smokeAlphas[_loc6_]),null,true);
            }
            _loc6_++;
         }
      }
   }
}
