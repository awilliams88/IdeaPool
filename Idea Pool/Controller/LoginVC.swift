//
//  LoginVC.swift
//  Idea Pool
//
//  Created by Arpit Williams on 30/11/17.
//  Copyright © 2017 ePaisa. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    // Mark: Properties
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var nameTxtFld: UITextField!
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var pswdTxtFld: UITextField!
    
    // Constraints
    
    // Stack View Aspect Ratio constraints allows to maintain layout changes between login state changes
    @IBOutlet var stackViewAspectRatio0: NSLayoutConstraint!
    @IBOutlet var stackViewAspectRatio1: NSLayoutConstraint!
    
    // Enum for maintaining Login State
    enum LoginState: Int {
        case SignIn = 0
        case SignUp = 1
    }
    
    // Login State allows the controller to differentiate between sign-in/sign-up states
    var currentLoginState = LoginState.SignUp
    
    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI(for: currentLoginState)
    }
    
    // Switches login state
    @IBAction func infoBtnPrsd(_ sender: UIButton) {
        switch currentLoginState {
        case .SignUp:
            currentLoginState = .SignIn
            updateUI(for: .SignIn)
        case .SignIn:
            currentLoginState = .SignUp
            updateUI(for: .SignUp)
        }
    }
    
    // Updates UI for fiven login state
    func updateUI(for state: LoginState) {
        switch state {
        case .SignUp:
            // Title Label
            titleLbl.text = Constants.Label.SignUp
            
            // Name View
            if stackView.arrangedSubviews.index(of: nameView) == nil {
                nameView.isHidden = false
                stackView.insertArrangedSubview(nameView, at: 0)
            }
            
            // Stack View
            stackViewAspectRatio0.isActive = true
            stackViewAspectRatio1.isActive = false
            
            // Login Button
            loginBtn.setTitle(Constants.Label.SignUp.uppercased(), for: .normal)
            
            // Info button
            let attributedString = NSMutableAttributedString(string: Constants.Label.SignUpInfo)
            attributedString.setColorForText("Don’t have an account?", with: UIColor(red: 42/255.0, green: 56/255.0, blue: 66/255.0, alpha: 1))
            attributedString.setColorForText("Create an account", with: UIColor(red: 0/255.0, green: 168/255.0, blue: 67/255.0, alpha: 1))
            infoBtn.setAttributedTitle(attributedString, for: .normal)
            
        case .SignIn:
            // Title Label
            titleLbl.text = Constants.Label.SignIn
            
            // Name View
            nameView.isHidden = true
            stackView.removeArrangedSubview(nameView)
            
            // Stack View
            stackViewAspectRatio0.isActive = false
            stackViewAspectRatio1.isActive = true
            
            // Login Button
            loginBtn.setTitle(Constants.Label.SignIn.uppercased(), for: .normal)
            
            // Info button
            let attributedString = NSMutableAttributedString(string: Constants.Label.SignInInfo)
            attributedString.setColorForText("Already have an account?", with: UIColor(red: 42/255.0, green: 56/255.0, blue: 66/255.0, alpha: 1))
            attributedString.setColorForText("Log in", with: UIColor(red: 0/255.0, green: 168/255.0, blue: 67/255.0, alpha: 1))
            infoBtn.setAttributedTitle(attributedString, for: .normal)
        }
    }
    
    // Performs sign-up/sign-in operation as per current login state
    @IBAction func loginBtnPrsd(_ sender: UIButton) {
        switch currentLoginState {
        case .SignUp:
            UserManager.shared.register(["name": nameTxtFld.text ?? "",
                                         "email": emailTxtFld.text ?? "",
                                         "password": pswdTxtFld.text ?? ""], completion: { (result) in
                                            do {
                                                if let user = try result.unwrap() as? User {
                                                    print(user.email)
                                                    // Sign Up Success
                                                }
                                            }
                                            catch ResponseError.InvalidResponseCode(let reason) {
                                                print(reason ?? "Not Reason Found")
                                                if let reason =  reason as? [String: String] {
                                                    Utility.showAlert(for: self, title: reason.keys.first ?? "", message: reason.values.first ?? "")
                                                }
                                            }
                                            catch {
                                                print(error)
                                            }
            })
        case .SignIn:
            UserManager.shared.login(["email": emailTxtFld.text ?? "",
                                      "password": pswdTxtFld.text ?? ""], completion: { (result) in
                                        do {
                                            if let user = try result.unwrap() as? User {
                                                print(user.email)
                                                // Sign In Success
                                            }
                                        }
                                        catch ResponseError.InvalidResponseCode(let reason) {
                                            if let reason =  reason as? [String: String] {
                                                Utility.showAlert(for: self, title: reason.keys.first ?? "", message: reason.values.first ?? "")
                                            }
                                        }
                                        catch {
                                            print(error)
                                        }
            })
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension LoginVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
