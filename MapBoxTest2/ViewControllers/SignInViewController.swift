//
//  SignInViewController.swift
//  MapBoxTest2
//
//  Created by Şevval Mertoğlu on 20.07.2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class SignInViewController: UIViewController {
    
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

       
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if Core.shared.isNewUser() {
            
            // show onboarding
            let ovc = storyboard?.instantiateViewController(identifier: "OnboardingViewController") as! OnboardingViewController
            ovc.modalPresentationStyle = .fullScreen
            present(ovc, animated: true)
        }
    }
    
    
    @IBAction func loginClicked(_ sender: Any) {
        //activity Indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        if emailText.text != "" && passwordText.text != "" {
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { (authdata, error) in
                if error != nil {
                    self.makeAlert(titleInput: "ERROR!", messageInput: error?.localizedDescription ?? "Error")
                    //activity Indicator
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()

                } else {
                    self.performSegue(withIdentifier: "toHomeVC", sender: nil)
                    //activity Indicator
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()

                }
            }
        } else {
            makeAlert(titleInput: Localizer.localize("ERROR"), messageInput: Localizer.localize("Please enter your email and password."))
        }
        

    }
    
    @IBAction func toSignUpClicked(_ sender: Any) {
        performSegue(withIdentifier: "toSignUpVC", sender: nil)
    }
    
    func makeAlert(titleInput: String, messageInput:String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let OkeyButton = UIAlertAction(title: Localizer.localize("OK"), style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(OkeyButton)
        self.present(alert, animated: true, completion: nil)
        
    }
    
}


class Core {
    static let shared = Core()
    
    func isNewUser() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    func setIsNotNewUser() {
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
}
