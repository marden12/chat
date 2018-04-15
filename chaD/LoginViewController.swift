//
//  LoginViewController.swift
//  chaD
//
//  Created by Dayana Marden on 30.04.17.
//  Copyright © 2017 Dayana Marden. All rights reserved.
//

import UIKit
extension UITextField
{
    func setBottomBorder(borderColor: UIColor)
    {
        
        self.borderStyle = UITextBorderStyle.none
        self.backgroundColor = UIColor.clear
        let width = 1.0
        
        let borderLine = UIView()
        borderLine.frame = CGRect(x: 0, y: Double(self.frame.height) - width, width: Double(self.frame.width), height: width)
        
        borderLine.backgroundColor = borderColor
        self.addSubview(borderLine)
    }
}
class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginView: UIView!
    
    var authService = AuthenticationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        usernameTextField.setBottomBorder(borderColor: UIColor(colorLiteralRed: 101/255, green: 75/255, blue: 119/255, alpha: 1))
        passwordTextField.setBottomBorder(borderColor: UIColor(colorLiteralRed: 101/255, green: 75/255, blue: 119/255, alpha: 1))

        
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard(_:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard(_:)))
        swipDown.direction = .down
        view.addGestureRecognizer(swipDown)
        
        view.bringSubview(toFront: loginView)
    }
    
    // Unwind Segue Action
    @IBAction func unwindToLogin(_ storyboard: UIStoryboardSegue){}
    
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func dismissKeyboard(_ gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    // Moving the View down after the Keyboard appears
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
    
    // Loging in the User
    @IBAction func loginAction(_ sender: AnyObject) {
        let email = usernameTextField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: CharacterSet.whitespaces)
        let password = passwordTextField.text!
        
        if finalEmail.isEmpty || password.isEmpty {
            self.view.endEditing(true)
            print("error")
            
        }else {
            self.view.endEditing(true)
            authService.signIn(finalEmail, password: password)
            
        }
        
    }
    
}

