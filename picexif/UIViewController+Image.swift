//
//  UIViewController+Image.swift
//  picexif
//
//  Created by Simon on 05/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import Foundation

extension UIViewController {
    @IBAction func importImage() {
        let actionSheet = HJCActionSheet(title: "", delegate: self,
                                         cancelButtonTitle: "取消",
                                         otherButtonTitles: ["拍照", "从手机相册选择"])
        actionSheet?.show()
        actionSheet?.tag = 999
    }
}

extension UIViewController: HJCActionSheetDelegate {
    public func actionSheet(_ actionSheet: HJCActionSheet!, clickedButtonAt buttonIndex: Int) {
        if let actionSheet = actionSheet {
            if actionSheet.tag == 999 {
                if buttonIndex == 1 {
                    let vc = UIImagePickerController()
                    vc.allowsEditing = true
                    vc.sourceType = .camera
                    if let this = self as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
                        vc.delegate = this
                    }
                    self.present(vc, animated: true, completion: nil)
                }
                else if buttonIndex == 2 {
                    let vc = UIImagePickerController()
                    vc.allowsEditing = false
                    vc.sourceType = .photoLibrary
                    if let this = self as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
                        vc.delegate = this
                    }
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
}
