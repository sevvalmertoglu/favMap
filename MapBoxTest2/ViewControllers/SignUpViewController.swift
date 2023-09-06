//
//  SignUpViewController.swift
//  MapBoxTest2
//
//  Created by Şevval Mertoğlu on 27.07.2023.
//

import UIKit
import FirebaseAuth



class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var signUpEmail: UITextField!
    @IBOutlet weak var signUpPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    

    @IBAction func signUpClicked(_ sender: Any) {
        //activity Indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        if signUpEmail.text != "" && signUpPassword.text != "" {
            Auth.auth().createUser(withEmail: signUpEmail.text!, password: signUpPassword.text!) { (authdata, error) in
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
            makeAlert(titleInput: "ERROR", messageInput: Localizer.localize("Please enter your email and password."))
        }
        
        
    }
    
    
    @IBAction func toLoginClicked(_ sender: Any) {
        dismiss(animated: true)
        
    }
   
    func makeAlert(titleInput: String, messageInput:String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let OkeyButton = UIAlertAction(title: Localizer.localize("OK"), style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(OkeyButton)
        self.present(alert, animated: true, completion: nil)
        
    }
}
