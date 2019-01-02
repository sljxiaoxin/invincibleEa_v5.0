//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

class CMa
{  
   private:
     int period;
     int tf;
     
   public:
      double data[50];
      
      CMa(int _tf, int _period){
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

void CMa::Fill()
{
   for(int i=0;i<50;i++){ 
      data[i] = iMA(NULL,tf,period,0,MODE_SMA,PRICE_CLOSE,i);
   }
}

bool CMa::IsUp()
{
   if(data[1] > data[2] && data[2]>=data[3]){
      return true;
   }
   return false;
}

bool CMa::IsDown()
{
   if(data[1] < data[2] && data[2]<=data[3]){
      return true;
   }
   return false;
}

double CMa::HighValue(int counts)
{
   double h = -1;
   for(int i=1;i<counts;i++){ 
      if(data[i] > h){
         h = data[i];
      }
   }
   return h;
}

double CMa::LowValue(int counts)
{
   double l = 9999999;
   for(int i=1;i<counts;i++){ 
      if(data[i] < l){
         l = data[i];
      }
   }
   return l;
}

double CMa::Distance(int counts)
{
   double h = this.HighValue(counts);
   double l = this.LowValue(counts);
   return h - l;
}