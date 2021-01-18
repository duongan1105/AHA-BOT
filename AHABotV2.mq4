
string version = "v2.04.1";

class MyCandles{
   public:
      double v_rsi;
      double v_entry;
      double v_close;
      double v_stochK;
      double v_stochD;
      double v_wma45;
      double v_wma90;
      double v_smaRSI;
      double v_wmaRSI;
      double v_upperBand;
      double v_lowerBand;
      double v_smoothK;
      double v_smoothD;
      double v_slUp;
      double v_slDown;
      double v_high;
      double v_low;
      int v_type;
      datetime v_create_time;
      
      MyCandles(){}
};

class MyOrders{
   public:
      double entry;
      double sl;
      double tp;
      int type;
      int ticket;
      datetime create_time;
      
      MyOrders(){}
};

enum Position
{
   None=2,
   Long=1,
   Short=0,
};

input int max_order = 5;
input int candle_period = 15;
input int order_magic = 8369;
input int spread = 0;
input double stoploss = 0.01;
input double max_drawdown = 0;

input bool is_force_close = true;

input bool is_only_auto = true;
input bool is_trailing_stop = true;

input bool order_limit = false;
input bool are_you_rich = true;
input bool is_min_stoploss = false;

input bool is_multi_lots = true;

double c_tp = 0;
double c_entry = 0;
double c_sl = 0;
double c_lots = 0;
int c_type = 2;
int ticket = 0;
datetime D1;
int countBars = 0;
int pending_order_period = 3;
bool isReRun = true;

MyCandles data[];

int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll();
}
  
void OnTick()
{
   genList(candle_period);
   
   genComment();
   
   run();
}

// -----------------------------------------------------------------------------------------------------------------------------------------------------
// comment
void genComment()
{
   string pos = c_type == 0 ? "Short" : c_type == 1 ? "Long" : "None";
   
   ObjectCreate("BotName",OBJ_LABEL,0,0,0);
   ObjectSet("BotName",OBJPROP_XDISTANCE,2);
   ObjectSet("BotName",OBJPROP_YDISTANCE,10);
   ObjectSetText("BotName","AHA BOT",20,"Arial",LawnGreen);
   ObjectCreate("Version",OBJ_LABEL,0,0,0);
   ObjectSet("Version",OBJPROP_XDISTANCE,122);
   ObjectSet("Version",OBJPROP_YDISTANCE,23);
   ObjectSetText("Version",version,10,"Arial",LawnGreen);
   ObjectCreate("Close",OBJ_LABEL,0,0,0);
   ObjectSet("Close",OBJPROP_XDISTANCE,2);
   ObjectSet("Close",OBJPROP_YDISTANCE,40);
   ObjectSetText("Close","Close: " + DoubleToStr(data[0].v_close,3),10,"Arial",White);
   ObjectCreate("Entry",OBJ_LABEL,0,0,0);
   ObjectSet("Entry",OBJPROP_XDISTANCE,2);
   ObjectSet("Entry",OBJPROP_YDISTANCE,55);
   ObjectSetText("Entry","Entry: " + DoubleToStr(data[0].v_entry,3),10,"Arial",White);
   ObjectCreate("Rsi",OBJ_LABEL,0,0,0);
   ObjectSet("Rsi",OBJPROP_XDISTANCE,2);
   ObjectSet("Rsi",OBJPROP_YDISTANCE,70);
   ObjectSetText("Rsi","Rsi: " + DoubleToStr(data[0].v_rsi,3),10,"Arial",White);
   ObjectCreate("smaRSI",OBJ_LABEL,0,0,0);
   ObjectSet("smaRSI",OBJPROP_XDISTANCE,2);
   ObjectSet("smaRSI",OBJPROP_YDISTANCE,85);
   ObjectSetText("smaRSI","smaRSI: " + DoubleToStr(data[0].v_smaRSI,3),10,"Arial",White);
   ObjectCreate("wma45",OBJ_LABEL,0,0,0);
   ObjectSet("wma45",OBJPROP_XDISTANCE,2);
   ObjectSet("wma45",OBJPROP_YDISTANCE,100);
   ObjectSetText("wma45","wma45: " + DoubleToStr(data[0].v_wma45,3),10,"Arial",White);
   ObjectCreate("wma90",OBJ_LABEL,0,0,0);
   ObjectSet("wma90",OBJPROP_XDISTANCE,2);
   ObjectSet("wma90",OBJPROP_YDISTANCE,115);
   ObjectSetText("wma90","wma90: " + DoubleToStr(data[0].v_wma90,3),10,"Arial",White);
   ObjectCreate("stochK",OBJ_LABEL,0,0,0);
   ObjectSet("stochK",OBJPROP_XDISTANCE,2);
   ObjectSet("stochK",OBJPROP_YDISTANCE,130);
   ObjectSetText("stochK","stochK: " + DoubleToStr(data[0].v_stochK,3),10,"Arial",White);
   ObjectCreate("stochD",OBJ_LABEL,0,0,0);
   ObjectSet("stochD",OBJPROP_XDISTANCE,2);
   ObjectSet("stochD",OBJPROP_YDISTANCE,145);
   ObjectSetText("stochD","stochD: " + DoubleToStr(data[0].v_stochD,3),10,"Arial",White);
   ObjectCreate("smoothK",OBJ_LABEL,0,0,0);
   ObjectSet("smoothK",OBJPROP_XDISTANCE,2);
   ObjectSet("smoothK",OBJPROP_YDISTANCE,160);
   ObjectSetText("smoothK","smoothK: " + DoubleToStr(data[0].v_smoothK,3),10,"Arial",White);
   ObjectCreate("smoothD",OBJ_LABEL,0,0,0);
   ObjectSet("smoothD",OBJPROP_XDISTANCE,2);
   ObjectSet("smoothD",OBJPROP_YDISTANCE,175);
   ObjectSetText("smoothD","smoothD: " + DoubleToStr(data[0].v_smoothD,3),10,"Arial",White);
   ObjectCreate("upperBand",OBJ_LABEL,0,0,0);
   ObjectSet("upperBand",OBJPROP_XDISTANCE,2);
   ObjectSet("upperBand",OBJPROP_YDISTANCE,190);
   ObjectSetText("upperBand","upperBand: " + DoubleToStr(data[0].v_upperBand,3),10,"Arial",White);
   ObjectCreate("lowerBand",OBJ_LABEL,0,0,0);
   ObjectSet("lowerBand",OBJPROP_XDISTANCE,2);
   ObjectSet("lowerBand",OBJPROP_YDISTANCE,205);
   ObjectSetText("lowerBand","lowerBand: " + DoubleToStr(data[0].v_lowerBand,3),10,"Arial",White);
   ObjectCreate("high",OBJ_LABEL,0,0,0);
   ObjectSet("high",OBJPROP_XDISTANCE,2);
   ObjectSet("high",OBJPROP_YDISTANCE,220);
   ObjectSetText("high","high: " + DoubleToStr(data[0].v_high,3),10,"Arial",White);
   ObjectCreate("low",OBJ_LABEL,0,0,0);
   ObjectSet("low",OBJPROP_XDISTANCE,2);
   ObjectSet("low",OBJPROP_YDISTANCE,235);
   ObjectSetText("low","low: " + DoubleToStr(data[0].v_low,3),10,"Arial",White);
}

void run()
{
   if(D1!=iTime(Symbol(),PERIOD_M15,0)) // new candle on D1
   {
      countBars++;
      D1=iTime(Symbol(),PERIOD_M15,0);
      if(OrdersTotal()==0){
         ticket = 0;
         countBars = 0;
      }
      if(is_force_close)
         callExit();
      callEnter();
   }
   mapOrders();
   callTrailing();
}
//-----------------------------------------------------------------------------------------------------------
void callEnter()
{
   c_type = 2;
   if(OrdersTotal() >= max_order){
      if(is_only_auto == true){
         return;
      }
      int countOrders = 0;
      for(int b=OrdersTotal()-1;b>=0;b--){
         if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES)==true){
            if(OrderMagicNumber() == order_magic){
               countOrders++;
            }
         }
      }
      if(countOrders >= max_order){
         return;
      }
   }
   if(OrdersTotal()>0){
      for(int a=OrdersTotal()-1;a>=0;a--){
         if(OrderSelect(a,SELECT_BY_POS,MODE_TRADES)==true){
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==order_magic){
               if(OrderType() == OP_BUY){
                  c_type = 1;
               }
               if(OrderType() == OP_SELL){
                  c_type = 0;
               }
            }
         }
      }
   }
   if(data[0].v_type == 2 || c_type < 2 || ticket > 0 || AccountBalance() <= max_drawdown){
      return;
   }
   c_type = data[0].v_type;
	double v_sl = 0;
	double v_tp = 0;
   double v_stoploss = 0; 
   double min_sl = 0;
   double min_lv = MarketInfo(Symbol(),MODE_STOPLEVEL); 
   double pts = min_lv*Point();
   if(data[0].v_type == 0)
   {
      v_sl = data[0].v_high;
      for(int isl=0;isl<candle_period;isl++)
      {
         v_sl = v_sl < data[isl].v_high ? data[isl].v_high : v_sl;
      }
      
      if(order_limit == false){
         c_entry = Bid;
         min_sl = Ask+pts;
         c_sl = NormalizeDouble(v_sl < min_sl ? min_sl : v_sl,Digits);
         c_lots = getLots(c_entry,c_sl);
         v_tp = c_entry - MathAbs(c_sl - c_entry);
         c_tp = is_trailing_stop == true ? 0 : v_tp;
         ticket = OrderSend(Symbol(), OP_SELL, c_lots, c_entry, spread, c_sl, c_tp,"",order_magic);
      }else{
         c_entry = NormalizeDouble(data[0].v_entry < Ask ? Ask : data[0].v_entry, Digits);
         min_sl = c_entry+(pts*1.1);
         c_sl = NormalizeDouble(v_sl < min_sl ? min_sl : v_sl,Digits);
         c_lots = getLots(c_entry,c_sl);
         ticket = OrderSend(Symbol(), OP_SELLLIMIT, c_lots, c_entry, spread, c_sl, 0,"",order_magic);
      }
   }
   if(data[0].v_type == 1)
   {
      v_sl = data[0].v_low;
      for(int isl1=0;isl1<candle_period;isl1++)
      {
         v_sl = v_sl > data[isl1].v_low ? data[isl1].v_low : v_sl;
      }
      if(order_limit == false){
         c_entry = Ask;
         min_sl = Bid-pts;
         c_sl = NormalizeDouble(v_sl > min_sl ? min_sl : v_sl,Digits);
         c_lots = getLots(c_entry,c_sl);
         v_tp = c_entry + MathAbs(c_entry - c_sl);
         c_tp = is_trailing_stop == true ? 0 : v_tp;
         ticket = OrderSend(Symbol(), OP_BUY, c_lots, c_entry, spread, c_sl, c_tp,"",order_magic);
      }else{
         c_entry = NormalizeDouble(data[0].v_entry > Bid ? Bid : data[0].v_entry, Digits);
         min_sl = c_entry-(pts*1.1);
         c_sl = NormalizeDouble(v_sl > min_sl ? min_sl : v_sl,Digits);
         c_lots = getLots(c_entry,c_sl);
         ticket = OrderSend(Symbol(), OP_BUYLIMIT, c_lots, c_entry, spread, c_sl, 0,"",order_magic);
      }
   }
   if(ticket <= 0)
   {
      c_type = 2;
      string typepos = data[0].v_type == 0 ? "short" : "long";
      Print("Open order " + typepos + " faile: " + IntegerToString(GetLastError()));
   }
}

double getLots(double entry, double sl) {
   double dblLotsMinimum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double dblLotsMaximum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double tValue = MarketInfo(_Symbol, MODE_TICKSIZE);
   double amount = AccountEquity() * stoploss;
   double lots = dblLotsMinimum;
   if(are_you_rich == true){
      double vmargin = MathAbs(entry - sl);
      double vtick = vmargin / tValue;
      vtick = Digits == 3 || Digits == 5 ? vtick * 1 : vtick * 0.01;
      lots = amount / vtick;
      lots = lots > dblLotsMaximum ? dblLotsMaximum : lots;
      lots = lots < dblLotsMinimum ? dblLotsMinimum : lots;
   }else{
      lots = amount/entry;
      lots = lots > dblLotsMaximum ? dblLotsMaximum : lots;
      lots = lots < dblLotsMinimum ? dblLotsMinimum : lots;
   }
   lots = is_min_stoploss == true ? dblLotsMinimum : lots;
   lots = is_multi_lots ? getLotsMulti(lots) : lots;
   return NormalizeDouble(lots, Digits);
}
double getLotsMulti(double lots){
   if(OrdersHistoryTotal() < 5)
      return lots;
   
   int countLoss = 0;
   double sumLots = 0;
   int maxCount = OrdersHistoryTotal();
   for(int a=maxCount-1;a>=maxCount-5;a--){
      if(OrderSelect(a,SELECT_BY_POS,MODE_HISTORY)==true){
         if(OrderProfit() < 0){
            countLoss++;
            sumLots += OrderLots();
         }
      }
   }
   
   return countLoss == 5 ? sumLots : lots;
}
//-----------------------------------------------------------------------------------------------------------
void callExit()
{
   c_type = 2;
   double od_close = 0;
   if(OrdersTotal()>0){
      for(int a=OrdersTotal()-1;a>=0;a--){
         if(OrderSelect(a,SELECT_BY_POS,MODE_TRADES)==true){
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==order_magic){
               ticket = OrderTicket();
               od_close = OrderClosePrice();
               if(OrderType() == OP_BUY){
                  c_type = 1;
               }
               if(OrderType() == OP_SELL){
                  c_type = 0;
               }
               if(countBars > pending_order_period && (OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)){
                  c_type = 2;
                  bool isDeleted = OrderDelete(ticket);
                  ticket = 0;
                  countBars = 0;
               }
            }
         }
      }
   }
   if(c_type == 2 || ticket <= 0){
      return;
   }
   
   // đang có lệnh short, kiểm tra có đóng short
	if(c_type == 0 && (data[0].v_wma90 <= data[0].v_wma45 || data[0].v_rsi >= data[0].v_upperBand || data[0].v_high >= c_sl)){
		c_type = data[0].v_high <= c_entry ? 5 : 3; // close win / lose short
	}
	// đang có lệnh long, kiểm tra có đóng long
	if(c_type == 1 && (data[0].v_wma90 >= data[0].v_wma45 || data[0].v_rsi <= data[0].v_lowerBand || data[0].v_low <= c_sl)){
		c_type = data[0].v_low >= c_entry ? 6 : 4; // close win / lose long
	}
	
   // thoát lệnh
   if(c_type > 2)
   {
      //double lots = getLots(c_entry, c_sl, AccountBalance(), AccountLeverage(), 10);
      bool check = true;
      
      if(c_type == 3 || c_type == 5)
      {   
         check = OrderClose(ticket,c_lots,Ask,spread,clrRed);
      }
      if(c_type == 4 || c_type == 6)
      {   
         check = OrderClose(ticket,c_lots,Bid,spread,clrGreen);
      }
      if(check == false)
      {
         Print("Close order faile: " + IntegerToString(GetLastError()));
      }
      
      c_type = 2;
      c_sl = 0;
      c_entry = 0;
      c_tp = 0;
      ticket = 0;
   }
}
//-----------------------------------------------------------------------------------------------------------
void callTrailing()
{
   c_type = 2;
   if(OrdersTotal()>0){
      for(int a=OrdersTotal()-1;a>=0;a--){
         if(OrderSelect(a,SELECT_BY_POS,MODE_TRADES)==true){
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==order_magic){
               ticket = OrderTicket();
               if(OrderType() == OP_BUY){
                  c_type = 1;
                  c_tp = c_entry + (c_entry - c_sl);
               }
               if(OrderType() == OP_SELL){
                  c_type = 0;
                  c_tp = c_entry - (c_sl - c_entry);
               }
            }
         }
      }
   }
   if(c_type == 2 || ticket <= 0 || c_entry == 0){
      return;
   }
   
   double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL); 
   bool isModif = false;
   if(c_type == 0 && Close[0] <= c_tp)
   {
      c_sl = c_entry;
      //c_sl = c_sl < Ask+minstoplevel*Point() ? Ask+minstoplevel*Point() : c_sl;
      c_entry = c_tp;
      c_tp = c_entry - MathAbs(c_sl - c_entry);
      isModif = true;
   }
   
   if(c_type == 1 && Close[0] >= c_tp && c_tp > 0)
   {
      c_sl = c_entry;
      //c_sl = c_sl > Bid-minstoplevel*Point() ? Bid-minstoplevel*Point() : c_sl;
      c_entry = c_tp;
      c_tp = c_entry + MathAbs(c_entry - c_sl);
      isModif = true;
   }
   
   // sửa lệnh
   if(isModif){
      c_sl = NormalizeDouble(c_sl, Digits);
      bool check = OrderModify(ticket,0,c_sl,0,0,clrYellow);
      if(check == false)
      {
         Print("ticket: " + IntegerToString(ticket) + ", " + DoubleToStr(c_entry,Digits) + ", " + DoubleToStr(c_sl,Digits) + ", " + DoubleToStr(c_tp,Digits));
      }
   }
}
//-----------------------------------------------------------------------------------------------------------
void mapOrders(){
   if(isReRun == false){
      return;
   }
   if(isReRun == true){
      isReRun = false;
   }
   if(OrdersTotal()>0){
      for(int a=0;a<OrdersTotal();a++){
         if(OrderSelect(a,SELECT_BY_POS,MODE_TRADES)==true){
            if(Symbol() == OrderSymbol() && OrderMagicNumber()==order_magic){
               ticket = OrderTicket();
               c_entry = OrderOpenPrice();
               c_sl = OrderStopLoss();
               if(OrderType() == OP_BUY){
                  c_tp = c_entry + MathAbs(c_entry - c_sl);
               }
               if(OrderType() == OP_SELL){
                  c_tp = c_entry - MathAbs(c_entry - c_sl);
               }
            }
         }
      }
   }
}


// -----------------------------------------------------------------------------------------------------------------------------------------------------
// candle
void genList(int period)
{
   ArrayResize(data, period);
   if(!(data[0].v_close > 0))
   {
      for(int y=0;y<period;y++)
      {
         genItem(y);
      }
   }
   
   if(data[1].v_close != Close[1])
   {
      for(int i=period-1;i>0;i--)
      {
         data[i].v_rsi = data[i-i].v_rsi;
         data[i].v_entry = data[i-i].v_entry;
         data[i].v_close = data[i-i].v_close;
         data[i].v_stochK = data[i-i].v_stochK;
         data[i].v_stochD = data[i-i].v_stochD;
         data[i].v_wma45 = data[i-i].v_wma45;
         data[i].v_wma90 = data[i-i].v_wma90;
         data[i].v_upperBand = data[i-i].v_upperBand;
         data[i].v_lowerBand = data[i-i].v_lowerBand;
         data[i].v_smoothK = data[i-i].v_smoothK;
         data[i].v_smoothD = data[i-i].v_smoothD;
         data[i].v_smaRSI = data[i-i].v_smaRSI;
         data[i].v_slUp = data[i-i].v_slUp;
         data[i].v_slDown = data[i-i].v_slDown;
         data[i].v_high = data[i-i].v_high;
         data[i].v_low = data[i-i].v_low;
         data[i].v_type = data[i-i].v_type;
         data[i].v_create_time = data[i-i].v_create_time;
      }
   }
   genItem(0);
}
void genItem(int idx)
{
   data[idx] = new MyCandles();
   data[idx].v_rsi = calRsi(PRICE_CLOSE,9,idx);
   data[idx].v_close = Close[idx];
   data[idx].v_smaRSI = smaRsiS(5,9,idx);
   data[idx].v_wmaRSI = wmaRsiS(45,9,idx);
   data[idx].v_high = High[idx];
   data[idx].v_low = Low[idx];
   calWma(idx);
   calStoch(idx);
   calBB(idx);
   calEntry(idx);
   calSl(idx);
   data[idx].v_type = calType(idx);
}

// -----------------------------------------------------------------------------------------------------------------------------------------------------
// type

int calType(int idx)
{
   if(idx > 5){
      return None;
   }
   int minNumber = 1;
   int action = None;
   double rsi9 = data[idx].v_rsi;
   double smaRsi = data[idx].v_smaRSI;
   
   double sumStoch = (data[idx].v_stochK + data[idx].v_stochD);
   double sumSmooth = (data[idx].v_smoothK + data[idx].v_smoothD);
   
   bool wma4590 = data[idx].v_wma45 > data[idx].v_wma90;
   bool wma9045 = data[idx].v_wma90 > data[idx].v_wma45;
   
   bool rsiBBOver = smaRsi < data[idx].v_upperBand;
   bool rsiBBOverRsi = rsi9 < smaRsi - minNumber;
   bool rsiBBUnder = smaRsi > data[idx].v_lowerBand;
   bool rsiBBUnderRsi = rsi9 > smaRsi + minNumber;
   
   if (sumStoch <= 30 && sumSmooth <= 30)
   	action = Long;
   if (sumStoch <= 80 && sumSmooth >= 120)
   	action = Long;
   
   if (sumStoch >= 170 && sumSmooth >= 170)
   	action = Short;
   if (sumStoch >= 120 && sumSmooth <= 80)
   	action = Short;
   	
   if (action == Short && wma9045 == false){
      action = None;
   } 
   if (action == Long && wma4590 == false){
      action = None;
   }
   
   if (action == Short && (rsiBBOver == false || rsiBBOverRsi == false)){
      action = None;
   }
   if (action == Long && (rsiBBUnder == false || rsiBBUnderRsi == false)){
      action = None;
   }   
      
   rsiBBOver = false;
   rsiBBUnder = false;
   for(int i=1;i<4;i++)
   {
      double rsi9Idx = calRsi(MODE_CLOSE,9,i+idx);
      if(action == Short && rsi9Idx > data[i+idx].v_upperBand)
      {
         rsiBBOver = true;
      }
      if(action == Long && rsi9Idx < data[i+idx].v_lowerBand)
      {
         rsiBBUnder = true;
      }
   }
   
   if (action == Short && rsiBBOver == false){
      action = None;
   }   
   if (action == Long && rsiBBUnder == false){
      action = None;
   }   
   
   return action;
}

// -----------------------------------------------------------------------------------------------------------------------------------------------------
// candle properties

void calSl(int idx)
{
   double srcSl = (High[idx] + Low[idx]) / 2;
   double atrSl = iATR(NULL,0,14,idx);
   double srcSl1 = (High[idx+1] + Low[idx+1]) / 2;
   double atrSl1 = iATR(NULL,0,14,idx+1);
   
   double upSl = srcSl-(3*atrSl);
   double upSl1 = srcSl1-(3*atrSl1);
   data[idx].v_slUp = Close[1] > upSl1 ? MathMax(upSl,upSl1) : upSl;
   double dnSl = srcSl+(3*atrSl);
   double dnSl1 = srcSl1+(3*atrSl1);
   data[idx].v_slDown = Close[1] < dnSl1 ? MathMin(dnSl, dnSl1) : dnSl;
}

void calWma(int idx)
{
   data[idx].v_wma45 = wmaS(45, idx);
   data[idx].v_wma90 = wmaS(90, idx);
}

void calStoch(int idx)
{
   data[idx].v_stochK = iCustom(NULL, 0, "StochFast",0,idx);
   data[idx].v_stochD = iCustom(NULL, 0, "StochFast",1,idx);
   data[idx].v_smoothK = iCustom(NULL, 0, "StochSmooth",0,idx);
   data[idx].v_smoothD = iCustom(NULL, 0, "StochSmooth",1,idx);
}

void calBB(int idx)
{
   int bbLen = 30;
   int rsiLen = 9;
   int smaLen = 5;
   int wmaLen = 45;
   double vRsi2[30];
   for(int i=0;i<bbLen;i++)
   {
      vRsi2[i] = calRsi(PRICE_CLOSE,rsiLen,i+idx);
   }
   double offs = 1.6185 * StDev(vRsi2,bbLen);
   double ma = smaRsiS(bbLen, rsiLen, idx);
   double smaRSI = smaRsiS(smaLen, rsiLen, idx);
   double wmaRSI = wmaRsiS(wmaLen, rsiLen, idx);
   
   data[idx].v_upperBand = ma + offs; // Upper Bands
   data[idx].v_lowerBand = ma - offs; // Lower Bands
}

void calEntry(int idx)
{
   int smaLen = 5;
   
   double emaRsi = emaByRsi(smaLen);
   double auc = emaByClose0(smaLen);
   double adc = emaByClose1(smaLen);
   double x3 = (smaLen - 1) * ( adc * emaRsi / (100-emaRsi) - auc);
   data[idx].v_entry = x3 >= 0 ? Close[0+idx] + x3 : Close[0+idx] + x3 * (100-emaRsi)/emaRsi;
}
double emaByRsi(int len)
{
   double vRsiEma[50];
   if(len == 0)
   {
      vRsiEma[0] = calRsi(PRICE_CLOSE,9,0);
      return ema(vRsiEma, len);
   }
   for(int i=0;i<len;i++)
   {
      vRsiEma[i] = calRsi(PRICE_CLOSE,9,i);
   }
   return ema(vRsiEma, len);
}
double emaByClose0(int len)
{
   double emaClose[50];
   if(len == 0)
   {
      emaClose[0] = MathMax(Close[0] - Close[1], 0);
      return ema(emaClose, len);
   }
   int ep = 2 * len - 1;
   for(int i=0;i<len;i++)
   {
      emaClose[i] = MathMax(Close[i] - Close[1+i], 0);
   }
   return ema(emaClose, len);
}
double emaByClose1(int len)
{
   double emaClose[50];
   if(len == 0)
   {
      emaClose[0] = MathMax(Close[1] - Close[0], 0);
      return ema(emaClose, len);
   }
   int ep = 2 * len - 1;
   for(int i=0;i<len;i++)
   {
      emaClose[i] = MathMax(Close[i+1] - Close[i], 0);
   }
   return ema(emaClose, len);
}

// -----------------------------------------------------------------------------------------------------------------------------------------------------
// calculate value
double calRsi(int mode, int len, int idx)
{
   return iRSI(NULL,0,len,mode,idx);
}

double StDev(double& Data[], int Per)
{
   return(MathSqrt(Variance(Data,Per)));
}
double Variance(double& Data[], int Per)
{
   double sum = 0;
   double ssum = 0;
   for (int i=0; i<Per; i++)
   {
      sum += Data[i];
      ssum += MathPow(Data[i],2);
   }
   return ((ssum*Per - sum*sum)/(Per*(Per-1)));
}

double ema(double& values[], int len)
{
   int alpha = 2 / (len + 1);
   double total = values[0];
   for(int i=1;i<len;i++)
   {
      total += (values[i] - values[i-1]) * alpha + values[i-1];
   }
   return total / len;
}

double smaRsi(int y, int len)
{
   double sum = 0.0;
   for(int i=0;i<y;i++)
   {
      double vRsi = calRsi(PRICE_CLOSE,len,i);
      sum = sum + vRsi / y;
   }
   return sum;
}

double smaRsiS(int y, int len, int idx)
{
   double sum = 0.0;
   for(int i=0;i<y;i++)
   {
      double vRsi = calRsi(PRICE_CLOSE,len,i + idx);
      sum = sum + vRsi / y;
   }
   return sum;
}

double wma(int y)
{
   double norm = 0.0;
   double sum = 0.0;
   for(int i=0;i<y;i++)
   {;
      double weight = (y - i) * y;
      double vRsi = calRsi(PRICE_CLOSE,14,i);
      norm = norm + weight;
      sum = sum + vRsi * weight;
   }
   return sum / norm;
}

double wmaRsi(int y, int len)
{
   double norm = 0.0;
   double sum = 0.0;
   for(int i=0;i<y;i++)
   {;
      double weight = (y - i) * y;
      double vRsi = calRsi(PRICE_CLOSE,len,i);
      norm = norm + weight;
      sum = sum + vRsi * weight;
   }
   return sum / norm;
}

double wmaS(int y, int idx)
{
   double norm = 0.0;
   double sum = 0.0;
   for(int i=0;i<y;i++)
   {;
      double weight = (y - i) * y;
      double vRsi = calRsi(PRICE_CLOSE,14,i + idx);
      norm = norm + weight;
      sum = sum + vRsi * weight;
   }
   return sum / norm;
}

double wmaRsiS(int y, int len, int idx)
{
   double norm = 0.0;
   double sum = 0.0;
   for(int i=0;i<y;i++)
   {;
      double weight = (y - i) * y;
      double vRsi = calRsi(PRICE_CLOSE,len,i + idx);
      norm = norm + weight;
      sum = sum + vRsi * weight;
   }
   return sum / norm;
}

// -----------------------------------------------------------------------------------------------------------------------------------------------------
