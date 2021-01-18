#include <Classes\MyCandle.mqh>

MyCandles data[];
MyOrders orders[];

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
      for(int i=14;i>0;i--)
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
   data[idx].v_rsi = calRsi(PRICE_CLOSE,14,idx);
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
   if(idx > 10){
      return None;
   }
   int action = None;
   double sumStoch = (data[idx].v_stochK + data[idx].v_stochD);
   double sumSmooth = (data[idx].v_smoothK + data[idx].v_smoothD);
   double minusWma4590 = (data[idx].v_wma45 - data[idx].v_wma90);
   double minusWma9045 = (data[idx].v_wma90 - data[idx].v_wma45);
   double rsi9 = data[idx].v_rsi;
   double smaRsi = data[idx].v_smaRSI;
   bool rsiBBOver = smaRsi < data[idx].v_upperBand;
   bool rsiBBOverRsi = rsi9 < smaRsi - 1;
   bool rsiBBUnder = smaRsi > data[idx].v_lowerBand;
   bool rsiBBUnderRsi = rsi9 > smaRsi + 1;
   
   if (sumStoch <= 30 && sumSmooth <= 30)
   	action = Long;
   if (sumStoch <= 80 && sumSmooth >= 120)
   	action = Long;
   
   if (sumStoch >= 170 && sumSmooth >= 170)
   	action = Short;
   if (sumStoch >= 120 && sumSmooth <= 80)
   	action = Short;
   	
   if (action == Long && minusWma4590 < 1)
     action = None;
   if (action == Short && minusWma9045 < 1)
     action = None;
     
   if (action == Short && (rsiBBOver == false || rsiBBOverRsi == false))
      action = None;
   if (action == Long && (rsiBBUnder == false || rsiBBUnderRsi == false))
      action = None;
      
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
   
   if (action == Short && rsiBBOver == false)
      action = None;
   if (action == Long && rsiBBUnder == false)
      action = None;
   
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
