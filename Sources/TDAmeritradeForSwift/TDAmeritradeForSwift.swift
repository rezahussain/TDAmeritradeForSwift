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

public struct Quote:Decodable
{
    let symbol:String
    let bidPrice:Float
    let askPrice:Float
    let bidSize:UInt
    let askSize:UInt
    let lastPrice:Float
    let lastSize:UInt
    let openPrice:Float
    let highPrice:Float
    let lowPrice:Float
    let closePrice:Float
    let totalVolume:Float
    let marginable:Bool
    let shortable:Bool
    let securityStatus:String
    let delayed:Bool
    
    /*
     {
       "AAPL": {
         "assetType": "EQUITY",
         "assetMainType": "EQUITY",
         "cusip": "037833100",
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

public struct Instrument:Decodable,Encodable
{
    let assetType:String
    //let cusip:String
    let symbol:String
    /*
     "instrument": {
       "assetType": "EQUITY",
       "cusip": "69420",
       "symbol": "TXN"
     },
     */
}

public struct Position:Decodable
{
    let shortQuantity:Int
    let averagePrice:Float
    let currentDayProfitLoss:Float
    let currentDayProfitLossPercentage:Float
    let longQuantity:Int
    let settledLongQuantity:Int
    let settledShortQuantity:Int//this can be negative so i just used Int for all of them to be consistent
    let instrument:Instrument
    let marketValue:Float
    let maintenanceRequirement:Float
        
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

public struct Account:Decodable
{
    let type:String
    let accountId:String
    let roundTrips:Int
    let isDayTrader:Bool
    let isClosingOnlyRestricted:Bool
    let positions:[Position]
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
public struct OrderLeg:Decodable,Encodable
{
    let instruction:String//BUY,SELL,BUY_TO_COVER,SELL_SHORT
    let quantity:Int
    let instrument:Instrument
    let quantityType:String
}


public struct Order:Decodable,Encodable
{
    let orderType:String
    let session:String
    let duration:String
    let orderStrategyType:String//dont know what this is
    let orderLegCollection:[OrderLeg]
    let price:Decimal
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
                
                print(someJson)
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








    public class func tryToEnterLongPosition(accountNumber:Int,accessTokenToUse:String,quantity:Int,symbol:String,limitPrice:Decimal)->Bool
    {
        /*
         https://developer.tdameritrade.com/account-access/apis
         
         So the tdameritrade api doesn't allow you to choose the orderid and
         they dont provide an orderid after placing an order
         like alpaca does or etrade
         
         So think of this scenario:
         
         BUY 1x AAPL
         BUY 1x AAPL
         
         With their api, you can only
            retrieve
            -all orders by account
            -all orders by a query
         
         so what am I gonna do, separately track that I have two AAPL orders
         then query all of the orders I have made for today, then separately count them
         and make sure the end number matches, then make more queries for each order status
         to see where they ended up?
         
         it defeats the purpose if I have to code my own order tracking, and would have been so much simpler
            if they provided an order id after placing an order or let me provide an order id when placing
         
         because then I can make one function that places the order, then loops and watches it's status like
         I can for the other brokers.
         
         But its possible there is a good reason they have that I just dont know about
            or there is something right in front of me that im oblivious to
         
         so im just doing Fill or kill, then checking whether the position size changed
         in the account summary
         
         and will return a boolean on whether position size changed or not
        */

        
        //-----------------------------
        // 1 get account before
        // 2 get account after 3 seconds
        // 3 compare for diff
        
        let accountBefore = getAccount(tdAmeritradeAccountNumber:accountNumber,accessTokenToUse:accessTokenToUse)
        
        var startingPosition:Optional<Position> = nil
        for position in accountBefore!.positions
        {
            if position.instrument.symbol.compare(symbol) == .orderedSame
            {
                startingPosition = position
            }
        }
        //-----------------------------
        
        
        //https://developer.tdameritrade.com/account-access/apis/post/accounts/%7BaccountId%7D/orders-0
        let anInstrument = Instrument(assetType: "EQUITY", symbol: symbol)
        let anOrderLeg = OrderLeg(instruction: "BUY", quantity: quantity, instrument: anInstrument, quantityType: "SHARES")
        let orderLegs = [anOrderLeg]
        let newOrder = Order(orderType: "LIMIT", session: "NORMAL", duration: "FILL_OR_KILL", orderStrategyType: "SINGLE", orderLegCollection: orderLegs,price:limitPrice)
        
        //https://www.advancedswift.com/http-requests-in-swift/
        let url = URL(string:"https://api.tdameritrade.com/v1/accounts/\(accountNumber)/orders")!
        var request = URLRequest(url:url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(accessTokenToUse)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try! encoder.encode(newOrder)
        print(String(data: jsonData, encoding: .utf8)!)
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
                
                /*
                //https://www.avanderlee.com/swift/json-parsing-decoding/
                struct someResponse: Decodable
                {
                    let access_token:String
                }
                */
                let someJson = String(data: data, encoding: .utf8)!
                print(someJson)
                //let jsonData = someJson.data(using: .utf8)!
                //let decoder = JSONDecoder()
                //let aResponse = try! decoder.decode(someResponse.self, from: jsonData)
                //accessToken = aResponse.access_token
                
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
        
        
        //-----------------------------
        
        sleep(3)
        
        let accountAfter = getAccount(tdAmeritradeAccountNumber:accountNumber,accessTokenToUse:accessTokenToUse)
        var endingPosition:Optional<Position> = nil
        for position in accountAfter!.positions
        {
            if position.instrument.symbol.compare(symbol) == .orderedSame
            {
                endingPosition = position
            }
        }
        
        //-----------------------------
        
        
        var didItFill:Bool = false
        
        if endingPosition != nil && startingPosition == nil
        {
            didItFill = true
        }
        
        if endingPosition != nil && startingPosition != nil
        {
            if endingPosition!.longQuantity > startingPosition!.longQuantity
            {
                didItFill = true
            }
        }
        
        //-----------------------------
        
        return didItFill
    }





    public class func tryToExitLongPosition(accountNumber:Int,accessTokenToUse:String,quantity:Int,symbol:String,limitPrice:Decimal)->Bool
    {
        
        //-----------------------------
        // 1 get account before
        // 2 get account after 3 seconds
        // 3 compare for diff
        
        let accountBefore = getAccount(tdAmeritradeAccountNumber:accountNumber,accessTokenToUse:accessTokenToUse)
        
        var startingPosition:Optional<Position> = nil
        for position in accountBefore!.positions
        {
            if position.instrument.symbol.compare(symbol) == .orderedSame
            {
                startingPosition = position
            }
        }
        //-----------------------------
        
        
        //https://developer.tdameritrade.com/account-access/apis/post/accounts/%7BaccountId%7D/orders-0
        let anInstrument = Instrument(assetType: "EQUITY", symbol: symbol)
        let anOrderLeg = OrderLeg(instruction: "SELL", quantity: quantity, instrument: anInstrument, quantityType: "SHARES")
        let orderLegs = [anOrderLeg]
        let newOrder = Order(orderType: "LIMIT", session: "NORMAL", duration: "FILL_OR_KILL", orderStrategyType: "SINGLE", orderLegCollection: orderLegs,price:limitPrice)
        
        //https://www.advancedswift.com/http-requests-in-swift/
        let url = URL(string:"https://api.tdameritrade.com/v1/accounts/\(accountNumber)/orders")!
        var request = URLRequest(url:url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(accessTokenToUse)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try! encoder.encode(newOrder)
        print(String(data: jsonData, encoding: .utf8)!)
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
                
                /*
                //https://www.avanderlee.com/swift/json-parsing-decoding/
                struct someResponse: Decodable
                {
                    let access_token:String
                }
                */
                let someJson = String(data: data, encoding: .utf8)!
                print(someJson)
                //let jsonData = someJson.data(using: .utf8)!
                //let decoder = JSONDecoder()
                //let aResponse = try! decoder.decode(someResponse.self, from: jsonData)
                //accessToken = aResponse.access_token
                
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
        
        
        //-----------------------------
        
        sleep(3)
        
        let accountAfter = getAccount(tdAmeritradeAccountNumber:accountNumber,accessTokenToUse:accessTokenToUse)
        var endingPosition:Optional<Position> = nil
        for position in accountAfter!.positions
        {
            if position.instrument.symbol.compare(symbol) == .orderedSame
            {
                endingPosition = position
            }
        }
        
        //-----------------------------
        

        
        var didItFill:Bool = false
        
        if endingPosition == nil && startingPosition != nil
        {
            didItFill = true
        }
        
        if endingPosition != nil && startingPosition != nil
        {
            if endingPosition!.longQuantity < startingPosition!.longQuantity
            {
                didItFill = true
            }
        }
        
        //-----------------------------
        
        return didItFill
    }



    public class func tryToEnterShortPosition(accountNumber:Int,accessTokenToUse:String,quantity:Int,symbol:String,limitPrice:Decimal)->Bool
    {
        
        //-----------------------------
        // 1 get account before
        // 2 get account after 3 seconds
        // 3 compare for diff
        
        let accountBefore = getAccount(tdAmeritradeAccountNumber:accountNumber,accessTokenToUse:accessTokenToUse)
        
        var startingPosition:Optional<Position> = nil
        for position in accountBefore!.positions
        {
            if position.instrument.symbol.compare(symbol) == .orderedSame
            {
                startingPosition = position
            }
        }
        //-----------------------------
        
        
        //https://developer.tdameritrade.com/account-access/apis/post/accounts/%7BaccountId%7D/orders-0
        let anInstrument = Instrument(assetType: "EQUITY", symbol: symbol)
        let anOrderLeg = OrderLeg(instruction: "SELL_SHORT", quantity: quantity, instrument: anInstrument, quantityType: "SHARES")
        let orderLegs = [anOrderLeg]
        let newOrder = Order(orderType: "LIMIT", session: "NORMAL", duration: "FILL_OR_KILL", orderStrategyType: "SINGLE", orderLegCollection: orderLegs,price:limitPrice)
        
        //https://www.advancedswift.com/http-requests-in-swift/
        let url = URL(string:"https://api.tdameritrade.com/v1/accounts/\(accountNumber)/orders")!
        var request = URLRequest(url:url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(accessTokenToUse)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try! encoder.encode(newOrder)
        print(String(data: jsonData, encoding: .utf8)!)
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
                
                /*
                //https://www.avanderlee.com/swift/json-parsing-decoding/
                struct someResponse: Decodable
                {
                    let access_token:String
                }
                */
                let someJson = String(data: data, encoding: .utf8)!
                print(someJson)
                //let jsonData = someJson.data(using: .utf8)!
                //let decoder = JSONDecoder()
                //let aResponse = try! decoder.decode(someResponse.self, from: jsonData)
                //accessToken = aResponse.access_token
                
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
        
        
        //-----------------------------
        
        sleep(3)
        
        let accountAfter = getAccount(tdAmeritradeAccountNumber:accountNumber,accessTokenToUse:accessTokenToUse)
        var endingPosition:Optional<Position> = nil
        for position in accountAfter!.positions
        {
            if position.instrument.symbol.compare(symbol) == .orderedSame
            {
                endingPosition = position
            }
        }
        
        //-----------------------------
        
      
        var didItFill:Bool = false
        
        if endingPosition != nil && startingPosition == nil
        {
            didItFill = true
        }
        
        if endingPosition != nil && startingPosition != nil
        {
            //short positions have negative quantities
            if endingPosition!.shortQuantity < startingPosition!.shortQuantity
            {
                didItFill = true
            }
        }
        
        //-----------------------------
        
        return didItFill
    }


    public class func tryToExitShortPosition(accountNumber:Int,accessTokenToUse:String,quantity:Int,symbol:String,limitPrice:Decimal)->Bool
    {
        
        //-----------------------------
        // 1 get account before
        // 2 get account after 3 seconds
        // 3 compare for diff
        
        let accountBefore = getAccount(tdAmeritradeAccountNumber:accountNumber,accessTokenToUse:accessTokenToUse)
        
        var startingPosition:Optional<Position> = nil
        for position in accountBefore!.positions
        {
            if position.instrument.symbol.compare(symbol) == .orderedSame
            {
                startingPosition = position
            }
        }
        //-----------------------------
        
        
        //https://developer.tdameritrade.com/account-access/apis/post/accounts/%7BaccountId%7D/orders-0
        let anInstrument = Instrument(assetType: "EQUITY", symbol: symbol)
        let anOrderLeg = OrderLeg(instruction: "BUY_TO_COVER", quantity: quantity, instrument: anInstrument, quantityType: "SHARES")
        let orderLegs = [anOrderLeg]
        let newOrder = Order(orderType: "LIMIT", session: "NORMAL", duration: "FILL_OR_KILL", orderStrategyType: "SINGLE", orderLegCollection: orderLegs,price:limitPrice)
        
        //https://www.advancedswift.com/http-requests-in-swift/
        let url = URL(string:"https://api.tdameritrade.com/v1/accounts/\(accountNumber)/orders")!
        var request = URLRequest(url:url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(accessTokenToUse)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try! encoder.encode(newOrder)
        print(String(data: jsonData, encoding: .utf8)!)
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
                
                /*
                //https://www.avanderlee.com/swift/json-parsing-decoding/
                struct someResponse: Decodable
                {
                    let access_token:String
                }
                */
                let someJson = String(data: data, encoding: .utf8)!
                print(someJson)
                //let jsonData = someJson.data(using: .utf8)!
                //let decoder = JSONDecoder()
                //let aResponse = try! decoder.decode(someResponse.self, from: jsonData)
                //accessToken = aResponse.access_token
                
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
        
        
        //-----------------------------
        
        sleep(3)
        
        let accountAfter = getAccount(tdAmeritradeAccountNumber:accountNumber,accessTokenToUse:accessTokenToUse)
        var endingPosition:Optional<Position> = nil
        for position in accountAfter!.positions
        {
            if position.instrument.symbol.compare(symbol) == .orderedSame
            {
                endingPosition = position
            }
        }
        
        //-----------------------------
        
        
        var didItFill:Bool = false
        
        if endingPosition == nil && startingPosition != nil
        {
            didItFill = true
        }
        
        if endingPosition != nil && startingPosition != nil
        {
            //short positions have negative quantities
            if endingPosition!.shortQuantity > startingPosition!.shortQuantity
            {
                didItFill = true
            }
        }
        
        //-----------------------------
        
        return didItFill
    }















    
}

