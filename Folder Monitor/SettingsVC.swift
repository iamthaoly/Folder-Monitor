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
    
    @IBOutlet weak var btnTestAPI: NSButton!
    // MARK: - CONSTANTS
    let API_USERNAME_FIELD = "apiUsername"
    let API_PASSWORD_FIELD = "apiPassword"
    let API_KEY_FIELD = "apiKey"
    
    // MARK: - VARS
//    var username: String?
//    var password: String?
//    var apiKey: String?
    let apiManager = BillbeeAPIManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        print("This is setting view controller.")
        
        if apiManager.checkNil() == false {
            edtUsername.stringValue = apiManager.username ?? ""
            edtPassword.stringValue = apiManager.password ?? ""
            edtAPIKey.stringValue = apiManager.apiKey ?? ""
        }
        
    }
    
    
    @IBAction func saveAPISetting(_ sender: Any) {
        if edtUsername.stringValue == "" || edtPassword.stringValue == "" || edtAPIKey.stringValue == "" {
            // Display alert. Please fill all the fields.
            Utils.displayAlert(title: "Warning", text: "Please fill all the fields.")
            return
        }
        apiManager.saveAPI()
//        UserDefaults.standard.set(edtUsername.stringValue, forKey: API_USERNAME_FIELD)
//        UserDefaults.standard.set(edtPassword.stringValue, forKey: API_PASSWORD_FIELD)
//        UserDefaults.standard.set(edtAPIKey.stringValue, forKey: API_KEY_FIELD)
        txtStatus.stringValue = "Save successfully!"
    }
    
    @IBAction func testAPI(_ sender: Any) {
        if apiManager.checkNil() == false {
            btnTestAPI.isEnabled = false
            let api = "https://api.billbee.io/api/v1/shipment/ping"
            
            var headers: HTTPHeaders = [
                .authorization(username: apiManager.username!, password: apiManager.password!)
                    ]
            headers.add(name: "X-Billbee-Api-Key", value: apiManager.apiKey!)
//            let headers2: HTTPHeaders = ["api": "abc", "apiiii": "nosuch"]
            
            AF.request(api, method: .get ,headers: headers).responseJSON { result in
                debugPrint(result)
                DispatchQueue.main.async {
                    self.btnTestAPI.isEnabled = true
                }
                
                if (result.response != nil) {
                    let httpCode: Int = result.response!.statusCode
                    DispatchQueue.main.async {
                        let status = "Status: \(httpCode). Authentication " + (httpCode == 200 ? "successfully!" : "failed!")
                        self.txtStatus.stringValue = status
                        self.txtStatus.textColor = httpCode == 200 ? .green : .red
//                            self.txtStatus.stringValue = "Status: \(httpCode). Authentication successfully!"
                    }
                }
                else {
                    
                }

            }
        }
        // Notice the user
        // No API information had been saved. Please save first.
        
    }
    
//    private func loadAPI() -> Bool{
//        if let username = UserDefaults.standard.string(forKey: API_USERNAME_FIELD),
//           let password = UserDefaults.standard.string(forKey: API_PASSWORD_FIELD),
//           let apiKey = UserDefaults.standard.string(forKey: API_KEY_FIELD)
//           {
//            self.username = username
//            self.password = password
//            self.apiKey = apiKey
//            return true
//        }
//        else {
//            return false
//        }
//    }
}
