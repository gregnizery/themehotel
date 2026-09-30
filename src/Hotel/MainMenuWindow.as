package Hotel
{
   import FGKit.Tracker.Tracker;
   import Hotel.Objects.Main_Menu;
   import HotelCommon.GUI.NewHotelNameWindow;
   import HotelCommon.GUI.Window;
   import HotelCommon.Music;
   import HotelCommon.Sounds;
   import HotelCommon.GUI.InGameGui;
   import flash.display.GradientType;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.text.TextField;

   public class MainMenuWindow extends Window
   {

      private var m_gui:Main_Menu;

      private var m_controlsBtn:Sprite;

      private var m_help:Sprite;

      public function MainMenuWindow()
      {
         super();
      }

      override protected function CreateControls() : void
      {
         this.m_gui = new Main_Menu();
         m_container.addChild(this.m_gui);
         this.ApplyV2Layout();
         this.m_gui.new_game.addEventListener(MouseEvent.CLICK,this.OnNewGameClicked,false,0,true);
         this.m_gui.load_game.addEventListener(MouseEvent.CLICK,this.OnLoadGameClicked,false,0,true);
         this.m_gui.credits.addEventListener(MouseEvent.CLICK,this.OnCreditsClicked,false,0,true);
         this.m_gui.music_on.visible = Music.Instance().IsEnabled();
         this.m_gui.music_off.visible = !Music.Instance().IsEnabled();
         this.m_gui.sound_on.visible = Sounds.IsEnabled();
         this.m_gui.sound_off.visible = !Sounds.IsEnabled();
         this.m_gui.music_on.addEventListener(MouseEvent.CLICK,this.OnMusicToggle,false,0,true);
         this.m_gui.music_off.addEventListener(MouseEvent.CLICK,this.OnMusicToggle,false,0,true);
         this.m_gui.sound_on.addEventListener(MouseEvent.CLICK,this.OnSoundToggle,false,0,true);
         this.m_gui.sound_off.addEventListener(MouseEvent.CLICK,this.OnSoundToggle,false,0,true);
      }

      private function OnNewGameClicked(param1:Event) : void
      {
         Tracker.Message("NewGame clicked");
         PushDialog(new NewHotelNameWindow());
      }

      private function OnLoadGameClicked(param1:Event) : void
      {
         Tracker.Message("LoadGame clicked");
         if(m_dialog != null)
         {
            PopDialog(m_dialog);
         }
         PushDialog(new LoadWindow());
      }

      private function OnCreditsClicked(param1:Event) : void
      {
         Tracker.Message("Credits clicked");
         if(m_dialog != null)
         {
            PopDialog(m_dialog);
         }
         PushDialog(new CreditsWindow());
      }

      private function OnMusicToggle(param1:Event) : void
      {
         Music.Instance().Toggle();
         this.m_gui.music_on.visible = Music.Instance().IsEnabled();
         this.m_gui.music_off.visible = !Music.Instance().IsEnabled();
         Tracker.Message("Music enabled=" + Music.Instance().IsEnabled());
      }

      private function OnSoundToggle(param1:Event) : void
      {
         Sounds.Toggle();
         this.m_gui.sound_on.visible = Sounds.IsEnabled();
         this.m_gui.sound_off.visible = !Sounds.IsEnabled();
         Tracker.Message("Sounds enabled=" + Sounds.IsEnabled());
      }

      // V2: the "More Games" portal and sponsor logo are gone. Credits moves
      // up one slot and a new "Controls" button takes the last slot.
      private function ApplyV2Layout() : void
      {
         var _loc1_:Rectangle = this.m_gui.more_games.getBounds(this.m_gui);
         var _loc2_:Number = this.m_gui.credits.y - this.m_gui.more_games.y;
         this.m_gui.more_games.visible = false;
         this.m_gui.sponsorBtn.visible = false;
         this.m_gui.credits.y = this.m_gui.more_games.y;
         // bounds include the button's drop shadow: inset to match the other buttons
         this.m_controlsBtn = this.CreateButton("Controls",_loc1_.width - 13,_loc1_.height - 4);
         this.m_controlsBtn.x = _loc1_.x + 6;
         this.m_controlsBtn.y = _loc1_.y + _loc2_ + 1;
         this.m_controlsBtn.addEventListener(MouseEvent.CLICK,this.OnControlsClicked,false,0,true);
         this.m_gui.addChild(this.m_controlsBtn);
         var _loc3_:Sprite = new Sprite();
         _loc3_.graphics.lineStyle(2,16777215,1);
         _loc3_.graphics.beginFill(14163968,1);
         _loc3_.graphics.drawRoundRect(-58,-15,116,30,16,16);
         _loc3_.graphics.endFill();
         var _loc4_:TextField = InGameGui.CreateLabel("V2 Edition",17,16777215);
         _loc4_.x = -int(_loc4_.width * 0.5);
         _loc4_.y = -int(_loc4_.height * 0.5);
         _loc3_.addChild(_loc4_);
         _loc3_.x = 612;
         _loc3_.y = 128;
         _loc3_.rotation = -8;
         _loc3_.mouseEnabled = false;
         _loc3_.mouseChildren = false;
         _loc3_.filters = [new DropShadowFilter(3,45,0,0.5,4,4)];
         this.m_gui.addChild(_loc3_);
      }

      private function CreateButton(param1:String, param2:Number, param3:Number) : Sprite
      {
         var _loc4_:Sprite = new Sprite();
         var _loc5_:Matrix = new Matrix();
         _loc5_.createGradientBox(param2,param3,Math.PI / 2);
         _loc4_.graphics.lineStyle(2,1394032,1);
         _loc4_.graphics.beginGradientFill(GradientType.LINEAR,[7516895,2518203],[1,1],[0,255],_loc5_);
         _loc4_.graphics.drawRoundRect(1,1,param2 - 2,param3 - 2,18,18);
         _loc4_.graphics.endFill();
         var _loc6_:TextField = InGameGui.CreateLabel(param1,22,16777215);
         _loc6_.x = int((param2 - _loc6_.width) * 0.5);
         _loc6_.y = int((param3 - _loc6_.height) * 0.5);
         _loc4_.addChild(_loc6_);
         _loc4_.buttonMode = true;
         _loc4_.mouseChildren = false;
         _loc4_.addEventListener(MouseEvent.MOUSE_OVER,this.OnButtonOver,false,0,true);
         _loc4_.addEventListener(MouseEvent.MOUSE_OUT,this.OnButtonOut,false,0,true);
         return _loc4_;
      }

      private function OnButtonOver(param1:MouseEvent) : void
      {
         (param1.currentTarget as Sprite).transform.colorTransform = new ColorTransform(1.15,1.15,1.15,1,20,20,20,0);
      }

      private function OnButtonOut(param1:MouseEvent) : void
      {
         (param1.currentTarget as Sprite).transform.colorTransform = new ColorTransform();
      }

      private function OnControlsClicked(param1:Event) : void
      {
         if(this.m_help != null)
         {
            return;
         }
         this.m_help = InGameGui.CreateHelpPanel(false);
         this.m_help.addEventListener(MouseEvent.CLICK,this.OnHelpClosed,false,0,true);
         m_container.addChild(this.m_help);
      }

      private function OnHelpClosed(param1:Event) : void
      {
         if(this.m_help != null)
         {
            this.m_help.parent.removeChild(this.m_help);
            this.m_help = null;
         }
      }

      override protected function DestroyControls() : void
      {
         this.OnHelpClosed(null);
         this.m_gui.parent.removeChild(this.m_gui);
      }
   }
}
