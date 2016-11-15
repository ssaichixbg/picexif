//
//  PEiewController.swift
//  picexif
//
//  Created by Simon on 07/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import UIKit

class PETableViewController: UITableViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        MobClick.beginLogPageView(NSStringFromClass(self.classForCoder))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        MobClick.beginLogPageView(NSStringFromClass(self.classForCoder))
    }
}

class PEViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        MobClick.beginLogPageView(NSStringFromClass(self.classForCoder))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        MobClick.beginLogPageView(NSStringFromClass(self.classForCoder))
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
