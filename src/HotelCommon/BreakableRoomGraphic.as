package HotelCommon
{
   import FGKit.Graphics.MovieClipEx;
   import FGKit.Graphics.MovieClipGraphic;
   import FGKit.Utils;
   import FGKit.Properties.StringProperty;
   import flash.display.BitmapData;
   import flash.display.GradientType;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;

   public class BreakableRoomGraphic extends MovieClipGraphic
   {

      private var m_smokeAlphas:Array;

      private var m_smokeFrames:Array;

      private var s_smokeMC:MovieClipEx;

      // ---- V2: hand-drawn rooms (property "art"), currently only the Casino ----
      private static const ART_SCALE:Number = 2;

      private static var s_casinoStatic:BitmapData;

      private static var s_casinoDynamic:Shape;

      private static const CASINO_WIDTH:Number = 480;

      private static const CASINO_HEIGHT:Number = 60;

      private var m_artTime:Number = 0;

      private var m_artBounds:Rectangle;

      public function BreakableRoomGraphic()
      {
         this.s_smokeMC = new MovieClipEx(new MegaSmoke());
         super();
         AddProperty(StringProperty.Create("art",""));
      }

      private function GetArt() : String
      {
         var _loc1_:String = GetStringPropertyValue("art");
         return _loc1_ == null ? "" : _loc1_;
      }

      override public function GetLocalBounds() : Rectangle
      {
         if(this.GetArt() == "casino")
         {
            if(this.m_artBounds == null)
            {
               this.m_artBounds = new Rectangle(-1,-61,CASINO_WIDTH + 2,CASINO_HEIGHT + 2);
            }
            return this.m_artBounds;
         }
         return super.GetLocalBounds();
      }

      override public function IsUpdatable() : Boolean
      {
         return true;
      }

      override public function Update(param1:Number) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         super.Update(param1);
         this.m_artTime += param1;
         var _loc2_:BreakableBehaviour = GetEntity().GetBehaviourByClass(BreakableBehaviour) as BreakableBehaviour;
         var _loc3_:int = this.s_smokeMC.GetRawClip().totalFrames;
         if(this.m_smokeFrames == null)
         {
            this.m_smokeFrames = [];
            this.m_smokeAlphas = [];
            _loc4_ = 0;
            while(_loc4_ < _loc2_.GetBreakPositions().length)
            {
               this.m_smokeFrames.push(Number(Utils.RandomInt(1,_loc3_)));
               this.m_smokeAlphas.push(!!_loc2_.IsBroken(_loc4_) ? 1 : (true, true, 0));
               _loc4_++;
            }
         }
         _loc4_ = 0;
         while(true)
         {
            if(_loc4_ >= this.m_smokeFrames.length)
            {
               break;
            }
            this.m_smokeFrames[_loc4_] += param1 * 30;
            if(int(this.m_smokeFrames[_loc4_]) > _loc3_)
            {
               this.m_smokeFrames[_loc4_] -= _loc3_;
            }
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < this.m_smokeAlphas.length)
         {
            _loc5_ = !!_loc2_.IsBroken(_loc4_) ? (true, true, Number(1)) : Number(0);
            this.m_smokeAlphas[_loc4_] = Utils.AdvanceNumber(this.m_smokeAlphas[_loc4_],_loc5_,param1);
            _loc4_++;
         }
      }

      // V2: hook so that subclasses can draw the room body differently
      // (the Industrial Laundry draws a widened version of the Laundry)
      protected function RenderBody(param1:BitmapData, param2:Matrix, param3:Matrix) : void
      {
         if(this.GetArt() == "casino")
         {
            this.RenderCasino(param1,Utils.Concat(param2,param3));
            return;
         }
         super.Render(param1,param2,param3);
      }

      private function RenderCasino(param1:BitmapData, param2:Matrix) : void
      {
         if(s_casinoStatic == null)
         {
            s_casinoStatic = BuildCasinoStatic();
            s_casinoDynamic = new Shape();
         }
         // static art is cached at ART_SCALE, origin at (-1,-61) in room space
         var m:Matrix = new Matrix(1 / ART_SCALE,0,0,1 / ART_SCALE,-1,-61);
         m.concat(param2);
         param1.draw(s_casinoStatic,m,null,null,null,true);
         var g:* = s_casinoDynamic.graphics;
         g.clear();
         DrawCasinoDynamic(g,this.m_artTime);
         param1.draw(s_casinoDynamic,param2,null,null,null,true);
      }

      // ------------------------------------------------------------------
      // Casino art. Room space: x 0..480 (8 cells), y -60 (ceiling) .. 0 (floor)
      // ------------------------------------------------------------------

      private static const GOLD:uint = 0xF2C230;

      private static const GOLD_DARK:uint = 0xA87A12;

      private static const RED:uint = 0xC8102E;

      private static const RED_DARK:uint = 0x5E0812;

      private static function BuildCasinoStatic() : BitmapData
      {
         var root:Sprite = new Sprite();
         var art:Sprite = new Sprite();
         art.x = 1;
         art.y = 61;
         root.addChild(art);
         var g:* = art.graphics;
         var m:Matrix = new Matrix();
         var i:int = 0;
         var x:Number = 0;
         // wall
         m.createGradientBox(CASINO_WIDTH,52,Math.PI / 2,0,-60);
         g.beginGradientFill(GradientType.LINEAR,[0x6E0A14,0xA3121F,0x8A0E1A],[1,1,1],[0,150,255],m);
         g.drawRect(0,-60,CASINO_WIDTH,52);
         g.endFill();
         // damask-like wallpaper: gold diamonds
         g.beginFill(GOLD,0.13);
         for(x = 10; x < CASINO_WIDTH; x += 20)
         {
            g.moveTo(x,-50);
            g.lineTo(x + 5,-44);
            g.lineTo(x,-38);
            g.lineTo(x - 5,-44);
            g.lineTo(x,-50);
         }
         g.endFill();
         // ceiling band and gold cornice
         g.beginFill(0x3A0509,1);
         g.drawRect(0,-60,CASINO_WIDTH,6);
         g.endFill();
         g.beginFill(GOLD,1);
         g.drawRect(0,-54,CASINO_WIDTH,1.5);
         g.endFill();
         // wainscot
         g.beginFill(RED_DARK,1);
         g.drawRect(0,-22,CASINO_WIDTH,14);
         g.endFill();
         g.beginFill(GOLD,1);
         g.drawRect(0,-22.5,CASINO_WIDTH,1.2);
         g.endFill();
         g.lineStyle(0.6,GOLD_DARK,0.8);
         for(x = 4; x < CASINO_WIDTH - 20; x += 24)
         {
            g.drawRect(x,-19.5,20,9);
         }
         g.lineStyle();
         // red carpet with gold pattern and the red base line of every room
         g.beginFill(0x7A0C16,1);
         g.drawRect(0,-8,CASINO_WIDTH,8);
         g.endFill();
         g.beginFill(GOLD,0.55);
         for(x = 6; x < CASINO_WIDTH; x += 12)
         {
            g.drawCircle(x,-4.5,1);
         }
         g.endFill();
         g.beginFill(0xD00000,1);
         g.drawRect(0,-2,CASINO_WIDTH,2);
         g.endFill();
         // chandeliers
         DrawChandelier(g,130);
         DrawChandelier(g,280);
         DrawChandelier(g,430);
         // entrance: sign board and velvet rope
         g.beginFill(0x240306,1);
         g.lineStyle(1.5,GOLD,1);
         g.drawRoundRect(6,-51,56,17,6,6);
         g.endFill();
         g.lineStyle();
         DrawRopePost(g,12);
         DrawRopePost(g,54);
         g.lineStyle(2,RED,1);
         g.moveTo(12,-15);
         g.curveTo(33,-8,54,-15);
         g.lineStyle();
         // slot machines
         for(i = 0; i < 4; i++)
         {
            DrawSlotMachine(g,70 + i * 35,i);
         }
         // roulette table
         DrawRouletteTable(g);
         // blackjack table
         DrawBlackjackTable(g);
         // bar
         DrawBar(g);
         // room outline, like the other rooms
         g.lineStyle(1.5,0x9A9A9A,1);
         g.drawRect(0,-60,CASINO_WIDTH,60);
         g.lineStyle();
         // sign text
         var tf:TextField = new TextField();
         tf.embedFonts = true;
         tf.defaultTextFormat = new TextFormat("Cooper Black",11,GOLD);
         tf.autoSize = TextFieldAutoSize.LEFT;
         tf.text = "CASINO";
         tf.x = 1 + 34 - tf.width * 0.5;
         tf.y = 61 - 51 + 8.5 - tf.height * 0.5;
         root.addChild(tf);
         var bmp:BitmapData = new BitmapData(Math.ceil((CASINO_WIDTH + 2) * ART_SCALE),Math.ceil((CASINO_HEIGHT + 2) * ART_SCALE),true,0);
         bmp.draw(root,new Matrix(ART_SCALE,0,0,ART_SCALE,0,0),null,null,null,true);
         return bmp;
      }

      private static function DrawChandelier(g:*, x:Number) : void
      {
         var m:Matrix = new Matrix();
         m.createGradientBox(40,24,0,x - 20,-54);
         g.beginGradientFill(GradientType.RADIAL,[0xFFE7A0,0xFFE7A0],[0.35,0],[0,255],m);
         g.drawEllipse(x - 20,-54,40,24);
         g.endFill();
         g.lineStyle(0.8,GOLD,1);
         g.moveTo(x,-54);
         g.lineTo(x,-50);
         g.lineStyle();
         g.beginFill(GOLD,1);
         g.drawEllipse(x - 7,-50,14,3);
         g.endFill();
         g.beginFill(0xFFF6D0,1);
         g.drawCircle(x - 6,-51,1.2);
         g.drawCircle(x,-51.5,1.2);
         g.drawCircle(x + 6,-51,1.2);
         g.endFill();
      }

      private static function DrawRopePost(g:*, x:Number) : void
      {
         g.beginFill(GOLD,1);
         g.drawRect(x - 1,-16,2,14);
         g.drawEllipse(x - 3,-3,6,2);
         g.drawCircle(x,-17,2);
         g.endFill();
      }

      private static function DrawSlotMachine(g:*, x:Number, index:int) : void
      {
         var m:Matrix = new Matrix();
         // body
         m.createGradientBox(28,34,0,x,-40);
         g.beginGradientFill(GradientType.LINEAR,[0x8E0B1F,RED,0x8E0B1F],[1,1,1],[0,128,255],m);
         g.lineStyle(1,GOLD_DARK,1);
         g.drawRoundRect(x,-40,28,34,6,6);
         g.endFill();
         // top light housing
         g.beginFill(GOLD,1);
         g.drawRoundRect(x + 4,-45,20,6,5,5);
         g.endFill();
         g.lineStyle();
         // screen with 3 reels
         g.beginFill(0x1A0204,1);
         g.drawRoundRect(x + 3,-35,22,11,3,3);
         g.endFill();
         var r:int = 0;
         for(r = 0; r < 3; r++)
         {
            g.beginFill(0xFFF8E8,1);
            g.drawRect(x + 4.5 + r * 7,-33.5,6,8);
            g.endFill();
         }
         // symbols: 7, cherry, bar
         var sym:int = 0;
         for(r = 0; r < 3; r++)
         {
            sym = (index + r) % 3;
            var cx:Number = x + 7.5 + r * 7;
            if(sym == 0)
            {
               g.lineStyle(1.3,RED,1);
               g.moveTo(cx - 1.8,-32);
               g.lineTo(cx + 1.8,-32);
               g.lineTo(cx - 0.5,-27);
               g.lineStyle();
            }
            else if(sym == 1)
            {
               g.lineStyle(0.6,0x2E7D32,1);
               g.moveTo(cx - 1,-28.5);
               g.lineTo(cx + 0.5,-32);
               g.lineTo(cx + 1.5,-28.5);
               g.lineStyle();
               g.beginFill(0xD50000,1);
               g.drawCircle(cx - 1.2,-28,1.3);
               g.drawCircle(cx + 1.6,-28,1.3);
               g.endFill();
            }
            else
            {
               g.beginFill(0x222222,1);
               g.drawRect(cx - 2.2,-30.5,4.4,2);
               g.endFill();
            }
         }
         // coin tray and buttons
         g.beginFill(GOLD,1);
         g.drawRect(x + 5,-21,18,2);
         g.endFill();
         g.beginFill(0x1A0204,1);
         g.drawRect(x + 6,-12,16,4);
         g.endFill();
         g.beginFill(0x40C4FF,1);
         g.drawCircle(x + 8,-17,1.2);
         g.endFill();
         g.beginFill(0xFFEB3B,1);
         g.drawCircle(x + 14,-17,1.2);
         g.endFill();
         g.beginFill(0x76FF03,1);
         g.drawCircle(x + 20,-17,1.2);
         g.endFill();
         // lever
         g.lineStyle(1.4,0xC9C9C9,1);
         g.moveTo(x + 28,-26);
         g.lineTo(x + 31,-26);
         g.lineTo(x + 31,-36);
         g.lineStyle();
         g.beginFill(RED,1);
         g.drawCircle(x + 31,-37.5,2);
         g.endFill();
         // base
         g.beginFill(0x2A0306,1);
         g.drawRect(x + 1,-6,26,4);
         g.endFill();
      }

      private static function DrawRouletteTable(g:*) : void
      {
         var m:Matrix = new Matrix();
         // legs
         g.beginFill(0x4E2A0E,1);
         g.drawRect(220,-14,4,12);
         g.drawRect(318,-14,4,12);
         g.endFill();
         // table side (wood) and gold edge
         m.createGradientBox(110,8,Math.PI / 2,216,-20);
         g.beginGradientFill(GradientType.LINEAR,[0x7B4214,0x4E2A0E],[1,1],[0,255],m);
         g.drawRoundRect(216,-20,110,8,4,4);
         g.endFill();
         g.beginFill(GOLD,1);
         g.drawRect(216,-21,110,1.2);
         g.endFill();
         // felt seen slightly from above
         g.beginFill(0x0B6E2E,1);
         g.lineStyle(1,GOLD_DARK,1);
         g.drawRoundRect(218,-27,106,7,6,6);
         g.endFill();
         g.lineStyle(0.5,0xE8F5E9,0.8);
         var x:Number = 0;
         for(x = 262; x <= 318; x += 8)
         {
            g.moveTo(x,-26);
            g.lineTo(x,-21);
         }
         g.moveTo(258,-23.5);
         g.lineTo(320,-23.5);
         g.lineStyle();
         // wheel bowl (the spinning part is drawn every frame)
         g.beginFill(0x4E2A0E,1);
         g.lineStyle(1,GOLD,1);
         g.drawEllipse(224,-31,32,10);
         g.endFill();
         g.lineStyle();
      }

      private static function DrawBlackjackTable(g:*) : void
      {
         var m:Matrix = new Matrix();
         g.beginFill(0x4E2A0E,1);
         g.drawRect(345,-14,4,12);
         g.drawRect(417,-14,4,12);
         g.endFill();
         m.createGradientBox(90,8,Math.PI / 2,338,-20);
         g.beginGradientFill(GradientType.LINEAR,[0x7B4214,0x4E2A0E],[1,1],[0,255],m);
         g.drawRoundRect(338,-20,90,8,4,4);
         g.endFill();
         g.beginFill(GOLD,1);
         g.drawRect(338,-21,90,1.2);
         g.endFill();
         // half-moon felt
         g.beginFill(0x0B6E2E,1);
         g.lineStyle(1,GOLD_DARK,1);
         g.moveTo(340,-21);
         g.curveTo(383,-34,426,-21);
         g.lineTo(340,-21);
         g.endFill();
         g.lineStyle();
         // cards
         var c:int = 0;
         for(c = 0; c < 4; c++)
         {
            g.beginFill(0xFFFFFF,1);
            g.lineStyle(0.4,0x999999,1);
            g.drawRect(356 + c * 16,-25,5,3.5);
            g.endFill();
            g.lineStyle();
            g.beginFill(c % 2 == 0 ? 0xD50000 : 0x111111,1);
            g.drawCircle(358.5 + c * 16,-23.2,0.8);
            g.endFill();
         }
         // chip stacks
         var colors:Array = [0xD50000,0x1565C0,0x111111,0x2E7D32,0xF2C230];
         for(c = 0; c < 5; c++)
         {
            var h:int = 2 + c % 3;
            var k:int = 0;
            for(k = 0; k < h; k++)
            {
               g.beginFill(colors[c],1);
               g.lineStyle(0.3,0xFFFFFF,0.8);
               g.drawEllipse(372 + c * 6,-24.5 - k * 1.2,4.5,1.6);
               g.endFill();
            }
         }
         g.lineStyle();
         // dealer's shoe
         g.beginFill(0x3E2723,1);
         g.drawRect(405,-27,8,4);
         g.endFill();
      }

      private static function DrawBar(g:*) : void
      {
         var m:Matrix = new Matrix();
         // shelf with bottles on the wall
         g.beginFill(GOLD_DARK,1);
         g.drawRect(440,-40,36,1.5);
         g.endFill();
         var colors:Array = [0x2E7D32,0x8D6E63,0x1565C0,0xF9A825,0x6A1B9A,0xC62828];
         var b:int = 0;
         for(b = 0; b < 6; b++)
         {
            g.beginFill(colors[b],0.95);
            g.drawRoundRect(442 + b * 5.6,-48,3.4,8,2,2);
            g.drawRect(443 + b * 5.6,-50.5,1.4,3);
            g.endFill();
         }
         // counter
         m.createGradientBox(38,16,0,439,-20);
         g.beginGradientFill(GradientType.LINEAR,[0x4E2A0E,0x7B4214,0x4E2A0E],[1,1,1],[0,128,255],m);
         g.drawRect(439,-19,38,17);
         g.endFill();
         g.beginFill(GOLD,1);
         g.drawRect(437,-21,42,2.2);
         g.endFill();
         g.lineStyle(0.6,GOLD_DARK,1);
         g.drawRect(443,-15,13,10);
         g.drawRect(460,-15,13,10);
         g.lineStyle();
         // glasses
         g.beginFill(0xE0F7FA,0.85);
         g.drawRect(446,-25,2.5,4);
         g.drawRect(467,-25,2.5,4);
         g.endFill();
      }

      // animated parts: blinking bulbs, slot lights and the roulette wheel
      private static function DrawCasinoDynamic(g:*, t:Number) : void
      {
         var i:int = 0;
         var on:Boolean = false;
         // bulbs around the sign
         for(i = 0; i < 12; i++)
         {
            on = (int(t * 4) + i) % 2 == 0;
            var bx:Number = i < 6 ? 9 + i * 10 : 9 + (i - 6) * 10;
            var by:Number = i < 6 ? -51 : -34;
            g.beginFill(on ? 0xFFF59D : 0x8D6E1A,1);
            g.drawCircle(bx,by,1.1);
            g.endFill();
         }
         // slot machine top lights
         for(i = 0; i < 4; i++)
         {
            on = (int(t * 3) + i) % 3 != 0;
            g.beginFill(on ? 0xFFEB3B : 0x9E7B10,1);
            g.drawCircle(70 + i * 35 + 14,-42,1.8);
            g.endFill();
            if(on)
            {
               g.beginFill(0xFFF59D,0.25);
               g.drawCircle(70 + i * 35 + 14,-42,4);
               g.endFill();
            }
         }
         // roulette wheel: 12 alternating segments rotating
         var cx:Number = 240;
         var cy:Number = -26;
         var a0:Number = t * 3;
         for(i = 0; i < 12; i++)
         {
            var a1:Number = a0 + i * Math.PI / 6;
            var a2:Number = a1 + Math.PI / 6;
            g.beginFill(i == 0 ? 0x1B8E3A : (i % 2 == 0 ? 0xC8102E : 0x151515),1);
            g.moveTo(cx,cy);
            g.lineTo(cx + Math.cos(a1) * 13,cy + Math.sin(a1) * 4);
            g.lineTo(cx + Math.cos(a2) * 13,cy + Math.sin(a2) * 4);
            g.lineTo(cx,cy);
            g.endFill();
         }
         g.beginFill(GOLD,1);
         g.drawEllipse(cx - 3,cy - 1.2,6,2.4);
         g.endFill();
         // the ball
         g.beginFill(0xFFFFFF,1);
         g.drawCircle(cx + Math.cos(-t * 5) * 11,cy + Math.sin(-t * 5) * 3.4,0.9);
         g.endFill();
      }

      override public function Render(param1:BitmapData, param2:Matrix, param3:Matrix) : void
      {
         var _loc7_:Matrix = null;
         this.RenderBody(param1,param2,param3);
         var _loc4_:BreakableBehaviour;
         if((_loc4_ = GetEntity().GetBehaviourByClass(BreakableBehaviour) as BreakableBehaviour) == null || this.m_smokeAlphas == null)
         {
            return;
         }
         var _loc5_:Array = _loc4_.GetBreakPositions();
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_.length)
         {
            if(this.m_smokeAlphas[_loc6_] > 0)
            {
               _loc7_ = Utils.Concat(param2,param3);
               Utils.PreTranslateMatrix(_loc5_[_loc6_].x,_loc5_[_loc6_].y,_loc7_);
               this.s_smokeMC.Render(param1,this.m_smokeFrames[_loc6_],_loc7_,true,new ColorTransform(1,1,1,this.m_smokeAlphas[_loc6_]),null,true);
            }
            _loc6_++;
         }
      }
   }
}
