//
//  user.swift
//  ChatAppLine
//
//  Created by yasuyoshi on 2021/03/28.
//

import Foundation
//
import Firebase

class User {
    
    let email: String
    let username: String
    let createAt: Timestamp
    let profileImageUrl: String
    
    var uid: String?
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.createAt = dic["createAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
    }

}
