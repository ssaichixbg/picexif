//
//  StartupViewController.swift
//  picexif
//
//  Created by Simon on 05/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import UIKit
import Photos
import pop
import XRCarouselView

extension String {
    func repeatTime(_ time: Int) -> String{
       return repeatElement(self, count: time).joined(separator: "")
    }
}

class LocationLabel: UILabel {
    var searcher = POISearcher()
    var timer: Timer?
    var timeIndex: Int = 0
    var location: CLLocationCoordinate2D? {
        didSet {
            if let location = location {
                startLoading()
                searcher.requestAmapSearch(centerPos: location, done: { [weak self](poi) in
                    if poi.count > 0, let name = poi[0].name {
                        self?.text = "照片位置：\(name)\n\(poi[0].address ?? "")"
                    }
                    else {
                        self?.text = "照片不包含位置信息"
                    }
                    self?.stopLoading()
                })
            }
            else {
                text = "照片不包含位置信息"
            }
        }
    }
    
    func startLoading() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(LocationLabel.animation(_:)), userInfo: nil, repeats: true)
    }
    
    @objc func animation(_ userinfo: AnyObject) {
        text =  "\(" ".repeatTime(timeIndex))定位中\(".".repeatTime(timeIndex))"
        timeIndex += 1
        timeIndex %= 3
    }
    
    func stopLoading() {
        timer?.invalidate()
    }
}

class StartupViewController: PEViewController {
    @IBOutlet weak var arrowView: UIImageView!
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var changeImageButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var locationLabel: LocationLabel!
    @IBOutlet weak var imageScroll: XRCarouselView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    var image: UIImage? {
        didSet {
            if let image = image {
                previewView.image = image
                okButton.setTitle("修改位置", for: .normal)
                //arrowView.isHidden = true
                //changeImageButton.isHidden = false
                locationLabel.location = image.GPSLocation
                imageScroll.isHidden = true
                welcomeLabel.isHidden = true
            }
            else {
                previewView.image = nil
                okButton.setTitle("选择一张照片", for: .normal)
                //arrowView.isHidden =  false
                changeImageButton.isHidden = true
                locationLabel.location = nil
                locationLabel.text = ""
                imageScroll.isHidden = false
                welcomeLabel.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        changeImageButton.isHidden = true
        okButton.layer.cornerRadius = 5.0
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "clearImage"), object: nil, queue: OperationQueue.main, using: {[weak self](note) in
            self?.image = nil
            self?.locationLabel?.stopLoading()
        })

        imageScroll.imageArray = [
            "http://picexif.applinzi.com/static/img/start0.jpg",
            "http://picexif.applinzi.com/static/img/start1.jpg",
            "http://picexif.applinzi.com/static/img/start2.jpg",
            "http://picexif.applinzi.com/static/img/start3.jpg",
        ]
        imageScroll.time = 5
        imageScroll.contentMode = UIViewContentMode.scaleAspectFit
        imageScroll.changeMode = ChangeModeFade
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        arrowView.layer.pop_removeAllAnimations()
        let animation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationY)
        animation?.autoreverses = true
        animation?.repeatForever = true
        animation?.duration = 0.45
        animation?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation?.fromValue = 0
        animation?.toValue =  -8
        arrowView.layer.pop_add(animation, forKey: "pos")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! HomeViewController
        vc.image = image
    }
 
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension StartupViewController {
    @IBAction func okPressed(_ sender: AnyObject) {
        if let _ = image {
            performSegue(withIdentifier: "home", sender: sender)
        }
        else {
            importImage()
        }
    }
}

extension StartupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let url = info[UIImagePickerControllerReferenceURL] as? URL {
            let option = PHContentEditingInputRequestOptions()
            option.isNetworkAccessAllowed = true
            
            let asset = PHAsset.fetchAssets(withALAssetURLs: [url], options: PHFetchOptions()).lastObject!
            asset.requestContentEditingInput(with: option, completionHandler: {[weak self] (input, info) in
                let phImage = UIImage(ciImage: CIImage(contentsOf: (input?.fullSizeImageURL)!)!)
                self?.image = phImage
                picker.dismiss(animated: true, completion: nil)
            })
        }
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image = image
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
