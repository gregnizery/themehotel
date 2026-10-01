package HotelCommon.GUI
{
   import FGKit.Graphics.Chart;
   import FGKit.Utils;
   import Hotel.Objects.Stat_Window;
   import HotelCommon.Config;
   import HotelCommon.HotelGameLogic;
   import HotelCommon.StarChecker;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.utils.Dictionary;

   public class ChartWindow extends Window
   {

      private static const s_subWindows:Array = ["sub_budget","sub_rooms","sub_staff","sub_graph"];

      private static var m_hiddenGraphs:Dictionary = new Dictionary();

      private static const graphNames:Array = ["money","rep","rooms","guests"];

      private static const graphFriendlyNames:Array = ["Money","Reputation","Rooms","Guests"];

      private static const graphRanges:Array = [100000,1000,100,100];

      private static const graphGridSteps:Array = [25000,250,25,25];

      {
      }

      private var m_gui:Stat_Window;

      private var m_gameLogic:HotelGameLogic;

      private var m_refreshTimer:Number = 0;

      private var m_charts:Vector.<Chart>;

      public function ChartWindow(param1:HotelGameLogic)
      {
         this.m_charts = new Vector.<Chart>();
         super();
         this.m_gameLogic = param1;
      }

      override protected function CreateControls() : void
      {
         var _loc7_:MovieClip = null;
         var _loc8_:Chart = null;
         this.m_gui = new Stat_Window();
         m_container.addChild(this.m_gui);
         this.m_gui.budget.addEventListener(MouseEvent.CLICK,this.OnBudgetClicked,false,0,true);
         this.m_gui.rooms.addEventListener(MouseEvent.CLICK,this.OnRoomsClicked,false,0,true);
         this.m_gui.staff.addEventListener(MouseEvent.CLICK,this.OnStaffClicked,false,0,true);
         this.m_gui.graph.addEventListener(MouseEvent.CLICK,this.OnChartClicked,false,0,true);
         this.m_gui.exit.addEventListener(MouseEvent.CLICK,DefaultCloseHandler,false,0,true);
         var _loc1_:MovieClip = this.m_gui.sub_graph.back;
         var _loc2_:int = _loc1_.width;
         var _loc3_:int = _loc1_.height;
         _loc1_.removeChildAt(0);
         var _loc4_:int = 0;
         var _loc5_:int = _loc3_ / graphNames.length;
         var _loc6_:int = 0;
         while(_loc6_ < graphNames.length)
         {
            (_loc7_ = new MovieClip()).y = _loc4_;
            _loc1_.addChild(_loc7_);
            (_loc8_ = new Chart(_loc7_,this.m_gameLogic.GetChartData())).HideAllGraphs();
            _loc8_.ShowGraph(graphNames[_loc6_]);
            _loc8_.CreateControls(_loc2_,_loc5_ - 3);
            _loc8_.SetGridStep(250,graphGridSteps[_loc6_]);
            _loc4_ += _loc5_;
            _loc8_.SetFriendlyName(graphFriendlyNames[_loc6_]);
            this.m_charts.push(_loc8_);
            _loc6_++;
         }
         this.m_charts[this.m_charts.length - 1].SetShowDate(true);
         this.OnBudgetClicked(null);
      }

      private function OnBudgetClicked(param1:Event) : void
      {
         this.ShowSubWindow("sub_budget");
         this.RefreshBudgetWindow();
      }

      private function OnRoomsClicked(param1:Event) : void
      {
         this.ShowSubWindow("sub_rooms");
         this.RefreshRoomsWindow();
      }

      private function OnStaffClicked(param1:Event) : void
      {
         this.ShowSubWindow("sub_staff");
         this.RefreshStaffWindow();
      }

      private function OnChartClicked(param1:Event) : void
      {
         this.ShowSubWindow("sub_graph");
         this.RefreshChartWindow();
      }

      private function ShowSubWindow(param1:String) : void
      {
         var _loc2_:String = null;
         for each(_loc2_ in s_subWindows)
         {
            this.m_gui.getChildByName(_loc2_).visible = _loc2_ == param1;
         }
      }

      override public function Update(param1:Number) : void
      {
         this.m_refreshTimer += param1;
         if(this.m_refreshTimer > 1)
         {
            this.m_refreshTimer = this.m_refreshTimer - 1;
            if(this.m_gui.sub_graph.visible)
            {
               this.RefreshChartWindow();
            }
            else if(this.m_gui.sub_staff.visible)
            {
               this.RefreshStaffWindow();
            }
            else if(this.m_gui.sub_budget.visible)
            {
               this.RefreshBudgetWindow();
            }
            else if(this.m_gui.sub_rooms.visible)
            {
               this.RefreshRoomsWindow();
            }
         }
      }

      private static function SumWithAliases(param1:Dictionary, param2:String) : Number
      {
         var _loc4_:* = null;
         if(param1 == null)
         {
            return 0;
         }
         var _loc3_:Number = Number(param1[param2]) || Number(0);
         for(_loc4_ in Config.templateAliases)
         {
            if(Config.templateAliases[_loc4_] == param2)
            {
               _loc3_ += Number(param1[_loc4_]) || Number(0);
            }
         }
         return _loc3_;
      }

      private function RefreshStaffWindow() : void
      {
         var _loc1_:int = this.m_gameLogic.GetWorldQuery().GetEntitiesByTemplateName("Receptionist").length;
         var _loc2_:int = this.m_gameLogic.GetWorldQuery().GetEntitiesByTemplateName("Cleaner").length;
         var _loc3_:int = this.m_gameLogic.GetWorldQuery().GetEntitiesByTemplateName("Waiter").length;
         var _loc4_:int = this.m_gameLogic.GetWorldQuery().GetEntitiesByTemplateName("Mechanic").length;
         this.m_gui.sub_staff.quant_receptionist.text = _loc1_.toString();
         this.m_gui.sub_staff.quant_maid.text = _loc2_.toString();
         this.m_gui.sub_staff.quant_waiter.text = _loc3_.toString();
         this.m_gui.sub_staff.quant_engineer.text = _loc4_.toString();
         this.m_gui.sub_staff.salary_receptionist.text = "$ " + _loc1_ * Config.keepCosts["Receptionist"];
         this.m_gui.sub_staff.salary_maid.text = "$ " + _loc2_ * Config.keepCosts["Cleaner"];
         this.m_gui.sub_staff.salary_waiter.text = "$ " + _loc3_ * Config.keepCosts["Waiter"];
         this.m_gui.sub_staff.salary_engineer.text = "$ " + _loc4_ * Config.keepCosts["Mechanic"];
      }

      private function RefreshRoomsWindow() : void
      {
         var _loc3_:* = null;
         var _loc4_:TextField = null;
         var _loc5_:TextField = null;
         var _loc6_:TextField = null;
         var _loc7_:TextField = null;
         var _loc8_:TextField = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc1_:Dictionary = this.m_gameLogic.GetGameStatus().prevMonthCosts;
         var _loc2_:Dictionary = this.m_gameLogic.GetGameStatus().prevMonthIncomes;
         for(_loc3_ in Config.buildCosts)
         {
            // V2: the new buildings have no row of their own, they are
            // added to the row of the building they derive from
            if(Config.templateAliases[_loc3_] != null)
            {
               continue;
            }
            _loc4_ = this.m_gui.sub_rooms.getChildByName("name_" + _loc3_) as TextField;
            if(_loc4_ == null)
            {
               continue;
            }
            _loc5_ = this.m_gui.sub_rooms.getChildByName("quant_" + _loc3_) as TextField;
            _loc6_ = this.m_gui.sub_rooms.getChildByName("total_income_" + _loc3_) as TextField;
            _loc7_ = this.m_gui.sub_rooms.getChildByName("keep_" + _loc3_) as TextField;
            _loc8_ = this.m_gui.sub_rooms.getChildByName("total_" + _loc3_) as TextField;
            _loc9_ = !!Config.EntityIsGuestRoom(_loc3_) ? (false, false, true, true, true, true, int(Config.GetRoomPrice(_loc3_,this.m_gameLogic))) : int(Config.GetServicePrice(_loc3_));
            _loc10_ = Config.keepCosts[_loc3_].toString();
            _loc11_ = this.m_gameLogic.GetWorldQuery().GetEntitiesByTemplateName(_loc3_).length;
            _loc12_ = Math.round(SumWithAliases(_loc2_,_loc3_));
            _loc13_ = Math.round(SumWithAliases(_loc1_,_loc3_));
            _loc14_ = _loc12_ - _loc13_;
            if(StarChecker.IsAllowedToBuild(_loc3_,this.m_gameLogic) || _loc11_ > 0)
            {
               _loc4_.visible = true;
               _loc5_.text = _loc11_.toString();
               _loc7_.text = "$ " + _loc13_;
               if(Boolean(Config.EntityIsGuestRoom(_loc3_)) || Config.GetServicePrice(_loc3_) > 0)
               {
                  _loc6_.text = "$ " + _loc12_;
                  _loc8_.htmlText = Config.ColorCodeMoney(_loc14_);
               }
               else
               {
                  _loc6_.text = "-";
                  _loc8_.htmlText = "-";
               }
            }
            else
            {
               _loc4_.visible = false;
               _loc5_.text = "";
               _loc6_.text = "";
               _loc7_.text = "";
               _loc8_.text = "";
            }
         }
      }

      private function RefreshChartWindow() : void
      {
         var _loc2_:Chart = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Rectangle = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.m_charts.length)
         {
            _loc2_ = this.m_charts[_loc1_];
            _loc3_ = Math.max(this.m_gameLogic.GetGameStatus().day - Config.daysInGraph,_loc2_.GetData().GetMinX("money"));
            if(isNaN(_loc3_))
            {
               _loc3_ = 0;
            }
            _loc4_ = graphRanges[_loc1_];
            _loc5_ = _loc2_.GetData().GetMaxY(graphNames[_loc1_],_loc3_,_loc3_ + Config.daysInGraph);
            while(_loc4_ < _loc5_)
            {
               _loc4_ *= 2;
            }
            _loc6_ = new Rectangle(_loc3_,0,Config.daysInGraph,_loc4_);
            _loc2_.SetRange(_loc6_);
            _loc2_.Render();
            _loc1_++;
         }
      }

      private function RefreshBudgetWindow() : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:* = null;
         var _loc10_:* = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc1_:Dictionary = this.m_gameLogic.GetGameStatus().prevMonthCosts;
         var _loc2_:Dictionary = this.m_gameLogic.GetGameStatus().prevMonthIncomes;
         var _loc3_:Boolean = _loc1_ != null && _loc2_ != null;
         var _loc4_:Date;
         (_loc4_ = new Date()).setTime(this.m_gameLogic.GetGameStatus().date.valueOf());
         if(_loc3_)
         {
            _loc4_.setMonth(_loc4_.getMonth() - 1);
            this.m_gui.sub_budget.budget_date.text = "Budget for " + Utils.GetMonthName(_loc4_.month) + " " + _loc4_.fullYear;
            _loc5_ = 0;
            _loc6_ = 0;
            _loc7_ = 0;
            _loc8_ = 0;
            var _loc13_:int = 0;
            var _loc14_:* = _loc1_;
            while(true)
            {
               for(_loc9_ in _loc14_)
               {
                  if(Config.EntityIsStaff(_loc9_))
                  {
                     _loc5_ += _loc1_[_loc9_];
                  }
                  else
                  {
                     _loc6_ += _loc1_[_loc9_];
                  }
               }
               break;
            }
            _loc13_ = 0;
            for(_loc10_ in _loc2_)
            {
               if(Config.EntityIsGuestRoom(_loc10_))
               {
                  _loc7_ += _loc2_[_loc10_];
               }
               else
               {
                  _loc8_ += _loc2_[_loc10_];
               }
            }
            _loc8_ = Math.round(_loc8_);
            _loc7_ = Math.round(_loc7_);
            _loc5_ = Math.round(_loc5_);
            _loc6_ = Math.round(_loc6_);
            _loc11_ = Math.round(this.m_gameLogic.GetGameStatus().prevMonthLoanPayment);
            _loc12_ = _loc8_ + _loc7_ - _loc5_ - _loc6_ - _loc11_;
            this.m_gui.sub_budget.total_salary.text = "- $ " + _loc5_;
            this.m_gui.sub_budget.total_keeping.text = "- $ " + _loc6_;
            this.m_gui.sub_budget.loan_pyments.text = "- $ " + _loc11_;
            this.m_gui.sub_budget.total_rooms_income.text = "+ $ " + _loc7_;
            this.m_gui.sub_budget.total_service_income.text = "+ $ " + _loc8_;
            this.m_gui.sub_budget.total_profit.htmlText = Config.ColorCodeMoney(_loc12_);
         }
         else
         {
            this.m_gui.sub_budget.budget_date.text = "Budget for " + Utils.GetMonthName(_loc4_.month) + " " + _loc4_.fullYear + " (in progress ...)";
            this.m_gui.sub_budget.total_salary.text = "n/a";
            this.m_gui.sub_budget.total_keeping.text = "n/a";
            this.m_gui.sub_budget.total_rooms_income.text = "n/a";
            this.m_gui.sub_budget.loan_pyments.text = "n/a";
            this.m_gui.sub_budget.total_service_income.text = "n/a";
            this.m_gui.sub_budget.total_profit.text = "n/a";
         }
      }

      override protected function DestroyControls() : void
      {
         var _loc1_:Chart = null;
         for each(_loc1_ in this.m_charts)
         {
            _loc1_.DestroyControls();
         }
         this.m_gui.parent.removeChild(this.m_gui);
         this.m_gui = null;
      }
   }
}
