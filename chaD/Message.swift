//
//  Message.swift
//  chaD
//
//  Created by Dayana Marden on 30.04.17.
//  Copyright © 2017 Dayana Marden. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Message {
    
    var text: String!
    var senderId: String!
    var username: String!
    var mediaType: String!
    var mediaUrl: String!
    var ref: FIRDatabaseReference!
    var key: String = ""
    
    
    init(snapshot: FIRDataSnapshot){
        
        let value = snapshot.value as? NSDictionary

        self.text = value?["text"] as? String ?? ""
        self.senderId = value?["senderId"] as? String ?? ""
        self.username = value?["username"] as? String ?? ""
        self.mediaType = value?["mediaType"] as? String ?? ""
        self.mediaUrl = value?["mediaUrl"] as? String ?? ""
        self.ref = snapshot.ref
        self.key = snapshot.key

    }
    
    
    init(text: String, key: String = "", senderId: String, username: String, mediaType: String, mediaUrl: String){
        
        
        self.text = text
        self.senderId = senderId
        self.username = username
        self.mediaUrl = mediaUrl
        self.mediaType = mediaType
    }
    
    
    func toAnyObject() -> [String: AnyObject]{
        
        return ["text": text as AnyObject,"senderId": senderId as AnyObject, "username": username as AnyObject,"mediaType":mediaType as AnyObject, "mediaUrl":mediaUrl as AnyObject]
    }
    
    
    
}
