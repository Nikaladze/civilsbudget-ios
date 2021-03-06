//
//  ServiceRouter.swift
//  BankIdSDK
//
//  Created by Max Odnovolyk on 11/20/15.
//  Copyright © 2015 Build Apps. All rights reserved.
//

import Alamofire
import CryptoSwift

extension Service {
    
    /**
     */
    public enum Router: URLRequestConvertible {
        case Authorize
        case GetAccessToken(authCode: String)
        case RefreshAccessToken(refreshToken: String)
        case RequestInformation(fields: [String: AnyObject])
        case GetDocument(link: String)
        
        var baseURLString: String {
            switch self {
            case .Authorize, .GetAccessToken, .RefreshAccessToken:
                return configuration.baseAuthURLString
            case .RequestInformation, .GetDocument:
                return configuration.baseDataURLString
            }
        }
        
        var path: String {
            switch self {
            case .Authorize:
                return "/das/authorize"
            case .GetAccessToken:
                return "/oauth/token"
            case .RequestInformation:
                return "/checked/data"
            default:
                return ""
            }
        }
        
        var method: Alamofire.Method {
            switch self {
            case .Authorize, .GetAccessToken, .RefreshAccessToken, .GetDocument:
                return .GET
            case .RequestInformation:
                return .POST
            }
        }
        
        public var URLRequest: NSMutableURLRequest {
            let URL = NSURL(string: baseURLString)!
            let request = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
            request.HTTPMethod = method.rawValue
            
            switch self {
            case .Authorize:
                return Alamofire.ParameterEncoding.URL.encode(request,
                    parameters: ["response_type": "code", "client_id": configuration.clientID, "redirect_uri": configuration.redirectURI]).0
            case .GetAccessToken(let code):
                let calculatedClientSecret = "\(configuration.clientID)\(configuration.clientSecret)\(code)".sha1()
                return Alamofire.ParameterEncoding.URL.encode(request,
                    parameters: ["grant_type": "authorization_code",
                        "client_id": configuration.clientID,
                        "client_secret":  calculatedClientSecret,
                        "code": code,
                        "redirect_uri": configuration.redirectURI]).0
            case .RequestInformation(let fields):
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                if let authorization = authorization {
                    request.setValue("Bearer \(authorization.accessToken), Id \(configuration.clientID)", forHTTPHeaderField: "Authorization")
                }
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                return Alamofire.ParameterEncoding.JSON.encode(request, parameters: fields).0
            default:
                return request
            }
        }
    }
}