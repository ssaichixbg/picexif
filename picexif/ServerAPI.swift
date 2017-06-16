//
//  API.swift
//  picexif
//
//  Created by Simon on 05/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import Foundation
import Alamofire

let hostName = "https://picexif.applinzi.com"

enum ServerAPIUrl: String{
    case hotPOIURL = "/poi/hot"
    case nearPOIURL = "/poi/near"
    case loggingPOIURL = "/poi/logging"
    case searchPOIURL = "/poi/search"
    case ratingPromptURL = "/help/rating"
    case poiTemplatesURL = "/poi/templates"
    
    
    var fullURL: String {
        return hostName + rawValue
    }
}

class ServerAPI: NSObject {
    static var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.2"
    
    static func requestString(_ url: ServerAPIUrl, params: [String: Any]? = nil,block: @escaping (Bool, String)->()) -> DataRequest {
        var newParams = params ?? [String: Any]()
        newParams["v"] = appVersion
        return Alamofire.request(url.fullURL, parameters: newParams)
            .validate()
            .responseString { response in
                switch response.result {
                case .success:
                    if let json = response.result.value {
                        block(true, json)
                    }
                    else {
                        block(false, "")
                    }
                case .failure:
                    block(false, "")
                }
        }
    }
    
    static func reqeustJSONDict(_ url: ServerAPIUrl, params: [String: Any]? = nil,block: @escaping (Bool, [String: Any])->()) {
        var newParams = params ?? [String: Any]()
        newParams["v"] = appVersion
        Alamofire.request(url.fullURL, parameters: newParams)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.result.value {
                        block(true, (json as? [String: Any]) ?? [:])
                    }
                    else {
                        block(false, [:])
                    }
                case .failure:
                    block(false, [:])
                }
        }
    }
    
    static func jsonRequest(_ url: ServerAPIUrl, params: [String: Any]? = nil) {
        var newParams = params ?? [String: Any]()
        newParams["v"] = appVersion
        Alamofire.request(url.fullURL, method: .post, parameters: newParams, encoding: JSONEncoding.default).response { (DefaultDataResponse) in
            
        }
    }
}
