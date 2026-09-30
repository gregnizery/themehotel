package HotelCommon
{
   import FGKit.Utils;
   import FGKit.World.Entity;

   public class GuestSpawner
   {

      private var m_gameLogic:HotelGameLogic;

      private var m_spawnTimer:Number = 0;

      // V2 random events: guests arriving by tourist bus, spawned one by one
      private var m_busGuests:int = 0;

      private var m_busTimer:Number = 0;

      public function GuestSpawner(param1:HotelGameLogic)
      {
         super();
         this.m_gameLogic = param1;
      }

      private function SpawnGuest() : void
      {
         var _loc1_:Entity = new Entity(this.m_gameLogic.GetWorld().GetEntityTemplates().GetTemplateByFriendlyName("Guest"));
         _loc1_.SetPositionXY(Config.GetGuestAppearPosition(this.m_gameLogic),this.m_gameLogic.GetWorld().GetHeight() - Config.groundHeight - Config.personFloorShift);
         PersonAppearance.Randomize(_loc1_);
         (_loc1_.GetBehaviourByClass(GuestBehaviour) as GuestBehaviour).RandomizeDesires();
         _loc1_.GetGraphic().SetBoolPropertyValue("hasBag",true);
         this.m_gameLogic.GetWorld().AddEntity(_loc1_);
      }

      public function AddBusGuests(param1:int) : void
      {
         this.m_busGuests += param1;
      }

      public function Update(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         if(this.m_busGuests > 0)
         {
            this.m_busTimer -= param1;
            if(this.m_busTimer <= 0)
            {
               this.m_busTimer = 0.6;
               this.m_busGuests--;
               if(this.m_gameLogic.GetWorldQuery().GetTotalGuestsCount() < this.m_gameLogic.GetWorldQuery().GetTotalGuestRoomsCount())
               {
                  this.SpawnGuest();
               }
            }
         }
         this.m_spawnTimer -= param1;
         while(this.m_spawnTimer <= 0)
         {
            _loc2_ = this.m_gameLogic.GetWorldQuery().GetTotalGuestsCount();
            _loc3_ = this.m_gameLogic.GetWorldQuery().GetTotalGuestRoomsCount();
            if(_loc2_ >= _loc3_)
            {
               this.m_spawnTimer = 2;
               break;
            }
            this.SpawnGuest();
            _loc4_ = this.CalcGuestInterval();
            this.m_spawnTimer += _loc4_;
         }
      }

      public function CalcGuestInterval() : Number
      {
         var _loc1_:int = this.m_gameLogic.GetWorldQuery().GetTotalGuestsCount();
         var _loc2_:Number = Config.GetGuestSpawnInterval(this.m_gameLogic.GetTargetGuestCount(),_loc1_);
         return Utils.Clamp(_loc2_,0.1,20) * Utils.Random(0.7,1.4) / this.m_gameLogic.GetGuestRateBoost();
      }
   }
}
