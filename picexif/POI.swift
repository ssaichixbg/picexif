//
//  POI.swift
//  picexif
//
//  Created by Simon on 04/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import UIKit
import MapKit
import HandyJSON
import Alamofire

class POISearcher: NSObject {
    var callback: (([POI])->())?
    
    var amapSearch = AMapSearchAPI()

    var mkSearch: MKLocalSearch!
    
    var FQRequest: DataRequest!
    var POIRequest: DataRequest!
    var POIReqeustDelayTimer: SwiftTimer?
    
    override init() {
        
    }
    
    func requestFQSearch(centerPos: CLLocationCoordinate2D, done: @escaping ([POI])->()) {
        if let FQRequest = FQRequest {
            FQRequest.cancel()
            self.FQRequest = nil
        }
        
        FQRequest = ServerAPI.requestString(.nearPOIURL,
                                params: [
                                    "ll":"\(centerPos.latitude),\(centerPos.longitude)"
            ], block: {
                [weak self](success, result) in
                self?.FQRequest = nil
                
                if (success) {
                    var list = [POI]()
                    let jsonList = JSONDeserializer<POI>.deserializeModelArrayFrom(json: result) ?? []
                    for poi in jsonList {
                        if let poi = poi {
                            list.append(poi)
                        }
                    }
                    done(list)

                }
                else {
                    done([])
                }
        })
        
    }
    func requestAmapSearch(centerPos: CLLocationCoordinate2D, done: @escaping ([POI])->()) {
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(centerPos.latitude), longitude: CGFloat(centerPos.longitude))
        request.sortrule = 0
        request.requireExtension = true
        amapSearch?.delegate = self
        amapSearch?.aMapPOIAroundSearch(request)
        callback = done
    }
    
    func requestMKSearch(centerPos: CLLocationCoordinate2D?,searchQuery: String? ,done: @escaping ([POI])->()) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchQuery
        if let centerPos = centerPos {
            request.region = MKCoordinateRegionMakeWithDistance(centerPos, 1000, 1000)
        }
        if let mkSearch = mkSearch {
            mkSearch.cancel()
        }
        mkSearch = MKLocalSearch(request: request)
        mkSearch.start { (response, error) in
            if error == nil {
                if let response = response {
                    let pois = response.mapItems.map({POI(mkItem: $0)}).filter({$0.location != nil})
                    done(pois)
                    return
                }
            }
            done([])
        }
    }
    
    func requestPOISearch(searchQuery: String?, done: @escaping ([POI])->()) {
        guard let searchQuery = searchQuery, searchQuery.characters.count > 0 else {
            done([])
            return
        }
        
        if let POIRequest = POIRequest {
            POIRequest.cancel()
            self.POIRequest = nil
        }
        
//        if let POIReqeustDelayTimer = POIReqeustDelayTimer {
//            POIReqeustDelayTimer.suspend()
//        }
        
//        POIReqeustDelayTimer = SwiftTimer(interval: .milliseconds(300),
//                                          handler: { [weak self](timer) in
//                                            
//                                            })
//        })
//        
//        POIReqeustDelayTimer?.start()
        POIRequest = ServerAPI.requestString(.searchPOIURL,
                                                   params: ["k": searchQuery],
                                                   block: {
                                                    [weak self](suc, response) in
                                                    self?.POIRequest = nil
                                                    
                                                    let result = JSONDeserializer<POI>.deserializeModelArrayFrom(json: response)
                                                    guard let r = result else {
                                                        done([])
                                                        return
                                                    }
                                                    let poiList = r.filter({$0 != nil}).map({$0!})
                                                    done(poiList)
        })
    }

}

extension POISearcher: AMapSearchDelegate {
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if let pois = response.pois {
            if pois.count > 0 {
                callback?(pois.map({p in return POI(poi: p)}))
                return
            }
            else {
                if let request = request as? AMapPOIAroundSearchRequest {
                    requestFQSearch(centerPos: request.location.clCoordinate, done: { [weak self](pois) in
                        self?.callback?(pois)
                    })
                    return
                }
            }
        }
        
        callback?([])
    }

}

extension AMapGeoPoint {
    var clCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude))
    }
}

class POI: HandyJSON{
    var name: String?
    var address: String?
    var longitude: Double?
    var latitude: Double?
    var location: CLLocationCoordinate2D? {
        get {
            if let latitude = latitude, let longitude = longitude {
                return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
            else {
                return nil
            }

        }
        set {
            longitude = newValue?.longitude
            latitude = newValue?.latitude
        }
    }
    
    required init(){}
    init(poi: AMapPOI) {
        name = poi.name
        address = "\(poi.province ?? "")\(poi.province == poi.city ? "": poi.city ?? "") \(poi.district ?? "") \(poi.address ?? "")"
        longitude = Double(poi.location.longitude)
        latitude = Double(poi.location.latitude)
    }
    
    init(mkItem: MKMapItem) {
        name = mkItem.name
        location = mkItem.placemark.coordinate
        address = mkItem.placemark.title
    }
    
    static func hotList(onSuccess: @escaping ([String: [POI]])->(), onError: @escaping (String)->())  {
        ServerAPI.reqeustJSONDict(.hotPOIURL,
                                   block: { (success, result) in
                                    if success {
                                        var dict = [String: [POI]]()
                                        
                                        guard let result = result as? [String: [[String:Any]]] else {
                                            onError("网络错误，请稍后重试😂")
                                            return
                                        }
                                        
                                        for key in result.keys {
                                            let list = result[key]
                                            dict[key] = [POI]()
                                            for item in list! {
                                                if let item = item as? NSDictionary {
                                                    dict[key]?.append(JSONDeserializer<POI>.deserializeFrom(dict: item )!)
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
