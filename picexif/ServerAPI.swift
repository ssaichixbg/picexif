//
//  API.swift
//  picexif
//
//  Created by Simon on 05/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import Foundation
import Alamofire

let hostName = "https://picexif.sinaapp.com"

enum APIUrl: String{
    case hotPOIURL = "/POI/hot"
    
    var fullURL: String {
        return hostName + rawValue
    }
}

class API: NSObject {
    
    func requestJSONArray(url: APIUrl, block: @escaping (Bool,[AnyObject])->()) {
        Alamofire.request(url.fullURL)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.result.value as? [AnyObject] {
                        block(true, json)
                    }
                    else {
                        block(false, [])
                    }
                case .failure:
                    block(false, [])
                }
        }
    }
}
