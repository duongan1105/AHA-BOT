#include <SuperRecipe.mqh>

string version = "v1.07";

input int limit_order = 5;
input int candle_period = 15;
input int order_magic = 8369;
input int spread = 0;
input double stoploss = 0.01;
input double max_drawdown = 0;
input bool is_auto_stoploss = true;
input bool is_min_stoploss = true;
input bool is_only_auto = true;
input bool is_trailing_stop = true;
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

int OnInit()
{
   ArrayResize(orders, limit_order * 10);
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
   if(OrdersTotal() >= limit_order){
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
      if(countOrders >= limit_order){
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
      c_entry = Bid;
      min_sl = Ask+pts;
      c_sl = is_auto_stoploss == true ? c_sl : Ask + (stoploss*100*Point());
      c_sl = NormalizeDouble(v_sl < min_sl ? min_sl : v_sl,Digits);
      c_lots = getLots(c_entry,c_sl);
      c_tp = c_entry - MathAbs(c_sl - c_entry);
      v_tp = is_trailing_stop == true ? 0 : c_tp;
      ticket = OrderSend(Symbol(), OP_SELL, c_lots, c_entry, spread, c_sl, c_tp,"",order_magic);
   }
   if(data[0].v_type == 1)
   {
      v_sl = data[0].v_low;
      for(int isl1=0;isl1<candle_period;isl1++)
      {
         v_sl = v_sl > data[isl1].v_low ? data[isl1].v_low : v_sl;
      }
      c_entry = Ask;
      min_sl = Bid-pts;
      c_sl = is_auto_stoploss == true ? c_sl : Bid + (stoploss*100*Point());
      c_sl = NormalizeDouble(v_sl > min_sl ? min_sl : v_sl,Digits);
      c_lots = getLots(c_entry,c_sl);
      c_tp = c_entry + MathAbs(c_entry - c_sl);
      v_tp = is_trailing_stop == true ? 0 : c_tp;
      ticket = OrderSend(Symbol(), OP_BUY, c_lots, c_entry, spread, c_sl, v_tp,"",order_magic);
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
   double amount = AccountEquity() * stoploss;
   double lots = amount/entry;
   lots = lots > dblLotsMaximum ? dblLotsMaximum : lots;
   lots = lots < dblLotsMinimum ? dblLotsMinimum : lots;
   lots = is_min_stoploss == true ? dblLotsMinimum : NormalizeDouble(lots, Digits);
   return lots;
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
	if(c_type == 0 && (data[0].v_wma90 <= data[0].v_wma45 || data[0].v_smaRSI >= data[0].v_upperBand || data[0].v_high >= c_sl)){
		c_type = data[0].v_high <= c_entry ? 5 : 3; // close win / lose short
	}
	// đang có lệnh long, kiểm tra có đóng long
	if(c_type == 1 && (data[0].v_wma90 >= data[0].v_wma45 || data[0].v_smaRSI <= data[0].v_lowerBand || data[0].v_low <= c_sl)){
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
