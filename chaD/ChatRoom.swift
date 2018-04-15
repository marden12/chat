//
//  ChatRoom.swift
//  chaD
//
//  Created by Dayana Marden on 30.04.17.
//  Copyright © 2017 Dayana Marden. All rights reserved.

import Foundation
import FirebaseDatabase


struct ChatRoom {
    
    var username: String!
    var other_Username: String!
    var userId: String!
    var other_UserId: String!
    var members: [String]!
    var chatRoomId: String!
    var key: String = ""
    var lastMessage: String!
    var ref: FIRDatabaseReference!
    var userPhotoUrl: String!
    var other_UserPhotoUrl: String!
    var date: NSNumber
 
    
    init(snapshot: FIRDataSnapshot){
        let value = snapshot.value as? NSDictionary
        
        self.username = value?["username"] as? String ?? ""
        self.other_Username = value?["other_Username"] as? String ?? ""
        self.userId = value?["userId"] as? String ?? ""
        self.other_UserId = value?["other_UserId"] as? String ?? ""
        self.lastMessage = value?["lastMessage"] as? String ?? ""
        self.userPhotoUrl = value?["userPhotoUrl"] as? String ?? ""
        self.other_UserPhotoUrl = value?["other_UserPhotoUrl"] as? String ?? ""
        self.members = value?["members"] as? [String] ?? [""]
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.chatRoomId = value?["chatRoomId"] as? String ?? ""
        self.date = value?["date"] as! NSNumber
 
    }
    
    
    init(username: String, other_Username: String,userId: String,other_UserId: String,members: [String],chatRoomId: String,lastMessage: String,key: String = "",userPhotoUrl: String,other_UserPhotoUrl: String, date:NSNumber ){
        
        self.username = username
        self.other_UserPhotoUrl = other_UserPhotoUrl
        self.other_Username = other_Username
        self.userId = userId
        self.other_UserId = other_UserId
        self.userPhotoUrl = userPhotoUrl
        self.members = members
        self.lastMessage = lastMessage
        self.chatRoomId = chatRoomId
        self.date  = date

    
        
    }

    func toAnyObject() -> [String: AnyObject] {
        
        return ["username": username as AnyObject, "other_Username": other_Username as AnyObject,"userId": userId as AnyObject,"other_UserId": other_UserId as AnyObject,"members": members as AnyObject,"chatRoomId": chatRoomId as AnyObject,"lastMessage": lastMessage as AnyObject,"userPhotoUrl": userPhotoUrl as AnyObject,"other_UserPhotoUrl": other_UserPhotoUrl as AnyObject,"date": date as AnyObject]
        
    }
    
}
