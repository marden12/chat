//
//  ChatViewController.swift
//  chaD
//
//  Created by Dayana Marden on 30.04.17.
//  Copyright © 2017 Dayana Marden. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import MobileCoreServices
import AVKit


class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var chatRoomId: String!
    
    var messages = [JSQMessage]()
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    var userIsTypingRef: FIRDatabaseReference!
    
    fileprivate var localTyping: Bool = false
    
//    var isTyping: Bool {
//        get {
//            return localTyping
//        }
//        set {
//            localTyping = newValue
//            userIsTypingRef.setValue(newValue)
//        }
//        
//    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        observeTypingUser()
        
            self.title = "MESSAGES"
        let factory = JSQMessagesBubbleImageFactory()
        
        
        
        incomingBubbleImageView = factory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(with: UIColor(colorLiteralRed: 101/255, green: 75/255, blue: 119/255, alpha: 1))
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        collectionView.backgroundColor = UIColor.clear
        let image = UIImage(named:"back")
        let imageView = UIImageView(image: image)
        collectionView.backgroundView = imageView
        
                
        fetchMessages()
        
    }


    
    func fetchMessages(){
        
        let messageQuery = databaseRef.child("ChatRooms").child(chatRoomId).child("Messages").queryLimited(toLast: 30)
        messageQuery.observe(.childAdded, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary

            let senderId = value?["senderId"] as? String ?? ""
            let text = value?["text"] as? String ?? ""
            let displayName = value?["displayName"] as? String ?? ""
            let mediaType = value?["mediaType"] as? String ?? ""
            let mediaUrl = value?["mediaUrl"] as? String ?? ""
            

            
            switch mediaType {
            case "TEXT":
                
                self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, text: text))

            case "PHOTO":
                
                let picture = UIImage(data: try! Data(contentsOf: URL(string: mediaUrl)!))
                let photo = JSQPhotoMediaItem(image: picture)
                self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: photo))

            case "VIDEO":
                
                if let url = URL(string: mediaUrl) {
                let video = JSQVideoMediaItem(fileURL: url, isReadyToPlay: true)
                self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: video))

                    }
                
            default: break
            }
            
            self.finishReceivingMessage()
            
        }) { (error) in
            print("error")
        }
        

    }
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        
        //isTyping = textView.text != ""
    }
    
    fileprivate func observeTypingUser(){
        let typingRef = databaseRef.child("ChatRooms").child(chatRoomId).child("typingIndicator")
        userIsTypingRef = typingRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        let userIsTypingQuery = typingRef.queryOrderedByValue().queryEqual(toValue: true)
        
        userIsTypingQuery.observe(.value, with: { (snapshot) in
            
//            if snapshot.childrenCount == 1 && self.isTyping {
//                return
//            }
//            self.showTypingIndicator = snapshot.childrenCount > 0
            self.scrollToBottom(animated: true)
            
            
            
            }) { (error) in
                print("error")
        }
        
        
    }
    
    
    
 
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = messages[indexPath.item]
        
        if message.isMediaMessage {
            if let media = message.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: media.fileURL)
                let avPlayerViewController = AVPlayerViewController()
                avPlayerViewController.player = player
                self.present(avPlayerViewController, animated: true, completion: nil)
                
            }
        }
    }
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let messageRef = databaseRef.child("ChatRooms").child(chatRoomId).child("Messages").childByAutoId()
        let message = Message(text: text, senderId: senderId, username: senderDisplayName, mediaType: "TEXT", mediaUrl: "")
        
        messageRef.setValue(message.toAnyObject()) { (error, ref) in
            if error == nil {
                
                let lastMessageRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("lastMessage")
                lastMessageRef.setValue(text, withCompletionBlock: { (error, ref) in
                    if error == nil {
                      
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateDiscussions"), object: nil)
                 
                    }else {
                        print("error")

                    }
                    
                    
                })
                let lastTimeRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("date")
                lastTimeRef.setValue(Date().timeIntervalSince1970, withCompletionBlock: { (error, ref) in
                    if error == nil {
                                                
                    }else {
                        print("error")
                        
                    }
                })
                
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                
            }else {
                print("error")
            }
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let alertController = UIAlertController(title: "Medias", message: "Choose your media type", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
        let imageAction = UIAlertAction(title: "Image", style: UIAlertActionStyle.default) { (action) in
        self.getMedia(kUTTypeImage)
            
        }
        
        let videoAction = UIAlertAction(title: "Video", style: UIAlertActionStyle.default) { (action) in
            self.getMedia(kUTTypeMovie)

            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertController.addAction(imageAction)
        alertController.addAction(videoAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)


    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            
            self.saveMediaMessage(withImage: picture, withVideo: nil)
            
            
        } else if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            
            self.saveMediaMessage(withImage: nil, withVideo: videoUrl)

        }
        
        self.dismiss(animated: true) {
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            self.finishSendingMessage()

        }

    }
    
    fileprivate func saveMediaMessage(withImage image: UIImage?, withVideo: URL?){
        
        if let image = image {
            
            let imagePath = "messageWithMedia\(chatRoomId + UUID().uuidString)/photo.jpg"
            
            let imageRef = storageRef.reference().child(imagePath)
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let imageData = UIImageJPEGRepresentation(image, 0.8)!
            
            imageRef.put(imageData, metadata: metadata, completion: { (newMetaData, error) in
                
                if error == nil {
                    
                    let message = Message(text: "", senderId: self.senderId, username: self.senderDisplayName, mediaType: "PHOTO", mediaUrl: String(describing: newMetaData!.downloadURL()!))
                  let messageRef =  self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("Messages").childByAutoId()
                    
                    messageRef.setValue(message.toAnyObject(), withCompletionBlock: { (error, ref) in
                        if error == nil {
                            
                            let lastMessageRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("lastMessage")
                            lastMessageRef.setValue(String(describing: newMetaData!.downloadURL()!), withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateDiscussions"), object: nil)
                                    
                                }else {
                                    print("error")
                                    
                                }
                                
                                
                            })
                            let lastTimeRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("date")
                            lastTimeRef.setValue(Date().timeIntervalSince1970, withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    
                                }else {
                                    print("error")
                                    
                                }
                            })
                            
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            self.finishSendingMessage()
                            
                        }
                        
                    })
                    
                    
                }else {
                   print("error")
                }
            })
            
            
        } else {
            
            
            let videoPath = "messageWithMedia\(chatRoomId + UUID().uuidString)/video.mp4"
            
            let videoRef = storageRef.reference().child(videoPath)
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "video/mp4"
            
            let videoData = try! Data(contentsOf: withVideo!)
            
            videoRef.put(videoData, metadata: metadata, completion: { (newMetaData, error) in
                
                if error == nil {
                    
                    let message = Message(text: "", senderId: self.senderId, username: self.senderDisplayName, mediaType: "VIDEO", mediaUrl: String(describing: newMetaData!.downloadURL()!))
                    
                    let messageRef =  self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("Messages").childByAutoId()

                    messageRef.setValue(message.toAnyObject(), withCompletionBlock: { (error, ref) in
                        if error == nil {
                            
                            let lastMessageRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("lastMessage")
                            lastMessageRef.setValue(String(describing: newMetaData!.downloadURL()!), withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateDiscussions"), object: nil)
                                    
                                }else {
                                   print("error")
                                    
                                }
                                
                                
                            })
                            let lastTimeRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("date")
                            lastTimeRef.setValue(Date().timeIntervalSince1970, withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    
                                }else {
                                    print("error")
                                    
                                }
                            })
                            
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            self.finishSendingMessage()
                            
                        }
                        
                    })
                    
                }else {
                    print("error")
                }
            })
            
            
            
            
            
            
        }
        
        
    }
    
    fileprivate func getMedia(_ mediaType: CFString){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.isEditing = true
        
        if mediaType == kUTTypeImage {
            
            imagePicker.mediaTypes = [mediaType as String]
            
        } else if mediaType == kUTTypeMovie {
            
            imagePicker.mediaTypes = [mediaType as String]

        }
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        }else {
            return incomingBubbleImageView
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        if !message.isMediaMessage {
        if message.senderId == senderId {
            cell.textView.textColor = UIColor.white
        }else {
            cell.textView.textColor = UIColor.black
        }
        }
        
        
        return cell
    }
    
    
    
    
    
    
    
}
