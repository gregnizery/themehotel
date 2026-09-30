package Hotel
{
   import FGKit.AppStates.StateManager;
   import FGKit.Application;
   import FGKit.CrossFader;
   import FGKit.MainTimer;
   import FGKit.MainWindow;
   import FGKit.Tracker.Tracker;
   import FGKit.World.EntityTemplatesManager;
   import Hotel.AppStates.GamesFreeSplashState;
   import Hotel.AppStates.LevelState;
   import Hotel.AppStates.MainMenuState;
   import Hotel.AppStates.StartupState;
   import HotelCommon.RegisterClasses;
   import HotelCommon.Resources;
   import flash.xml.XMLDocument;

   public class Application extends FGKit.Application
   {

      public static const Templates_xml:Class = Application_Templates_xml;

      {
      }

      private var m_stateManager:StateManager;

      private var m_crossFader:CrossFader;

      public function Application(param1:FGKit.MainWindow)
      {
         super(param1);
      }

      public static function Instance() : Hotel.Application
      {
         return FGKit.Application.Instance() as Hotel.Application;
      }

      override public function Initialize() : void
      {
         super.Initialize();
         RegisterClasses.Do();
         Resources.Register();
         this.m_crossFader = new CrossFader(4278190080);
         var _loc1_:XMLDocument = new XMLDocument(Templates_xml.data.toXMLString());
         EntityTemplatesManager.Instance().Load(_loc1_);
         this.m_stateManager = new StateManager();
         this.m_stateManager.AddState("mainmenu",new MainMenuState());
         this.m_stateManager.AddState("level",new LevelState());
         this.m_stateManager.AddState("startup",new StartupState());
         this.m_stateManager.AddState("splash",new GamesFreeSplashState());
         MainTimer.Instance().UseFixedDt(true);
         this.m_stateManager.SetCurrentState("startup",null);
         Tracker.Play();
      }

      public function GetStateManager() : StateManager
      {
         return this.m_stateManager;
      }

      override public function GetAppName() : String
      {
         return "Hotel";
      }

      override public function GetAppVersion() : String
      {
         return "2.1";
      }
   }
}
