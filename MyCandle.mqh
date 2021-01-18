
#property strict

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
