//
//  API.swift
//  picexif
//
//  Created by Simon on 05/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import Foundation
import Alamofire

let hostName = "http://picexif.applinzi.com"

enum ServerAPIUrl: String{
    case hotPOIURL = "/poi/hot"
    case nearPOIURL = "/poi/near"
    case loggingPOIURL = "/poi/logging"
    
    var fullURL: String {
        return hostName + rawValue
    }
}

class ServerAPI: NSObject {
    static func requestString(_ url: ServerAPIUrl, params: [String: Any]? = nil,block: @escaping (Bool, String)->()) {
        Alamofire.request(url.fullURL, parameters: params)
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
        newParams["v"] = "1.1"
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
        Alamofire.request(url.fullURL, method: .post, parameters: params, encoding: JSONEncoding.default).response { (DefaultDataResponse) in
            
        }
    }
}
