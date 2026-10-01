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

      // V2: extra buildings, appended to the original entity templates.
      // They only use existing graphics/behaviour classes (see Config.templateAliases).
      private static const V2_TEMPLATES:String = "" +
         "<template friendlyName=\"Room_Eco\" group=\"Common\" layer=\"100\" name=\"Room_Eco\">" +
            "<graphic className=\"HotelCommon::RoomGraphic\"><properties movieClip=\"Room Single\" tint=\"0.80,0.92,0.80,0,10,0\"/></graphic>" +
            "<behaviour className=\"HotelCommon::RoomBehaviour\"/>" +
         "</template>" +
         "<template friendlyName=\"Room_Royal\" group=\"Common\" layer=\"100\" name=\"Room_Royal\">" +
            "<graphic className=\"HotelCommon::PresidentLuxGraphic\"><properties movieClip=\"Room Pr\" tint=\"1.10,0.95,0.55,30,18,0\"/></graphic>" +
            "<behaviour className=\"HotelCommon::RoomBehaviour\"/>" +
         "</template>" +
         "<template friendlyName=\"Laundry_XL\" group=\"Common\" layer=\"100\" name=\"Laundry_XL\">" +
            "<graphic className=\"HotelCommon::LaundryGraphic\"><properties movieClip=\"Laundry\" useBaseScales=\"true\" industrial=\"true\"/></graphic>" +
            "<behaviour className=\"HotelCommon::LaundryBehaviour\"><properties guestFlips=\"0,0,0,0,0,0\" guestPositions=\"122,162,202,242,282,322\" queueRange=\"10 100\"/></behaviour>" +
            "<behaviour className=\"HotelCommon::BreakableBehaviour\"><properties breakPoints=\"145 -33,185 -33,225 -33,265 -33,305 -33,345 -33\"/></behaviour>" +
         "</template>";

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
         var _loc1_:XMLDocument = new XMLDocument(Templates_xml.data.toXMLString().replace("</templates>",V2_TEMPLATES + "</templates>"));
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
         return "2.2";
      }
   }
}
