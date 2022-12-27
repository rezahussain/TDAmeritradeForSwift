//
//  TDAPIBridge.swift
//  test
//
//  Created by admin on 2/6/21.
//

import Foundation
import AppKit

import Foundation
import Vapor
import NIOSSL

//import PerfectHTTP
//import PerfectHTTPServer


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
    public let price:Optional<Decimal>
    public let taxLotMethod:String =  "LOW_COST"
    
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
        
        let semaphore = DispatchSemaphore(value: 1)
        semaphore.wait()
        
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
                do
                {
                    refreshedOrder = try decoder.decode(Order.self, from: jsonData)
                }
                catch
                {
                    
                }
            }
            else
            {
                // Handle unexpected error
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        semaphore.signal()
        
        while task.state != .completed && hasError == nil
        {
            
        }
        
        if refreshedOrder != nil
        {
            //self = refreshedOrder!
            
            self.filledQuantity = refreshedOrder!.filledQuantity
            self.remainingQuantity = refreshedOrder!.remainingQuantity
            self.orderId = refreshedOrder!.orderId
            self.status = refreshedOrder!.status
            self.cancelable = refreshedOrder!.cancelable

        }
        
        
        
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
        let semaphore = DispatchSemaphore(value: 1)
        semaphore.wait()
        
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
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        semaphore.signal()
        
        while task.state != .completed && hasError == nil
        {
            
        }
        
    }
}



public class TDAmeritradeForSwift
{
    
    /*
    public class func obtainInitialAuthorizationCodeUsingLocalhostServerDeprecated(tempLocalhostServerPort:UInt16,tdameritradeRedirectURI:String,tdameritradeConsumerKey:String,sslCertPath:String,sslKeyPath:String) throws -> (Optional<String>,String)
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
     */
    
    public class func obtainInitialAuthorizationCodeUsingLocalhostServer(tempLocalhostServerPort:UInt16,tdameritradeRedirectURI:String,tdameritradeConsumerKey:String,sslCertPath:String,sslKeyPath:String) throws -> (Optional<String>,String)
    {
        //this is the first part, of
        //https://developer.tdameritrade.com/content/simple-auth-local-apps
        //it gets the initial code
        
        //----------------
        
        
        // configures your application
        func configure(_ app: Application) throws {
            // uncomment to serve files from /Public folder
            // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

            // register routes
            try routes(app)
        }

        var authCode:Optional<String> = nil

        func routes(_ app: Application) throws
        {
            app.get("") { req async -> String in
                //req.parameters
                //https://stackoverflow.com/questions/51954148/how-to-access-query-parameters-in-vapor-3
                authCode = try? req.query.get(String.self, at: "code")
                //print("\(req) \(req.parameters) \(req.parameters.get("code"))")
                return "message received"
            }
        }
        
        
        
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let app = Application(env)
        
        
        
        /*
         https://stackoverflow.com/questions/63195304/difference-between-pem-crt-key-files
         https://stackoverflow.com/questions/10175812/how-to-generate-a-self-signed-ssl-certificate-using-openssl
         openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365 -subj /CN=localhost -nodes
         
         
         this works
         openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365 -subj /CN=localhost -nodes
         then just add the key to the keychain, do this by drag and dropping into the certificates tab under the login keychain
         in safari you will have to navigate the warning page once
         u can do curl -k url to also ignore self signed
         
         */

        let y: NIOSSLCertificate = try! NIOSSLCertificate.init(file: sslCertPath, format: NIOSSLSerializationFormats.pem)
        let x: NIOSSLCertificateSource = NIOSSLCertificateSource.certificate(y)

        let y1: NIOSSLPrivateKey = try! NIOSSLPrivateKey.init(file: sslKeyPath,format:NIOSSLSerializationFormats.pem)
        let x1: NIOSSLPrivateKeySource = NIOSSLPrivateKeySource.privateKey(y1)

        app.http.server.configuration.tlsConfiguration  = .makeServerConfiguration(certificateChain:[x],privateKey:x1)

        
        try configure(app)
        
        app.http.server.configuration.port = Int(tempLocalhostServerPort)

        try app.server.start()
        
        //try app.run()

        
        //https://stackoverflow.com/questions/24551816/swift-encode-url
        let tdameritradeRedirectURIURLEncoded = tdameritradeRedirectURI.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let tdameritradeConsumerKeyURLEncoded = tdameritradeConsumerKey.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        let urlEncodedRedirectURI = tdameritradeRedirectURIURLEncoded!
        let urlEncodedConsumerKey = tdameritradeConsumerKeyURLEncoded!
        let basicUrl = "https://auth.tdameritrade.com/auth?response_type=code&redirect_uri=\(urlEncodedRedirectURI)&client_id=\(urlEncodedConsumerKey)%40AMER.OAUTHAP"

        if let _ = URL(string: basicUrl)
        {
            //NSWorkspace.shared.open(url)
            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = [basicUrl]
            task.launch()
        }
        
        
        
        //----------------
        
        while authCode == nil
        {
            print("waiting for initial auth token \(Date())")
            sleep(1)
        }
        
        app.server.shutdown()
        try app.server.onShutdown.wait()
        
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
        
        let semaphore = DispatchSemaphore(value: 1)
        semaphore.wait()
        
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
                do
                {
                    let aResponse = try decoder.decode(someResponse.self, from: jsonData)
                    refreshToken = aResponse.refresh_token
                    accessToken = aResponse.access_token
                }
                catch
                {
                
                }
            }
            else
            {
                // Handle unexpected error
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        semaphore.signal()
        
        while (task.state != .completed && hasError == nil)
        {
            
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
        
        let semaphore = DispatchSemaphore(value: 1)
        semaphore.wait()
        
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
                do
                {
                    let aResponse = try decoder.decode(someResponse.self, from: jsonData)
                    accessToken = aResponse.access_token
                }
                catch
                {
                    
                }
            }
            else
            {
                // Handle unexpected error
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        semaphore.signal()
        
        while task.state != .completed && hasError == nil
        {
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
        
        let semaphore = DispatchSemaphore(value: 1)
        semaphore.wait()
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
                
                var someQuotePackage:Optional<[String:Quote]>  =  nil
                do
                {
                    //https://forums.swift.org/t/encoding-decoding-a-swift-dictionary-to-from-json/39989
                    someQuotePackage = try decoder.decode([String:Quote].self, from: jsonData)
                }
                catch
                {
                    
                }
                
                if someQuotePackage != nil
                {
                    if someQuotePackage!.first != nil
                    {
                        let (key,value) = someQuotePackage!.first!
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
                    }
                }
                
                
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        semaphore.signal()
        
        while task.state != .completed && hasError == nil
        {
            
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
        
        let semaphore = DispatchSemaphore(value: 1)
        semaphore.wait()
        
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
                do
                {
                    let someDictionary = try decoder.decode([String:Account].self, from: jsonData)
                    
                    let (key,value) = someDictionary.first!
                    someAccount = value
                }
                catch
                {
                    
                }
            }
            else
            {
                // Handle unexpected error
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        semaphore.signal()
        
        while task.state != .completed && hasError == nil
        {
            
        }

        return someAccount
        
    }
    
    public class func getPositionForSymbol(tdAmeritradeAccountNumber:Int,accessTokenToUse:String,chosenSymbol:String)->Optional<Position>
    {
        
        let someAccount = TDAmeritradeForSwift.getAccount(tdAmeritradeAccountNumber:tdAmeritradeAccountNumber,accessTokenToUse:accessTokenToUse)
        
        var maybePosition:Optional<Position> = nil
        
        if someAccount != nil
        {
            for somePosition in someAccount!.positions
            {
                if somePosition.instrument.symbol.compare(chosenSymbol) == .orderedSame
                {
                    maybePosition = somePosition
                }
            }
        }
        return maybePosition
        
    }
    
    
    
    
    public class func doOrder(tdAmeritradeAccountNumber:Int,accessTokenToUse:String,quantity:Int,symbol:String,limitPrice:Optional<Decimal>,orderType:orderTypeEnum)->Optional<Order>
    {
        let beforeDate = Date()
        sleep(2)
        var beforeOrders = getOrdersFromDate(tdAmeritradeAccountNumber:tdAmeritradeAccountNumber,accessTokenToUse:accessTokenToUse,fromDate:beforeDate)
        sleep(2)
        
        
        var orderInstruction:Optional<String> = nil
        switch orderType
        {
            case .buy:
                orderInstruction = "BUY"
            case .sell:
                orderInstruction = "SELL"
            case .sellShort:
                orderInstruction = "SELL_SHORT"
            case .buyToCover:
                orderInstruction = "BUY_TO_COVER"
        }
        placeGenericOrder(accountNumber: tdAmeritradeAccountNumber, accessTokenToUse: accessTokenToUse, quantity: quantity, symbol: symbol, limitPrice: limitPrice, instruction: orderInstruction!)
        sleep(2)
        
        let afterDate = Date()
        
        let afterOrders = getOrdersFromDate(tdAmeritradeAccountNumber:tdAmeritradeAccountNumber,accessTokenToUse:accessTokenToUse,fromDate:afterDate)
        sleep(2)
        
        if beforeOrders != nil && afterOrders != nil
        {
            var tries:Int = 0
            while beforeOrders!.count == afterOrders!.count
            {
                let afterOrders = getOrdersFromDate(tdAmeritradeAccountNumber:tdAmeritradeAccountNumber,accessTokenToUse:accessTokenToUse,fromDate:afterDate)
                
                sleep(1)
                
                if tries > 30
                {
                    break
                }
                tries = tries + 1
            }
        }
        
        if beforeOrders != nil && afterOrders != nil
        {
            let boSet = Set<Order>(beforeOrders!)
            let aoSet = Set<Order>(afterOrders!)
            let diff = aoSet.subtracting(boSet)
            
            /*
            if diff.count > 1
            {
                print("A) problem finding new order, did you call this from multiple threads or are also trading from the tdameritrade gui? doOrder is not thread safe bo=\(boSet)\n ao=\(aoSet)\n diff=\(diff)\n\n")
            }
            
            let newOrder = diff.first
            
            if newOrder!.orderLegCollection.first!.instrument.symbol.compare(symbol) != .orderedSame
            {
                print("B) problem finding new order, did you call this from multiple threads or are also trading from the tdameritrade gui? doOrder is not thread safe bo=\(boSet)\n ao=\(aoSet)\n diff=\(diff)\n\n")
            }
           */
            
            var beforeIdsSet:Set<Int> = Set()
            for order in boSet
            {
                beforeIdsSet.insert(order.orderId!)
            }
            
            var afterIdsSet:Set<Int> = Set()
            for order in aoSet
            {
                afterIdsSet.insert(order.orderId!)
            }
            
            let diffIds = afterIdsSet.subtracting(beforeIdsSet)
            
            var candidates:[Order] = []
            for id in diffIds
            {
                for oc in aoSet
                {
                    if id == oc.orderId!
                    {
                        //should not need this, but doing it for extra safety
                        if (oc.orderLegCollection.first!.instrument.symbol.compare(symbol) == .orderedSame) &&
                           (oc.orderLegCollection.first!.instruction.compare(orderInstruction!) == .orderedSame)
                        {
                            candidates.append(oc)
                        }
                    }
                    
                }
                
            }
            
            
            /*
            var candidates:[Order] = []
            for oc in diff
            {
                if (oc.orderLegCollection.first!.instrument.symbol.compare(symbol) == .orderedSame) &&
                   (oc.orderLegCollection.first!.quantity == quantity) &&
                   (oc.orderLegCollection.first!.instruction.compare(orderInstruction!) == .orderedSame)
                {
                   
                    
                        candidates.append(oc)
                    
                }
            }
            */
            
            if candidates.count == 0 || candidates.count > 1
            {
                print("TDAmeritradeForSwift Problem: problem finding new order, did you call this from multiple threads or are also trading from the tdameritrade gui? doOrder is not thread safe bo=\(boSet)\n ao=\(aoSet)\n diff=\(diff)\n\n candid=\(candidates)")
            }
            
            return candidates.first
        }
        else
        {
            return nil
        }
    }
    

    public class func getOpenOrdersForSingleSymbol(symbol:String,accessTokenToUse:String,tdAmeritradeAccountNumber:Int,fromDate:Date)->Optional<[Order]>
    {
        
        let fromEnteredTime = fromDate.yyyy_mm_ddString()
        let toEnteredTime = fromDate.yyyy_mm_ddString()
        
        var orderArray:Optional<[Order]> = nil
        
        //https://www.advancedswift.com/http-requests-in-swift/
        let url = URL(string:"https://api.tdameritrade.com/v1/accounts/\(tdAmeritradeAccountNumber)/orders?fromEnteredTime=\(fromEnteredTime)&toEnteredTime=\(toEnteredTime)&status=WORKING")!
        
    
        print(url)
        var request = URLRequest(url:url)
        
        request.setValue("Bearer \(accessTokenToUse)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        var hasError:Optional<Error> = nil
        
        let semaphore = DispatchSemaphore(value: 1)
        semaphore.wait()
        
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
                do
                {
                    orderArray = try decoder.decode([Order].self, from: jsonData)
                }
                catch
                {
                    
                }
            }
            else
            {
                // Handle unexpected error
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        semaphore.signal()
        
        while task.state != .completed && hasError == nil
        {
            
        }
        
        var orderArray2:Optional<[Order]> = nil
        
        if orderArray != nil
        {
            orderArray2 = orderArray?.compactMap( {(someOrder) -> Optional<Order> in
                if someOrder.orderLegCollection.first!.instrument.symbol.compare(symbol) == .orderedSame
                {
                    return someOrder
                }
                else
                {
                    return nil
                }
            })
        }

        return orderArray2
        
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
        
        let semaphore = DispatchSemaphore(value: 1)
        semaphore.wait()
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
                do
                {
                    orderArray = try decoder.decode([Order].self, from: jsonData)
                }
                catch
                {
                    
                }
            }
            else
            {
                // Handle unexpected error
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        semaphore.signal()
        
        while task.state != .completed && hasError == nil
        {
        }

        return orderArray
    }

    

    
    
    public class func placeGenericOrder(accountNumber:Int,accessTokenToUse:String,quantity:Int,symbol:String,limitPrice:Optional<Decimal>,instruction:String)
    {
        
        let anInstrument = Instrument(assetType: "EQUITY", symbol: symbol)
        let anOrderLeg = OrderLeg(instruction: instruction, quantity: quantity, instrument: anInstrument, quantityType: "SHARES")
        let orderLegs = [anOrderLeg]
        
        var orderType:String = "LIMIT"
        var sessionType:String = "SEAMLESS"
        if limitPrice == nil
        {
            orderType = "MARKET"
            sessionType = "NORMAL"
        }
        
        let newOrder = Order(orderType: orderType, session: sessionType, duration: "DAY", orderStrategyType: "SINGLE", orderLegCollection: orderLegs,price:limitPrice,filledQuantity: nil,remainingQuantity: nil,orderId: nil,status:nil,cancelable: nil)
        
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
        
        let semaphore = DispatchSemaphore(value: 1)
        semaphore.wait()

        let task = session.dataTask(with: request) { (data, response, error) in

            if error != nil
            {
     
                print(error!.localizedDescription)
                hasError = error!
            }
            //else if let data = data
            //{
            //}
            //else
            //{
                // Handle unexpected error
            //}
            semaphore.signal()
        }
        
        
        task.resume()
        
        semaphore.wait()
        semaphore.signal()
        //using the semaphore approach reduces total execution time to 0.143
        
        
        while task.state != .completed && hasError == nil
        {
            
        }
        
    }
    
}

