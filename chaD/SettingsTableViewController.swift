//
//  SettingsTableViewController.swift
//  chaD
//
//  Created by Dayana Marden on 30.04.17.
//  Copyright © 2017 Dayana Marden. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class SettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userBioLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    var user: User!
    override func viewDidLoad() {
        super.viewDidLoad()
        userImageView.layer.cornerRadius = userImageView.layer.frame.width/2
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor(colorLiteralRed: 167/255, green: 63/255, blue: 75/255, alpha: 1).cgColor
        
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let userRef = FIRDatabase.database().reference().child("users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
        
        userRef.observe(.value, with: { (snapshot) in
            
            for userInfo in snapshot.children {
                
                self.user = User(snapshot: userInfo as! FIRDataSnapshot)
                
            }
            
            if let user = self.user {
                
                self.usernameLabel.text = user.username
                self.userBioLabel.text = user.biography

                FIRStorage.storage().reference(forURL: user.photoURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                    if let error = error {
                        print(error)
                        
                    }else{
                        
                        DispatchQueue.main.async(execute: {
                            if let data = imgData {
                                self.userImageView.image = UIImage(data: data)
                            }
                        })
                    }
                    
                })
                
                
            }
            
            
            
        }) { (error) in
            print("error")
            
        }
        
    }
    

    
    func deleteAccount(){
        let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "1st", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            let currentUserRef = FIRDatabase.database().reference().child("users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
            
            currentUserRef.observe(.value, with: { (snapshot) in
                
                for user in snapshot.children {
                    
                    let currentUser = User(snapshot: user as! FIRDataSnapshot)
                    
                    currentUser.ref?.removeValue(completionBlock: { (error, ref) in
                        if error == nil {
                            
                            FIRAuth.auth()?.currentUser?.delete(completion: { (error) in
                                if error == nil {
                                    
                                    print("account successfully deleted!")
                                    DispatchQueue.main.async(execute: {
                                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
                                        self.present(vc, animated: true, completion: nil)
                                        
                                    })
                                    
                                }else {
                                    print("erropr")
                                    
                                }
                            })
                            
                        }else {
                            print("error")
                            
                        }
                    })
                    
                    
                }}) { (error) in
                    print("")
                    
            }

        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func resetPassword(){
        let email = FIRAuth.auth()!.currentUser!.email!
         AuthenticationService().resetPassword(email)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0  {
            deleteAccount()
        }else if indexPath.section == 1 && indexPath.row == 1 {
            resetPassword()
        }
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem){
        print("YES")
        do {
            
            try FIRAuth.auth()?.signOut()
            
            if FIRAuth.auth()?.currentUser == nil {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login") as! LoginViewController
                present(vc, animated: true, completion: nil)
            }
            
        } catch let error as NSError {
            print(error)
        }
        
    }

    
    

}
