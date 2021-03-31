//
//  ChatRoom.swift
//  ChatAppLine
//
//  Created by yasuyoshi on 2021/03/31.
//

import Foundation
//
import Firebase

class ChatRoom {
    
    let latestMessageId: String
    let members: [String]
    let createdAt: Timestamp
    
    var partnerUser: User?
    
    init(dic: [String:Any]) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.members = dic["members"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
    
}
