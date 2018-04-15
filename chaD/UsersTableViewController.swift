//
//  UsersTableViewController.swift
//  chaD
//
//  Created by Dayana Marden on 30.04.17.
//  Copyright © 2017 Dayana Marden. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class UsersTableViewController: UITableViewController {

    var dataBaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage {
        
        return FIRStorage.storage()
    }
    
    var users = [User]()
    var chatFunctions = ChatFunctions()
        
    override func viewDidLoad() {
        tabBarController?.tabBar.isHidden = false
        super.viewDidLoad()

       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        animateTable()
        
        let usersRef = dataBaseRef.child("users")
        usersRef.observe(.value, with: { (snapshot) in
            
            var allUsers = [User]()
            
            for user in snapshot.children {
                
                let myself = User(snapshot: user as! FIRDataSnapshot)
                
                if myself.uid != FIRAuth.auth()!.currentUser!.uid {
                    
                    let newUser = User(snapshot: user as! FIRDataSnapshot)
                    allUsers.append(newUser)
                }
           
            }
            self.users = allUsers
            self.tableView.reloadData()
            
            
            }) { (error) in
                print("error")
        }
        
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91
    }
    
override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentUser = User(username:FIRAuth.auth()!.currentUser!.displayName! , userId: FIRAuth.auth()!.currentUser!.uid, photoUrl: String(describing: FIRAuth.auth()!.currentUser!.photoURL!))
        chatFunctions.startChat(currentUser, user2: users[indexPath.row])
        performSegue(withIdentifier: "goToChat", sender: self)
        

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath) as! UsersTableViewCell

        // Configure the cell...
        
        cell.usernameLabel.text = users[indexPath.row].username
        cell.userCountryLabel.text = users[indexPath.row].country
        
        storageRef.reference(forURL: users[indexPath.row].photoURL!).data(withMaxSize: 1*1024*1024) { (data, error) in
            if error == nil {
                
                DispatchQueue.main.async(execute: { 
                    if let data = data {
                        
                        cell.userImageView.image = UIImage(data: data)
                    }
                })
               
                
            }else {
                print("error")
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
       
        let whiteRoundedView : UIView = UIView(frame: CGRect(x:0, y:10,width: self.view.frame.size.width, height:106))
        whiteRoundedView.layer.backgroundColor = UIColor(colorLiteralRed: 101/255, green: 75/255, blue: 119/255, alpha: 1).cgColor
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 3.0
        whiteRoundedView.layer.shadowOffset = CGSize(width:-1,height: 1)
        whiteRoundedView.layer.shadowOpacity = 0.5
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubview(toBack: whiteRoundedView)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChat" {

            let chatViewController = segue.destination as! ChatViewController
            chatViewController.senderId = FIRAuth.auth()!.currentUser!.uid
            chatViewController.senderDisplayName = FIRAuth.auth()!.currentUser!.displayName!
            chatViewController.chatRoomId = chatFunctions.chatRoom_id
            
            
        }
    }
    
    func animateTable() {
        tableView.reloadData()
        
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            
            index += 1
        }
    }

   
}
