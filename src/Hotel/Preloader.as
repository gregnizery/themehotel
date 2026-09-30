package Hotel
{
   import FGKit.Preloader;
   import Hotel.Objects.Preloader;
   import flash.display.DisplayObject;
   import flash.utils.getDefinitionByName;

   public class Preloader extends FGKit.Preloader
   {

      public static const Cursor_png:Class = Preloader_Cursor_png;

      private var m_gui:Hotel.Objects.Preloader;

      public function Preloader()
      {
         super();
         // V2: removed the call-home tracking request (track.g-bot.net) and the
         // dead sponsor link. The game now runs fully offline.
         this.m_gui = new Hotel.Objects.Preloader();
         this.m_gui.loading_bar.bar.width = 0;
         this.m_gui.sponsor_logo.visible = false;
         addChild(this.m_gui);
      }

      override protected function OnProgressChanged() : void
      {
         this.m_gui.loading_bar.bar.width = GetProgress() * 360;
      }

      override protected function OnLoadComplete() : void
      {
         this.Startup();
      }

      private function Startup() : void
      {
         removeChild(this.m_gui);
         var _loc1_:Class = getDefinitionByName("Hotel.MainWindow") as Class;
         addChild(new _loc1_() as DisplayObject);
      }
   }
}
