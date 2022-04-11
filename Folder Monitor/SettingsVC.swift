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
    @IBOutlet weak var edtPassword: NSTextField!
    @IBOutlet weak var edtUsername: NSTextField!
    @IBOutlet weak var edtAPIKey: NSTextField!
    
    @IBOutlet weak var txtStatus: NSTextField!
    // MARK: - CONSTANTS
    let API_USERNAME_FIELD = "apiUsername"
    let API_PASSWORD_FIELD = "apiPassword"
    let API_KEY_FIELD = "apiKey"
    
    // MARK: - VARS
    var username: String?
    var password: String?
    var apiKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        print("This is setting view controller.")
        
        if loadAPI() == true {
            edtUsername.stringValue = username ?? ""
            edtPassword.stringValue = password ?? ""
            edtAPIKey.stringValue = apiKey ?? ""
        }
        
    }
    
    
    @IBAction func saveAPISetting(_ sender: Any) {
        if edtUsername.stringValue == "" || edtPassword.stringValue == "" || edtAPIKey.stringValue == "" {
            // Display alert. Please fill all the fields.
            
            return
        }
        UserDefaults.standard.set(edtUsername.stringValue, forKey: API_USERNAME_FIELD)
        UserDefaults.standard.set(edtPassword.stringValue, forKey: API_PASSWORD_FIELD)
        UserDefaults.standard.set(edtAPIKey.stringValue, forKey: API_KEY_FIELD)
        txtStatus.stringValue = "Save successfully!"
    }
    
    @IBAction func testAPI(_ sender: Any) {
        if loadAPI() == true {
            
        }
        // Notice the user
        // No API information had been saved. Please save first.
    }
    
    private func loadAPI() -> Bool{
        if let username = UserDefaults.standard.string(forKey: API_USERNAME_FIELD),
           let password = UserDefaults.standard.string(forKey: API_PASSWORD_FIELD),
           let apiKey = UserDefaults.standard.string(forKey: API_KEY_FIELD)
           {
            self.username = username
            self.password = password
            self.apiKey = apiKey
            return true
        }
        else {
            return false
        }
    }
}
