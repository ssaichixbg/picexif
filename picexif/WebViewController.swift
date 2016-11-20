//
//  WebViewController.swift
//  picexif
//
//  Created by Simon on 15/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import UIKit
import JGProgressHUD

class WebViewController: UIViewController {
    @IBOutlet weak var webview: UIWebView!
    
    var urlString: String = "https://picexif.applinzi.com/help/feedback?v=1.1"
    var hud: JGProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        webview.delegate = self
        webview.loadRequest(URLRequest(url: URL(string: urlString)!))
        let hud = JGProgressHUD(style: .dark)!
        hud.textLabel.text = "加载中..."
        hud.show(in: navigationController?.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }

}

extension WebViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        hud?.dismiss()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        hud?.textLabel.text = "网络错误:(请稍后再试"
        hud?.dismiss(afterDelay: 1.0)
        dismiss(animated: true, completion: nil)
    }
}
