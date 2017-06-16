//
//  POITemplates.swift
//  picexif
//
//  Created by Simon on 25/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import Foundation
import HandyJSON

class POITemplate: HandyJSON {
    var imageURL: String?
    var poi: POI?
    
    required init(){}
    
    static func all(onSuccess: @escaping (([String: [POITemplate]])->()), onError: @escaping (String)->()) {
        ServerAPI.reqeustJSONDict(.poiTemplatesURL,
                                  block: {(suc, result) in
                                    if suc {
                                        var dict = [String: [POITemplate]]()
                                        
                                        guard let result = result as? [String: [[String:Any]]] else {
                                            onError("网络错误，请稍后重试😂")
                                            return
                                        }
                                        
                                        for key in result.keys {
                                            let list = result[key]!
                                            dict[key] = [POITemplate]()
                                            for item in list {
                                                if let item = item as? NSDictionary {
                                                    dict[key]?.append(JSONDeserializer<POITemplate>.deserializeFrom(dict: item )!)
                                                }
                                            }
                                        }
                                        
                                        onSuccess(dict)
                                    }
                                    else {
                                        onError("网络错误，请稍后重试😂")
                                    }
        })
    }
}
