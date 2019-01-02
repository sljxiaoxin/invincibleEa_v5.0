//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

class CStoch
{  
   private:
     int period;
     int tf;   //PERIOD_M1
     
   public:
      double data[50];
      
      CStoch(int _tf, int _period){
         period = _period;
         tf = _tf;
         Fill();
      };
      
      void Fill();
      bool IsUp();
      bool IsDown();
      double HighValue(int counts); 
      double LowValue(int counts);
      double Distance(int counts);
};

void CStoch::Fill()
{
   for(int i=0;i<50;i++){
      data[i] = iStochastic(NULL, tf, period, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
   }
}

bool CStoch::IsUp()
{
   if(data[1] > data[2] && data[2]>=data[3]){
      return true;
   }
   return false;
}

bool CStoch::IsDown()
{
   if(data[1] < data[2] && data[2]<=data[3]){
      return true;
   }
   return false;
}

double CStoch::HighValue(int counts)
{
   double h = -1;
   for(int i=1;i<counts;i++){ 
      if(data[i] > h){
         h = data[i];
      }
   }
   return h;
}

double CStoch::LowValue(int counts)
{
   double l = 9999999;
   for(int i=1;i<counts;i++){ 
      if(data[i] < l){
         l = data[i];
      }
   }
   return l;
}

double CStoch::Distance(int counts)
{
   double h = this.HighValue(counts);
   double l = this.LowValue(counts);
   return h - l;
}