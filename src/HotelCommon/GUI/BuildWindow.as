package HotelCommon.GUI
{
   import FGKit.World.Entity;
   import FGKit.World.EntityTemplatesManager;
   import Hotel.Objects.Build_Window;
   import Hotel.Objects.Lock_Button;
   import Hotel.Objects.New_Room;
   import HotelCommon.Config;
   import HotelCommon.HotelGameLogic;
   import HotelCommon.Modes.BuildElevatorMode;
   import HotelCommon.Modes.BuildMode;
   import HotelCommon.StarChecker;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.DisplayObject;
   import flash.display.GradientType;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;

   public class BuildWindow extends Window
   {

      private static var m_iconBitmap:Bitmap = new Bitmap(new BitmapData(120,60,true,0));

      private static const s_categories:Object = {
         "rooms":"sub_rooms",
         "utility":"sub_service",
         "food":"sub_food",
         "elevator":"sub_elevator",
         "health":"sub_health",
         "entertanment":"sub_entertainment"
      };

      private static const s_iconShifts:Object = {
         "Reception":102,
         "Room_Lux":20,
         "Room_Lux_Pr":129,
         "Restaurant":38,
         "Gym":150,
         "BeautySalon":3,
         "Arcade":40,
         "Bowling":180,
         "Cinema":5,
         "DiscoBar":120,
         "RoofCafe":20,
         "Pool":20,
         "Room_Royal":129,
         "Laundry_XL":200,
         "Casino":200
      };

      // V2: buttons for the new buildings, drawn under the original ones
      private static const s_v2Buttons:Array = [{
         "panel":"sub_rooms",
         "template":"Room_Eco",
         "label":"Economy",
         "col":0,
         "cols":2
      },{
         "panel":"sub_rooms",
         "template":"Room_Royal",
         "label":"Royal Suite",
         "col":1,
         "cols":2
      },{
         "panel":"sub_service",
         "template":"Laundry_XL",
         "label":"Industrial Laundry",
         "col":0,
         "cols":1
      },{
         "panel":"sub_entertainment",
         "template":"Casino",
         "label":"Casino",
         "col":0,
         "cols":1
      }];

      private static const s_buttons:Object = {
         "standard":"Room",
         "lux":"Room_Lux",
         "pr_lux":"Room_Lux_Pr",
         "reception":"Reception",
         "laundry":"Laundry",
         "gym":"Gym",
         "beauty":"BeautySalon",
         "cafe":"Cafe",
         "restaurant":"Restaurant",
         "roof_cafe":"RoofCafe",
         "elevator_5p":"Elevator",
         "elevator_10p":"Elevator10",
         "elevator_staff":"ServiceElevator",
         "arcade":"Arcade",
         "bar":"DiscoBar",
         "internet_cafe":"Internet",
         "cinema":"Cinema",
         "bowling":"Bowling",
         "pool":"Pool"
      };

      {
      }

      private var m_closeTimer:Number = -1;

      private var m_gui:Build_Window;

      private var m_gameLogic:HotelGameLogic;

      public function BuildWindow(param1:HotelGameLogic)
      {
         super();
         this.m_gameLogic = param1;
      }

      override protected function CreateControls() : void
      {
         var _loc1_:* = null;
         var _loc2_:String = null;
         var _loc3_:Boolean = false;
         var _loc4_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc6_:SimpleButton = null;
         var _loc7_:MovieClip = null;
         this.m_gui = new Build_Window();
         this.m_gui.exit.addEventListener(MouseEvent.CLICK,DefaultCloseHandler,false,0,true);
         for(_loc1_ in s_categories)
         {
            this.m_gui.getChildByName(_loc1_).addEventListener(MouseEvent.CLICK,this.OnCategoryClicked,false,0,true);
            _loc2_ = s_categories[_loc1_];
            _loc3_ = false;
            (_loc4_ = this.m_gui.getChildByName(_loc2_) as MovieClip).visible = false;
            _loc5_ = 0;
            while(_loc5_ < _loc4_.numChildren)
            {
               if((_loc6_ = _loc4_.getChildAt(_loc5_) as SimpleButton) != null && s_buttons[_loc6_.name] != null)
               {
                  if(StarChecker.IsAllowedToBuild(s_buttons[_loc6_.name],this.m_gameLogic))
                  {
                     _loc6_.addEventListener(MouseEvent.CLICK,this.OnBuildClicked,false,0,true);
                     _loc6_.addEventListener(MouseEvent.MOUSE_OVER,this.OnBuildHover,false,0,true);
                     _loc6_.addEventListener(MouseEvent.MOUSE_OUT,this.OnBuildOut,false,0,true);
                     _loc3_ = true;
                     if(StarChecker.IsNewToBuild(s_buttons[_loc6_.name],this.m_gameLogic))
                     {
                        _loc7_ = new New_Room();
                        _loc6_.parent.addChild(_loc7_);
                        _loc7_.x = _loc6_.x;
                        _loc7_.y = _loc6_.y;
                     }
                  }
                  else
                  {
                     this.Lock(_loc6_);
                  }
               }
               _loc5_++;
            }
            if(_loc3_)
            {
            }
         }
         this.CreateV2Buttons();
         this.m_gui.text_back.visible = false;
         this.m_gui.choose_text.visible = true;
         this.m_gui.description.text = "";
         this.m_gui.price.text = "";
         this.m_gui.keep.text = "";
         this.m_gui.frame.visible = false;
         this.m_gui.centre_text.text = "";
         while(true)
         {
            if(this.m_gui.room_template.numChildren <= 0)
            {
               break;
            }
            this.m_gui.room_template.removeChildAt(0);
         }
         if(this.m_gameLogic.GetTutorial().GetCurrentItem() != null)
         {
            this.m_gui.y = 40;
         }
         m_container.addChild(this.m_gui);
      }

      private function CreateV2Buttons() : void
      {
         var def:Object = null;
         for each(def in s_v2Buttons)
         {
            var panel:MovieClip = this.m_gui.getChildByName(def.panel) as MovieClip;
            if(panel == null)
            {
               continue;
            }
            var area:Rectangle = null;
            var i:int = 0;
            while(i < panel.numChildren)
            {
               var child:DisplayObject = panel.getChildAt(i);
               if(child is SimpleButton && s_buttons[child.name] != null)
               {
                  var r:Rectangle = child.getBounds(panel);
                  area = area == null ? r : area.union(r);
               }
               i++;
            }
            if(area == null)
            {
               continue;
            }
            var cols:int = def.cols;
            var bh:Number = 26;
            // not enough room above the description box: shrink the whole
            // column of buttons (uniformly, so labels are not squashed)
            var limit:Number = this.m_gui.text_back.getBounds(panel).top - 3;
            if(def.col == 0 && area.bottom + 3 + bh > limit)
            {
               var k:Number = (limit - area.top) / (area.height + 3 + bh);
               var cx:Number = area.x + area.width * 0.5;
               i = 0;
               while(i < panel.numChildren)
               {
                  var c2:DisplayObject = panel.getChildAt(i);
                  if(c2.height > 60)
                  {
                     // panel background
                     i++;
                     continue;
                  }
                  c2.x = cx + (c2.x - cx) * k;
                  c2.y = area.top + (c2.y - area.top) * k;
                  c2.scaleX *= k;
                  c2.scaleY *= k;
                  i++;
               }
               area = new Rectangle(cx - area.width * k * 0.5,area.top,area.width * k,area.height * k);
               bh *= k;
            }
            var bw:Number = (area.width - (cols - 1) * 4) / cols;
            var allowed:Boolean = StarChecker.IsAllowedToBuild(def.template,this.m_gameLogic);
            var btn:Sprite = new Sprite();
            var mat:Matrix = new Matrix();
            mat.createGradientBox(bw,bh,Math.PI / 2);
            btn.graphics.lineStyle(2,!!allowed ? 1394032 : 6710886,1);
            btn.graphics.beginGradientFill(GradientType.LINEAR,!!allowed ? [7516895,2518203] : [11184810,7829367],[1,1],[0,255],mat);
            btn.graphics.drawRoundRect(0,0,bw,bh,14,14);
            btn.graphics.endFill();
            var label:TextField = InGameGui.CreateLabel(!!allowed ? def.label : def.label + " (locked)",12,16777215,"Arial");
            label.x = int((bw - label.width) * 0.5);
            label.y = int((bh - label.height) * 0.5);
            btn.addChild(label);
            btn.x = area.x + def.col * (bw + 4);
            btn.y = area.bottom + 3;
            btn.name = def.template;
            btn.mouseChildren = false;
            btn.buttonMode = allowed;
            panel.addChild(btn);
            if(allowed)
            {
               btn.addEventListener(MouseEvent.CLICK,this.OnV2BuildClicked,false,0,true);
               btn.addEventListener(MouseEvent.MOUSE_OVER,this.OnV2BuildHover,false,0,true);
               btn.addEventListener(MouseEvent.MOUSE_OUT,this.OnBuildOut,false,0,true);
               if(StarChecker.IsNewToBuild(def.template,this.m_gameLogic))
               {
                  var badge:MovieClip = new New_Room();
                  panel.addChild(badge);
                  badge.x = btn.x;
                  badge.y = btn.y;
               }
            }
            else
            {
               btn.addEventListener(MouseEvent.MOUSE_OVER,this.OnLockHover,false,0,true);
               btn.addEventListener(MouseEvent.MOUSE_OUT,this.OnLockOut,false,0,true);
            }
         }
      }

      private function OnV2BuildHover(param1:Event) : void
      {
         this.ShowBuildInfo((param1.currentTarget as DisplayObject).name);
      }

      private function OnV2BuildClicked(param1:Event) : void
      {
         this.StartBuild((param1.currentTarget as DisplayObject).name);
      }

      private function NothingHovered() : void
      {
         this.m_gui.centre_text.htmlText = "Choose a room to build";
         this.m_gui.description.text = "";
         this.m_gui.price.text = "";
         this.m_gui.keep.text = "";
         this.m_gui.frame.visible = false;
         m_iconBitmap.bitmapData.fillRect(m_iconBitmap.bitmapData.rect,0);
      }

      private function Lock(param1:SimpleButton) : void
      {
         param1.visible = false;
         var _loc2_:Lock_Button = new Lock_Button();
         param1.parent.addChild(_loc2_);
         _loc2_.x = param1.x;
         _loc2_.y = param1.y;
         _loc2_.enabled = false;
         _loc2_.width = param1.width;
         _loc2_.addEventListener(MouseEvent.MOUSE_OVER,this.OnLockHover,false,0,true);
         _loc2_.addEventListener(MouseEvent.MOUSE_OUT,this.OnLockOut,false,0,true);
      }

      private function OnCategoryClicked(param1:Event) : void
      {
         var _loc4_:String = null;
         var _loc2_:SimpleButton = param1.target as SimpleButton;
         var _loc3_:String = s_categories[_loc2_.name];
         for each(_loc4_ in s_categories)
         {
            this.m_gui.getChildByName(_loc4_).visible = _loc4_ == _loc3_;
         }
         this.m_gui.text_back.visible = true;
         this.m_gui.choose_text.visible = false;
         this.m_gui.room_template.addChild(m_iconBitmap);
         this.NothingHovered();
      }

      private function OnLockHover(param1:Event) : void
      {
         this.m_gui.centre_text.htmlText = "Locked";
         this.m_gui.price.text = "";
         this.m_gui.keep.text = "";
         this.m_gui.description.htmlText = "Achieve higher star status<br/> to unlock this room";
         this.m_gui.frame.visible = false;
         this.m_closeTimer = -1;
         m_iconBitmap.bitmapData.fillRect(m_iconBitmap.bitmapData.rect,0);
      }

      private function OnLockOut(param1:Event) : void
      {
         this.m_closeTimer = 0;
      }

      private function OnBuildHover(param1:Event) : void
      {
         var _loc2_:SimpleButton = param1.target as SimpleButton;
         this.ShowBuildInfo(s_buttons[_loc2_.name]);
      }

      private function ShowBuildInfo(param1:String) : void
      {
         var _loc3_:String = param1;
         this.m_gui.price.htmlText = "Build Cost: <font color=\'#b80000\'>$" + Config.GetBuildCost(_loc3_) + "</font>";
         this.m_gui.keep.htmlText = "Keep expense: <font color=\'#b80000\'>$" + Config.keepCosts[_loc3_] + "</font>";
         this.m_gui.description.text = Config.roomDescriptions[_loc3_];
         this.m_gui.centre_text.htmlText = "";
         this.m_gui.frame.visible = true;
         this.m_closeTimer = -1;
         var _loc4_:Entity = new Entity(EntityTemplatesManager.Instance().GetTemplateByFriendlyName(_loc3_));
         var _loc5_:Matrix;
         (_loc5_ = new Matrix()).ty = 60;
         _loc5_.tx = Number(-s_iconShifts[_loc3_]) || Number(0);
         m_iconBitmap.bitmapData.fillRect(m_iconBitmap.bitmapData.rect,4285572307);
         _loc4_.GetGraphic().Render(m_iconBitmap.bitmapData,_loc5_,new Matrix());
      }

      private function OnBuildOut(param1:Event) : void
      {
         this.m_closeTimer = 0;
      }

      public function GetActiveSubWindow() : String
      {
         var _loc1_:String = null;
         for each(_loc1_ in s_categories)
         {
            if(this.m_gui.getChildByName(_loc1_).visible)
            {
               return _loc1_;
            }
         }
         return "";
      }

      private function OnBuildClicked(param1:Event) : void
      {
         var _loc2_:SimpleButton = param1.target as SimpleButton;
         this.StartBuild(s_buttons[_loc2_.name]);
      }

      private function StartBuild(param1:String) : void
      {
         var _loc4_:Entity = null;
         var _loc3_:String = param1;
         if(_loc3_ != null)
         {
            _loc4_ = new Entity(this.m_gameLogic.GetWorld().GetEntityTemplates().GetTemplateByFriendlyName(_loc3_));
            if(Config.EntityIsElevator(_loc4_))
            {
               this.m_gameLogic.SetMode(new BuildElevatorMode(_loc4_));
            }
            else
            {
               this.m_gameLogic.SetMode(new BuildMode(_loc4_));
            }
         }
      }

      override protected function DestroyControls() : void
      {
         this.m_gui.parent.removeChild(this.m_gui);
         this.m_gui = null;
      }

      override public function Update(param1:Number) : void
      {
         if(this.m_closeTimer >= 0)
         {
            this.m_closeTimer += param1;
            if(this.m_closeTimer > 0.05)
            {
               this.m_closeTimer = -1;
               this.NothingHovered();
            }
         }
      }
   }
}
