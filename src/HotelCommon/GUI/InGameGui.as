package HotelCommon.GUI
{
   import FGKit.AppStates.StateManager;
   import FGKit.Application;
   import FGKit.Tooltip;
   import FGKit.Tracker.Tracker;
   import FGKit.Utils;
   import Hotel.Objects.GUI;
   import Hotel.Objects.Left_Line;
   import Hotel.Objects.Right_Line;
   import Hotel.Objects.tooltip_01_cursor;
   import Hotel.Objects.tooltip_02_build;
   import Hotel.Objects.tooltip_03_staff;
   import Hotel.Objects.tooltip_04_stat;
   import Hotel.Objects.tooltip_05_hotel_stat;
   import Hotel.Objects.tooltip_06_delete;
   import Hotel.Objects.tooltip_07_money;
   import Hotel.Objects.tooltip_08_loan;
   import Hotel.Objects.tooltip_09_guests;
   import Hotel.Objects.tooltip_10_reputation;
   import Hotel.Objects.tooltip_11_stars;
   import Hotel.Objects.tooltip_12_exit;
   import Hotel.Objects.tooltip_13_save;
   import Hotel.Objects.tooltip_14_scale50;
   import Hotel.Objects.tooltip_15_scale100;
   import Hotel.Objects.tooltip_16_scale150;
   import Hotel.Objects.tooltip_17_pause;
   import Hotel.Objects.tooltip_18_time1x;
   import Hotel.Objects.tooltip_19_time2x;
   import Hotel.Objects.tooltip_20_time4x;
   import Hotel.Objects.tooltip_21_sound;
   import Hotel.Objects.tooltip_22_music;
   import Hotel.Objects.tooltip_23_sponsor;
   import HotelCommon.Config;
   import HotelCommon.GameStatus;
   import HotelCommon.HotelGameLogic;
   import HotelCommon.Modes.DeleteMode;
   import HotelCommon.Modes.DialogBasedMode;
   import HotelCommon.Modes.SelectMode;
   import HotelCommon.Music;
   import HotelCommon.Sounds;
   import HotelCommon.ProgressManager;
   import FGKit.KeyCodes;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;

   public class InGameGui extends Window
   {

      private static var m_sTimings:Dictionary;

      private static var m_sZooms:Dictionary;

      var m_gameLogic:HotelGameLogic;

      private var m_guiMC:GUI;

      private var m_leftBorderMC:Left_Line;

      private var m_rightBorderMC:Right_Line;

      private var m_leftBorderPos:Number = 0;

      private var m_rightBorderPos:Number = 0;

      private var m_smallBarWidth:Number = 0;

      private var m_activeButton:MovieClip;

      private var m_autoSaveTimer:Number = 0;

      private var m_starFlashTimer:Number = 0;

      // ---- V2 additions ----
      private static const s_timeOrder:Array = ["time1x","time2x","time4x","time8x"];

      private static const s_zoomOrder:Array = ["zoom05x","zoom1x","zoom2x"];

      private var m_currentTime:String = "time1x";

      private var m_timeBeforePause:String = "time1x";

      private var m_timeBeforeHelp:String = "time1x";

      private var m_currentZoom:String = "zoom1x";

      private var m_speedBadge:TextField;

      private var m_helpPanel:Sprite;

      private var m_toast:TextField;

      private var m_toastTimer:Number = 0;

      // note: FFDec's compiler mis-compiles a bare "new X(...);" statement,
      // so tooltips are kept in an array instead
      private var m_tooltips:Array = [];

      public function InGameGui(param1:HotelGameLogic)
      {
         super();
         this.m_gameLogic = param1;
      }

      override protected function CreateControls() : void
      {
         this.m_leftBorderMC = new Left_Line();
         m_container.addChild(this.m_leftBorderMC);
         this.m_leftBorderMC.cacheAsBitmap = true;
         this.m_leftBorderMC.expand_btn.addEventListener(MouseEvent.CLICK,this.OnExpandLeftClick,false,0,true);
         this.m_leftBorderMC.mouseEnabled = false;
         this.m_leftBorderMC.mouseChildren = true;
         this.m_rightBorderMC = new Right_Line();
         m_container.addChild(this.m_rightBorderMC);
         this.m_rightBorderMC.cacheAsBitmap = true;
         this.m_rightBorderMC.expand_btn.addEventListener(MouseEvent.CLICK,this.OnExpandRightClick,false,0,true);
         this.m_rightBorderMC.mouseEnabled = false;
         this.m_rightBorderMC.mouseChildren = true;
         this.m_guiMC = new GUI();
         this.m_guiMC.cursor.addEventListener(MouseEvent.CLICK,this.OnCursorClick,false,0,true);
         this.m_guiMC.staff.addEventListener(MouseEvent.CLICK,this.OnStaffClick,false,0,true);
         this.m_guiMC.build.addEventListener(MouseEvent.CLICK,this.OnBuildClick,false,0,true);
         this.m_guiMC.stat.addEventListener(MouseEvent.CLICK,this.OnStatClick,false,0,true);
         this.m_guiMC.del.addEventListener(MouseEvent.CLICK,this.OnDelClick,false,0,true);
         this.m_guiMC.stat_hotel.addEventListener(MouseEvent.CLICK,this.OnChartsClick,false,0,true);
         this.m_guiMC.music_on.visible = Music.Instance().IsEnabled();
         this.m_guiMC.music_off.visible = !Music.Instance().IsEnabled();
         this.m_guiMC.sound_on.visible = Sounds.IsEnabled();
         this.m_guiMC.sound_off.visible = !Sounds.IsEnabled();
         this.m_guiMC.music_on.addEventListener(MouseEvent.CLICK,this.OnMusicToggle,false,0,true);
         this.m_guiMC.music_off.addEventListener(MouseEvent.CLICK,this.OnMusicToggle,false,0,true);
         this.m_guiMC.sound_on.addEventListener(MouseEvent.CLICK,this.OnSoundToggle,false,0,true);
         this.m_guiMC.sound_off.addEventListener(MouseEvent.CLICK,this.OnSoundToggle,false,0,true);
         this.RegisterButton(this.m_guiMC.cursor);
         this.RegisterButton(this.m_guiMC.build);
         this.RegisterButton(this.m_guiMC.staff);
         this.RegisterButton(this.m_guiMC.stat);
         this.RegisterButton(this.m_guiMC.stat_hotel);
         this.RegisterButton(this.m_guiMC.del);
         this.RegisterButton(this.m_guiMC.pause);
         this.RegisterButton(this.m_guiMC.time1x);
         this.RegisterButton(this.m_guiMC.time2x);
         this.RegisterButton(this.m_guiMC.time4x);
         this.RegisterButton(this.m_guiMC.zoom05x);
         this.RegisterButton(this.m_guiMC.zoom1x);
         this.RegisterButton(this.m_guiMC.zoom2x);
         this.m_guiMC.menu.addEventListener(MouseEvent.CLICK,this.OnMenuClick,false,0,true);
         this.m_guiMC.save.addEventListener(MouseEvent.CLICK,this.OnSaveClick,false,0,true);
         this.m_guiMC.pause.addEventListener(MouseEvent.CLICK,this.OnTimeClick,false,0,true);
         this.m_guiMC.time1x.addEventListener(MouseEvent.CLICK,this.OnTimeClick,false,0,true);
         this.m_guiMC.time2x.addEventListener(MouseEvent.CLICK,this.OnTimeClick,false,0,true);
         this.m_guiMC.time4x.addEventListener(MouseEvent.CLICK,this.OnTimeClick,false,0,true);
         this.m_guiMC.zoom05x.addEventListener(MouseEvent.CLICK,this.OnZoomClick,false,0,true);
         this.m_guiMC.zoom1x.addEventListener(MouseEvent.CLICK,this.OnZoomClick,false,0,true);
         this.m_guiMC.zoom2x.addEventListener(MouseEvent.CLICK,this.OnZoomClick,false,0,true);
         this.m_guiMC.stars.buttonMode = true;
         this.m_guiMC.stars.addEventListener(MouseEvent.CLICK,this.OnStarsClick,false,0,true);
         this.m_guiMC.add_money.addEventListener(MouseEvent.CLICK,this.OnMoneyClick,false,0,true);
         m_container.addChild(this.m_guiMC);
         this.m_smallBarWidth = this.m_guiMC.small_bar.bar.width;
         this.m_tooltips.push(new Tooltip(new tooltip_01_cursor(),this.m_guiMC.cursor));
         this.m_tooltips.push(new Tooltip(new tooltip_02_build(),this.m_guiMC.build));
         this.m_tooltips.push(new Tooltip(new tooltip_03_staff(),this.m_guiMC.staff));
         this.m_tooltips.push(new Tooltip(new tooltip_04_stat(),this.m_guiMC.stat));
         this.m_tooltips.push(new Tooltip(new tooltip_05_hotel_stat(),this.m_guiMC.stat_hotel));
         this.m_tooltips.push(new Tooltip(new tooltip_06_delete(),this.m_guiMC.del));
         this.m_tooltips.push(new Tooltip(new tooltip_07_money(),this.m_guiMC.money));
         this.m_tooltips.push(new Tooltip(new tooltip_08_loan(),this.m_guiMC.add_money));
         this.m_tooltips.push(new Tooltip(new tooltip_09_guests(),this.m_guiMC.guests));
         this.m_tooltips.push(new Tooltip(new tooltip_10_reputation(),this.m_guiMC.rep_sel));
         this.m_tooltips.push(new Tooltip(new tooltip_10_reputation(),this.m_guiMC.rep));
         this.m_tooltips.push(new Tooltip(new tooltip_11_stars(),this.m_guiMC.stars));
         this.m_tooltips.push(new Tooltip(new tooltip_12_exit(),this.m_guiMC.menu));
         this.m_tooltips.push(new Tooltip(new tooltip_13_save(),this.m_guiMC.save));
         this.m_tooltips.push(new Tooltip(new tooltip_14_scale50(),this.m_guiMC.zoom05x));
         this.m_tooltips.push(new Tooltip(new tooltip_15_scale100(),this.m_guiMC.zoom1x));
         this.m_tooltips.push(new Tooltip(new tooltip_16_scale150(),this.m_guiMC.zoom2x));
         this.m_tooltips.push(new Tooltip(new tooltip_17_pause(),this.m_guiMC.pause));
         this.m_tooltips.push(new Tooltip(new tooltip_18_time1x(),this.m_guiMC.time1x));
         this.m_tooltips.push(new Tooltip(new tooltip_19_time2x(),this.m_guiMC.time2x));
         this.m_tooltips.push(new Tooltip(new tooltip_20_time4x(),this.m_guiMC.time4x));
         this.m_tooltips.push(new Tooltip(new tooltip_21_sound(),this.m_guiMC.sound_on));
         this.m_tooltips.push(new Tooltip(new tooltip_21_sound(),this.m_guiMC.sound_off));
         this.m_tooltips.push(new Tooltip(new tooltip_22_music(),this.m_guiMC.music_on));
         this.m_tooltips.push(new Tooltip(new tooltip_22_music(),this.m_guiMC.music_off));
         // V2: the sponsor portal is gone, hide its button
         this.m_guiMC.sponsorBtn.visible = false;
         this.m_speedBadge = CreateLabel("x8",13,16768512);
         this.m_speedBadge.x = this.m_guiMC.time4x.x + this.m_guiMC.time4x.width - 12;
         this.m_speedBadge.y = this.m_guiMC.time4x.y - 16;
         this.m_speedBadge.visible = false;
         this.m_guiMC.addChild(this.m_speedBadge);
         this.m_toast = CreateLabel("",14,16777215);
         this.m_toast.visible = false;
         m_container.addChild(this.m_toast);
         this.SetZoom("zoom1x");
         this.SetTime("time1x");
         // V2: mouse wheel zoom (the handler existed in v1 but was never registered)
         m_container.stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.OnMouseWheel,false,0,true);
      }

      public function OnAfterLoad() : void
      {
         this.m_guiMC.hotel_name.text = this.m_gameLogic.GetGameStatus().hotelName;
         this.UpdateBorderButtons();
         this.m_leftBorderPos = Config.GetLeftBorderPos(this.m_gameLogic.GetGameStatus());
         this.m_rightBorderPos = Config.GetRightBorderPos(this.m_gameLogic.GetGameStatus());
      }

      private function OnMouseWheel(param1:MouseEvent) : void
      {
         if(m_dialog != null || this.m_helpPanel != null)
         {
            return;
         }
         var _loc2_:Number = this.m_gameLogic.GetCamera().GetScale().x;
         if(param1.delta > 0)
         {
            if(_loc2_ < 1)
            {
               this.SetZoom("zoom1x");
            }
            else
            {
               this.SetZoom("zoom2x");
            }
         }
         else if(_loc2_ > 1)
         {
            this.SetZoom("zoom1x");
         }
         else
         {
            this.SetZoom("zoom05x");
         }
      }

      private function OnExpandLeftClick(param1:Event) : void
      {
         var _loc4_:Point = null;
         var _loc2_:GameStatus = this.m_gameLogic.GetGameStatus();
         var _loc3_:int = Config.GetBorderIncreasePrice(_loc2_);
         if(_loc2_.money >= _loc3_)
         {
            _loc4_ = new Point(m_container.mouseX,m_container.mouseY);
            this.m_gameLogic.GetCamera().PointScreenToWorld(_loc4_,_loc4_,new Point(1,1));
            ++this.m_gameLogic.GetGameStatus().leftBorderPos;
            this.m_gameLogic.Charge(_loc3_,_loc4_);
            this.UpdateBorderButtons();
            Sounds.PlayHire();
            Tracker.Message("Expanded left");
         }
         else
         {
            Sounds.PlayWrong();
         }
      }

      private function OnExpandRightClick(param1:Event) : void
      {
         var _loc4_:Point = null;
         var _loc2_:GameStatus = this.m_gameLogic.GetGameStatus();
         var _loc3_:int = Config.GetBorderIncreasePrice(_loc2_);
         if(_loc2_.money >= _loc3_)
         {
            var _loc5_:*;
            var _loc6_:* = (_loc5_ = this.m_gameLogic.GetGameStatus()).rightBorderPos + 1;
            _loc5_.rightBorderPos = _loc6_;
            _loc4_ = new Point(m_container.mouseX,m_container.mouseY);
            this.m_gameLogic.GetCamera().PointScreenToWorld(_loc4_,_loc4_,new Point(1,1));
            this.m_gameLogic.Charge(_loc3_,_loc4_);
            this.UpdateBorderButtons();
            Sounds.PlayHire();
            Tracker.Message("Expanded right");
         }
         else
         {
            Sounds.PlayWrong();
         }
      }

      override public function SetDialog(param1:Window) : void
      {
         Tracker.Message("Dialog set " + Utils.GetShortClassName(param1));
         super.SetDialog(param1);
      }

      private function OnCursorClick(param1:Event) : void
      {
         this.m_gameLogic.SetMode(new SelectMode());
      }

      private function OnStaffClick(param1:Event) : void
      {
         this.m_gameLogic.SetMode(new DialogBasedMode(new HireWindow(this.m_gameLogic),"staff"));
      }

      private function OnStarsClick(param1:Event) : void
      {
         if(this.m_gameLogic.GetGameStatus().stars < 5)
         {
            this.m_gameLogic.SetMode(new DialogBasedMode(new StarsWindow(this.m_gameLogic),"cursor"));
         }
         else
         {
            this.m_gameLogic.SetMode(new DialogBasedMode(new WinWindow(this.m_gameLogic),"cursor"));
         }
      }

      private function OnMoneyClick(param1:Event) : void
      {
         this.m_gameLogic.SetMode(new DialogBasedMode(new BorrowWindow(this.m_gameLogic),"cursor"));
      }

      private function OnBuildClick(param1:Event) : void
      {
         this.m_gameLogic.SetMode(new DialogBasedMode(new BuildWindow(this.m_gameLogic),"build"));
      }

      private function OnStatClick(param1:Event) : void
      {
         this.m_gameLogic.SetMode(new DialogBasedMode(new FeedbackWindow(this.m_gameLogic),"stat"));
      }

      private function OnSettingsClick(param1:Event) : void
      {
         this.m_gameLogic.SetMode(new DialogBasedMode(new PauseWindow(this.m_gameLogic),"cursor"));
      }

      private function OnChartsClick(param1:Event) : void
      {
         this.m_gameLogic.SetMode(new DialogBasedMode(new ChartWindow(this.m_gameLogic),"stat_hotel"));
      }

      private function OnDelClick(param1:Event) : void
      {
         this.m_gameLogic.SetMode(new DeleteMode("del"));
      }

      private function OnMusicToggle(param1:Event) : void
      {
         Music.Instance().Toggle();
         this.m_guiMC.music_on.visible = Music.Instance().IsEnabled();
         this.m_guiMC.music_off.visible = !Music.Instance().IsEnabled();
         Tracker.Message("Music enabled=" + Music.Instance().IsEnabled());
      }

      private function OnSoundToggle(param1:Event) : void
      {
         Sounds.Toggle();
         this.m_guiMC.sound_on.visible = Sounds.IsEnabled();
         this.m_guiMC.sound_off.visible = !Sounds.IsEnabled();
         Tracker.Message("Sounds enabled=" + Sounds.IsEnabled());
      }

      private function SetTime(param1:String) : void
      {
         var _loc2_:String = null;
         if(m_sTimings == null)
         {
            m_sTimings = new Dictionary();
            m_sTimings["pause"] = 0;
            m_sTimings["time1x"] = 1;
            m_sTimings["time2x"] = 2;
            m_sTimings["time4x"] = 4;
            m_sTimings["time8x"] = 8;
         }
         if(m_sTimings[param1] == null)
         {
            return;
         }
         if(param1 != "pause")
         {
            this.m_timeBeforePause = param1;
         }
         this.m_currentTime = param1;
         this.m_gameLogic.m_timeScale = m_sTimings[param1];
         // x8 has no button of its own: it lights up the x4 button plus a badge
         var _loc3_:String = param1 == "time8x" ? "time4x" : param1;
         for each(_loc2_ in ["pause","time1x","time2x","time4x"])
         {
            if(_loc2_ == _loc3_)
            {
               this.HLightButton(this.m_guiMC[_loc2_]);
            }
            else
            {
               this.UNHLightButton(this.m_guiMC[_loc2_]);
            }
         }
         if(this.m_speedBadge != null)
         {
            this.m_speedBadge.visible = param1 == "time8x";
         }
         Tracker.Message("TimeScale set " + param1);
      }

      public function OnTimeClick(param1:Event) : void
      {
         this.SetTime(param1.target.name);
      }

      private function SetZoom(param1:String) : void
      {
         var _loc3_:* = null;
         if(m_sZooms == null)
         {
            m_sZooms = new Dictionary();
            m_sZooms["zoom05x"] = new Point(0.5,0.5);
            m_sZooms["zoom1x"] = new Point(1,1);
            m_sZooms["zoom2x"] = new Point(1.6,1.6);
         }
         var _loc2_:Point = m_sZooms[param1];
         if(_loc2_ == null)
         {
            return;
         }
         this.m_currentZoom = param1;
         this.m_gameLogic.GetCamera().SetScale(_loc2_.x,_loc2_.y);
         for(_loc3_ in m_sZooms)
         {
            if(_loc3_ == param1)
            {
               this.HLightButton(this.m_guiMC[_loc3_]);
            }
            else
            {
               this.UNHLightButton(this.m_guiMC[_loc3_]);
            }
         }
         Tracker.Message("Zoom set " + param1);
      }

      public function OnZoomClick(param1:Event) : void
      {
         this.SetZoom(param1.target.name);
      }

      private function OnMenuClick(param1:Event) : void
      {
         var e:Event = param1;
         var gameLogic:HotelGameLogic = this.m_gameLogic;
         var doQuit:Function = function():void
         {
            // V2: progress is kept in the autosave slot when leaving the game
            var _loc1_:Object = {};
            gameLogic.Save(_loc1_);
            ProgressManager.Instance().SaveGame(Config.AutoSaveSlot,_loc1_);
            (Application.Instance()["GetStateManager"]() as StateManager).SetCurrentState("mainmenu",null);
         };
         PushDialog(new YesNoWindow("Quit to main menu? (progress is autosaved)",doQuit,null));
      }

      private function OnSaveClick(param1:Event) : void
      {
         this.SetDialog(new SaveWindow(this.m_gameLogic));
      }

      private function UpdateBorderButtons() : void
      {
         var _loc1_:GameStatus = this.m_gameLogic.GetGameStatus();
         this.m_leftBorderMC.expand_btn.visible = Config.GetLeftBorderPos(_loc1_) > 500;
         this.m_rightBorderMC.expand_btn.visible = Config.GetRightBorderPos(_loc1_) < this.m_gameLogic.GetWorld().GetWidth() - 500;
         this.m_leftBorderMC.price.visible = this.m_leftBorderMC.expand_btn.visible;
         this.m_rightBorderMC.price.visible = this.m_rightBorderMC.expand_btn.visible;
         var _loc2_:int = Config.GetBorderIncreasePrice(this.m_gameLogic.GetGameStatus());
         this.m_leftBorderMC.price.text = "$" + _loc2_;
         this.m_rightBorderMC.price.text = "$" + _loc2_;
      }

      public function Autosaved() : void
      {
         this.m_autoSaveTimer = 2.5;
      }

      override public function Update(param1:Number) : void
      {
         this.m_autoSaveTimer = Utils.AdvanceNumber(this.m_autoSaveTimer,0,param1);
         this.m_guiMC.autosaving.alpha = Math.min(this.m_autoSaveTimer,1);
         this.m_guiMC.autosaving.visible = this.m_autoSaveTimer > 0;
         if(!(this.m_guiMC.stage.focus is TextField))
         {
            this.m_guiMC.stage.focus = this.m_guiMC.stage.stage;
         }
         this.m_guiMC.date.text = Utils.FormatDate(this.m_gameLogic.GetGameStatus().date);
         this.m_guiMC.money.text = "$" + Math.round(this.m_gameLogic.GetGameStatus().money);
         this.m_guiMC.guests.text = this.m_gameLogic.GetWorldQuery().GetTotalGuestsCount() + "/" + this.m_gameLogic.GetWorldQuery().GetTotalGuestRoomsCount();
         this.m_guiMC.rep.text = "" + int(this.m_gameLogic.GetGameStatus().reputation);
         this.m_guiMC.reputation_bar.x = 26 + int(this.m_gameLogic.GetGameStatus().reputation) / 1000 * 90;
         this.m_guiMC.reputation_bar.width = 90 - int(this.m_gameLogic.GetGameStatus().reputation) / 1000 * 90;
         var _loc2_:int = this.m_gameLogic.GetGameStatus().stars + 1;
         if(this.m_guiMC.stars.currentFrame != _loc2_)
         {
            this.m_guiMC.stars.gotoAndStop(_loc2_);
         }
         this.m_guiMC.small_bar.visible = _loc2_ <= 5;
         this.m_leftBorderPos = Utils.AdvanceNumber(this.m_leftBorderPos,Config.GetLeftBorderPos(this.m_gameLogic.GetGameStatus()),1000 * param1);
         this.m_rightBorderPos = Utils.AdvanceNumber(this.m_rightBorderPos,Config.GetRightBorderPos(this.m_gameLogic.GetGameStatus()),1000 * param1);
         var _loc3_:Point = new Point(1,1);
         var _loc4_:Point = new Point();
         var _loc5_:Point = new Point(this.m_leftBorderPos,this.m_gameLogic.GetWorld().GetHeight() - Config.floorHeight);
         this.m_gameLogic.GetCamera().PointWorldToScreen(_loc5_,_loc4_,_loc3_);
         this.m_leftBorderMC.x = _loc4_.x;
         this.m_leftBorderMC.y = _loc4_.y;
         this.m_leftBorderMC.expand_btn.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
         _loc5_.x = this.m_rightBorderPos;
         this.m_gameLogic.GetCamera().PointWorldToScreen(_loc5_,_loc4_,_loc3_);
         this.m_rightBorderMC.x = _loc4_.x;
         this.m_rightBorderMC.y = _loc4_.y;
         var _loc6_:Object;
         var _loc7_:Number = (_loc6_ = Config.GetStarProgress(this.m_gameLogic)).moneyProgress + _loc6_.roomsProgress + _loc6_.reputationProgress;
         this.m_guiMC.small_bar.bar.width = this.m_smallBarWidth * _loc7_ / 3;
         if(_loc7_ == 3 && this.m_gameLogic.GetGameStatus().stars < 5)
         {
            this.m_guiMC.stars.alpha = this.m_starFlashTimer >= 0 ? Number(1) : Number(0);
            this.m_starFlashTimer += param1;
            if(this.m_starFlashTimer > 0.45)
            {
               this.m_starFlashTimer -= 0.9;
            }
         }
         else
         {
            this.m_guiMC.stars.alpha = 1;
            this.m_starFlashTimer = 0;
         }
         if(this.m_toastTimer > 0)
         {
            this.m_toastTimer = Utils.AdvanceNumber(this.m_toastTimer,0,param1);
            this.m_toast.alpha = Math.min(this.m_toastTimer * 2,1);
            this.m_toast.visible = this.m_toastTimer > 0;
         }
         if(m_dialog != null)
         {
            m_dialog.Update(param1);
         }
      }

      // ------------------------------------------------------------------
      // V2: keyboard shortcuts
      // ------------------------------------------------------------------

      private function IsModalDialogOpen() : Boolean
      {
         return m_dialog is PauseWindow || m_dialog is SaveWindow || m_dialog is YesNoWindow || m_dialog is WinWindow || m_dialog is GotStarWindow;
      }

      public function OnHotkey(param1:KeyboardEvent) : Boolean
      {
         if(this.m_guiMC == null || this.m_guiMC.stage == null || this.m_guiMC.stage.focus is TextField)
         {
            return false;
         }
         var _loc2_:uint = param1.keyCode;
         if(_loc2_ == KeyCodes.VK_F1 || _loc2_ == 191 || _loc2_ == 72)
         {
            this.ToggleHelp();
            return true;
         }
         if(this.m_helpPanel != null)
         {
            if(_loc2_ == KeyCodes.VK_ESCAPE)
            {
               this.ToggleHelp();
               return true;
            }
            return false;
         }
         if(this.IsModalDialogOpen())
         {
            return false;
         }
         switch(_loc2_)
         {
            case KeyCodes.VK_SPACE:
            case 80:
               this.SetTime(this.m_currentTime == "pause" ? this.m_timeBeforePause : "pause");
               this.ShowToast(this.m_currentTime == "pause" ? "Paused" : "Speed " + this.GetSpeedLabel());
               return true;
            case 49:
            case 97:
               this.SetTimeWithToast("time1x");
               return true;
            case 50:
            case 98:
               this.SetTimeWithToast("time2x");
               return true;
            case 51:
            case 99:
               this.SetTimeWithToast("time4x");
               return true;
            case 52:
            case 100:
               this.SetTimeWithToast("time8x");
               return true;
            case 187:
            case 107:
            case 69:
               this.StepZoom(1);
               return true;
            case 189:
            case 109:
            case 81:
               this.StepZoom(-1);
               return true;
            case 66:
               this.OnBuildClick(null);
               return true;
            case 82:
               this.OnStaffClick(null);
               return true;
            case 88:
            case 46:
               this.OnDelClick(null);
               return true;
            case 70:
               this.OnStatClick(null);
               return true;
            case 71:
               this.OnChartsClick(null);
               return true;
            case 76:
               this.OnMoneyClick(null);
               return true;
            case 77:
               this.OnMusicToggle(null);
               this.ShowToast(Music.Instance().IsEnabled() ? "Music on" : "Music off");
               return true;
            case 78:
               this.OnSoundToggle(null);
               this.ShowToast(Sounds.IsEnabled() ? "Sounds on" : "Sounds off");
               return true;
            case 75:
               this.OnSaveClick(null);
               return true;
            default:
               return false;
         }
      }

      private function GetSpeedLabel() : String
      {
         return "x" + m_sTimings[this.m_currentTime];
      }

      private function SetTimeWithToast(param1:String) : void
      {
         this.SetTime(param1);
         this.ShowToast("Speed " + this.GetSpeedLabel());
      }

      private function StepZoom(param1:int) : void
      {
         var _loc2_:int = s_zoomOrder.indexOf(this.m_currentZoom) + param1;
         _loc2_ = Math.max(0,Math.min(s_zoomOrder.length - 1,_loc2_));
         this.SetZoom(s_zoomOrder[_loc2_]);
      }

      private function ShowToast(param1:String) : void
      {
         this.m_toast.text = param1;
         this.m_toast.x = int((700 - this.m_toast.width) * 0.5);
         this.m_toast.y = 380;
         this.m_toast.alpha = 1;
         this.m_toast.visible = true;
         this.m_toastTimer = 1.2;
      }

      private function ToggleHelp() : void
      {
         if(this.m_helpPanel != null)
         {
            this.m_helpPanel.parent.removeChild(this.m_helpPanel);
            this.m_helpPanel = null;
            this.SetTime(this.m_timeBeforeHelp);
            return;
         }
         // the game is paused while the help is displayed
         this.m_timeBeforeHelp = this.m_currentTime;
         this.SetTime("pause");
         this.m_helpPanel = CreateHelpPanel(true);
         this.m_helpPanel.addEventListener(MouseEvent.CLICK,this.OnHelpClick,false,0,true);
         m_container.stage.addChild(this.m_helpPanel);
      }

      private function OnHelpClick(param1:Event) : void
      {
         this.ToggleHelp();
      }

      public static function CreateLabel(param1:String, param2:int, param3:uint, param4:String = "Cooper Black") : TextField
      {
         var _loc5_:TextField = new TextField();
         _loc5_.embedFonts = true;
         _loc5_.defaultTextFormat = new TextFormat(param4,param2,param3);
         _loc5_.autoSize = TextFieldAutoSize.LEFT;
         _loc5_.selectable = false;
         _loc5_.mouseEnabled = false;
         _loc5_.text = param1;
         _loc5_.filters = [new GlowFilter(1847434,1,3,3,8,2)];
         return _loc5_;
      }

      private static function AddRow(container:DisplayObjectContainer, key:String, desc:String, px:Number, py:Number, descOffset:Number) : void
      {
         var keyLabel:TextField = CreateLabel(key,13,16768512,"Arial");
         keyLabel.x = px;
         keyLabel.y = py;
         container.addChild(keyLabel);
         var descLabel:TextField = CreateLabel(desc,13,16777215,"Arial");
         descLabel.x = px + descOffset;
         descLabel.y = py;
         container.addChild(descLabel);
      }

      // Shared by the in-game help (H / F1) and the main menu "Controls" button
      public static function CreateHelpPanel(param1:Boolean) : Sprite
      {
         var _loc2_:Sprite = new Sprite();
         _loc2_.buttonMode = true;
         _loc2_.graphics.beginFill(0,0.45);
         _loc2_.graphics.drawRect(0,0,700,500);
         _loc2_.graphics.endFill();
         var _loc3_:Sprite = new Sprite();
         _loc3_.graphics.lineStyle(3,16777215,1);
         _loc3_.graphics.beginFill(1324474,0.96);
         _loc3_.graphics.drawRoundRect(0,0,560,370,28,28);
         _loc3_.graphics.endFill();
         _loc3_.x = 70;
         _loc3_.y = 55;
         _loc3_.filters = [new DropShadowFilter(4,45,0,0.6,8,8)];
         _loc2_.addChild(_loc3_);
         var _loc4_:TextField = CreateLabel("Theme Hotel V2 - Controls",24,16777215);
         _loc4_.x = int((560 - _loc4_.width) * 0.5);
         _loc4_.y = 14;
         _loc3_.addChild(_loc4_);
         var _loc5_:Number = 62;
         var _loc6_:Number = 22;
         AddRow(_loc3_,"Space / P","Pause / resume",30,_loc5_,118);
         AddRow(_loc3_,"1  2  3  4","Speed x1 / x2 / x4 / x8 (new)",30,_loc5_ += _loc6_,118);
         AddRow(_loc3_,"Mouse wheel","Zoom in / out",30,_loc5_ += _loc6_,118);
         AddRow(_loc3_,"+ / -   E / Q","Zoom in / out",30,_loc5_ += _loc6_,118);
         AddRow(_loc3_,"Arrows / WASD","Scroll the view",30,_loc5_ += _loc6_,118);
         AddRow(_loc3_,"B","Build",30,_loc5_ += _loc6_,118);
         AddRow(_loc3_,"R","Recruit staff",30,_loc5_ += _loc6_,118);
         AddRow(_loc3_,"X / Delete","Demolish",30,_loc5_ += _loc6_,118);
         AddRow(_loc3_,"Esc","Select tool / close",30,_loc5_ += _loc6_,118);
         _loc5_ = 62;
         AddRow(_loc3_,"F","Guest feedback",360,_loc5_,62);
         AddRow(_loc3_,"G","Hotel charts",360,_loc5_ += _loc6_,62);
         AddRow(_loc3_,"L","Bank loan",360,_loc5_ += _loc6_,62);
         AddRow(_loc3_,"K","Save game",360,_loc5_ += _loc6_,62);
         AddRow(_loc3_,"M / N","Music / sounds",360,_loc5_ += _loc6_,62);
         AddRow(_loc3_,"H / F1","This help",360,_loc5_ += _loc6_,62);
         var _loc7_:TextField = CreateLabel("New in V2: x8 speed, keyboard shortcuts, wheel zoom,\nautosave on quit, offline play (no tracking, no dead links).",12,13434879,"Arial");
         _loc7_.x = 30;
         _loc7_.y = 282;
         _loc3_.addChild(_loc7_);
         var _loc8_:TextField = CreateLabel(!!param1 ? "Click anywhere or press H to continue" : "Click anywhere to close",14,16768512);
         _loc8_.x = int((560 - _loc8_.width) * 0.5);
         _loc8_.y = 330;
         _loc3_.addChild(_loc8_);
         return _loc2_;
      }

      override protected function DestroyControls() : void
      {
         if(this.m_helpPanel != null)
         {
            this.m_helpPanel.parent.removeChild(this.m_helpPanel);
            this.m_helpPanel = null;
         }
         if(this.m_toast != null)
         {
            this.m_toast.parent.removeChild(this.m_toast);
            this.m_toast = null;
         }
         m_container.stage.removeEventListener(MouseEvent.MOUSE_WHEEL,this.OnMouseWheel);
         this.m_guiMC.parent.removeChild(this.m_guiMC);
         this.m_guiMC = null;
         this.m_leftBorderMC.parent.removeChild(this.m_leftBorderMC);
         this.m_rightBorderMC.parent.removeChild(this.m_rightBorderMC);
      }

      private function RegisterButton(param1:MovieClip) : void
      {
         param1.buttonMode = true;
         param1.gotoAndStop(1);
         param1.addEventListener(MouseEvent.MOUSE_OVER,this.OnBMouseOver,false,0,true);
         param1.addEventListener(MouseEvent.MOUSE_OUT,this.OnBMouseOut,false,0,true);
      }

      private function UNHLightButton(param1:MovieClip) : void
      {
         if(param1.currentFrame > 2)
         {
            param1.gotoAndStop(param1.currentFrame - 2);
         }
      }

      private function HLightButton(param1:MovieClip) : void
      {
         if(param1.currentFrame <= 2)
         {
            param1.gotoAndStop(param1.currentFrame + 2);
         }
      }

      private function OnBMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.target as MovieClip;
         _loc2_.gotoAndStop(_loc2_.currentFrame == 3 ? 4 : 2);
      }

      private function OnBMouseOut(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.target as MovieClip;
         _loc2_.gotoAndStop(_loc2_.currentFrame == 4 ? 3 : 1);
      }

      public function SetActiveButton(param1:String) : void
      {
         var _loc2_:MovieClip = this.m_guiMC.getChildByName(param1) as MovieClip;
         if(this.m_activeButton == _loc2_)
         {
            return;
         }
         if(this.m_activeButton != null)
         {
            this.UNHLightButton(this.m_activeButton);
         }
         this.m_activeButton = _loc2_;
         if(this.m_activeButton != null)
         {
            this.HLightButton(this.m_activeButton);
         }
      }
   }
}
