//
//  Storyboard+Shortcut.swift
//  picexif
//
//  Created by Simon on 15/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import Foundation

extension UIStoryboard {
    static func generalWebview() -> WebViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "webview") as! WebViewController
        return vc
    }
}
