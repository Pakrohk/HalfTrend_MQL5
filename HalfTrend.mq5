//+------------------------------------------------------------------+
//|                         HalfTrend.mq5                            |
//|                    Copyright 2025, Pakrohk GPLv3                 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Pakrohk GPLv3"
#property link      "pakrohk@gmail.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3

//--- plot HalfTrend
#property indicator_label1  "HalfTrend"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrBlue,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- plot ATR High
#property indicator_label2  "ATR High"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_DOT

//--- plot ATR Low
#property indicator_label3  "ATR Low"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_DOT

//--- inputs
input int    InpAmplitude = 2;           // Amplitude
input int    InpChannelDeviation = 2;   // Channel Deviation
input bool   InpShowChannels = true;    // Show Channels

//--- indicator buffers
double HalfTrendBuffer[];
double HalfTrendColorBuffer[];
double ATRHighBuffer[];
double ATRLowBuffer[];
double UpTrendBuffer[];      // For EA access (buffer 4)
double DownTrendBuffer[];    // For EA access (buffer 5)

//--- global variables
int trend = 0;
int nextTrend = 0;
double maxLowPrice = 0.0;
double minHighPrice = 0.0;
double up = 0.0;
double down = 0.0;
int atrHandle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- indicator buffers mapping
   SetIndexBuffer(0, HalfTrendBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, HalfTrendColorBuffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, ATRHighBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, ATRLowBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, UpTrendBuffer, INDICATOR_DATA);      // For EA access
   SetIndexBuffer(5, DownTrendBuffer, INDICATOR_DATA);    // For EA access
   
   //--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   
   //--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 100);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, 100);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, 100);
   
   //--- name for data window and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME, "HalfTrend(" + string(InpAmplitude) + "," + string(InpChannelDeviation) + ")");
   
   //--- initialize ATR
   atrHandle = iATR(_Symbol, _Period, 100);
   if(atrHandle == INVALID_HANDLE) {
      Print("Error creating ATR indicator");
      return(INIT_FAILED);
   }
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(atrHandle != INVALID_HANDLE)
      IndicatorRelease(atrHandle);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(rates_total < 100) return(0);
   
   //--- get ATR values
   double atrArray[];
   if(CopyBuffer(atrHandle, 0, 0, rates_total, atrArray) <= 0)
      return(0);
   
   //--- calculate start position
   int start = 100;
   if(prev_calculated > 100)
      start = prev_calculated - 1;
   
   //--- main loop
   for(int i = start; i < rates_total; i++) {
      
      // Get highest/lowest in amplitude period
      double highPrice = GetHighestPrice(high, i, InpAmplitude);
      double lowPrice = GetLowestPrice(low, i, InpAmplitude);
      
      // Calculate simple moving averages
      double highma = GetSMA(high, i, InpAmplitude);
      double lowma = GetSMA(low, i, InpAmplitude);
      
      // ATR calculation
      double atr2 = atrArray[i] / 2.0;
      double dev = InpChannelDeviation * atr2;
      
      // Initialize on first valid bar
      if(i == 100) {
         maxLowPrice = low[i];
         minHighPrice = high[i];
         trend = close[i] > GetSMA(close, i, InpAmplitude) ? 0 : 1;
         nextTrend = trend == 0 ? 1 : 0;
      }
      
      // HalfTrend logic
      if(nextTrend == 1) {
         maxLowPrice = MathMax(lowPrice, maxLowPrice);
         if(highma < maxLowPrice && close[i] < (i > 0 ? low[i-1] : low[i])) {
            trend = 1;
            nextTrend = 0;
            minHighPrice = highPrice;
         }
      } else {
         minHighPrice = MathMin(highPrice, minHighPrice);
         if(lowma > minHighPrice && close[i] > (i > 0 ? high[i-1] : high[i])) {
            trend = 0;
            nextTrend = 1;
            maxLowPrice = lowPrice;
         }
      }
      
      // Calculate up/down values
      if(trend == 0) {
         if(i > 100 && (i == 100 || GetTrendFromBuffer(i-1) != 0)) {
            up = (GetDownFromBuffer(i-1) == EMPTY_VALUE) ? down : GetDownFromBuffer(i-1);
         } else {
            up = (i <= 100 || GetUpFromBuffer(i-1) == EMPTY_VALUE) ? maxLowPrice : MathMax(maxLowPrice, GetUpFromBuffer(i-1));
         }
         down = EMPTY_VALUE;
      } else {
         if(i > 100 && (i == 100 || GetTrendFromBuffer(i-1) != 1)) {
            down = (GetUpFromBuffer(i-1) == EMPTY_VALUE) ? up : GetUpFromBuffer(i-1);
         } else {
            down = (i <= 100 || GetDownFromBuffer(i-1) == EMPTY_VALUE) ? minHighPrice : MathMin(minHighPrice, GetDownFromBuffer(i-1));
         }
         up = EMPTY_VALUE;
      }
      
      // Set buffer values
      HalfTrendBuffer[i] = (trend == 0) ? up : down;
      HalfTrendColorBuffer[i] = trend;  // 0 = blue, 1 = red
      
      // ATR channels
      if(InpShowChannels) {
         double htValue = HalfTrendBuffer[i];
         ATRHighBuffer[i] = htValue + dev;
         ATRLowBuffer[i] = htValue - dev;
      } else {
         ATRHighBuffer[i] = EMPTY_VALUE;
         ATRLowBuffer[i] = EMPTY_VALUE;
      }
      
      // Set buffers for EA access
      if(trend == 0) {
         UpTrendBuffer[i] = HalfTrendBuffer[i];    // UP trend line
         DownTrendBuffer[i] = 0;                   // No DOWN trend
      } else {
         UpTrendBuffer[i] = 0;                     // No UP trend  
         DownTrendBuffer[i] = HalfTrendBuffer[i];  // DOWN trend line
      }
   }
   
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Helper functions                                                 |
//+------------------------------------------------------------------+
double GetHighestPrice(const double &high[], int index, int period)
{
   if(index < period) return high[index];
   
   double highest = high[index];
   for(int i = 1; i < period; i++) {
      if(index - i >= 0 && high[index - i] > highest)
         highest = high[index - i];
   }
   return highest;
}

double GetLowestPrice(const double &low[], int index, int period)
{
   if(index < period) return low[index];
   
   double lowest = low[index];
   for(int i = 1; i < period; i++) {
      if(index - i >= 0 && low[index - i] < lowest)
         lowest = low[index - i];
   }
   return lowest;
}

double GetSMA(const double &price[], int index, int period)
{
   if(index < period - 1) return price[index];
   
   double sum = 0.0;
   for(int i = 0; i < period; i++) {
      if(index - i >= 0)
         sum += price[index - i];
   }
   return sum / period;
}

int GetTrendFromBuffer(int index)
{
   if(index < 0 || index >= ArraySize(HalfTrendColorBuffer))
      return -1;
   return (int)HalfTrendColorBuffer[index];
}

double GetUpFromBuffer(int index)
{
   if(index < 0 || index >= ArraySize(UpTrendBuffer))
      return EMPTY_VALUE;
   return UpTrendBuffer[index];
}

double GetDownFromBuffer(int index)
{
   if(index < 0 || index >= ArraySize(DownTrendBuffer))
      return EMPTY_VALUE;
   return DownTrendBuffer[index];
}
