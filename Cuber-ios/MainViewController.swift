//
//  ViewController.swift
//  Cuber-ios
//
//  Created by Pourpre on 2/2/17.
//  Copyright © 2017 Pourpre. All rights reserved.
//

import UIKit
import Parse

class MainViewController: UIViewController, UITextFieldDelegate {

    
    //--------------------------------------
    //MARK: - Variable declaration
    //--------------------------------------
    
    var signupMode = false
    
    //--------------------------------------
    //MARK: - Function declaration
    //--------------------------------------

    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //--------------------------------------
    //MARK: - IBOutlet declaration
    //--------------------------------------
    
    @IBOutlet weak var isDriverSwitch: UISwitch!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupOrLoginLbl: UIButton!
    @IBOutlet weak var changeSignUpModeLbl: UIButton!
    
    
    //--------------------------------------
    //MARK: - IBAction declaration
    //--------------------------------------
    
    @IBAction func signupOrLoginBtn(_ sender: UIButton) {
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            
            displayAlert(title: "Error in form", message: "Email and Password are reauire")
            
        } else {
            
            if signupMode {
                
                let user = PFUser()
                
                user.email = emailTextField.text
                user.username = emailTextField.text
                user.password = passwordTextField.text
                
                user["isDriver"] = isDriverSwitch.isOn
                
                user.signUpInBackground(block: { (success, error) in
                    
                    if let error = error as? NSError {
                        
                        var displayedErrorMessage = "Please try again later"
                        
                        if let parseError = error.userInfo["error"] as? String {
                            
                            displayedErrorMessage = parseError
                            
                        }
                        
                        self.displayAlert(title: "Sign Up Failed", message: displayedErrorMessage)
                        
                    } else {
                        
                        print("Sign Up Successful")
                        
                    }
                    
                })
            } else {
                
                PFUser.logInWithUsername(inBackground: emailTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                    
                    if let error = error as? NSError {
                        
                        var displayedErrorMessage = "Please try again later"
                        
                        if let parseError = error.userInfo["error"] as? String {
                            
                            displayedErrorMessage = parseError
                            
                        }
                        
                        self.displayAlert(title: "Log In Failed", message: displayedErrorMessage)
                        
                    } else {
                        
                        print("Log In Successful")
                        
                    }

                })
            }
            
        }
    }
    
    @IBAction func changeSignUpModeBtn(_ sender: UIButton) {
        
        if signupMode {
            
            signupOrLoginLbl.setTitle("Log In", for: [])
            changeSignUpModeLbl.setTitle("Don't have an account?", for: [])
            signupMode = false
            
        } else {
            
            signupOrLoginLbl.setTitle("Sign Up", for: [])
            changeSignUpModeLbl.setTitle("Already have an account?", for: [])
            signupMode = true

        }
    }
    
    
    //--------------------------------------
    //MARK: - Override Function declaration
    //--------------------------------------
    
    // Hide keyboard if you clic outside the text field
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    // Hide keyboard if you press return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return textField.resignFirstResponder()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        signupOrLoginLbl.layer.cornerRadius = 5.0
        changeSignUpModeLbl.layer.cornerRadius = 5.0

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

