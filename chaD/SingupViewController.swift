//
//  RegistrationViewController.swift
//  chaD
//
//  Created by Dayana Marden on 30.04.17.
//  Copyright © 2017 Dayana Marden. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController,UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var biographyTextField: UITextField!
    
    var pickerView: UIPickerView!
    var countryArrays = [String]()
    var authService = AuthenticationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
        countryTextField.delegate = self
        biographyTextField.delegate = self
        
        // Retrieving all the countries, Sorting and Storing them inside countryArrays
        for code in Locale.isoRegionCodes as [String]{
            let id = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = (Locale(identifier: "en_EN") as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            
            countryArrays.append(name)
            countryArrays.sort(by: { (name1, name2) -> Bool in
                name1 < name2
            })
        }
        
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.black
        countryTextField.inputView = pickerView
        
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.dismissKeyboard(_:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(SignupViewController.dismissKeyboard(_:)))
        swipDown.direction = .down
        view.addGestureRecognizer(swipDown)
    }
    
    // Signing up the User
    @IBAction func signUpAction(_ sender: AnyObject) {
        
        let data = UIImageJPEGRepresentation(self.userImageView.image!, 0.8)
        let email = emailTextField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: CharacterSet.whitespaces)
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        let country = countryTextField.text!
        let biography = biographyTextField.text!
        
        if username.isEmpty || password.isEmpty || finalEmail.isEmpty || country.isEmpty || biography.isEmpty || data == nil {
            self.view.endEditing(true)
            print("error")
        } else {
            self.view.endEditing(true)
            
            authService.signUp(finalEmail, username: username, password: password, country: country, biography: biography, data: data)
        }
        
        
        
    }
    
    // Choosing User Picture
    @IBAction func choosePictureAction(_ sender: AnyObject) {
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
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: true, completion: nil)
        self.userImageView.image = image
    }
    
    // Dismissing all editing actions when User Tap or Swipe down on the Main View
    func dismissKeyboard(_ gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        countryTextField.resignFirstResponder()
        biographyTextField.resignFirstResponder()
        return true
    }
    
    // Moving the View up after the Keyboard appears
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateView(true, moveValue: 80)
    }
    
    
    // Moving the View down after the Keyboard disappears
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateView(false, moveValue: 80)
    }
    
    
    // Move the View Up & Down when the Keyboard appears
    func animateView(_ up: Bool, moveValue: CGFloat){
        
        let movementDuration: TimeInterval = 0.3
        let movement: CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
        
        
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
