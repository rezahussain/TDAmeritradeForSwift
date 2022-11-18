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
                    return nil
                    //break
                }
                sleep(1)
            }
            
            
            
            if didFill
            {
                
            }
            else
            {
                someOrder!.refresh(tdAmeritradeAccountNumber: tdAmeritradeAccountNumber, accessTokenToUse: accessTokenToUse)
                
                if someOrder!.cancelable! == true
                {
                    someOrder!.cancel(tdAmeritradeAccountNumber: tdAmeritradeAccountNumber, accessTokenToUse: accessTokenToUse)
                    
                    var tries:Int = 0
                    while (someOrder!.status!.compare("CANCELED") != .orderedSame) && (someOrder!.status!.compare("FILLED") != .orderedSame) && (someOrder!.status!.compare("REJECTED") != .orderedSame)
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
                else
                {
                    print("order not cancellable")
                    var tries:Int = 0
                    while ((someOrder!.status!.compare("FILLED") != .orderedSame) && (someOrder!.status!.compare("REJECTED") != .orderedSame))
                    {
                        someOrder!.refresh(tdAmeritradeAccountNumber: tdAmeritradeAccountNumber, accessTokenToUse: accessTokenToUse)
                        print("waiting for non cancellable order to fill or get rejected  \(someOrder!.status!) \(someOrder!) \(Date())")
                        sleep(1)
                        tries = tries + 1
                        if tries > 10
                        {
                            break
                        }
                    }
                }
                
            }
            
            //------------------------------------------
            
            //tdameritrade api reports FILLED once an order's filledQuantity goes above 0
            //so we have to refresh because that number can keep going up in the mean time
            //tdameritrade api also changes the filledquantity even when u cancel, it can have a partial fill
            //so in that case you still want to have a couple of refreshes to make sure that the filledQuantity stopped moving
            //after we cancelled
            //this is what I use, its not perfect but does what I need right now
            
            if (someOrder!.status!.compare("CANCELED") == .orderedSame) || (someOrder!.status!.compare("FILLED") == .orderedSame)
            {
                var tries:Int = 0
                while tries < 5
                {
                    if (someOrder!.filledQuantity != nil)
                    {
                        if someOrder!.filledQuantity! == quantity
                        {
                            break
                        }
                        else
                        {
                            someOrder!.refresh(tdAmeritradeAccountNumber: tdAmeritradeAccountNumber, accessTokenToUse: accessTokenToUse)
                            tries = tries + 1
                            sleep(1)
                        }
                    }
                }
            }
            
            if someOrder!.status!.compare("REJECTED") == .orderedSame
            {
                return nil
            }
            
            /*
            cuz it can be cancelled with a partial fill ugh, so you cant do this

            if someOrder!.status!.compare("CANCELED") == .orderedSame
            {
                return nil
            }*/
            
            //------------------------------------------
            
        }
        
        return someOrder
        
    }
    
}

