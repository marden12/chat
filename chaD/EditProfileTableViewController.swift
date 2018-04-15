//
//  EditProfileTableViewController.swift
//  chaD
//
//  Created by Dayana Marden on 30.04.17.
//  Copyright © 2017 Dayana Marden. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class EditProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var biographyTextField: UITextField!
    
    
    var databaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorageReference! {
        
        return FIRStorage.storage().reference()
    }

    
    var pickerView: UIPickerView!
    var countryArrays = [String]()
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userImageView.layer.cornerRadius = userImageView.layer.frame.height/2
        
        for code in Locale.isoRegionCodes as [String]{
            let id = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = (Locale(identifier: "en_EN") as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            
            countryArrays.append(name)
            countryArrays.sort(by: { (name1, name2) -> Bool in
                name1 < name2
            })
        }
        usernameTextField.delegate = self
        emailTextField.delegate = self
        countryTextField.delegate = self
        biographyTextField.delegate = self
        usernameTextField.setBottomBorder(borderColor: UIColor.white)
        emailTextField.setBottomBorder(borderColor: UIColor.white)
        countryTextField.setBottomBorder(borderColor: UIColor.white)
        biographyTextField.setBottomBorder(borderColor: UIColor.white)
        
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.black
        countryTextField.inputView = pickerView
        
        
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileTableViewController.choosePictureAction))
        imageTapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(imageTapGesture)
        
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(imageTapGesture)
        
        
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileTableViewController.dismissKeyboard(_:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
       
        
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(EditProfileTableViewController.dismissKeyboard(_:)))
        swipDown.direction = .down
        view.addGestureRecognizer(swipDown)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchCurrentUserInfo()
    }
    
    // Dismissing all editing actions when User Tap or Swipe down on the Main View
    func dismissKeyboard(_ gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }

    
    
    func fetchCurrentUserInfo(){
        
        let userRef = FIRDatabase.database().reference().child("users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
        
        userRef.observe(.value, with: { (snapshot) in
            
            for userInfo in snapshot.children {
                
                self.user = User(snapshot: userInfo as! FIRDataSnapshot)
                
            }
            
            if let user = self.user {
                
                self.emailTextField.text = user.email
                self.usernameTextField.text = user.username
                self.biographyTextField.text = user.biography
                self.countryTextField.text = user.country
                
            }
            
            
            
        }) { (error) in
            print("error")
            
        }

        
        
    }
    
    @IBAction func updateAction(_ sender: AnyObject) {
    
        let email = emailTextField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: CharacterSet.whitespaces)
        let country = countryTextField.text!
        let biography = biographyTextField.text!
        let username = usernameTextField.text!
        let userPicture = userImageView.image
        
        let imgData = UIImageJPEGRepresentation(userPicture!, 0.8)!
        
        if finalEmail.isEmpty || finalEmail.characters.count < 8 || country.isEmpty || biography.isEmpty || username.isEmpty {
            DispatchQueue.main.async(execute: {
                print("spmething is not correct,please look again")
                
            })
            
        }else {
            
            let imagePath = "profileImage\(user.uid)/userPic.jpg"
            
            let imageRef = storageRef.child(imagePath)
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            imageRef.put(imgData, metadata: metadata) { (metadata, error) in
                if error == nil {
                    
                    FIRAuth.auth()!.currentUser!.updateEmail(finalEmail, completion: { (error) in
                        if error == nil {
                            print("email updated successfully")
                        }else {
                            DispatchQueue.main.async(execute: {
                                print("error")
                            })
                        }
                    })
                    
                    let changeRequest = FIRAuth.auth()!.currentUser!.profileChangeRequest()
                    changeRequest.displayName = username
                    
                    if let photoURL = metadata!.downloadURL(){
                        changeRequest.photoURL = photoURL
                    }
                    
                    changeRequest.commitChanges(completion: { (error) in
                        if error == nil {
                            let user = FIRAuth.auth()!.currentUser!
                            
                            let userInfo = ["email": user.email!, "username": username, "country": country, "biography": biography, "uid": user.uid, "photoURL": String(describing: user.photoURL!)]
                            
                            let userRef = self.databaseRef.child("users").child(user.uid)
                            
                            userRef.setValue(userInfo, withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    self.navigationController?.popViewController(animated: true)
                                }else {
                                    DispatchQueue.main.async(execute: {
                                        print("error")
                                    })

                                }
                            })
                        }
                        else {
                            
                            DispatchQueue.main.async(execute: {
                                print("error")
                            })
                        }  
                    })
                }else {
                    
                    DispatchQueue.main.async(execute: {
                        print("error")
                    })
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        countryTextField.resignFirstResponder()
        biographyTextField.resignFirstResponder()
        return true
    }
    
    func choosePictureAction() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        
        let alertController = UIAlertController(title: "Add a Picture", message: "Choose From", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
            
        }
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
            pickerController.sourceType = .savedPhotosAlbum
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            self.choosePictureAction()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: true, completion: nil)
        self.userImageView.image = image
    }
    
   

    // MARK: - Picker view data source
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryArrays[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryTextField.text = countryArrays[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryArrays.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let title = NSAttributedString(string: countryArrays[row], attributes: [NSForegroundColorAttributeName: UIColor.white])
        return title
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
}
