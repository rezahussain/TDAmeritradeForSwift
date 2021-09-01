//
//  File.swift
//  
//
//  Created by admin on 7/18/21.
//

import Foundation


extension TDAmeritradeForSwift
{
    public class func doOrderFillOrKillImitation(tdAmeritradeAccountNumber:Int,accessTokenToUse:String,quantity:Int,symbol:String,limitPrice:Optional<Decimal>,timeLimitSecondsForFill:UInt,orderType:orderTypeEnum)->Optional<Order>
    {
        
        var someOrder:Optional<Order> = doOrder(tdAmeritradeAccountNumber:tdAmeritradeAccountNumber,accessTokenToUse:accessTokenToUse,quantity:quantity,symbol:symbol,limitPrice:limitPrice,orderType:orderType)
        
        if someOrder != nil
        {
            let startDate = Date()
            
            var didFill:Bool = false
            
            while Date().timeIntervalSince(startDate) < Double(timeLimitSecondsForFill)
            {
                someOrder!.refresh(tdAmeritradeAccountNumber: tdAmeritradeAccountNumber, accessTokenToUse: accessTokenToUse)
                if someOrder!.status!.compare("FILLED") == .orderedSame
                {
                    didFill = true
                    break
                }
                if someOrder!.status!.compare("REJECTED") == .orderedSame
                {
                    didFill = false
                    break
                }
                sleep(1)
            }
            
            someOrder!.refresh(tdAmeritradeAccountNumber: tdAmeritradeAccountNumber, accessTokenToUse: accessTokenToUse)
            
            if didFill
            {
                
            }
            else
            {
                if someOrder!.cancelable! == true
                {
                    someOrder!.cancel(tdAmeritradeAccountNumber: tdAmeritradeAccountNumber, accessTokenToUse: accessTokenToUse)
                    
                    var tries:Int = 0
                    while someOrder!.status!.compare("CANCELED") != .orderedSame && someOrder!.status!.compare("FILLED") != .orderedSame
                    {
                        someOrder!.refresh(tdAmeritradeAccountNumber: tdAmeritradeAccountNumber, accessTokenToUse: accessTokenToUse)
                        sleep(1)
                        
                        tries = tries + 1
                        if tries > 5
                        {
                            break
                        }
                    }
                }
                
            }
            
        }
        
        return someOrder
        
    }
    
}

