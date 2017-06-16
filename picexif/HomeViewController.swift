//
//  ViewController.swift
//  picexif
//
//  Created by Simon on 03/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import UIKit
import MapKit
import Photos
import SnapKit
import JGProgressHUD

extension UIImageView {
    func onTap(target: Any, action: Selector) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
}

class HomeSearchResultTableViewController: PEViewController {
    var searcher = POISearcher()
    var didSelectPOI :((POI)->())?
    var tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)
    var result: [POI]? {
        didSet {
            if let _ = result {
                tableView.isHidden = false
            }
            else {
                tableView.isHidden = POIResult == nil ? true : false
            }
            tableView.reloadSections(IndexSet(integer: 1), with: .fade)
        }
    }
    var POIResult: [POI]? {
        didSet {
            if let _ = POIResult {
                tableView.isHidden = false
            }
            else {
                tableView.isHidden = result == nil ? true : false
            }
            tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        }
    }
    var searchKeyword: String?
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsets(top: 22+44, left: 0, bottom: 0, right: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(HomeSearchResultTableViewController.keyboardDidShow(note:)), name:NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    func keyboardDidShow(note: NSNotification) {
        let userInfo = note.userInfo! as NSDictionary
        let value: NSValue = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let height = value.cgRectValue.size.height
        tableView.contentInset = UIEdgeInsets(top: 22+44, left: 0, bottom: height, right: 0)
    }
}


extension HomeSearchResultTableViewController: UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text.characters.count > 1 {
            searchKeyword = text
            tableView.startLoading()
            searcher.requestMKSearch(centerPos: nil, searchQuery: text, done: {[weak self](pois) in
                self?.result = pois
                self?.tableView.stopLoading()
            })
            searcher.requestPOISearch(searchQuery: text, done: {[weak self](pois) in
                self?.POIResult = pois
                self?.tableView.stopLoading()
            })
        }
        else {
            result = nil
            POIResult = nil
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return (result?.count) ?? 0
        }
        else {
            return (POIResult?.count) ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "location")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "location")
        }
        
        let r = indexPath.section == 0 ? POIResult : result
        
        let textAttr = [
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName: UIFont.systemFont(ofSize: 16)
        ] as [String : AnyObject]
        let textHighlightAttr = [
            NSForegroundColorAttributeName: UIColor.withRGB(red: 70, green: 185, blue: 66),
            NSFontAttributeName: UIFont.systemFont(ofSize: 16)
            ] as [String : AnyObject]
        let detailTextAttr = [
            NSForegroundColorAttributeName: UIColor.lightGray,
            NSFontAttributeName: UIFont.systemFont(ofSize: 14)
        ] as [String : AnyObject]
        let detailHighlightTextAttr = [
            NSForegroundColorAttributeName: UIColor.withRGB(red: 70, green: 185, blue: 66),
            NSFontAttributeName: UIFont.systemFont(ofSize: 14)
            ] as [String : AnyObject]
        
        let plainText = r?[indexPath.row].name ?? ""
        let text: NSMutableAttributedString = NSMutableAttributedString(string:  plainText, attributes: textAttr)
        let plainDetailText = r?[indexPath.row].address ?? ""
        let detailText: NSMutableAttributedString = NSMutableAttributedString(string: plainDetailText, attributes: detailTextAttr)
        text.setAttributes(textHighlightAttr, range: (plainText as NSString).range(of: searchKeyword ?? ""))
        detailText.setAttributes(detailHighlightTextAttr, range: (plainDetailText as NSString).range(of: searchKeyword ?? ""))
        cell!.textLabel?.attributedText = text
        cell!.detailTextLabel?.attributedText = detailText
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let r = indexPath.section == 0 ? POIResult : result
        if let r = r {
            didSelectPOI?(r[indexPath.row])
        }
    }
}

class HomeViewController: PEViewController {
    var mapView: MKMapView!
    var searchController: UISearchController!
    var searchResultContoller = HomeSearchResultTableViewController()
    
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var pinView: UIImageView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var mapHeight: NSLayoutConstraint!
    
    var searcher = POISearcher()
    var locationManager: CLLocationManager!
    var centerPos: CLLocationCoordinate2D! {
        didSet {
            
        }
    }
    var locationList = [POI]()
    var image: UIImage? {
        didSet {
            selectedImage?.image = image//?.scale(maxLength: 40.0)
            selectedImage?.isHidden = false
            selectedImage?.layer.shadowColor = UIColor.black.cgColor
            selectedImage?.layer.shadowRadius = 5
            selectedImage?.layer.shadowOpacity = 0.8
            selectedImage?.layer.shadowOffset = CGSize.zero
        }
    }
    
    override func viewDidLoad() {
        func setupSearchController() {
            searchController = UISearchController(searchResultsController: searchResultContoller)
            
            searchController.searchResultsUpdater = searchResultContoller
            searchController.searchBar.placeholder = "搜索地点"
            mapContainerView.insertSubview(searchController.searchBar, aboveSubview: mapContainerView)
            searchController.searchBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
            searchController.searchBar.barTintColor = UIColor.withRGB(red: 235, green: 235, blue: 241)
            searchController.searchBar.tintColor = UIColor.withRGB(red: 70, green: 185, blue: 66)
            searchController.delegate = self
            
            searchResultContoller.didSelectPOI = { [weak self] (poi) in
                if let this = self {
                    this.centerPos = poi.location!
                    this.mapView.setRegion(MKCoordinateRegionMakeWithDistance(this.centerPos, 2000, 2000), animated: true)
                    this.requestPOI()
                    this.searchController.isActive = false
                }
            }
            
        }
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // setup mapview
        mapView = MKMapView(frame: mapContainerView.bounds)
        mapView.delegate = self
        mapView.isRotateEnabled = false
        mapView.mapType = .standard
        mapContainerView.addSubview(mapView)
        pinView.superview?.bringSubview(toFront: pinView)
        selectedImage.superview?.bringSubview(toFront: selectedImage)
        
        // setup view
        locationTableView.layer.cornerRadius = 4.0
        
        // setup image
        selectedImage.onTap(target: self, action: #selector(HomeViewController.importPressed(sender:)))
        selectedImage.image = image?.scale(maxLength: 40.0)
        
        setupSearchController()
        
        automaticallyAdjustsScrollViewInsets = false
        mapHeight.constant = 0.45 * UIScreen.main.bounds.height
        
        DispatchQueue.main.async {
            [weak self] in
            if let this = self {
                this.centerPos = this.image?.GPSLocation  ?? CLLocationCoordinate2D(latitude: 39.963438, longitude: 116.316376)
                this.mapView.setRegion(MKCoordinateRegionMakeWithDistance(this.centerPos, 8000, 8000), animated: true)
                this.requestPOI()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        mapView.frame = mapContainerView.bounds
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? HotTableViewController {
            vc.onSelectPOI = {
                [weak self](poi) in
                if let this = self {
                    this.centerPos = poi.location!
                    this.mapView.setRegion(MKCoordinateRegionMakeWithDistance(this.centerPos, 2000, 2000), animated: true)
                    this.requestPOI()
                }
            }
        }
        
    }
    
    func requestPOI() {
        locationTableView.startLoading()
        searcher.requestAmapSearch(centerPos: centerPos,
                                   done: { [weak self](pois) in
                        self?.locationList = pois
                        self?.locationTableView.reloadData()
                        self?.locationTableView.stopLoading()
        })
    }
    
    func exportImage() {
        image?.saveToAlbum(withGPS: centerPos)
        navigationController?.present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "share"), animated: true, completion: { [weak self] in
            _ = self?.navigationController?.popToRootViewController(animated: false)
        })
        
        ServerAPI.jsonRequest(.loggingPOIURL,
                          params: [
                            "uuid":" ",
                            "platform": 0,
                            "name": locationList.count > 0 ? (locationList[0].name ?? " " ):" ",
                            "longitude": centerPos?.longitude ?? 0,
                            "latitude": centerPos?.latitude ?? 0,
            ])
    }
}

extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard let _ = centerPos else {
            return
        }
        
        centerPos = mapView.centerCoordinate
        
        requestPOI()
        
        
        UIView.animate(withDuration: 0.3, animations: {
            [weak self] in
            self?.pinView.transform = CGAffineTransform(translationX: 0, y: -10)
        }, completion: {
            (s) in
            UIView.animate(withDuration: 0.3, animations: {
                [weak self] in
                self?.pinView.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        })
    }
}

extension HomeViewController: UIBarPositioningDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
    }
}
extension HomeViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
}


extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : locationList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "hot", for: indexPath)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "location", for: indexPath)
        
        cell.textLabel?.text = locationList[indexPath.row].name
        cell.detailTextLabel?.text =  locationList[indexPath.row].address
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            centerPos = locationList[indexPath.row].location!
            mapView.setCenter(centerPos, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HomeViewController {
    @IBAction func okPressed(_ sender: AnyObject) {
        if let _ = image {
            exportImage()
        }
        else {
            importImage()
        }
    }
    
    @IBAction func importPressed( sender: AnyObject) {
        importImage()
    }
    
    @IBAction func back() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "clearImage"), object: nil)
        navigationController?.popViewController(animated: true)
    }
}
