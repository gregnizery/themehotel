package HotelCommon
{
   import FGKit.Utils;
   import FGKit.World.Entity;

   public class Config
   {

      public static const minStayTime:Number = 140;

      public static const maxStayTime:Number = 200;

      public static const stayTimeShift:Number = 60;

      public static const avgStayTime:Number = (maxStayTime + minStayTime) * 0.5 + stayTimeShift;

      public static const staffTemplates:Array = ["Receptionist","Cleaner","Waiter","Mechanic"];

      public static const staffDescriptions:Object = {
         "Receptionist":"Works at reception. Performs checkin and checkout for guests",
         "Cleaner":"Cleans rooms. Keeps the hotel tidy",
         "Waiter":"Serves at cafes and restaurants",
         "Mechanic":"Fixes broken facilities"
      };

      public static const daysToIncreaseStars:int = 30;

      public static const starBuildRequirements:Object = {
         "Room":0,
         "Elevator":0,
         "Reception":0,
         "Laundry":0,
         "Cafe":0,
         "Arcade":1,
         "Gym":1,
         "ServiceElevator":1,
         "Internet":1,
         "Bowling":2,
         "Elevator10":2,
         "RoofCafe":2,
         "BeautySalon":2,
         "Room_Lux":3,
         "Cinema":3,
         "Pool":3,
         "Room_Lux_Pr":4,
         "DiscoBar":4,
         "Restaurant":4,
         "Room_Eco":0,
         "Laundry_XL":1,
         "Room_Royal":4,
         "Casino":4
      };

      public static const timeOutForMissingServicePenalties:Object = {
         "Laundry":0,
         "Cafe":20,
         "Arcade":50,
         "Internet":100,
         "Gym":150,
         "Bowling":50,
         "RoofCafe":100,
         "BeautySalon":150,
         "Cinema":50,
         "Pool":100,
         "Room_Lux":10,
         "DiscoBar":50,
         "Restaurant":100,
         "Room_Lux_Pr":10
      };

      public static var starAchieveCriteria:Array = [{
         "money":10000,
         "rooms":20,
         "reputation":550
      },{
         "money":30000,
         "rooms":40,
         "reputation":600
      },{
         "money":50000,
         "rooms":60,
         "reputation":650
      },{
         "money":100000,
         "rooms":90,
         "reputation":700
      },{
         "money":200000,
         "rooms":150,
         "reputation":750
      },{
         "money":200000,
         "rooms":150,
         "reputation":750
      }];

      private static const roomPrices:Object = {
         "Room":6,
         "Room_Lux":30,
         "Room_Lux_Pr":90,
         "Room_Eco":4,
         "Room_Royal":180
      };

      private static const servicePrices:Object = {
         "Laundry":3 * 10,
         "Laundry_XL":3 * 10,
         "Casino":2000,
         "Cafe":4 * 10,
         "Arcade":9 * 30,
         "Gym":7 * 30,
         "Internet":4.5 * 30,
         "RoofCafe":22 * 30 / 4,
         "Bowling":13 * 30,
         "Pool":36 * 30,
         "BeautySalon":18 * 30,
         "Restaurant":72 * 30 / 4,
         "DiscoBar":71 * 30,
         "Cinema":40 * 30
      };

      public static var keepCosts:Object = {
         "Room":20,
         "Elevator":200,
         "Reception":200,
         "Laundry":80,
         "Cafe":120,
         "Arcade":400,
         "Gym":320,
         "ServiceElevator":400,
         "Internet":200,
         "RoofCafe":1000,
         "Bowling":610,
         "Pool":40 * 4,
         "Elevator10":1000,
         "Room_Lux":100,
         "BeautySalon":800,
         "Restaurant":800 * 4,
         "DiscoBar":850 * 4,
         "Room_Lux_Pr":300,
         "Cinema":450 * 4,
         "Room_Eco":10,
         "Laundry_XL":120,
         "Room_Royal":700,
         "Casino":3100,
         "Waiter":300,
         "Cleaner":200,
         "Receptionist":400,
         "Mechanic":500
      };

      public static var roomDescriptions:Object = {
         "Room":"Standard single room",
         "Elevator":"Elevator with 5 persons capacity",
         "Reception":"A service where guests check in and check out. Requires receptionist",
         "Laundry":"A room with automatic washing machines, where guests can launder their clothes",
         "Cafe":"Small but neat cafe with tasty food and affordable prices. Requires waiter",
         "Arcade":"A room with playing machines for entertaining your guests",
         "Gym":"Excercise room with treadmills for athletic guests who wants to work out",
         "ServiceElevator":"Elevator used by hotel staff decreases workload of guest elevators",
         "Internet":"Cyber cafe, where guests can get access to the internet",
         "RoofCafe":"Fashionable cafe with panoramic view and good menu. Requires waiter",
         "Bowling":"Modern automatic bowling lane for maximum fun",
         "Pool":"Swimming pool with comfortable deck chairs for total relax",
         "Elevator10":"Big elevator, with 10 persons capacity",
         "Room_Lux":"Enhanced room for rich guests with high expectations",
         "BeautySalon":"A room for guests, who cares on their appearance",
         "Restaurant":"Luxury restaurant for high-ranking guests. Requires waiter",
         "DiscoBar":"A club where guests can relax and dance",
         "Room_Lux_Pr":"VIP class room for the most pretentious guests",
         "Cinema":"State-of-the-art cinema",
         "Room_Eco":"Basic room at a low price. Cheap to build and to keep, but earns less per night",
         "Laundry_XL":"Industrial laundry: 6 washing machines instead of 4, takes 6 cells instead of 4",
         "Room_Royal":"Golden suite for royalty. Very expensive, but earns twice as much as the Presidential Lux",
         "Casino":"Red and gold casino with slot machines, roulette, blackjack and a bar. Guests looking for fun play here"
      };

      public static var buildCosts:Object = {
         "Room":500,
         "Elevator":5000,
         "Reception":5000,
         "Laundry":2000,
         "Cafe":3000,
         "Arcade":10000,
         "Gym":8000,
         "ServiceElevator":10000,
         "Internet":5000,
         "RoofCafe":25000,
         "Bowling":15000,
         "Pool":40000,
         "Elevator10":25000,
         "Room_Lux":2500,
         "BeautySalon":20000,
         "Restaurant":80000,
         "DiscoBar":85000,
         "Room_Lux_Pr":7500,
         "Cinema":45000,
         "Room_Eco":250,
         "Laundry_XL":3000,
         "Room_Royal":18000,
         "Casino":75000
      };

      public static var entityNames:Object = {
         "Guest":"Guest",
         "Cleaner":"Maid",
         "Mechanic":"Engineer",
         "Receptionist":"Receptionist",
         "Waiter":"Waiter",
         "Room":"Room",
         "Elevator":"Elevator",
         "Reception":"Reception",
         "Laundry":"Laundry",
         "Cafe":"Cafe",
         "Arcade":"Arcade",
         "Gym":"Gym",
         "ServiceElevator":"Staff elevator",
         "Internet":"Internet",
         "RoofCafe":"Open Air Cafe",
         "Bowling":"Bowling",
         "Pool":"Pool",
         "Elevator10":"Big Elevator",
         "Room_Lux":"Lux Room",
         "BeautySalon":"Beauty Salon",
         "Restaurant":"Restaurant",
         "DiscoBar":"Disco Bar",
         "Room_Lux_Pr":"Presidental Lux",
         "Cinema":"Cinema",
         "Room_Eco":"Economy Room",
         "Laundry_XL":"Industrial Laundry",
         "Room_Royal":"Royal Suite",
         "Casino":"Casino"
      };

      public static const floorHeight:Number = 60;

      public static const tileWidth:Number = 60;

      public static const personFloorShift:Number = 5;

      public static const groundHeight:Number = floorHeight;

      public static const secondsPerDay:Number = 2;

      public static const maxPenaltyForMissingService:Number = 70;

      public static const daysInGraph:Number = 1200;

      public static const graphSnapshotInterval:int = 5;

      public static const borderIncrease:Number = 240;

      public static const loanPercent:Number = 0.1;

      public static const doorPositions:Object = {
         "Room":40,
         "Room_Lux":112,
         "Room_Lux_Pr":238,
         "Room_Eco":40,
         "Room_Royal":238
      };

      // V2: new buildings reuse the logic of an original building. The
      // world query also lists them under their base name, so guests,
      // staff and tutorials treat an Industrial Laundry as a Laundry, etc.
      public static const templateAliases:Object = {
         "Room_Eco":"Room",
         "Room_Royal":"Room_Lux_Pr",
         "Laundry_XL":"Laundry",
         "Casino":"Arcade"
      };

      public static const AutoSaveSlot:int = 4;

      {
      }

      public function Config()
      {
         super();
      }

      public static function GetBaseTemplate(param1:String) : String
      {
         var _loc2_:String = templateAliases[param1];
         return _loc2_ != null ? _loc2_ : param1;
      }

      public static function GetRoomPrice(param1:String, param2:HotelGameLogic) : Number
      {
         return roomPrices[param1];
      }

      public static function GetServicePrice(param1:String) : int
      {
         return int(servicePrices[param1]) || 0;
      }

      public static function GetRoomCleannessPenalty(param1:RoomBehaviour) : Number
      {
         return Utils.Clamp((80 - param1.GetCleanness()) * 3,0,200);
      }

      public static function EntityIsStaff(param1:String) : Boolean
      {
         return staffTemplates.indexOf(param1) != -1;
      }

      public static function EntityIsGuest(param1:String) : Boolean
      {
         return param1 == "Guest";
      }

      public static function EntityIsElevator(param1:Entity) : Boolean
      {
         return param1.GetBehaviourByClass(ElevatorBehaviour) != null;
      }

      public static function EntityIsBuilding(param1:Entity) : Boolean
      {
         return starBuildRequirements[param1.GetTemplate().GetFriendlyName()] != null;
      }

      public static function EntityIsGuestRoom(param1:String) : Boolean
      {
         return roomPrices[param1] != null;
      }

      public static function GetTargetGuestCountByReptation(param1:Number, param2:int) : Number
      {
         param1 = Utils.Clamp(param1,0,1000);
         var _loc3_:Number = Math.sin(param1 * Math.PI / 1000 - Math.PI / 2) * 0.45 + 0.55;
         return Number(param2 * _loc3_);
      }

      public static function GetGuestSpawnInterval(param1:Number, param2:int) : Number
      {
         var _loc3_:Number = avgStayTime / (param1 + 1);
         var _loc4_:Number = Utils.Clamp(Utils.Sqr(Utils.Sqr(param2 / param1)),0.5,2);
         return Number(_loc3_ * _loc4_);
      }

      public static function GetBuildCost(param1:String) : int
      {
         return int(buildCosts[param1]) || 0;
      }

      public static function GetGuestAppearPosition(param1:HotelGameLogic) : Number
      {
         return Math.max(GetLeftBorderPos(param1.GetGameStatus()) - 500,0);
      }

      public static function GetLeftBorderPos(param1:GameStatus) : Number
      {
         return 2160 - param1.leftBorderPos * borderIncrease;
      }

      public static function GetRightBorderPos(param1:GameStatus) : Number
      {
         return 3000 + param1.rightBorderPos * borderIncrease;
      }

      public static function GetBorderIncreasePrice(param1:GameStatus) : int
      {
         if(param1.leftBorderPos + param1.rightBorderPos > 0)
         {
            return (param1.leftBorderPos + param1.rightBorderPos) * 50000;
         }
         return 5000;
      }

      public static function GetStarProgress(param1:HotelGameLogic) : Object
      {
         var _loc2_:int = param1.GetGameStatus().stars;
         var _loc3_:Object = Config.starAchieveCriteria[_loc2_];
         var _loc4_:Object;
         (_loc4_ = {}).moneyProgress = Utils.Clamp(Number(param1.GetGameStatus().money / _loc3_.money),0,1);
         _loc4_.roomsProgress = Utils.Clamp(Number(param1.GetWorldQuery().GetTotalGuestRoomsCount() / _loc3_.rooms),0,1);
         _loc4_.reputationProgress = Utils.Clamp(Number(param1.GetGameStatus().reputation / _loc3_.reputation),0,1);
         _loc4_.targetMoney = _loc3_.money;
         _loc4_.targetReputation = _loc3_.reputation;
         _loc4_.targetRooms = _loc3_.rooms;
         return _loc4_;
      }

      public static function GetMaxLoan(param1:HotelGameLogic) : int
      {
         var _loc2_:int = param1.GetGameStatus().stars;
         return 20000 + _loc2_ * 30000;
      }

      public static function ColorCodeMoney(param1:int) : String
      {
         if(param1 >= 0)
         {
            return "<font color=\'#449900\'>$ " + param1.toString() + "</font>";
         }
         return "<font color=\'#FF0000\'>- $ " + (-param1).toString() + "</font>";
      }
   }
}
