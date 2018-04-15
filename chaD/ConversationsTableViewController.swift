//
//  ConversationsTableViewController.swift
//  chaD
//
//  Created by Dayana Marden on 30.04.17.
//  Copyright © 2017 Dayana Marden. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class ConversationsTableViewController: UITableViewController {
    var label = UILabel()
    var chatFunctions = ChatFunctions()

    
    var dataBaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage! {
        return FIRStorage.storage()
    }
    
    var chatsArray = [ChatRoom]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label  = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        label.textAlignment = .center
        label.center.y = view.center.y
        label.text = "CREATE new CHAT NOW"
        view.addSubview(label)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationsTableViewController.fetchChats), name: NSNotification.Name(rawValue: "updateDiscussions"), object: nil)
        fetchChats()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        animateTable()
        
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


    func fetchChats(){
        chatsArray.removeAll(keepingCapacity: false)
        dataBaseRef.child("ChatRooms").queryOrdered(byChild: "userId").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid).observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            let username = value?["username"] as? String ?? ""
            let other_Username = value?["other_Username"] as? String ?? ""
            let userId = value?["userId"] as? String ?? ""
            let other_UserId = value?["other_UserId"] as? String ?? ""
            let lastMessage = value?["lastMessage"] as? String ?? ""
            let userPhotoUrl = value?["userPhotoUrl"] as? String ?? ""
            let other_UserPhotoUrl = value?["other_UserPhotoUrl"] as? String ?? ""
            let members = value?["members"] as? [String] ?? [""]
            let ref = snapshot.ref
            let key = snapshot.key
            let chatRoomId = value?["chatRoomId"] as? String ?? ""
            let date = value?["date"] as! NSNumber
     

            
            var newChat = ChatRoom(username: username, other_Username: other_Username, userId: userId, other_UserId: other_UserId, members: members, chatRoomId: chatRoomId, lastMessage: lastMessage, userPhotoUrl: userPhotoUrl, other_UserPhotoUrl: other_UserPhotoUrl,date:date)
            newChat.ref = ref
            newChat.key = key
            
            self.chatsArray.insert(newChat, at: 0)
            self.tableView.reloadData()
            
            
            
            }) { (error) in
                print("error")
                

        }
        
        
        dataBaseRef.child("ChatRooms").queryOrdered(byChild: "other_UserId").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid).observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            let username = value?["username"] as? String ?? ""
            let other_Username = value?["other_Username"] as? String ?? ""
            let userId = value?["userId"] as? String ?? ""
            let other_UserId = value?["other_UserId"] as? String ?? ""
            let lastMessage = value?["lastMessage"] as? String ?? ""
            let userPhotoUrl = value?["userPhotoUrl"] as? String ?? ""
            let other_UserPhotoUrl = value?["other_UserPhotoUrl"] as? String ?? ""
            let members = value?["members"] as? [String] ?? [""]
            let ref = snapshot.ref
            let key = snapshot.key
            let chatRoomId = value?["chatRoomId"] as? String ?? ""
            let date = value?["date"] as! NSNumber
 
            
            var newChat = ChatRoom(username: username, other_Username: other_Username, userId: userId, other_UserId: other_UserId, members: members, chatRoomId: chatRoomId, lastMessage: lastMessage, key:key, userPhotoUrl: userPhotoUrl,other_UserPhotoUrl: other_UserPhotoUrl,date:date)
            newChat.ref = ref
            newChat.key = key
            
            self.chatsArray.insert(newChat, at: 0)
            self.tableView.reloadData()
            
            
            
        }) { (error) in
            print("error")
            
        }


    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chatsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationsCell", for: indexPath) as! ConversationsTableViewCell
        label.isHidden = true
        
        var userPhotoUrlString: String? = ""
        
        if chatsArray[indexPath.row].userId == FIRAuth.auth()!.currentUser!.uid {
            userPhotoUrlString = chatsArray[indexPath.row].other_UserPhotoUrl
            cell.usernameLabel.text = chatsArray[indexPath.row].other_Username
        }else {
            userPhotoUrlString = chatsArray[indexPath.row].userPhotoUrl
            cell.usernameLabel.text = chatsArray[indexPath.row].username
        }
        
        let fromDate = Date(timeIntervalSince1970: TimeInterval(chatsArray[indexPath.row].date))
        let toDate = Date()
        
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth,]
        let differenceOfDate = (Calendar.current as NSCalendar).components(components, from: fromDate, to: toDate, options: [])
        
        if differenceOfDate.second! <= 0 {
            cell.dateLabel.text = "now"
        } else if differenceOfDate.second! > 0 && differenceOfDate.minute! == 0 {
            cell.dateLabel.text = ("\(differenceOfDate.second!.description).s")

        }else if differenceOfDate.minute! > 0 && differenceOfDate.hour! == 0 {
            cell.dateLabel.text = ("\(differenceOfDate.minute!.description).m")
            print(cell.dateLabel.text!)
            
        }else if differenceOfDate.hour! > 0 && differenceOfDate.day! == 0 {
            cell.dateLabel.text = ("\(differenceOfDate.hour!.description).h")
            
        }else if differenceOfDate.day! > 0 && differenceOfDate.weekOfMonth! == 0 {
            cell.dateLabel.text = ("\(differenceOfDate.day!.description).d")
            
        }else if differenceOfDate.weekOfMonth! > 0 {
            cell.dateLabel.text = ("\(differenceOfDate.weekOfMonth!.description).w")
            
        }
    
        cell.lastMessageLabel.text = chatsArray[indexPath.row].lastMessage
        if let urlString = userPhotoUrlString {
            storageRef.reference(forURL: urlString).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                if let error = error {
                    print(error)
                }else {
                    
                    DispatchQueue.main.async(execute: {
                        if let data = imgData {
                            cell.userImageView.image = UIImage(data: data)
                        }
                    })
                    
                }
            })
            
            
        }
        


        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentUser = User(username: FIRAuth.auth()!.currentUser!.displayName!, userId: FIRAuth.auth()!.currentUser!.uid, photoUrl: String(describing: FIRAuth.auth()!.currentUser!.photoURL!))
        var otherUser: User!
        if currentUser.uid == chatsArray[indexPath.row].userId{
             otherUser = User(username: chatsArray[indexPath.row].other_Username, userId: chatsArray[indexPath.row].other_UserId, photoUrl: chatsArray[indexPath.row].other_UserPhotoUrl)
        }else {
            otherUser = User(username: chatsArray[indexPath.row].username, userId: chatsArray[indexPath.row].userId, photoUrl: chatsArray[indexPath.row].userPhotoUrl)
        }
        
        chatFunctions.startChat(currentUser, user2: otherUser)

        performSegue(withIdentifier: "goToChat1", sender: self)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            self.chatsArray[indexPath.row].ref?.removeValue()
            self.chatsArray.remove(at: indexPath.row)
            self.tableView.reloadData()
        
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        let whiteRoundedView : UIView = UIView(frame: CGRect(x:0, y:10,width: self.view.frame.size.width, height:136))
        whiteRoundedView.layer.backgroundColor = UIColor(colorLiteralRed: 101/255, green: 75/255, blue: 119/255, alpha: 1).cgColor
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 3.0
        whiteRoundedView.layer.shadowOffset = CGSize(width:-1,height: 1)
        whiteRoundedView.layer.shadowOpacity = 0.5
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubview(toBack: whiteRoundedView)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChat1" {
            
            let chatVC = segue.destination as! ChatViewController
            chatVC.senderId = FIRAuth.auth()!.currentUser!.uid
            chatVC.senderDisplayName = FIRAuth.auth()!.currentUser!.displayName!
            chatVC.chatRoomId = chatFunctions.chatRoom_id
        }
    }
    
    
    
    
    
    
    
    
    
    }
