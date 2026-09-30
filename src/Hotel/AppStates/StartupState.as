package Hotel.AppStates
{
   import FGKit.AppStates.AppState;
   import FGKit.MainWindow;
   import Hotel.Application;
   import Hotel.Objects.Preloader;
   import Hotel.Objects.Sound_Window;
   import HotelCommon.Music;
   import HotelCommon.Sounds;
   import flash.events.Event;
   import flash.events.MouseEvent;

   public class StartupState extends AppState
   {

      private var m_gui:Sound_Window;

      private var m_back:Preloader;

      public function StartupState()
      {
         super();
      }

      override public function OnEnter(param1:Object) : void
      {
         var _loc2_:MainWindow = Application.Instance().GetMainWindow();
         this.m_back = new Preloader();
         _loc2_.addChild(this.m_back);
         this.m_back.loading_bar.visible = false;
         this.m_gui = new Sound_Window();
         _loc2_.addChild(this.m_gui);
         this.m_gui.y = 70;
         this.m_gui.sound_yes.addEventListener(MouseEvent.CLICK,this.OnYesClick,false,0,true);
         this.m_gui.sound_no.addEventListener(MouseEvent.CLICK,this.OnNoClick,false,0,true);
      }

      private function Start() : void
      {
         // V2: skip the defunct sponsor splash screen and go straight to the menu
         Application.Instance().GetStateManager().SetCurrentState("mainmenu",null);
      }

      private function OnYesClick(param1:Event) : void
      {
         this.Start();
      }

      private function OnNoClick(param1:Event) : void
      {
         Sounds.SetEnabled(false);
         Music.Instance().SetEnabled(false);
         this.Start();
      }

      override public function OnLeave() : void
      {
         this.m_gui.parent.removeChild(this.m_gui);
         this.m_gui = null;
         this.m_back.parent.removeChild(this.m_back);
         this.m_back = null;
      }
   }
}
