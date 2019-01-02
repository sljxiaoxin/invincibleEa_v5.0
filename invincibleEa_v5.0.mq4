//+------------------------------------------------------------------+
//|     
//|                                                      
//|                                             
//+------------------------------------------------------------------+
#property copyright "xiaoxin003"
#property link      "yangjx009@139.com"
#property version   "2.0"
#property strict

#include "CStrategySmOne.mqh";
 
extern int       SmOne_MagicNumber  = 20181103;    
extern double    SmOne_Lots         = 0.1;
extern int       SmOne_intTP        = 12;
extern int       SmOne_intSL        = 12;
      

CStrategySmOne* oCStrategySmOne;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   Print("begin");
   if(oCStrategySmOne == NULL){
      oCStrategySmOne = new CStrategySmOne(SmOne_MagicNumber);
   }
   oCStrategySmOne.Init(SmOne_Lots,SmOne_intTP,SmOne_intSL);
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("deinit");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
{
   oCStrategySmOne.Tick();
}


void subPrintDetails()
{
   //
   string sComment   = "";
   string sp         = "----------------------------------------\n";
   string NL         = "\n";

   sComment = sp;
   //sComment = sComment + "TotalItems = " + oCOrder.TotalItems() + NL; 
   sComment = sComment + sp;
   //sComment = sComment + "TotalItemsActive = " + oCOrder.TotalItemsActive() + NL; 
   sComment = sComment + sp;
   //sComment = sComment + "Lots=" + DoubleToStr(Lots,2) + NL;
   Comment(sComment);
}


