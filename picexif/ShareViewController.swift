//
//  ShareViewController.swift
//  picexif
//
//  Created by Simon on 05/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import UIKit
import JGProgressHUD
import KFSwiftImageLoader

class ShareViewController: PEViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var qqButton: UIButton!
    @IBOutlet weak var wechatButton: UIButton!
    @IBOutlet weak var weiboButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let hud = JGProgressHUD(style: .dark)!
        hud.textLabel.text = "已保存到相册最后一张"
        hud.indicatorView = JGProgressHUDImageIndicatorView(image: UIImage(named: "Fav_Note_ToolBar_Album_HL"))
        hud.show(in: view)
        hud.dismiss(afterDelay: 2.0)
        
        imageView.loadImage(urlString: "http://picexif.applinzi.com/static/img/end0.jpg")
        
        qqButton.isHidden = !(UIApplication.shared.canOpenURL(URL(string: "mqq://")!) || UIApplication.shared.canOpenURL(URL(string: "mqzone://")!))
        wechatButton.isHidden = !UIApplication.shared.canOpenURL(URL(string: "weixin://")!)
        weiboButton.isHidden = !(UIApplication.shared.canOpenURL(URL(string: "sinaweibo://")!) || UIApplication.shared.canOpenURL(URL(string: "sinaweibohd://")!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func back() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "clearImage"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareToQQ() {
        if UIApplication.shared.canOpenURL(URL(string: "mqzone://")!) {
            UIApplication.shared.openURL(URL(string: "mqzone://")!)
        }
        else if UIApplication.shared.canOpenURL(URL(string: "mqq://")!) {
            UIApplication.shared.openURL(URL(string: "mqq://")!)
        }
    }
    
    @IBAction func shareToWechat() {
        if UIApplication.shared.canOpenURL(URL(string: "weixin://")!) {
            UIApplication.shared.openURL(URL(string: "weixin://")!)
        }
    }
    
    @IBAction func shareToWeibo() {
        if UIApplication.shared.canOpenURL(URL(string: "sinaweibo://")!) {
            UIApplication.shared.openURL(URL(string: "sinaweibo://")!)
        }
        else if UIApplication.shared.canOpenURL(URL(string: "sinaweibohd://")!) {
            UIApplication.shared.openURL(URL(string: "sinaweibohd://")!)
        }

    }

}
