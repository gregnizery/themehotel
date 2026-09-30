package HotelCommon
{
   import FGKit.DefaultGameLogic;
   import FGKit.FPSCounter;
   import FGKit.Graphics.ChartData;
   import FGKit.InputManager;
   import FGKit.KeyCodes;
   import FGKit.Properties.ObjectProperty;
   import FGKit.Serializers.WorldXmlSerializer;
   import FGKit.Tracker.Tracker;
   import FGKit.Utils;
   import FGKit.World.Entity;
   import Hotel.LoadWindow;
   import HotelCommon.Events.IncomeEvent;
   import HotelCommon.GUI.GotStarWindow;
   import HotelCommon.GUI.InGameGui;
   import HotelCommon.GUI.PauseWindow;
   import HotelCommon.GUI.SaveWindow;
   import HotelCommon.GUI.WinWindow;
   import HotelCommon.GUI.YesNoWindow;
   import HotelCommon.Modes.DialogBasedMode;
   import HotelCommon.Modes.Mode;
   import HotelCommon.Modes.SelectMode;
   import HotelCommon.Tutorial.Tutorial;
   import flash.display.MovieClip;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.system.Capabilities;
   import flash.system.System;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;

   public class HotelGameLogic extends DefaultGameLogic
   {

      private static var s_defaultColorTransform:ColorTransform = new ColorTransform();

      {
      }

      private var m_chartData:ChartData;

      private var m_query:WorldQuery;

      private var m_infoBar:TextField;

      private var m_guestSpawner:GuestSpawner;

      private var m_gui:InGameGui;

      public var m_timeScale:Number = 1;

      private var m_gameStatus:GameStatus;

      private var m_reputationManager:ReputationManager;

      private var m_currentMode:Mode;

      private var m_tutorial:Tutorial;

      private var m_tutorialContainer:MovieClip;

      private var m_tutorialFlashFrame:int = 0;

      private var m_tutorialFlashTimer:Number = 0;

      private var m_guiContainer:MovieClip;

      private var m_floorDisplayer:FloorDisplayer;

      // ---- V2: random events ----
      public static const EVENT_GOOD:int = 1;

      public static const EVENT_BAD:int = 2;

      public static const EVENT_NEUTRAL:int = 3;

      private var m_eventLog:Array = [];

      private var m_daysSinceEvent:int = 0;

      private var m_festivalDays:int = 0;

      public var m_eventsEnabled:Boolean = true;

      public function HotelGameLogic()
      {
         super();
      }

      override protected function InitGame() : void
      {
         var _loc3_:TextFormat = null;
         this.m_guestSpawner = new GuestSpawner(this);
         this.m_guiContainer = new MovieClip();
         m_container.addChild(this.m_guiContainer);
         this.m_gui = new InGameGui(this);
         this.m_gui.InitAsRoot(this.m_guiContainer);
         this.m_gameStatus = new GameStatus();
         this.m_reputationManager = new ReputationManager(this);
         this.InitWorld();
         this.SetMode(new SelectMode());
         var _loc1_:int = Config.daysInGraph / Config.graphSnapshotInterval + 1;
         this.m_chartData = new ChartData();
         this.m_chartData.AddGraph("money",4278190335,_loc1_);
         this.m_chartData.AddGraph("rep",4278255360,_loc1_);
         this.m_chartData.AddGraph("guests",4294901760,_loc1_);
         this.m_chartData.AddGraph("rooms",4289374720,_loc1_);
         var _loc2_:* = m_container.root.loaderInfo.parameters.showInfoBar == "true";
         if(_loc2_)
         {
            this.m_infoBar = new TextField();
            this.m_infoBar.width = 700;
            this.m_infoBar.height = 100;
            this.m_infoBar.y = 30;
            this.m_infoBar.mouseEnabled = false;
            this.m_infoBar.htmlText = "";
            this.m_infoBar.multiline = true;
            m_container.addChild(this.m_infoBar);
            _loc3_ = new TextFormat("Courier New",12,4294967295);
            this.m_infoBar.defaultTextFormat = _loc3_;
         }
         this.m_tutorialContainer = new MovieClip();
         m_container.addChild(this.m_tutorialContainer);
         this.m_tutorial = new Tutorial(this);
         this.m_floorDisplayer = new FloorDisplayer(this);
      }

      private function InitWorld() : void
      {
         this.m_query = new WorldQuery(m_world);
         this.m_query.Init();
         m_world.AddProperty(ObjectProperty.Create("gameLogic",this));
         m_world.addEventListener("income",this.OnIncome,false,0,true);
      }

      override protected function InitKeyboardInput() : void
      {
         super.InitKeyboardInput();
         var _loc1_:InputManager = m_world.GetInputManager();
         _loc1_.RegisterKeyboardAction(InputManager.ACTION_UP,KeyCodes.VK_UP);
         _loc1_.RegisterKeyboardAction(InputManager.ACTION_DOWN,KeyCodes.VK_DOWN);
         _loc1_.RegisterKeyboardAction(InputManager.ACTION_LEFT,KeyCodes.VK_LEFT);
         _loc1_.RegisterKeyboardAction(InputManager.ACTION_RIGHT,KeyCodes.VK_RIGHT);
         _loc1_.RegisterKeyboardAction(InputManager.ACTION_UP,KeyCodes.VK_W);
         _loc1_.RegisterKeyboardAction(InputManager.ACTION_DOWN,KeyCodes.VK_S);
         _loc1_.RegisterKeyboardAction(InputManager.ACTION_LEFT,KeyCodes.VK_A);
         _loc1_.RegisterKeyboardAction(InputManager.ACTION_RIGHT,KeyCodes.VK_D);
      }

      override protected function OnKeyDown(param1:KeyboardEvent) : void
      {
         // V2: keyboard shortcuts (see InGameGui.OnHotkey)
         if(this.m_gui != null && this.m_gui.OnHotkey(param1))
         {
            return;
         }
         if(param1.keyCode == KeyCodes.VK_ESCAPE && m_world != null)
         {
            if(!(this.m_currentMode is SelectMode))
            {
               this.SetMode(new SelectMode());
            }
         }
         super.OnKeyDown(param1);
      }

      override protected function DestroyGame() : void
      {
         super.DestroyGame();
         if(this.m_currentMode != null)
         {
            this.m_currentMode.Dispose();
         }
         this.m_guestSpawner = null;
         this.m_gui.DestroyAsRoot();
         this.m_gui = null;
         this.m_gameStatus = null;
         this.m_reputationManager = null;
         if(this.m_infoBar != null)
         {
            m_container.removeChild(this.m_infoBar);
            this.m_infoBar = null;
         }
         this.m_guiContainer.parent.removeChild(this.m_guiContainer);
         this.m_guiContainer = null;
         this.m_tutorialContainer.parent.removeChild(this.m_tutorialContainer);
         this.m_tutorialContainer = null;
         this.m_tutorial = null;
         this.m_floorDisplayer = null;
      }

      override protected function InitCameraController() : void
      {
         m_cameraController = new HotelCameraController(m_camera,this);
         m_camera.SetPositionXY(Config.GetLeftBorderPos(this.m_gameStatus) + 320,m_world.GetHeight() - m_camera.GetHeight() * 0.5);
      }

      private function OnIncome(param1:IncomeEvent) : void
      {
         var _loc2_:String = param1.service.GetTemplate().GetFriendlyName();
         this.m_gameStatus.money += param1.amount;
         this.m_gameStatus.curMonthIncomes[_loc2_] = (this.m_gameStatus.curMonthIncomes[_loc2_] || 0) + param1.amount;
         var _loc3_:Entity = new Entity(m_world.GetEntityTemplates().GetTemplateByFriendlyName("Payment"));
         (_loc3_.GetGraphic() as PaymentGraphic).SetAmount(param1.amount);
         _loc3_.SetPositionXY(param1.entity.GetX(),param1.entity.GetY());
         m_world.AddEntity(_loc3_);
      }

      public function Charge(param1:int, param2:Point) : void
      {
         this.m_gameStatus.money -= param1;
         var _loc3_:Entity = new Entity(m_world.GetEntityTemplates().GetTemplateByFriendlyName("Payment"));
         (_loc3_.GetGraphic() as PaymentGraphic).SetAmount(-param1);
         _loc3_.SetPosition(param2);
         m_world.AddEntity(_loc3_);
      }

      override protected function OnMouseDown(param1:MouseEvent) : void
      {
         if(param1.target == m_container && this.m_currentMode != null)
         {
            this.m_currentMode.OnScreenMouseDown(param1);
         }
      }

      override protected function OnDeactivate(param1:Event) : void
      {
         this.m_gui.SetDialog(new PauseWindow(this));
      }

      private function DayEnded() : void
      {
         var _loc2_:* = null;
         var _loc3_:ServiceBehaviour = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:Number = NaN;
         if(this.m_gameStatus.borrowedMoney > 0)
         {
            _loc5_ = (_loc4_ = Math.min(this.m_gameStatus.loanSize / 365,this.m_gameStatus.borrowedMoney)) * Config.loanPercent;
            _loc6_ = _loc4_ + _loc5_;
            this.m_gameStatus.borrowedMoney -= _loc4_;
            this.m_gameStatus.money -= _loc6_;
            this.m_gameStatus.curMonthLoanPayment += _loc6_;
         }
         var _loc1_:int = Utils.GetDaysInMonth(this.m_gameStatus.date.month,this.m_gameStatus.date.fullYear);
         var _loc9_:int = 0;
         var _loc10_:* = Config.keepCosts;
         while(true)
         {
            for(_loc2_ in _loc10_)
            {
               _loc7_ = Config.keepCosts[_loc2_];
               if((_loc8_ = Number(_loc7_) * this.m_query.GetEntitiesByTemplateName(_loc2_).length / _loc1_) > 0)
               {
                  this.m_gameStatus.curMonthCosts[_loc2_] = (this.m_gameStatus.curMonthCosts[_loc2_] || 0) + _loc8_;
                  this.m_gameStatus.money -= _loc8_;
               }
            }
            break;
         }
         _loc9_ = 0;
         for each(_loc3_ in this.m_query.GetServices())
         {
            _loc3_.UpdateStats(_loc1_);
         }
      }

      private function IsPaused() : Boolean
      {
         return this.m_gui.GetDialog() is PauseWindow || this.m_gui.GetDialog() is LoadWindow;
      }

      override public function Update(param1:Number) : void
      {
         if(this.m_infoBar != null)
         {
            this.m_infoBar.htmlText = "FPS: " + FPSCounter.Instance().GetFPS() + "   RAM: " + int(System.totalMemory / 1024 / 1024) + "   Atlases: " + PersonGraphic.m_atlas.GetAtlasBitmaps().length + "   Ver: " + Capabilities.version;
         }
         this.m_tutorialContainer.visible = !(this.m_gui.GetDialog() is PauseWindow || this.m_gui.GetDialog() is SaveWindow || this.m_gui.GetDialog() is YesNoWindow);
         if(!this.IsPaused())
         {
            super.Update(param1);
         }
      }

      override protected function UpdateGame(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         this.m_gui.Update(param1);
         if(this.m_currentMode != null)
         {
            this.m_currentMode.Update(param1);
         }
         this.FlashTutor(param1);
         param1 *= this.m_timeScale;
         this.m_tutorial.Update(param1);
         if(param1 == 0)
         {
            return;
         }
         this.m_guestSpawner.Update(param1);
         this.m_reputationManager.Update(param1);
         this.m_gameStatus.dayTimer += param1;
         while(true)
         {
            if(this.m_gameStatus.dayTimer <= Config.secondsPerDay)
            {
               break;
            }
            if(this.m_gameStatus.day % Config.graphSnapshotInterval == 0)
            {
               _loc2_ = this.m_gameStatus.date.valueOf() / 1000 / 60 / 60 / 24;
               this.m_chartData.AddPoint("money",new Point(_loc2_,this.m_gameStatus.money));
               this.m_chartData.AddPoint("rep",new Point(_loc2_,this.m_gameStatus.reputation));
               this.m_chartData.AddPoint("guests",new Point(_loc2_.valueOf(),this.m_query.GetTotalGuestsCount()));
               this.m_chartData.AddPoint("rooms",new Point(_loc2_.valueOf(),this.m_query.GetTotalGuestRoomsCount()));
            }
            this.DayEnded();
            this.UpdateRandomEvents();
            var _loc3_:*;
            var _loc4_:* = (_loc3_ = this.m_gameStatus.date).date + 1;
            _loc3_.date = _loc4_;
            _loc4_ = (_loc3_ = this.m_gameStatus).day + 1;
            _loc3_.day = _loc4_;
            if(this.m_gameStatus.date.date == 1)
            {
               this.NewMonthBegin();
            }
            this.m_gameStatus.dayTimer -= Config.secondsPerDay;
         }
         this.m_gameStatus.timeSinceStarsIncreased += param1;
         if(StarChecker.IsStarCriteriaMet(this))
         {
            this.m_gameStatus.timeStarCriteriaMet += param1;
            if(this.m_gameStatus.timeStarCriteriaMet > Config.daysToIncreaseStars * Config.secondsPerDay)
            {
               ++this.m_gameStatus.stars;
               if(this.m_gameStatus.stars == 5)
               {
                  this.m_gameStatus.winDate = new Date();
                  this.m_gameStatus.winDate.setTime(this.m_gameStatus.date.valueOf());
               }
               this.m_gameStatus.timeSinceStarsIncreased = 0;
               this.m_gameStatus.timeStarCriteriaMet = 0;
               if(this.m_gameStatus.stars == 5)
               {
                  this.SetMode(new DialogBasedMode(new WinWindow(this),"cursor"));
               }
               else
               {
                  this.SetMode(new DialogBasedMode(new GotStarWindow(this),"cursor"));
               }
               Sounds.PlayStarGot();
               Tracker.Message("Star got " + this.m_gameStatus.stars);
            }
         }
         else
         {
            this.m_gameStatus.timeStarCriteriaMet = 0;
         }
      }

      override protected function UpdateWorld(param1:Number) : void
      {
         // V2: speeds above x4 are simulated in x4 sub-steps so that the
         // physics/pathing keeps the same step size as the original game
         var _loc2_:Number = this.m_timeScale;
         while(_loc2_ > 4)
         {
            super.UpdateWorld(param1 * 4);
            _loc2_ -= 4;
         }
         if(_loc2_ > 0 || this.m_timeScale == 0)
         {
            super.UpdateWorld(param1 * _loc2_);
         }
      }

      private function NewMonthBegin() : void
      {
         var _loc1_:ServiceBehaviour = null;
         var _loc2_:Object = null;
         this.m_gameStatus.prevMonthCosts = this.m_gameStatus.curMonthCosts;
         this.m_gameStatus.prevMonthIncomes = this.m_gameStatus.curMonthIncomes;
         this.m_gameStatus.prevMonthLoanPayment = this.m_gameStatus.curMonthLoanPayment;
         this.m_gameStatus.curMonthCosts = new Dictionary();
         this.m_gameStatus.curMonthIncomes = new Dictionary();
         this.m_gameStatus.curMonthLoanPayment = 0;
         for each(_loc1_ in this.m_query.GetServices())
         {
            _loc1_.NewMonth();
         }
         _loc2_ = {};
         this.Save(_loc2_);
         ProgressManager.Instance().SaveGame(Config.AutoSaveSlot,_loc2_);
         this.m_gui.Autosaved();
         Tracker.Message("New month " + Utils.FormatDate(this.m_gameStatus.date) + " reputation " + int(this.m_gameStatus.reputation) + " money " + int(this.m_gameStatus.money) + " borrowed " + int(this.m_gameStatus.borrowedMoney) + " guests " + this.m_query.GetTotalGuestsCount() + " rooms " + this.m_query.GetTotalGuestRoomsCount());
      }

      override protected function ClearScreen() : void
      {
      }

      override protected function RenderWorld() : void
      {
         if(this.IsPaused())
         {
            return;
         }
         super.RenderWorld();
         this.m_floorDisplayer.Render(m_screen.bitmapData);
         if(this.m_currentMode != null)
         {
            this.m_currentMode.Render();
         }
      }

      // ------------------------------------------------------------------
      // V2: random events (checked once per game day)
      // ------------------------------------------------------------------

      public function GetGuestRateBoost() : Number
      {
         return this.m_festivalDays > 0 ? 2 : 1;
      }

      public function GetFestivalDaysLeft() : int
      {
         return this.m_festivalDays;
      }

      public function GetEventLog() : Array
      {
         return this.m_eventLog;
      }

      private function UpdateRandomEvents() : void
      {
         if(this.m_festivalDays > 0)
         {
            this.m_festivalDays--;
         }
         this.m_daysSinceEvent++;
         if(!this.m_eventsEnabled)
         {
            return;
         }
         var roomCount:int = this.m_query.GetTotalGuestRoomsCount();
         if(this.m_gameStatus.day < 30 || roomCount < 4 || this.m_query.GetEntitiesByTemplateName("Reception").length == 0)
         {
            return;
         }
         // at least 30 days between events, then about 1 chance in 30 per day
         if(this.m_daysSinceEvent < 30 || Math.random() > 1 / 30)
         {
            return;
         }
         this.TriggerRandomEvent();
      }

      // debug (flashvar v2debug=1, key J): force a given event kind
      public var m_forcedEvent:String = null;

      public function TriggerRandomEvent() : void
      {
         this.m_daysSinceEvent = 0;
         var candidates:Array = ["bus","celebrity","inspector","gift"];
         if(this.m_festivalDays == 0)
         {
            candidates.push("festival");
         }
         // breakable spots (facility + machine index) that are still working
         var spots:Array = [];
         var bb:BreakableBehaviour = null;
         for each(bb in this.m_query.GetBreakableRooms())
         {
            for(i = 0; i < bb.GetBreakPositions().length; i++)
            {
               if(!bb.IsBroken(i))
               {
                  spots.push({"b":bb,"i":i});
               }
            }
         }
         if(spots.length > 0)
         {
            candidates.push("power");
         }
         candidates.push("storm");
         var kind:String = candidates[Utils.RandomInt(0,candidates.length - 1)];
         if(this.m_forcedEvent != null)
         {
            kind = this.m_forcedEvent;
            this.m_forcedEvent = null;
         }
         var stars:int = this.m_gameStatus.stars;
         var rep:Number = this.m_gameStatus.reputation;
         var amount:int = 0;
         var i:int = 0;
         if(kind == "bus")
         {
            var free:int = this.m_query.GetTotalGuestRoomsCount() - this.m_query.GetTotalGuestsCount();
            if(free < 2)
            {
               kind = "gift";
            }
            else
            {
               var count:int = Math.min(free,Utils.RandomInt(4,10));
               this.m_guestSpawner.AddBusGuests(count);
               this.AddEvent(EVENT_GOOD,"Tourist bus!","A bus full of tourists stops in front of your hotel: " + count + " new guests are coming.");
               return;
            }
         }
         if(kind == "celebrity")
         {
            if(rep >= 650)
            {
               amount = 1500 + 1000 * stars;
               this.m_gameStatus.money += amount;
               this.m_gameStatus.reputation = Math.min(1000,rep + 60);
               this.AddEvent(EVENT_GOOD,"Celebrity visit","A movie star loved your hotel and told everyone about it! +$" + amount + ", reputation boost.");
            }
            else
            {
               this.m_gameStatus.reputation = Math.max(0,rep - 40);
               this.AddEvent(EVENT_BAD,"Celebrity visit","A movie star stayed here and complained to the press. Reputation drops. (Needs 650+ to impress)");
            }
            return;
         }
         if(kind == "inspector")
         {
            if(rep >= 700)
            {
               amount = 3000 * (stars + 1);
               this.m_gameStatus.money += amount;
               this.AddEvent(EVENT_GOOD,"Hotel inspector","The inspector is delighted and awards you a quality prize of $" + amount + ".");
            }
            else if(rep < 450)
            {
               amount = 1500 * (stars + 1);
               this.m_gameStatus.money -= amount;
               this.AddEvent(EVENT_BAD,"Hotel inspector","The inspector found many problems. You are fined $" + amount + ".");
            }
            else
            {
               this.AddEvent(EVENT_NEUTRAL,"Hotel inspector","The inspector visited your hotel. Everything is acceptable. (700+ reputation earns a prize)");
            }
            return;
         }
         if(kind == "festival")
         {
            this.m_festivalDays = 15;
            this.AddEvent(EVENT_GOOD,"Festival in town","A big festival starts in town: twice as many guests for 15 days. Build rooms!");
            return;
         }
         if(kind == "power")
         {
            if(spots.length == 0)
            {
               kind = "gift";
            }
            else
            {
               var broken:int = Math.min(spots.length,Utils.RandomInt(1,3));
               for(i = 0; i < broken; i++)
               {
                  var spot:Object = spots.splice(Utils.RandomInt(0,spots.length - 1),1)[0];
                  (spot.b as BreakableBehaviour).AddBreakFactor(spot.i,100000);
               }
               this.AddEvent(EVENT_BAD,"Power surge","A power surge broke " + broken + " machine" + (broken > 1 ? "s" : "") + ". Make sure you have engineers!");
               return;
            }
         }
         if(kind == "storm")
         {
            var rooms:Vector.<RoomBehaviour> = this.m_query.GetGuestRooms();
            for(i = 0; i < rooms.length; i++)
            {
               rooms[i].AddCleanness(-60);
            }
            this.AddEvent(EVENT_BAD,"Muddy storm","A storm brought mud everywhere: all rooms got dirty. Your maids have work to do!");
            return;
         }
         amount = Utils.RandomInt(5,25) * 100 * (stars + 1);
         this.m_gameStatus.money += amount;
         this.AddEvent(EVENT_GOOD,"Generous guest","A happy guest left a big tip for the staff: +$" + amount + ".");
      }

      private function AddEvent(param1:int, param2:String, param3:String) : void
      {
         this.m_eventLog.unshift({
            "kind":param1,
            "title":param2,
            "text":param3,
            "date":Utils.FormatDate(this.m_gameStatus.date)
         });
         if(this.m_eventLog.length > 5)
         {
            this.m_eventLog.pop();
         }
         if(param1 == EVENT_BAD)
         {
            Sounds.PlayWrong();
         }
         else
         {
            Sounds.PlayStarGot();
         }
         Tracker.Message("Event " + param2);
         this.m_gui.ShowEvent(param1,param2,param3);
      }

      public function GetGameStatus() : GameStatus
      {
         return this.m_gameStatus;
      }

      public function GetReputationManager() : ReputationManager
      {
         return this.m_reputationManager;
      }

      public function SetMode(param1:Mode) : void
      {
         Tracker.Message("Mode set " + Utils.GetShortClassName(param1));
         if(this.m_currentMode != null)
         {
            this.m_currentMode.Dispose();
         }
         param1.SetGameLogic(this);
         param1.Init();
         this.m_currentMode = param1;
      }

      public function GetWorldQuery() : WorldQuery
      {
         return this.m_query;
      }

      public function Save(param1:Object) : void
      {
         var _loc2_:Entity = null;
         var _loc3_:WorldXmlSerializer = null;
         var _loc4_:PersonBehaviour = null;
         param1.progress = this.m_gameStatus.SaveToXML();
         for each(_loc2_ in m_world.GetEntities())
         {
            if((_loc4_ = _loc2_.GetBehaviourByClass(PersonBehaviour) as PersonBehaviour) != null)
            {
               _loc4_.OnBeforeSave();
            }
         }
         _loc3_ = new WorldXmlSerializer();
         param1.world = _loc3_.SerializeWorld(m_world).toString();
         param1.metaData = {
            "saveName":this.m_gameStatus.hotelName,
            "money":this.m_gameStatus.money,
            "day":this.m_gameStatus.day,
            "gameTime":this.m_gameStatus.date.valueOf(),
            "realTime":new Date().valueOf(),
            "stars":this.m_gameStatus.stars
         };
      }

      public function OnAfterLoad() : void
      {
         var _loc1_:Entity = null;
         var _loc2_:PersonBehaviour = null;
         for each(_loc1_ in m_world.GetEntities())
         {
            _loc2_ = _loc1_.GetBehaviourByClass(PersonBehaviour) as PersonBehaviour;
            if(_loc2_ != null)
            {
               _loc2_.OnAfterLoad();
            }
         }
         this.m_gui.OnAfterLoad();
      }

      public function GetChartData() : ChartData
      {
         return this.m_chartData;
      }

      public function GetTargetGuestCount() : Number
      {
         return Config.GetTargetGuestCountByReptation(this.m_gameStatus.reputation,this.m_query.GetTotalGuestRoomsCount());
      }

      public function GetGUI() : InGameGui
      {
         return this.m_gui;
      }

      public function GetCameraController() : HotelCameraController
      {
         return m_cameraController as HotelCameraController;
      }

      public function GetCurrentMode() : Mode
      {
         return this.m_currentMode;
      }

      public function ShowTutorial(param1:MovieClip) : void
      {
         if(this.m_tutorialContainer.numChildren > 0)
         {
            throw new IllegalOperationError();
         }
         this.m_tutorialContainer.mouseEnabled = param1.mouseEnabled;
         this.m_tutorialContainer.mouseChildren = this.m_tutorialContainer.mouseChildren = param1.mouseChildren;
         this.m_tutorialContainer.addChild(param1);
         this.m_tutorialFlashFrame = 0;
         this.FlashTutor(0.001);
      }

      public function HideTutorial() : void
      {
         if(this.m_tutorialContainer.numChildren != 1)
         {
            throw new IllegalOperationError();
         }
         this.m_tutorialContainer.removeChildAt(0);
      }

      private function FlashTutor(param1:Number) : void
      {
         var _loc4_:Number = NaN;
         if(this.m_tutorialContainer.numChildren == 0)
         {
            return;
         }
         var _loc2_:MovieClip = this.m_tutorialContainer.getChildAt(0) as MovieClip;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:MovieClip = _loc2_.getChildByName("tutorial_text") as MovieClip;
         if(_loc3_ == null)
         {
            return;
         }
         if(_loc3_.currentFrame != this.m_tutorialFlashFrame)
         {
            this.m_tutorialFlashFrame = _loc3_.currentFrame;
            this.m_tutorialFlashTimer = 1;
         }
         else
         {
            this.m_tutorialFlashTimer = Utils.AdvanceNumber(this.m_tutorialFlashTimer,0,param1 * 2);
         }
         if(this.m_tutorialFlashTimer > 0)
         {
            _loc4_ = this.m_tutorialFlashTimer * 255;
            _loc3_.transform.colorTransform = new ColorTransform(1,1,1,1,_loc4_,_loc4_,_loc4_);
         }
         else
         {
            _loc3_.transform.colorTransform = s_defaultColorTransform;
         }
      }

      public function GetTutorial() : Tutorial
      {
         return this.m_tutorial;
      }
   }
}
