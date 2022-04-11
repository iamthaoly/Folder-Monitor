//
//  SettingsVC.swift
//  Folder Monitor
//
//  Created by ly on 08/04/2022.
//  Copyright © 2022 lytran. All rights reserved.
//

import Cocoa
import Alamofire

class SettingsVC: NSViewController {

    // MARK: - OUTLETS
    @IBOutlet weak var edtUsername: NSTextField!
    @IBOutlet weak var edtPassword: NSTextField!
    @IBOutlet weak var edtAPIKey: NSTextField!
    
    @IBOutlet weak var txtStatus: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        print("This is setting view controller.")
    }
    
    
    @IBAction func saveAPISetting(_ sender: Any) {
        
    }
    
    @IBAction func testAPI(_ sender: Any) {
        
    }
}
