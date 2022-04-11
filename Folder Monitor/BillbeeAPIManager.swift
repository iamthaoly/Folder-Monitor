//
//  BillbeeAPIManager.swift
//  Folder Monitor
//
//  Created by ly on 11/04/2022.
//  Copyright © 2022 lytran. All rights reserved.
//

import Foundation

class BillbeeAPIManager {
    // MARK: - CONSTANTS
    let API_USERNAME_FIELD = "apiUsername"
    let API_PASSWORD_FIELD = "apiPassword"
    let API_KEY_FIELD = "apiKey"

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
}
