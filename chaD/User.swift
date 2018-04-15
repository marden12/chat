//
//  User.swift
//  chaD
//
//  Created by Dayana Marden on 30.04.17.
//  Copyright © 2017 Dayana Marden. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

struct User {
    
    var username: String!
    var email: String?
    var country: String?
    var photoURL: String!
    var biography: String?
    var uid: String!
    var ref: FIRDatabaseReference?
    var key: String?
    
    init(snapshot: FIRDataSnapshot){
        
        key = snapshot.key
        ref = snapshot.ref
        
        let value = snapshot.value as? NSDictionary
        
        username = value?["username"] as? String ?? ""
        email = value?["email"] as? String ?? ""
        country = value?["country"] as? String ?? ""
        biography = value?["biography"] as? String ?? ""
        photoURL = value?["photoURL"] as? String ?? ""
        uid = value?["uid"] as? String ?? ""

    }
    
    init(username: String, userId: String, photoUrl: String){
        self.username = username
        self.uid = userId
        self.photoURL = photoUrl
    }
    
}
