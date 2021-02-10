//
//  TDAPIBridge.swift
//  test
//
//  Created by admin on 2/6/21.
//

import Foundation
import PerfectHTTP
import PerfectHTTPServer
import AppKit


extension Date
{
    func yyyy_mm_ddString()->String
    {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd"
        inputDateFormatter.timeZone = TimeZone.init(identifier: "EST")//why didnt they use GMT :\
        inputDateFormatter.locale = Locale.init(identifier: "EST")
        return inputDateFormatter.string(from: self)
    }
}


//https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method
extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}
extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

public struct Quote:Decodable,Encodable,Hashable
{
    public let symbol:String
    public var bidPrice:Decimal
    public var askPrice:Decimal
    public let bidSize:UInt
    public let askSize:UInt
    public var lastPrice:Decimal
    public let lastSize:UInt
    public var openPrice:Decimal
    public var highPrice:Decimal
    public var lowPrice:Decimal
    public var closePrice:Decimal
    public let totalVolume:Float
    public let marginable:Bool
    public let shortable:Bool
    public let securityStatus:String
    public let delayed:Bool
    
    /*
     {
       "AAPL": {
         "assetType": "EQUITY",
         "assetMainType": "EQUITY",
         "symbol": "AAPL",
         "description": "Apple Inc. - Common Stock",
         "bidPrice": 136.68,
         "bidSize": 700,
         "bidId": "P",
         "askPrice": 136.7,
         "askSize": 1000,
         "askId": "P",
         "lastPrice": 136.68,
         "lastSize": 300,
         "lastId": "Q",
         "openPrice": 137.35,
         "highPrice": 137.42,
         "lowPrice": 135.86,
         "bidTick": " ",
         "closePrice": 136.76,
         "netChange": -0.08,
         "totalVolume": 75693830,
         "quoteTimeInLong": 1612573198214,
         "tradeTimeInLong": 1612573198054,
         "mark": 136.76,
         "exchange": "q",
         "exchangeName": "NASD",
         "marginable": true,
         "shortable": true,
         "volatility": 0.0104,
         "digits": 4,
         "52WkHigh": 145.09,
         "52WkLow": 53.1525,
         "nAV": 0,
         "peRatio": 37.1415,
         "divAmount": 0.82,
         "divYield": 0.6,
         "divDate": "2021-02-05 00:00:00.000",
         "securityStatus": "Normal",
         "regularMarketLastPrice": 136.76,
         "regularMarketLastSize": 32349,
         "regularMarketNetChange": 0,
         "regularMarketTradeTimeInLong": 1612558800630,
         "netPercentChangeInDouble": -0.0585,
         "markChangeInDouble": 0,
         "markPercentChangeInDouble": 0,
         "regularMarketPercentChangeInDouble": 0,
         "delayed": false
       }
     }
     */
    
}

public struct Instrument:Decodable,Encodable,Hashable
{
    public let assetType:String
    //let cusip:String
    public let symbol:String
    /*
     "instrument": {
       "assetType": "EQUITY",
       "cusip": "69420",
       "symbol": "TXN"
     },
     */
}

public struct Position:Decodable,Encodable,Hashable
{
    public let shortQuantity:Int
    public let averagePrice:Float
    public let currentDayProfitLoss:Float
    public let currentDayProfitLossPercentage:Float
    public let longQuantity:Int
    public let settledLongQuantity:Int
    public let settledShortQuantity:Int//this can be negative so i just used Int for all of them to be consistent
    public let instrument:Instrument
    public let marketValue:Float
    public let maintenanceRequirement:Float
        
    /*
     {
       "shortQuantity": 0,
       "averagePrice": 146.425,
       "currentDayProfitLoss": 0,
       "currentDayProfitLossPercentage": 0,
       "longQuantity": 2,
       "settledLongQuantity": 2,
       "settledShortQuantity": 0,
       "instrument": {
         "assetType": "EQUITY",
         "cusip": "69420",
         "symbol": "TXN"
       },
       "marketValue": 339.86,
       "maintenanceRequirement": 101.96
     },
     */
}

public struct Account:Decodable,Encodable,Hashable
{
    public let type:String
    public let accountId:String
    public let roundTrips:Int
    public let isDayTrader:Bool
    public let isClosingOnlyRestricted:Bool
    public let positions:[Position]
    /*
     "securitiesAccount": {
         "type": "MARGIN",
         "accountId": "69420",
         "roundTrips": 89,
         "isDayTrader": true,
         "isClosingOnlyRestricted": false,
         "positions": [
           {
             "shortQuantity": 0,
             "averagePrice": 146.425,
             "currentDayProfitLoss": 0,
             "currentDayProfitLossPercentage": 0,
             "longQuantity": 2,
             "settledLongQuantity": 2,
             "settledShortQuantity": 0,
             "instrument": {
               "assetType": "EQUITY",
               "cusip": "69420",
               "symbol": "TXN"
             },
             "marketValue": 339.86,
             "maintenanceRequirement": 101.96
           },
        blah blah
     */
}

//https://developer.tdameritrade.com/content/place-order-samples
public struct OrderLeg:Decodable,Encodable,Hashable
{
    public let instruction:String//BUY,SELL,BUY_TO_COVER,SELL_SHORT
    public let quantity:Int
    public let instrument:Instrument
    public let quantityType:Optional<String>
}

public enum orderTypeEnum
{
    case buy
    case sell
    case sellShort
    case buyToCover
}


public struct Order:Decodable,Encodable,Hashable
{
    public let orderType:String
    public let session:String
    public let duration:String
    public let orderStrategyType:String//dont know what this is
    public let orderLegCollection:[OrderLeg]
    public let price:Decimal
    
    public var filledQuantity:Optional<Int>
    public var remainingQuantity:Optional<Int>
    public var orderId:Optional<Int>
    public var status:Optional<String>
    public var cancelable:Optional<Bool>
    
    public mutating func refresh(tdAmeritradeAccountNumber:Int,accessTokenToUse:String)
    {
        //https://developer.tdameritrade.com/account-access/apis/get/accounts/%7BaccountId%7D/orders/%7BorderId%7D-0
        
        //https://www.advancedswift.com/http-requests-in-swift/
        let url = URL(string:"https://api.tdameritrade.com/v1/accounts/\(tdAmeritradeAccountNumber)/orders/\(orderId!)")!
        
        var request = URLRequest(url:url)
        
        request.setValue("Bearer \(accessTokenToUse)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        var hasError:Optional<Error> = nil
        
        var refreshedOrder:Optional<Order> = nil
        
        //https://developer.apple.com/documentation/foundation/urlsessiondatatask
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in

            if error != nil
            {
                hasError = error
                print(error!.localizedDescription)
            }
            else if let data = data {
                
                //https://www.avanderlee.com/swift/json-parsing-decoding/
                let someJson = String(data: data, encoding: .utf8)!
                
                
                
                let jsonData = someJson.data(using: .utf8)!
                let decoder = JSONDecoder()
                //https://forums.swift.org/t/encoding-decoding-a-swift-dictionary-to-from-json/39989
                refreshedOrder = try! decoder.decode(Order.self, from: jsonData)

            }
            else
            {
                // Handle unexpected error
            }
        }
        task.resume()
        
        while task.state != .completed && hasError == nil
        {
            sleep(1)
        }
        
        self = refreshedOrder!
    }
    
    public mutating func cancel(tdAmeritradeAccountNumber:Int,accessTokenToUse:String)
    {
        //https://developer.tdameritrade.com/account-access/apis/get/accounts/%7BaccountId%7D/orders/%7BorderId%7D-0
        
        //https://www.advancedswift.com/http-requests-in-swift/
        let url = URL(string:"https://api.tdameritrade.com/v1/accounts/\(tdAmeritradeAccountNumber)/orders/\(orderId!)")!
        
        var request = URLRequest(url:url)
        
        request.setValue("Bearer \(accessTokenToUse)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        
        var hasError:Optional<Error> = nil
        
        //https://developer.apple.com/documentation/foundation/urlsessiondatatask
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in

            if error != nil
            {
                hasError = error
                print(error!.localizedDescription)
            }
            else if let data = data {
                
            }
            else
            {
                // Handle unexpected error
            }
        }
        task.resume()
        
        while task.state != .completed && hasError == nil
        {
            sleep(1)
        }
        
    }
}


public class TDAmeritradeForSwift
{
    
    public class func obtainInitialAuthorizationCodeUsingLocalhostServer(tempLocalhostServerPort:UInt16,tdameritradeRedirectURI:String,tdameritradeConsumerKey:String,sslCertPath:String,sslKeyPath:String) throws -> (Optional<String>,String)
    {
        //this is the first part, of
        //https://developer.tdameritrade.com/content/simple-auth-local-apps
        //it gets the initial code
        
        var authCode:Optional<String> = nil
        
        func handler(request: HTTPRequest, response: HTTPResponse) {
            
            //print(request.params())//[("code", "123")]

            response.completed()
            
            for (param,value) in request.params()
            {
                if param.compare("code") == .orderedSame
                {
                    //print(value)
                    //perfect url decodes it for us!
                    authCode = value
                }
            }
        }
        
        var routes = Routes()
        routes.add(method: .get, uri: "/", handler: handler)
        
        // https://medium.com/@jonsamp/how-to-set-up-https-on-localhost-for-macos-b597bcf935ee
        // cd ~/
        // mkdir .localhost-ssl
        // create a self signed key and certificate with next command
        // sudo openssl genrsa -out ~/.localhost-ssl/localhost.key 2048
        // sudo openssl req -new -x509 -key ~/.localhost-ssl/localhost.key -out ~/.localhost-ssl/localhost.crt -days 3650 -subj /CN=localhost
        // now you have to drag and drop the crt file into your keychain app, so when the browser opens the callback https://localhost url, it doesnt
        // think that the self signed ssl cert for localhost that we just generated is a mitm attack
        // stuff is here:
        // ~/.localhost-ssl/localhost.crt
        // ~/.localhost-ssl/localhost.key
        // for some reason I had to move them to the desktop before the app got permissions to read them :\
        // "/Users/admin/Desktop/localhost-ssl/localhost.crt"
        
        //https://perfect.org/docs/HTTPServer.html
        //If a "tlsConfig" key is provided then a secure HTTPS server will be attempted.
        let launchContexts = try HTTPServer.launch(wait:false,.secureServer(TLSConfiguration(certPath: sslCertPath,keyPath:sslKeyPath), name: "localhost", port: Int(tempLocalhostServerPort), routes: routes))
        
        //https://stackoverflow.com/questions/24551816/swift-encode-url
        let tdameritradeRedirectURIURLEncoded = tdameritradeRedirectURI.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let tdameritradeConsumerKeyURLEncoded = tdameritradeConsumerKey.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let urlEncodedRedirectURI = tdameritradeRedirectURIURLEncoded!
        let urlEncodedConsumerKey = tdameritradeConsumerKeyURLEncoded!
        let basicUrl = "https://auth.tdameritrade.com/auth?response_type=code&redirect_uri=\(urlEncodedRedirectURI)&client_id=\(urlEncodedConsumerKey)%40AMER.OAUTHAP"
        
        if let url = URL(string: basicUrl)
        {
            NSWorkspace.shared.open(url)
        }
        
        while authCode == nil
        {
            print("waiting for initial auth token \(Date())")
            sleep(1)
        }
        
        //launchContexts[0].terminate()
        //I dont like to terminate because it gives the below error, its not an error :\
        //Unexpected networking error: 53 'Software caused connection abort
        //the http server terminates when it goes out of scope anyways
        let clientId = "\(tdameritradeConsumerKey)@AMER.OAUTHAP"
        
        //the values need to be taken and used with
        //https://developer.tdameritrade.com/authentication/apis/post/token-0
        //grant_type: authorization_code
        //access_type: offline
        //client_id: clientId above
        //code: authCode
        //redirect_uri: tdameritradeRedirectURI
        //this will give you an access token and a refresh token
        //the access token is used to make requests, and the refresh token is used to get
        //new access tokens, because they expire after 1800 seconds(30 min)
        //refresh tokens expire in 90 days
        
        return (authCode,clientId)
    }




    public class func grantRefreshTokenAndAccessTokenUsingAuthorizationCode(clientId:String,authCode:String,tdameritradeRedirectURI:String)->(Optional<String>,Optional<String>)
    {
        //https://developer.tdameritrade.com/authentication/apis/post/token-0
        //grant_type: authorization_code
        //access_type: offline
        //client_id: clientId above
        //code: authCode
        //redirect_uri: tdameritradeRedirectURI
        //this will give you an access token and a refresh token
        //the access token is used to make requests, and the refresh token is used to get
        //new access tokens, because they expire after 1800 seconds(30 min)
        //refresh tokens expire in 90 days
        
        
        //https://www.advancedswift.com/http-requests-in-swift/
        let url = URL(string:"https://api.tdameritrade.com/v1/oauth2/token")!
        var request = URLRequest(url:url)
        
        
        let body = ["grant_type":"authorization_code","redirect_uri":tdameritradeRedirectURI,"access_type":"offline","code":authCode,"client_id":clientId]
        

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        request.httpBody = body.percentEncoded()!
        //print(String(data: body.percentEncoded()!, encoding: .utf8)!)
        
        
        var hasError:Optional<Error> = nil
        
        var refreshToken:Optional<String> = nil
        var accessToken:Optional<String> = nil
        
        //https://developer.apple.com/documentation/foundation/urlsessiondatatask
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in

            if error != nil
            {
                hasError = error
                print(error!.localizedDescription)
            }
            else if let data = data {
                
                //https://www.avanderlee.com/swift/json-parsing-decoding/
                struct someResponse: Decodable
                {
                    let refresh_token:String
                    let access_token:String
                }
                let someJson = String(data: data, encoding: .utf8)!
                
                let jsonData = someJson.data(using: .utf8)!
                let decoder = JSONDecoder()
                let aResponse = try! decoder.decode(someResponse.self, from: jsonData)
                refreshToken = aResponse.refresh_token
                accessToken = aResponse.access_token
                
            }
            else
            {
                // Handle unexpected error
            }
        }
        task.resume()
        
        while task.state != .completed && hasError == nil
        {
            sleep(1)
        }
        
        return (refreshToken,accessToken)
    }




    public class func grantAccessTokenUsingRefreshToken(clientId:String,refreshToken:String,tdameritradeRedirectURI:String)->Optional<String>
    {
        //https://developer.tdameritrade.com/authentication/apis/post/token-0
        //grant_type: authorization_code
        //access_type: offline
        //client_id: clientId above
        //code: authCode
        //redirect_uri: tdameritradeRedirectURI
        //this will give you an access token and a refresh token
        //the access token is used to make requests, and the refresh token is used to get
        //new access tokens, because they expire after 1800 seconds(30 min)
        //refresh tokens expire in 90 days
        
        
        //https://www.advancedswift.com/http-requests-in-swift/
        let url = URL(string:"https://api.tdameritrade.com/v1/oauth2/token")!
        var request = URLRequest(url:url)
        
        
        let body = ["grant_type":"refresh_token","redirect_uri":tdameritradeRedirectURI,"refresh_token":refreshToken,"client_id":clientId]
        

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        request.httpBody = body.percentEncoded()!
        //print(String(data: body.percentEncoded()!, encoding: .utf8)!)
        
        
        var hasError:Optional<Error> = nil
        
        
        var accessToken:Optional<String> = nil
        
        //https://developer.apple.com/documentation/foundation/urlsessiondatatask
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in

            if error != nil
            {
                hasError = error
                print(error!.localizedDescription)
            }
            else if let data = data {
                
                //https://www.avanderlee.com/swift/json-parsing-decoding/
                struct someResponse: Decodable
                {
                    let access_token:String
                }
                let someJson = String(data: data, encoding: .utf8)!
                
                let jsonData = someJson.data(using: .utf8)!
                let decoder = JSONDecoder()
                let aResponse = try! decoder.decode(someResponse.self, from: jsonData)
                accessToken = aResponse.access_token
                
            }
            else
            {
                // Handle unexpected error
            }
        }
        task.resume()
        
        while task.state != .completed && hasError == nil
        {
            sleep(1)
        }
        
        return accessToken
    }







    public class func getQuoteForSingleSymbol(symbol:String,accessTokenToUse:String)->Optional<Quote>
    {
        

        
        var someQuote:Optional<Quote> = nil
        
        //https://www.advancedswift.com/http-requests-in-swift/
        let url = URL(string:"https://api.tdameritrade.com/v1/marketdata/\(symbol)/quotes")!
        var request = URLRequest(url:url)
        
        request.setValue("Bearer \(accessTokenToUse)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        var hasError:Optional<Error> = nil
        
        //https://developer.apple.com/documentation/foundation/urlsessiondatatask
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in

            if error != nil
            {
                hasError = error
                print(error!.localizedDescription)
            }
            else if let data = data {
                
                //https://www.avanderlee.com/swift/json-parsing-decoding/
                let someJson = String(data: data, encoding: .utf8)!
                
                //print(someJson)
                //print(response!.description)
                
                let jsonData = someJson.data(using: .utf8)!
                let decoder = JSONDecoder()
                //https://forums.swift.org/t/encoding-decoding-a-swift-dictionary-to-from-json/39989
                let someQuotePackage = try! decoder.decode([String:Quote].self, from: jsonData)
                
                let (key,value) = someQuotePackage.first!
                someQuote = value
                
                //let properDouble =  Double(someQuote!.lastPrice.description)!
                //let twoDecimalPlaces = String(format: "%.2f", properDouble)
                //someQuote!.lastPrice = Decimal(string:twoDecimalPlaces)!
                
                //funny story, the json encoder only uses floats :\
                someQuote!.bidPrice = Decimal(string:String(format: "%.2f", Double(someQuote!.bidPrice.description)!))!
                someQuote!.askPrice = Decimal(string:String(format: "%.2f", Double(someQuote!.askPrice.description)!))!
                someQuote!.lastPrice = Decimal(string:String(format: "%.2f", Double(someQuote!.lastPrice.description)!))!
                someQuote!.openPrice = Decimal(string:String(format: "%.2f", Double(someQuote!.openPrice.description)!))!
                someQuote!.highPrice = Decimal(string:String(format: "%.2f", Double(someQuote!.highPrice.description)!))!
                someQuote!.lowPrice = Decimal(string:String(format: "%.2f", Double(someQuote!.lowPrice.description)!))!
                someQuote!.closePrice = Decimal(string:String(format: "%.2f", Double(someQuote!.closePrice.description)!))!
                
                
                //let abc:Optional<Double> =  nil
            }
            else
            {
                // Handle unexpected error
            }
        }
        task.resume()
        
        while task.state != .completed && hasError == nil
        {
            sleep(1)
        }
         
        return someQuote
        
    }




    public class func getAccount(tdAmeritradeAccountNumber:Int,accessTokenToUse:String)->Optional<Account>
    {
        
        
        var someAccount:Optional<Account> = nil
        
        //https://www.advancedswift.com/http-requests-in-swift/
        let url = URL(string:"https://api.tdameritrade.com/v1/accounts/\(tdAmeritradeAccountNumber)?fields=positions")!
        var request = URLRequest(url:url)
        
        request.setValue("Bearer \(accessTokenToUse)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        var hasError:Optional<Error> = nil
        
        //https://developer.apple.com/documentation/foundation/urlsessiondatatask
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in

            if error != nil
            {
                hasError = error
                print(error!.localizedDescription)
            }
            else if let data = data {
                
                //https://www.avanderlee.com/swift/json-parsing-decoding/
                let someJson = String(data: data, encoding: .utf8)!
                
                
                //print(response!.description)
                
                let jsonData = someJson.data(using: .utf8)!
                let decoder = JSONDecoder()
                //https://forums.swift.org/t/encoding-decoding-a-swift-dictionary-to-from-json/39989
                let someDictionary = try! decoder.decode([String:Account].self, from: jsonData)
                
                let (key,value) = someDictionary.first!
                someAccount = value
            }
            else
            {
                // Handle unexpected error
            }
        }
        task.resume()
        
        while task.state != .completed && hasError == nil
        {
            sleep(1)
        }

        return someAccount
        
    }
    
    public class func getPositionForSymbol(tdAmeritradeAccountNumber:Int,accessTokenToUse:String,chosenSymbol:String)->Optional<Position>
    {
        
        let someAccount = TDAmeritradeForSwift.getAccount(tdAmeritradeAccountNumber:tdAmeritradeAccountNumber,accessTokenToUse:accessTokenToUse)
        
        var maybePosition:Optional<Position> = nil
        for somePosition in someAccount!.positions
        {
            if somePosition.instrument.symbol.compare(chosenSymbol) == .orderedSame
            {
                maybePosition = somePosition
            }
        }
        
        return maybePosition
        
    }
    
    public class func doOrderFillOrKillImitation(tdAmeritradeAccountNumber:Int,accessTokenToUse:String,quantity:Int,symbol:String,limitPrice:Decimal,timeLimitSecondsForFill:UInt,orderType:orderTypeEnum)->Optional<Order>
    {
        
        var someOrder:Optional<Order> = doOrder(tdAmeritradeAccountNumber:tdAmeritradeAccountNumber,accessTokenToUse:accessTokenToUse,quantity:quantity,symbol:symbol,limitPrice:limitPrice,orderType:orderType)
        
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
        
        if didFill
        {
            return someOrder
        }
        else
        {
            if someOrder!.cancelable! == true
            {
                someOrder!.cancel(tdAmeritradeAccountNumber: tdAmeritradeAccountNumber, accessTokenToUse: accessTokenToUse)
                //someOrder!.refresh(tdAmeritradeAccountNumber: accountNumber, accessTokenToUse: accessToken2!)
                
                var tries:Int = 0
                while someOrder!.status!.compare("CANCELED") != .orderedSame
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
            return someOrder
        }
        
    }
    
    
    
    public class func doOrder(tdAmeritradeAccountNumber:Int,accessTokenToUse:String,quantity:Int,symbol:String,limitPrice:Decimal,orderType:orderTypeEnum)->Optional<Order>
    {
        let beforeOrders = getOrdersFromDate(tdAmeritradeAccountNumber:tdAmeritradeAccountNumber,accessTokenToUse:accessTokenToUse,fromDate:Date())
        switch orderType
        {
            case .buy:
                placeGenericOrder(accountNumber: tdAmeritradeAccountNumber, accessTokenToUse: accessTokenToUse, quantity: quantity, symbol: symbol, limitPrice: limitPrice, instruction: "BUY")
            case .sell:
                placeGenericOrder(accountNumber: tdAmeritradeAccountNumber, accessTokenToUse: accessTokenToUse, quantity: quantity, symbol: symbol, limitPrice: limitPrice, instruction: "SELL")
            case .sellShort:
                placeGenericOrder(accountNumber: tdAmeritradeAccountNumber, accessTokenToUse: accessTokenToUse, quantity: quantity, symbol: symbol, limitPrice: limitPrice, instruction: "SELL_SHORT")
            case .buyToCover:
                placeGenericOrder(accountNumber: tdAmeritradeAccountNumber, accessTokenToUse: accessTokenToUse, quantity: quantity, symbol: symbol, limitPrice: limitPrice, instruction: "BUY_TO_COVER")
        }
        
        let afterOrders = getOrdersFromDate(tdAmeritradeAccountNumber:tdAmeritradeAccountNumber,accessTokenToUse:accessTokenToUse,fromDate:Date())
        
        let boSet = Set<Order>(beforeOrders!)
        let aoSet = Set<Order>(afterOrders!)
        let diff = aoSet.subtracting(boSet)
        
        let newOrder = diff.first
        return newOrder
    }
    

    
    

    public class func getOrdersFromDate(tdAmeritradeAccountNumber:Int,accessTokenToUse:String,fromDate:Date)->Optional<[Order]>
    {
        
        let fromEnteredTime = fromDate.yyyy_mm_ddString()
        let toEnteredTime = fromDate.yyyy_mm_ddString()
        
        var orderArray:Optional<[Order]> = nil
        
        //https://www.advancedswift.com/http-requests-in-swift/
        let url = URL(string:"https://api.tdameritrade.com/v1/accounts/\(tdAmeritradeAccountNumber)/orders?fromEnteredTime=\(fromEnteredTime)&toEnteredTime=\(toEnteredTime)")!
        
    
        //print(url)
        var request = URLRequest(url:url)
        
        request.setValue("Bearer \(accessTokenToUse)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        var hasError:Optional<Error> = nil
        
        //https://developer.apple.com/documentation/foundation/urlsessiondatatask
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in

            if error != nil
            {
                hasError = error
                print(error!.localizedDescription)
            }
            else if let data = data {
                
                //https://www.avanderlee.com/swift/json-parsing-decoding/
                let someJson = String(data: data, encoding: .utf8)!
                
                //print("ok here")
                //print(someJson)
                //print(response!.description)
                
                
                let jsonData = someJson.data(using: .utf8)!
                let decoder = JSONDecoder()
                //https://forums.swift.org/t/encoding-decoding-a-swift-dictionary-to-from-json/39989
                orderArray = try! decoder.decode([Order].self, from: jsonData)
                
            }
            else
            {
                // Handle unexpected error
            }
        }
        task.resume()
        
        while task.state != .completed && hasError == nil
        {
            sleep(1)
        }

        return orderArray
    }

    

    
    
    public class func placeGenericOrder(accountNumber:Int,accessTokenToUse:String,quantity:Int,symbol:String,limitPrice:Decimal,instruction:String)
    {
        
        let anInstrument = Instrument(assetType: "EQUITY", symbol: symbol)
        let anOrderLeg = OrderLeg(instruction: instruction, quantity: quantity, instrument: anInstrument, quantityType: "SHARES")
        let orderLegs = [anOrderLeg]
        let newOrder = Order(orderType: "LIMIT", session: "NORMAL", duration: "DAY", orderStrategyType: "SINGLE", orderLegCollection: orderLegs,price:limitPrice,filledQuantity: nil,remainingQuantity: nil,orderId: nil,status:nil,cancelable: nil)
        
        //https://www.advancedswift.com/http-requests-in-swift/
        let url = URL(string:"https://api.tdameritrade.com/v1/accounts/\(accountNumber)/orders")!
        var request = URLRequest(url:url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(accessTokenToUse)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try! encoder.encode(newOrder)
        //print(String(data: jsonData, encoding: .utf8)!)
        request.httpBody = jsonData
        
        
        var hasError:Optional<Error> = nil
        //https://developer.apple.com/documentation/foundation/urlsessiondatatask

        let session = URLSession.shared

        let task = session.dataTask(with: request) { (data, response, error) in

            if error != nil
            {
     
                print(error!.localizedDescription)
                hasError = error!
            }
            else if let data = data {
                
                
            }
            else
            {
                // Handle unexpected error
            }
        }
        task.resume()
        
        while task.state != .completed && hasError == nil
        {
            sleep(1)
        }
    }
    
}

