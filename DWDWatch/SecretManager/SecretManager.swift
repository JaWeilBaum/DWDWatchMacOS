//
//  SecretManager.swift
//  DWDWatch
//
//  Created by Léon Friedmann on 06.07.21.
//

import Foundation

class SecretManager {
    static let shared = SecretManager()
    private let username = ""
    private let password = ""
    
    init() {
        
    }
    
    func getAuth() -> String {
        Data((username + ":" + password).utf8).base64EncodedString()
    }
}
