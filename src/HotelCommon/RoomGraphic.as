package HotelCommon
{
   import FGKit.Graphics.MovieClipEx;
   import FGKit.Properties.StringProperty;
   import FGKit.Resources.MovieClipResourceManager;
   import FGKit.Utils;
   import FGKit.World.Entity;
   import FGKit.World.Graphic;
   import Hotel.Objects.Door_lux_info_green;
   import Hotel.Objects.Door_prlux_info_green;
   import Hotel.Objects.Door_single_info_green;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;

   public class RoomGraphic extends Graphic
   {

      private static var s_movieClips:Dictionary = new Dictionary();

      private static var busyClips:Object = {
         "Room":new MovieClipEx(new Door_single_info_green()),
         "Room_Lux":new MovieClipEx(new Door_lux_info_green()),
         "Room_Lux_Pr":new MovieClipEx(new Door_prlux_info_green())
      };

      {
      }

      private var m_colorTransform:ColorTransform;

      private var m_localBounds:Rectangle;

      private var m_busyClip:MovieClipEx;

      private var m_movieClip:MovieClipEx;

      private var m_lastDirtFactor:int = -1;

      private const maxDirt:int = 9;

      private var m_dirtUpdateTimer:int = 0;

      public function RoomGraphic()
      {
         super();
         AddProperty(StringProperty.Create("movieClip",""));
         AddProperty(StringProperty.Create("tint",""));
      }

      override public function GetWidth() : int
      {
         return this.GetLocalBounds().width;
      }

      override public function GetHeight() : int
      {
         return this.GetLocalBounds().height;
      }

      private function GetDirtFactor() : int
      {
         var _loc1_:Entity = GetEntity();
         var _loc2_:int = Config.GetRoomCleannessPenalty(_loc1_.GetBehaviourByClass(RoomBehaviour) as RoomBehaviour);
         return int(Math.min(this.maxDirt,Math.ceil(_loc2_ * this.maxDirt / 200)));
      }

      private function GetMovieClip(param1:int) : MovieClipEx
      {
         var _loc4_:MovieClipEx = null;
         var _loc5_:MovieClip = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:MovieClip = null;
         var _loc2_:String = GetStringPropertyValue("movieClip");
         var _loc3_:String = _loc2_ + param1;
         if(s_movieClips[_loc3_] == null)
         {
            if((_loc4_ = MovieClipResourceManager.Instance().GetResource(_loc2_)) == null)
            {
               _loc4_ = MovieClipResourceManager.Instance().GetNotFoundStub();
            }
            var clipClass:Class = Utils.GetClass(_loc4_.GetRawClip());
            _loc5_ = new clipClass();
            _loc6_ = 0;
            while(_loc6_ < _loc5_.numChildren)
            {
               _loc5_.getChildAt(_loc6_).visible = _loc4_.GetRawClip().getChildAt(_loc6_).visible;
               _loc6_++;
            }
            _loc7_ = 0;
            while(_loc7_ < this.maxDirt)
            {
               if((_loc8_ = _loc5_.getChildByName("dirt_" + (_loc7_ + 1)) as MovieClip) != null)
               {
                  _loc8_.visible = _loc7_ < param1;
               }
               _loc7_++;
            }
            s_movieClips[_loc3_] = new MovieClipEx(_loc5_);
         }
         return s_movieClips[_loc3_];
      }

      override public function OnPropertyChanged(param1:String) : void
      {
         if(param1 == "movieClip")
         {
            this.m_localBounds = null;
            this.m_movieClip = null;
         }
      }

      override public function GetLocalBounds() : Rectangle
      {
         if(this.m_localBounds == null)
         {
            this.UpdateMovieClip();
            this.m_localBounds = this.m_movieClip.GetLocalBounds(true);
         }
         return this.m_localBounds;
      }

      private function UpdateMovieClip() : void
      {
         if(this.m_busyClip == null)
         {
            // V2: new room types use the door sign of the room they derive from
            this.m_busyClip = busyClips[Config.GetBaseTemplate(GetEntity().GetTemplate().GetFriendlyName())];
         }
         var _loc2_:*;
         var _loc3_:* = (_loc2_ = this).m_dirtUpdateTimer + 1;
         _loc2_.m_dirtUpdateTimer = _loc3_;
         var _loc1_:int = this.GetDirtFactor();
         if(this.m_movieClip == null || _loc1_ != this.m_lastDirtFactor && this.m_dirtUpdateTimer >= 5)
         {
            this.m_dirtUpdateTimer = 0;
            this.m_movieClip = this.GetMovieClip(this.GetDirtFactor());
            this.m_lastDirtFactor = _loc1_;
         }
      }

      override public function Render(param1:BitmapData, param2:Matrix, param3:Matrix) : void
      {
         // V2: optional colour tint ("rMul,gMul,bMul,rOff,gOff,bOff"), used by the new room types
         if(this.m_colorTransform == null)
         {
            var tint:String = GetStringPropertyValue("tint");
            if(tint != null && tint.length > 0)
            {
               var t:Array = tint.split(",");
               this.m_colorTransform = new ColorTransform(Number(t[0]),Number(t[1]),Number(t[2]),1,Number(t[3]),Number(t[4]),Number(t[5]),0);
            }
         }
         this.UpdateMovieClip();
         var _loc4_:Matrix = Utils.Concat(param2,param3);
         this.m_movieClip.Render(param1,1,_loc4_,true,this.m_colorTransform,null,true);
         var _loc5_:GuestBehaviour;
         if((_loc5_ = (GetEntity().GetBehaviourByClass(RoomBehaviour) as RoomBehaviour).GetGuest()) != null && _loc5_.IsOccupyingRoom())
         {
            this.m_busyClip.Render(param1,1,_loc4_,true,null,null,true);
         }
      }

      public function SetColorTransform(param1:ColorTransform) : void
      {
         this.m_colorTransform = param1;
      }
   }
}
