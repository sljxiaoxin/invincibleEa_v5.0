//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"
#include "CStoch.mqh";

class CStochCross
{  
   private:
      CStoch* oStochFast; //7
      CStoch* oStochMid;  //14
      CStoch* oStochSlow; //100
      
     
   public:
      
      
      CStochCross(CStoch* _oStochFast, CStoch* _oStochMid, CStoch* _oStochSlow){
         oStochFast = _oStochFast;
         oStochFast = _oStochMid;
         oStochSlow = _oStochSlow;
      };
      
      string GetEntrySignal();
      string GetExitSignal();
};

string CStochCross::GetEntrySignal()
{
   if(oStochFast.data[2]< 20 && oStochFast.data[1]> 20){
      return "up";  
   }
   if(oStochFast.data[2]> 80 && oStochFast.data[1]< 80){
      return "down";  
   }
   return "none";
}

string CStochCross::GetExitSignal()
{
   //TODO
   return "none";
}