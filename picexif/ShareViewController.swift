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
import AVFoundation
import VIMediaCache
import pop

extension UIView {
    func showWithAnimation() {
        guard isHidden == false else {
            return
        }
        transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.4, animations: {[weak self] in
            self?.transform = CGAffineTransform.identity
        })
    }
}
class ShareViewController: PEViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var qqButton: UIButton!
    @IBOutlet weak var wechatButton: UIButton!
    @IBOutlet weak var weiboButton: UIButton!
    
    var VIManager = VIResourceLoaderManager()
    var player : AVPlayer?
    var videoPlayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let hud = JGProgressHUD(style: .dark)!
        hud.textLabel.text = "已保存到相册最后一张"
        hud.indicatorView = JGProgressHUDImageIndicatorView(image: UIImage(named: "Fav_Note_ToolBar_Album_HL"))
        hud.show(in: view)
        hud.dismiss(afterDelay: 2.0)
        
        //imageView.loadImage(urlString: "http://picexif.applinzi.com/static/img/end0.jpg")
        let playerItem = VIManager.playerItem(with: URL(string: "https://picexif.applinzi.com/static/help.mp4")!)
        player = AVPlayer(playerItem: playerItem)
        player?.actionAtItemEnd = .none
        player?.play()
        NotificationCenter.default.addObserver(self, selector: #selector(ShareViewController.itemDidFinishPlaying(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        qqButton.isHidden = !(UIApplication.shared.canOpenURL(URL(string: "mqq://")!) || UIApplication.shared.canOpenURL(URL(string: "mqzone://")!))
        qqButton.showWithAnimation()
        wechatButton.isHidden = !UIApplication.shared.canOpenURL(URL(string: "weixin://")!)
        wechatButton.showWithAnimation()
        weiboButton.isHidden = !(UIApplication.shared.canOpenURL(URL(string: "sinaweibo://")!) || UIApplication.shared.canOpenURL(URL(string: "sinaweibohd://")!))
        weiboButton.showWithAnimation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if videoPlayer == nil {
            videoPlayer = AVPlayerLayer(player: player)
            videoPlayer!.frame = imageView.bounds
            videoPlayer!.videoGravity = AVLayerVideoGravityResizeAspect
            imageView.layer.addSublayer(videoPlayer!)

        }
    }
    
    @IBAction func back() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "clearImage"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareToQQ() {
        if UIApplication.shared.canOpenURL(URL(string: "mqzone://")!) {
            UIApplication.shared.openURL(URL(string: "mqzone://")!)
            subsribeAPPActive(name: " QQ ")
        }
        else if UIApplication.shared.canOpenURL(URL(string: "mqq://")!) {
            UIApplication.shared.openURL(URL(string: "mqq://")!)
            subsribeAPPActive(name: " QQ ")
        }
    }
    
    @IBAction func shareToWechat() {
        if UIApplication.shared.canOpenURL(URL(string: "weixin://")!) {
            UIApplication.shared.openURL(URL(string: "weixin://")!)
            subsribeAPPActive(name: "微信")
        }
    }
    
    @IBAction func shareToWeibo() {
        if UIApplication.shared.canOpenURL(URL(string: "sinaweibo://")!) {
            UIApplication.shared.openURL(URL(string: "sinaweibo://")!)
            subsribeAPPActive(name: "微博")
        }
        else if UIApplication.shared.canOpenURL(URL(string: "sinaweibohd://")!) {
            UIApplication.shared.openURL(URL(string: "sinaweibohd://")!)
            subsribeAPPActive(name: "微博")
        }

    }
    
    func subsribeAPPActive(name: String) {
        if UserDefaults.standard.bool(forKey: "helpAlert") {
            return
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "appBecomeActive"),
                                               object: nil, queue: OperationQueue.main,
                                               using: {
                                                [weak self](note) in
                                                guard let this = self else {
                                                    return
                                                }
                                                
                                                this.player?.play()
                                                let alert = UIAlertController(title: "", message: "分享到\(name)是否出现了无法定位的问题呢？", preferredStyle: .alert)
                                                alert.addAction(UIAlertAction(title: "顺利分享！", style: .default, handler: {(action) in
                                                    this.showRating()
                                                }))
                                                alert.addAction(UIAlertAction(title: "失败了", style: .destructive, handler:{(action)in
                                                    this.performSegue(withIdentifier: "help", sender: nil)
                                                }))
                                                
                                                this.present(alert, animated: true, completion: nil)
                                                NotificationCenter.default.removeObserver(this, name: NSNotification.Name(rawValue: "appBecomeActive"), object: nil)
                                                UserDefaults.standard.set(true, forKey: "helpAlert")
                                                UserDefaults.standard.synchronize()
                                                
        })
    }
    
    func showRating() {
        if !UserDefaults.standard.bool(forKey: "ratingAlert") {
            ServerAPI.reqeustJSONDict(.ratingPrompt,
                                      block: {[weak self](suc, dict) in
                                        if let prompt = dict["prmopt"] as? String, let title = dict["title"] as? String {
                                            
                                            let alert = UIAlertController(title: title, message: prompt, preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "好的",
                                                                          style: .default,
                                                                          handler: {
                                                                            [weak self](action) in
                                                                            let rateURL = URL(string: "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?mt=8&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software&id=1174697271")!
                                                                            if UIApplication.shared.canOpenURL(rateURL) {
                                                                                UIApplication.shared.openURL(rateURL)
                                                                            }
                                                                            let vc = UIStoryboard.generalWebview()
                                                                            vc.urlString = "https://picexif.applinzi.com/help/money?v=1.1"
                                                                            self?.present(vc, animated: true, completion: nil)
                                                                            
                                            }))
                                            alert.addAction(UIAlertAction(title: "不要红包了",
                                                                          style: .destructive,
                                                                          handler: nil))
                                            if let this = self {
                                                this.present(alert, animated: true, completion: nil)
                                                UserDefaults.standard.set(true, forKey: "ratingAlert")
                                                UserDefaults.standard.synchronize()
                                            }
                                        }
            })
        }
    }
    
    func itemDidFinishPlaying(notification: NSNotification) {
        if let item = notification.object as? AVPlayerItem {
            item.seek(to: kCMTimeZero)
        }
    }
}
