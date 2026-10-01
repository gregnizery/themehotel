package HotelCommon
{
   import FGKit.Graphics.BitmapAtlas;
   import FGKit.Graphics.MovieClipEx;
   import FGKit.Properties.BoolProperty;
   import FGKit.Properties.IntProperty;
   import FGKit.Properties.StringProperty;
   import FGKit.Resources.MovieClipResourceManager;
   import FGKit.Utils;
   import FGKit.World.Behaviour;
   import FGKit.World.Entity;
   import FGKit.World.Graphic;
   import Hotel.Objects.Door_lux;
   import Hotel.Objects.Door_prlux;
   import Hotel.Objects.Door_single;
   import Hotel.Objects.Doorway_lux;
   import Hotel.Objects.Doorway_prlux;
   import Hotel.Objects.Doorway_single;
   import Hotel.Objects.Fired;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;

   public class PersonGraphic extends Graphic
   {

      private static var s_propFrameDepends:Object = {
         "hair":"hairType",
         "torso":"torsoType",
         "head":"headType",
         "leg":"calfType",
         "leg_b":"calfType",
         "bag":"bagType"
      };

      private static var s_showPropDepends:Object = {"bag":"hasBag"};

      private static var s_matrix:Matrix = new Matrix();

      private static var s_point:Point = new Point();

      private static var s_sharedMcs:Dictionary = new Dictionary();

      private static var s_localBounds:Rectangle = new Rectangle(-14,-40,28,41);

      public static var m_atlas:BitmapAtlas = new BitmapAtlas(2048,2048);

      private static var s_doorData:Object = {
         "Room":{
            "way":new MovieClipEx(new Doorway_single()),
            "door":new MovieClipEx(new Door_single())
         },
         "Room_Lux":{
            "way":new MovieClipEx(new Doorway_lux()),
            "door":new MovieClipEx(new Door_lux())
         },
         "Room_Lux_Pr":{
            "way":new MovieClipEx(new Doorway_prlux()),
            "door":new MovieClipEx(new Door_prlux())
         }
      };

      private static var s_fired:MovieClipEx = new MovieClipEx(new Fired());

      {
      }

      private var m_colorTransform:ColorTransform;

      private var m_frame:Number = 0;

      private var m_movieClips:Vector.<MovieClipEx>;

      private var m_enteringRoom:Entity;

      private var m_cycleProperty:BoolProperty;

      public function PersonGraphic()
      {
         this.m_movieClips = new Vector.<MovieClipEx>();
         super();
         AddProperty(StringProperty.Create("movieClip",""));
         AddProperty(IntProperty.Create("hairType",1));
         AddProperty(IntProperty.Create("torsoType",1));
         AddProperty(IntProperty.Create("headType",1));
         AddProperty(IntProperty.Create("calfType",1));
         AddProperty(IntProperty.Create("bagType",1));
         AddProperty(BoolProperty.Create("hasBag",false));
         AddProperty(BoolProperty.Create("flip_x",false));
         this.m_cycleProperty = BoolProperty.Create("cyclic",true);
         AddProperty(this.m_cycleProperty);
      }

      override public function OnPropertyChanged(param1:String) : void
      {
         this.m_frame = 1;
         this.m_movieClips.length = 0;
      }

      private function HideAllBut(param1:MovieClip, param2:int) : void
      {
         var _loc4_:DisplayObject = null;
         var _loc3_:int = 0;
         while(_loc3_ < param1.numChildren)
         {
            (_loc4_ = param1.getChildAt(_loc3_)).visible = _loc3_ == param2;
            _loc3_++;
         }
      }

      private function BuildMovieClips() : void
      {
         var _loc5_:DisplayObject = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:MovieClipEx = null;
         var _loc11_:MovieClip = null;
         var _loc12_:MovieClip = null;
         if(this.m_movieClips.length > 0)
         {
            return;
         }
         var _loc1_:String = GetStringPropertyValue("movieClip");
         var _loc2_:MovieClipEx = MovieClipResourceManager.Instance().GetResource(_loc1_);
         var _loc3_:MovieClip = _loc2_.GetRawClip();
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.numChildren)
         {
            if((_loc5_ = _loc3_.getChildAt(_loc4_)).name != "arm")
            {
               _loc6_ = s_showPropDepends[_loc5_.name];
               if(!(_loc6_ != null && GetBoolPropertyValue(_loc6_) == false))
               {
                  _loc7_ = -1;
                  if((_loc8_ = s_propFrameDepends[_loc5_.name]) != null)
                  {
                     if((_loc7_ = GetIntPropertyValue(_loc8_)) > (_loc5_ as MovieClip).totalFrames)
                     {
                        _loc7_ = (_loc7_ - 1) % (_loc5_ as MovieClip).totalFrames + 1;
                     }
                  }
                  _loc9_ = _loc1_ + "_" + _loc4_ + "_" + _loc7_;
                  if((_loc10_ = s_sharedMcs[_loc9_]) == null)
                  {
                     var clipClass:Class = Utils.GetClass(_loc3_);
                     _loc11_ = new clipClass();
                     this.HideAllBut(_loc11_,_loc4_);
                     if(_loc7_ != -1)
                     {
                        (_loc11_.getChildAt(_loc4_) as MovieClip).gotoAndStop(_loc7_);
                     }
                     if(_loc5_.name == "torso")
                     {
                        (_loc12_ = _loc11_.getChildByName("arm") as MovieClip).visible = true;
                        if(_loc7_ != -1)
                        {
                           _loc12_.gotoAndStop(_loc7_);
                        }
                     }
                     _loc10_ = new MovieClipEx(_loc11_,m_atlas);
                     s_sharedMcs[_loc9_] = _loc10_;
                  }
                  this.m_movieClips.push(_loc10_);
               }
            }
            _loc4_++;
         }
      }

      public function SetEnteringRoom(param1:Entity) : void
      {
         this.m_enteringRoom = param1;
      }

      override public function GetLocalBounds() : Rectangle
      {
         return s_localBounds;
      }

      public function IsLastFrame() : Boolean
      {
         this.BuildMovieClips();
         return this.m_frame == this.m_movieClips[0].GetRawClip().totalFrames;
      }

      override public function IsUpdatable() : Boolean
      {
         return true;
      }

      override public function Update(param1:Number) : void
      {
         this.BuildMovieClips();
         var _loc2_:int = this.m_movieClips[0].GetRawClip().totalFrames;
         this.m_frame += param1 * 30;
         var _loc3_:Boolean = this.m_cycleProperty.GetValue();
         while(int(this.m_frame) > _loc2_)
         {
            if(_loc3_)
            {
               this.m_frame -= _loc2_;
            }
            else
            {
               this.m_frame = _loc2_;
            }
         }
      }

      override public function Render(param1:BitmapData, param2:Matrix, param3:Matrix) : void
      {
         var _loc5_:MovieClipEx = null;
         var _loc6_:Behaviour = null;
         this.BuildMovieClips();
         var _loc4_:Object = null;
         if(this.m_enteringRoom != null)
         {
            // V2: new room types use the doors of the room they derive from
            _loc4_ = s_doorData[Config.GetBaseTemplate(this.m_enteringRoom.GetTemplate().GetFriendlyName())];
         }
         Utils.CloneMatrixInplace(param2,s_matrix);
         s_matrix.concat(param3);
         if(GetBoolPropertyValue("flip_x"))
         {
            Utils.PreScaleMatrix(-1,1,s_matrix);
         }
         if(_loc4_ != null)
         {
            (_loc4_.way as MovieClipEx).Render(param1,1,Utils.Concat(this.m_enteringRoom.GetTransform(),param3),true,null,null,true);
         }
         for each(_loc5_ in this.m_movieClips)
         {
            _loc5_.Render(param1,int(this.m_frame),s_matrix,true,this.m_colorTransform,null,true);
         }
         _loc6_ = GetEntity().GetBehaviourByClass(WorkerBeaviour);
         if(_loc6_ != null && Boolean(_loc6_.GetBoolPropertyValue("fired")))
         {
            if(GetBoolPropertyValue("flip_x"))
            {
               Utils.PreScaleMatrix(-1,1,s_matrix);
            }
            s_fired.Render(param1,1,s_matrix,true,null,null,true);
         }
         if(_loc4_ != null)
         {
            (_loc4_.door as MovieClipEx).Render(param1,1,Utils.Concat(this.m_enteringRoom.GetTransform(),param3),true,null,null,true);
         }
      }

      public function SetColorTransform(param1:ColorTransform) : void
      {
         this.m_colorTransform = param1;
      }
   }
}
