//
//  ViewController.swift
//  onTheMap
//
//  Created by Lola M on 7/9/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var login: UIButton!
    
    func updateUI(processing: Bool) {
        DispatchQueue.main.async {
            self.email.isUserInteractionEnabled = !processing
            self.password.isUserInteractionEnabled = !processing
            self.login.isEnabled = !processing
        }
    }
    
    @IBAction func login(_ sender: Any) {
        updateUI(processing: true)
        let email = self.email.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password = self.password.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        guard !email.isEmpty, !password.isEmpty
            else {
                self.alert(title: "warning", message: "email and password shouldnt be empty")
                self.updateUI(processing: false)
                return
        }
        
        APIViewController.Login(username: email, password: password) { (errorMessage) in
            DispatchQueue.main.async {
                if errorMessage != nil {
                    self.alert(title: "Error", message: errorMessage)
                    self.updateUI(processing: false)
                    return
                }
                APIViewController.getRandomUserData {
                    (errorMessage) in
                    DispatchQueue.main.async {
                        self.updateUI(processing: false)
                        if errorMessage != nil {
                            self.alert(title: "Error", message: errorMessage)
                            return
                        }
                        self.email.text = ""
                        self.password.text = ""
                        self.performSegue(withIdentifier: "showMap", sender: self)
                    }
                }
            }
        }
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        let url = URL(string: "https://auth.udacity.com/sign-up")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
