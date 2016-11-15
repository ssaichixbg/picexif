//
//  PEImage.swift
//  picexif
//
//  Created by Simon on 03/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import Foundation
import ImageIO
import MobileCoreServices
import Photos

extension UIImage {
    var GPSMetaInfo: [NSString: Any] {
        let metaData = ciImage?.properties
        if let metaData = metaData {
            let GPSData = (metaData[kCGImagePropertyGPSDictionary as String] as? [NSString: Any] ) ?? [NSString: Any]()
            return GPSData
        }
        else {
            return [:]
        }
    }
    
    var GPSLocation: CLLocationCoordinate2D? {
        let gpsData = GPSMetaInfo
        
        guard let longitude = gpsData[kCGImagePropertyGPSLongitude] as? Double,
            let latitude = gpsData[kCGImagePropertyGPSLatitude] as? Double,
            let longitudeRef =  gpsData[kCGImagePropertyGPSLongitudeRef] as? String,
            let latitudeRef =  gpsData[kCGImagePropertyGPSLatitudeRef] as? String else {
                return nil
        }
        return CLLocationCoordinate2D(latitude: latitudeRef == "N" ? latitude: -latitude, longitude: longitudeRef == "E" ? longitude: -longitude)
    }
    
    func saveToAlbum(withGPS gps: CLLocationCoordinate2D) {
        var im: UIImage
        if let ciImage = ciImage, cgImage == nil {
            im = UIImage(cgImage: CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent)!)
        }
        else {
            im = self
        }
        let jpgData = UIImageJPEGRepresentation(im, 80)!
        let imageSource = CGImageSourceCreateWithData(jpgData as CFData, nil)!
        var metaData = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as! [NSString: Any]
        
        var GPSData = (metaData[kCGImagePropertyGPSDictionary] as? [NSString: Any] ) ?? [NSString: Any]()
        
        GPSData[kCGImagePropertyGPSLatitude] = abs(gps.latitude)
        GPSData[kCGImagePropertyGPSLatitudeRef] = gps.latitude > 0 ? "N" : "S"
        GPSData[kCGImagePropertyGPSLongitude] = abs(gps.longitude)
        GPSData[kCGImagePropertyGPSLongitudeRef] = gps.longitude > 0 ? "E" : "W"
        
        metaData[kCGImagePropertyGPSDictionary] = GPSData
        
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.jpg")
        let imageDest = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeJPEG, 1, nil)!

        CGImageDestinationAddImageFromSource(imageDest, imageSource, 0,  metaData as CFDictionary)
        //CGImageDestinationSetProperties(imageDest, metaData as CFDictionary)
        CGImageDestinationFinalize(imageDest)
        let lib = PHPhotoLibrary.shared()
        lib.performChanges({ 
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
        }, completionHandler: nil)
    }
}

extension UIImage {
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    
    func scale(maxLength: CGFloat)->UIImage {
        var reSize: CGSize
        if size.height > size.width {
            reSize = CGSize(width: size.width * maxLength / size.height, height: maxLength)
        }
        else {
            reSize = CGSize(width: maxLength, height: size.height * maxLength / size.width)
        }
        return reSizeImage(reSize: reSize)
    }
}
