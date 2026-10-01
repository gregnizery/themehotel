package HotelCommon
{
   import FGKit.Graphics.MovieClipEx;
   import FGKit.Properties.BoolProperty;
   import FGKit.Utils;
   import Hotel.Objects.Laundry;
   import Hotel.Objects.laundy_automate_baraban_with_cap;
   import Hotel.Objects.laundy_automate_baraban_with_cap_2;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;

   public class LaundryGraphic extends BreakableRoomGraphic
   {

      private static var s_barabanPositions:Vector.<Point> = new Vector.<Point>();

      // V2: machine positions of the Industrial Laundry (6 machines)
      private static var s_xlBarabanPositions:Vector.<Point> = new Vector.<Point>();

      private static const barabanCount:int = 4;

      private static const xlBarabanCount:int = 6;

      private static var s_barabans:Array = [new MovieClipEx(new laundy_automate_baraban_with_cap()),new MovieClipEx(new laundy_automate_baraban_with_cap_2())];

      // V2: the Industrial Laundry is drawn from slices of the Laundry clip,
      // [srcFrom, srcTo, dstX] in pixels from the clip's left edge:
      // left wall + 3 pairs of seats + 6 machines + right wall = 6 cells
      private static const s_xlSlices:Array = [[0,47,0],[10,47,47],[47,84,84],[84,164,121],[84,250,201]];

      // horizontal shift of each Industrial Laundry machine, relative to the original machine it copies
      private static const s_xlMachineShift:Array = [37,37,117,117,117,117];

      private static const s_xlMachineSource:Array = [0,1,0,1,2,3];

      private static const xlExtraWidth:Number = 117;

      private static var s_rawLaundry:MovieClip;

      private var m_barabanFrames:Vector.<Number>;

      private var m_xlBounds:Rectangle;

      public function LaundryGraphic()
      {
         this.m_barabanFrames = new Vector.<Number>();
         super();
         AddProperty(BoolProperty.Create("industrial",false));
         var _loc1_:int = 0;
         while(_loc1_ < xlBarabanCount)
         {
            this.m_barabanFrames.push(Utils.RandomInt(1,s_barabans[0].GetRawClip().totalFrames));
            _loc1_++;
         }
      }

      private function IsIndustrial() : Boolean
      {
         return GetBoolPropertyValue("industrial");
      }

      private function UpdatePositions() : void
      {
         var _loc4_:MovieClip = null;
         if(s_barabanPositions.length > 0)
         {
            return;
         }
         var _loc2_:MovieClip = new Laundry();
         var _loc3_:int = 0;
         while(_loc3_ < barabanCount)
         {
            _loc4_ = _loc2_.getChildByName("w_baraban_" + (_loc3_ + 1)) as MovieClip;
            s_barabanPositions.push(new Point(_loc4_.x,_loc4_.y));
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < xlBarabanCount)
         {
            var src:Point = s_barabanPositions[s_xlMachineSource[_loc3_]];
            s_xlBarabanPositions.push(new Point(src.x + s_xlMachineShift[_loc3_],src.y));
            _loc3_++;
         }
      }

      override public function GetLocalBounds() : Rectangle
      {
         var _loc1_:Rectangle = super.GetLocalBounds();
         if(!this.IsIndustrial())
         {
            return _loc1_;
         }
         if(this.m_xlBounds == null)
         {
            this.m_xlBounds = _loc1_.clone();
            this.m_xlBounds.width = _loc1_.width + xlExtraWidth;
         }
         return this.m_xlBounds;
      }

      override public function OnPropertyChanged(param1:String) : void
      {
         super.OnPropertyChanged(param1);
         this.m_xlBounds = null;
      }

      override public function IsUpdatable() : Boolean
      {
         return true;
      }

      override public function Update(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         super.Update(param1);
         if(this.m_barabanFrames.length > 0)
         {
            _loc2_ = (s_barabans[0] as MovieClipEx).GetRawClip().totalFrames;
            _loc3_ = 0;
            while(_loc3_ < this.m_barabanFrames.length)
            {
               _loc4_ = this.m_barabanFrames[_loc3_] + param1 * 30;
               while(int(_loc4_) > _loc2_)
               {
                  _loc4_ -= _loc2_;
               }
               this.m_barabanFrames[_loc3_] = _loc4_;
               _loc3_++;
            }
         }
      }

      override protected function RenderBody(param1:BitmapData, param2:Matrix, param3:Matrix) : void
      {
         if(!this.IsIndustrial())
         {
            super.RenderBody(param1,param2,param3);
            return;
         }
         if(s_rawLaundry == null)
         {
            s_rawLaundry = new Laundry();
            s_rawLaundry.gotoAndStop(1);
         }
         var world:Matrix = Utils.Concat(param2,param3);
         var b:Rectangle = super.GetLocalBounds();
         var i:int = 0;
         while(i < s_xlSlices.length)
         {
            var slice:Array = s_xlSlices[i];
            var w:Number = Math.min(slice[1],b.width) - slice[0];
            var m:Matrix = new Matrix(1,0,0,1,slice[2] - slice[0],0);
            m.concat(world);
            // destination rectangle of the slice, in screen space
            var tl:Point = world.transformPoint(new Point(b.x + slice[2],b.y));
            var br:Point = world.transformPoint(new Point(b.x + slice[2] + w,b.y + b.height));
            var clip:Rectangle = new Rectangle(Math.min(tl.x,br.x),Math.min(tl.y,br.y),Math.abs(br.x - tl.x) + 0.5,Math.abs(br.y - tl.y));
            param1.draw(s_rawLaundry,m,null,null,clip,true);
            i++;
         }
      }

      override public function Render(param1:BitmapData, param2:Matrix, param3:Matrix) : void
      {
         var _loc6_:Matrix = null;
         super.Render(param1,param2,param3);
         this.UpdatePositions();
         var _loc4_:LaundryBehaviour = GetEntity().GetBehaviourByClass(LaundryBehaviour) as LaundryBehaviour;
         var positions:Vector.<Point> = this.IsIndustrial() ? s_xlBarabanPositions : s_barabanPositions;
         var _loc5_:int = 0;
         while(_loc5_ < positions.length)
         {
            if(_loc4_.IsTableBusy(_loc5_))
            {
               (_loc6_ = param2.clone()).translate(positions[_loc5_].x,positions[_loc5_].y);
               (s_barabans[_loc5_ % 2] as MovieClipEx).Render(param1,this.m_barabanFrames[_loc5_],Utils.Concat(_loc6_,param3),true,null,null,true);
            }
            _loc5_++;
         }
      }
   }
}
