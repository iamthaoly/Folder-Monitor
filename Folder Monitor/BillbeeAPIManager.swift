//
//  BillbeeAPIManager.swift
//  Folder Monitor
//
//  Created by ly on 11/04/2022.
//  Copyright © 2022 lytran. All rights reserved.
//

import Foundation
import Alamofire

class BillbeeAPIManager {
    // MARK: - CONSTANTS
    let API_USERNAME_FIELD = "apiUsername"
    let API_PASSWORD_FIELD = "apiPassword"
    let API_KEY_FIELD = "apiKey"
    let API_BASE_URL = "https://api.billbee.io/api/v1"

    // MARK: - VARIABLES
    var username: String?
    var password: String?
    var apiKey: String?
    
    init() {
        if loadAPI() {
            print("API SETTINGS LOADED!")
        }
        else {
            print("NO API SETTINGS")
        }
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
    
    func saveAPI() {
        UserDefaults.standard.set(username, forKey: API_USERNAME_FIELD)
        UserDefaults.standard.set(password, forKey: API_PASSWORD_FIELD)
        UserDefaults.standard.set(apiKey, forKey: API_KEY_FIELD)
    }
    
    func checkNil() -> Bool {
        return username == nil || password == nil || apiKey == nil
    }
    
    func sendShipmentRequest(orderNumber: String) -> Bool{
        if checkNil() == false {
            let api = API_BASE_URL + "/orders/" + orderNumber
            var headers: HTTPHeaders = [
                .authorization(username: username!, password: password!)
                    ]
            headers.add(name: "X-Billbee-Api-Key", value: apiKey!)
            let body = """
                {
                  "NewStateId": 4
                }
                """
            
            AF.request(api, method: .put, headers: headers).responseJSON { result in
                debugPrint(result)
                
            }
        }
        
        return false
    }
}
