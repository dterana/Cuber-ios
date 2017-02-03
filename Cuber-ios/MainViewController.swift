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
    //MARK: - IBOutlet declaration
    //--------------------------------------
    
    @IBOutlet weak var riderSwitchDriverStack: UIStackView!
    @IBOutlet weak var isDriverSwitch: UISwitch!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupOrLoginLbl: UIButton!
    @IBOutlet weak var changeSignUpModeLbl: UIButton!
    
    
    //--------------------------------------
    //MARK: - Function declaration
    //--------------------------------------

    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
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
                        
                        if let isDriver = PFUser.current()?["isDriver"] as? Bool {
                            
                            if isDriver {
                                
                            } else {
                                
                                self.performSegue(withIdentifier: "showRiderVCSegue", sender: self)
                                
                            }
                        }
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
                        
                        if let isDriver = PFUser.current()?["isDriver"] as? Bool {
                            
                            if isDriver {
                                
                            } else {
                                
                                self.performSegue(withIdentifier: "showRiderVCSegue", sender: self)
                                
                            }
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func changeSignUpModeBtn(_ sender: UIButton) {
        
        if signupMode {
            
            riderSwitchDriverStack.isHidden = true
            signupOrLoginLbl.setTitle("Log In", for: [])
            changeSignUpModeLbl.setTitle("Don't have an account?", for: [])
            signupMode = false
            
            
        } else {
            
            riderSwitchDriverStack.isHidden = false
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
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let isDriver = PFUser.current()?["isDriver"] as? Bool {
            
            if isDriver {
                
            } else {
                
                performSegue(withIdentifier: "showRiderVCSegue", sender: self)
                
            }
        }
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

