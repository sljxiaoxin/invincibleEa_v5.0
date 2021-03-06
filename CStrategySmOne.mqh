//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

#include "inc\CTrade.mqh";
#include "inc\CMa.mqh";
#include "inc\CStoch.mqh";
#include "inc\CTicket.mqh";
#include "inc\CPriceAction.mqh";
#include "inc\CStochCross.mqh";


class CStrategySmOne
{  
   private:
   
     datetime CheckTimeM1; 
     double   Lots;
     int      Tp;
     int      Sl;
     
     CTrade* oCTrade;
     CMa* oCMa_fast;
     CMa* oCMa_slow;
     CStoch* oCStoch_fast;
     CStoch* oCStoch_mid;
     CStoch* oCStoch_slow;
     CTicket* oCTicket;
     CStochCross* oCStochCross;
     //CPriceAction* oCPriceAction;
     
     bool isCurrSignalOpen;
     string strSignalType;
     int intCurrSignalPass;
     
     bool isStochFastCrossOverArea;
     int intStochFastCrossOverAreaPass;
     
     void Update();
     void GetSignal();
     void SetSignal(string type);
     void Entry();
     void Exit();
     void CancelSignal();
     bool FirstSValueCheck(int index);
     bool FirstRValueCheck(int index);
   public:
      
      CStrategySmOne(int Magic){
         oCTrade      = new CTrade(Magic);
         oCMa_fast    = new CMa(PERIOD_M1,10);
         oCMa_slow    = new CMa(PERIOD_M1,30);
         oCStoch_fast = new CStoch(PERIOD_M1,7);
         oCStoch_mid = new CStoch(PERIOD_M1,14);
         oCStoch_slow = new CStoch(PERIOD_M1,100);
         oCTicket     = new CTicket(oCTrade);
         oCStochCross = new CStochCross(oCStoch_fast, oCStoch_mid, oCStoch_slow);
         
         isCurrSignalOpen = false;
         strSignalType = "none";
         intCurrSignalPass = -1;
         isStochFastCrossOverArea = false;
         intStochFastCrossOverAreaPass = -1;
         
      };
      
      void Init(double _lots, int _tp, int _sl);
      void Tick();
      
};

void CStrategySmOne::Init(double _lots, int _tp, int _sl)
{
   Lots = _lots;
   Tp = _tp;
   Sl = _sl;
}

void CStrategySmOne::Tick(void)
{  
    if(CheckTimeM1 == iTime(NULL,PERIOD_M1,0)){
      
    }else{
         CheckTimeM1 = iTime(NULL,PERIOD_M1,0);
         this.Update();
         this.Exit();
         this.GetSignal();
         this.Entry();
    }
}

void CStrategySmOne::Update()
{
   oCMa_fast.Fill();
   oCMa_slow.Fill();
   oCStoch_fast.Fill();
   oCStoch_slow.Fill();
   oCTicket.Update();
   
   intCurrSignalPass += 1;
   if(isStochFastCrossOverArea){
      intStochFastCrossOverAreaPass += 1;
   }
   
}

void CStrategySmOne::GetSignal(void)
{
   string sig = oCStochCross.GetEntrySignal();
   if(sig != "none"){
      this.SetSignal(sig);
   }
}

void CStrategySmOne::CancelSignal()
{
   this.SetSignal("none");
}

void CStrategySmOne::SetSignal(string type)
{
   strSignalType = type;
   isCurrSignalOpen = false;
   intCurrSignalPass = -1;
   
   isStochFastCrossOverArea = false;
   intStochFastCrossOverAreaPass = -1;
   
}

void CStrategySmOne::Entry()
{
   if(!oCTicket.isCanOpenOrder()){
      return ;
   }
   if(isCurrSignalOpen){
      return ;
   }
   
   if(!isStochFastCrossOverArea && intCurrSignalPass <15){
      if(strSignalType == "up" && oCStoch_fast.data[1]>21){
         isStochFastCrossOverArea = true;
         intStochFastCrossOverAreaPass = 0;
      }
      if(strSignalType == "down" && oCStoch_fast.data[1]<79){
         isStochFastCrossOverArea = true;
         intStochFastCrossOverAreaPass = 0;
      }
   }
   
   if(isStochFastCrossOverArea && strSignalType == "up" && intStochFastCrossOverAreaPass<17){
      if(oCStoch_fast.data[2]>oCStoch_slow.data[2] && oCStoch_fast.data[1]<oCStoch_slow.data[1])
      {
        // this.CancelSignal();
         //return ;
      }
      if(oCMa_fast.data[2]-oCMa_fast.data[1]<0.2*oCTrade.GetPip() && 
           oCStoch_fast.data[1] < 76 && 
           oCStoch_fast.data[1] >oCStoch_fast.data[2] && 
           oCStoch_fast.data[2] >oCStoch_fast.data[3] && 
           oCStoch_fast.data[1] > oCStoch_slow.data[1] && oCStoch_fast.data[1] - oCStoch_slow.data[1]<40 && 
           Close[2]>oCMa_fast.data[2] && 
            Close[1]>Open[1] && 
            Close[1]>oCMa_fast.data[1] && 
            (Ask - oCMa_fast.data[1]<3.5*oCTrade.GetPip()) && 
            ( Close[3] - oCMa_fast.data[3] > 1.2*oCTrade.GetPip() || Close[2] - oCMa_fast.data[2] > 1.2*oCTrade.GetPip() || Close[1] - oCMa_fast.data[1] > 1.2*oCTrade.GetPip() )
        )
      {
               
           double pips = CPriceAction::Distance(20)/oCTrade.GetPip(); 
           if(pips > 2){
               isCurrSignalOpen = true;
               oCTicket.Buy(Lots, Tp, Sl, "SmOne");
               
           }
      }
     
   }
   
   if(isStochFastCrossOverArea && strSignalType == "down" && intStochFastCrossOverAreaPass<17){
      if(oCStoch_fast.data[2]<oCStoch_slow.data[2] && oCStoch_fast.data[1]>oCStoch_slow.data[1])
      {
        // this.CancelSignal();
        // return ;
      }
      Print("------------------down---------------------",oCMa_fast.data[1],"---",oCMa_fast.data[2]);
      if(oCMa_fast.data[1] - oCMa_fast.data[2] <0.2*oCTrade.GetPip() && 
         oCStoch_fast.data[1] >24 && 
         oCStoch_fast.data[1] <oCStoch_fast.data[2] && 
         oCStoch_fast.data[2] <oCStoch_fast.data[3] && 
         oCStoch_fast.data[1] < oCStoch_slow.data[1] &&  oCStoch_slow.data[1]-oCStoch_fast.data[1]<40 && 
         Close[2] < oCMa_fast.data[2] && 
         Close[1]<Open[1] && 
         Close[1]<oCMa_fast.data[1] && 
         (oCMa_fast.data[1]-Bid<3.5*oCTrade.GetPip()) && 
         ( oCMa_fast.data[3] -Close[3] > 1.2*oCTrade.GetPip() || oCMa_fast.data[2] -Close[2] > 1.2*oCTrade.GetPip() || oCMa_fast.data[1] -Close[1] > 1.2*oCTrade.GetPip() )
      )
      {
           double pips = CPriceAction::Distance(20)/oCTrade.GetPip(); 
           if(pips > 2){
            isCurrSignalOpen = true;
            oCTicket.Sell(Lots, Tp, Sl, "SmOne");
           }
      }
   }
   
}

void CStrategySmOne::Exit()
{
   int orderpass = oCTicket.GetOrderPass();
   int opType = oCTicket.GetOpType();
   double firstSrValue = oCTicket.GetFirstSrValue();
   int ticket = oCTicket.GetTicket();
   
   if(ticket <= 0){return ;}
   double oop = oCTrade.GetOrderOpenPrice(ticket);
   double otp = oCTrade.GetOrderTakeProfit(ticket);
   double tp;
   
   //设置stochFast穿过超买超卖的数量，设置是否两条stoch都已经到达过超买超卖区域
   oCTicket.CheckOverArea(oCStoch_fast.data[1],oCStoch_slow.data[1]);
   
   //1、开单后，过10根以上，寻找到第一个支撑或阻力位，设置止损
   if(orderpass>10 && firstSrValue == -1){
      int max = orderpass;
      if(orderpass >48){
         max = 48;
      }
      if(opType == OP_BUY)
      {
         for(int i=6;i<max;i++){
            if(oCStoch_fast.data[i] < 70 && max -i >5 && this.FirstSValueCheck(i)){
               firstSrValue = Low[i];
               oCTicket.SetFirstSrValue(firstSrValue);
               double stopLine = firstSrValue - 0.5*oCTrade.GetPip();
               oCTrade.ModifySl(ticket,NormalizeDouble(stopLine, Digits));
               /*
               if(stopLine <oop){
                  if(oop - stopLine>6*oCTrade.GetPip() && oop - stopLine<=10*oCTrade.GetPip()){
                     tp = oop;
                     if(Bid > tp){
                        oCTrade.Close(ticket);
                     }else{
                        oCTrade.ModifyTp(ticket, NormalizeDouble(tp, Digits));
                     }
                  }
                  if(oop - stopLine>10*oCTrade.GetPip()){
                     tp = oop - ((oop - stopLine)/2);
                     if(Bid > tp){
                        oCTrade.Close(ticket);
                     }else{
                        oCTrade.ModifyTp(ticket, NormalizeDouble(tp, Digits));
                     }
                  }
                  
                  
               }
               */
            }
         }
      }
      if(opType == OP_SELL)
      {
         for(int i=6;i<max;i++){
            if(oCStoch_fast.data[i] >30 && max -i >5 && this.FirstRValueCheck(i)){
               firstSrValue = High[i];
               oCTicket.SetFirstSrValue(firstSrValue);
               double stopLine = firstSrValue + 0.5*oCTrade.GetPip();
               oCTrade.ModifySl(ticket,NormalizeDouble(stopLine, Digits));
               /*
               if(stopLine >oop){
                  if(stopLine - oop>6*oCTrade.GetPip() && stopLine-oop<=10*oCTrade.GetPip()){
                     tp = oop;
                     if(Ask < tp){
                        oCTrade.Close(ticket);
                     }else{
                        oCTrade.ModifyTp(ticket, NormalizeDouble(tp, Digits));
                     }
                  }
                  if(stopLine-oop>10*oCTrade.GetPip()){
                     tp = oop + ((stopLine-oop)/2);
                     if(Ask < tp){
                        oCTrade.Close(ticket);
                     }else{
                        oCTrade.ModifyTp(ticket, NormalizeDouble(tp, Digits));
                     }
                  }
                  
                  
               }
               */
            }
         }
      }
   }
   
   //2、buy：假设stoch14和stoch100都>80，然后(都掉到小于80)或(Close[1]<MaFast[1])
   bool isOver = oCTicket.GetIsTwoStochHavedInOverArea();
   if(isOver){
      if(opType == OP_BUY && ((oCStoch_fast.data[1]<80 && oCStoch_slow.data[1]<80) || Close[1] < oCMa_fast.data[1])){
         oCTrade.Close(ticket);
      }
      if(opType == OP_SELL && ((oCStoch_fast.data[1]>20 && oCStoch_slow.data[1]>20) || Close[1] > oCMa_fast.data[1])){
         oCTrade.Close(ticket);
      }
   }
   
   //3、buy：算出srValue后第一次stoch14进入超买区域，并且慢stoch大于50，如果Close[1]<MaFast则退出
   bool b = oCTicket.GetIsAfterFirstSrValueInOverArea();
   if(b){
      if(opType == OP_BUY && oCStoch_slow.data[1]>50 && Close[1] < oCMa_fast.data[1]){
         oCTrade.Close(ticket);
      }
      if(opType == OP_SELL && oCStoch_slow.data[1]<50 && Close[1] > oCMa_fast.data[1]){
         oCTrade.Close(ticket);
      }
   }
   
   //4、firstValue已有值，并且如果盈利大于6则移动止损到z2
   if(firstSrValue != -1){
      if(opType == OP_BUY && Bid - oop>6*oCTrade.GetPip()){
         oCTrade.ModifySl(ticket,NormalizeDouble(oop+2*oCTrade.GetPip(), Digits));
      }
      if(opType == OP_SELL && oop-Ask>6*oCTrade.GetPip()){
         oCTrade.ModifySl(ticket,NormalizeDouble(oop-2*oCTrade.GetPip(), Digits));
      }
   }
   //5、如果算出支撑阻力点，并且进入over区域2次以上，盈利都没大于3则关单子
   if(firstSrValue != -1 && oCTicket.GetOverAreaCount()>=2){
      if(opType == OP_BUY && Bid - oop<3*oCTrade.GetPip() && Bid - oop>0 && oCStoch_slow.data[1] <50){
         oCTrade.Close(ticket);
      }
      if(opType == OP_SELL && oop -Ask<3*oCTrade.GetPip() && oop-Ask>0  && oCStoch_slow.data[1] >50){
         oCTrade.Close(ticket);
      }
   }
   //6、如果柱子数大于10，慢stoch都没大于30则考虑止损
   /*
   if(oCTicket.GetOrderPass()>=10){
      if(opType == OP_BUY && oCStoch_slow.data[1]<oCStoch_slow.data[2] && oCStoch_slow.data[1]<31 && Bid - oop<2.2*oCTrade.GetPip()){
         oCTrade.Close(ticket);
      }
      if(opType == OP_SELL && oCStoch_slow.data[1]>oCStoch_slow.data[2] && oCStoch_slow.data[1]>69 && oop-Ask<2.2*oCTrade.GetPip()){
         oCTrade.Close(ticket);
      }
   }
   */
   
   //过了18根都没到overArea一次，则降低TP
   if(oCTicket.GetOrderPass()>=18 && oCTicket.GetOverAreaCount() <1){
      
      if(opType == OP_BUY ){
         if(Bid - oop>2.5*oCTrade.GetPip()){
            oCTrade.Close(ticket);
         }else{
            if(otp - oop>3.5*oCTrade.GetPip()){
               oCTrade.ModifyTp(ticket, NormalizeDouble(oop+3*oCTrade.GetPip(), Digits));
            }
         }
         
      }
      if(opType == OP_SELL){
         if(oop - Ask>2.5*oCTrade.GetPip()){
            oCTrade.Close(ticket);
         }else{
            if(oop - otp>3.5*oCTrade.GetPip()){
               oCTrade.ModifyTp(ticket, NormalizeDouble(oop-3*oCTrade.GetPip(), Digits));
            }
         }
         
      }
   }
   
   
}



////////////////////
//up support 
bool CStrategySmOne::FirstSValueCheck(int index)
{
   for(int i=index-5;i<index;i++){
      if(oCStoch_fast.data[i] < oCStoch_fast.data[index]){
         return false;
      }
   }
   for(int i=index+1;i<index+6;i++){
      if(oCStoch_fast.data[i] < oCStoch_fast.data[index]){
         return false;
      }
   }
   return true;
}
//down R
bool CStrategySmOne::FirstRValueCheck(int index)
{
   for(int i=index-5;i<index;i++){
      if(oCStoch_fast.data[i] > oCStoch_fast.data[index]){
         return false;
      }
   }
   for(int i=index+1;i<index+6;i++){
      if(oCStoch_fast.data[i] > oCStoch_fast.data[index]){
         return false;
      }
   }
   return true;
}