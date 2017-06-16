//
//  POITemplateViewController.swift
//  picexif
//
//  Created by Simon on 27/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import UIKit
import XRCarouselView
import JGProgressHUD

class POITemplateViewController: PEViewController {
    @IBOutlet weak var imageScrollView: XRCarouselView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "finish", sender: sender)
    }
}
