//
//  UITableView+Loading.swift
//  picexif
//
//  Created by Simon on 21/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import Foundation

extension UITableView {
    func startLoading() {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        indicator.tag = 213
        addSubview(indicator)
        indicator.startAnimating()
    }
    
    func stopLoading() {
        let indicator = viewWithTag(213)
        indicator?.removeFromSuperview()
    }
}
