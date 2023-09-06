//
//  InformationViewController.swift
//  MapBoxTest2
//
//  Created by Şevval Mertoğlu on 24.07.2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class InformationViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var informationImageView: UIImageView!
    @IBOutlet weak var informationTextLabel: UITextField!
    @IBOutlet weak var informationEmailLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        informationImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        informationImageView.addGestureRecognizer(gestureRecognizer)
        
        saveButton.isEnabled = false // Başlangıçta kaydetme düğmesi etkisiz
        
        if let user = Auth.auth().currentUser {
            if let email = user.email {
                // Kullanıcının e-posta adresini 'informationEmailLabel' etiketinde göster
                informationEmailLabel.text =  Localizer.localize("User mail: \(email)")
            } else {
                // Eğer kullanıcının e-posta adresi yoksa
                informationEmailLabel.text =  Localizer.localize("Email address not found.")
            }
        }
    }
    
    @objc func chooseImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        
        present(pickerController, animated: true) {
                self.saveButton.isEnabled = true //resim seçildiğinde buton etkin
            }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        informationImageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true) {
            // Kullanıcı resim seçmeyi iptal ederse kaydetme düğmesini etkisiz hale getirir
            self.saveButton.isEnabled = false
        }
    }

    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let cancelButton = UIAlertAction(title: Localizer.localize("Cancel"), style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        if self.informationTextLabel.text == "" {
            self.makeAlert(titleInput: Localizer.localize("It can't be empty space!"), messageInput: Localizer.localize("Please enter your name and surname"))
        }
            
        let storage = Storage.storage()
        let storageReference = storage.reference()
        let mediaFolder = storageReference.child("media")
        
        if let data = informationImageView.image?.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data, metadata: nil) { (metadata, error) in
                if let error = error {
                    self.makeAlert(titleInput: Localizer.localize("ERROR"), messageInput: error.localizedDescription)
                } else {
                    imageReference.downloadURL { (url, error) in
                        if let error = error {
                            self.makeAlert(titleInput: "Error!", messageInput: error.localizedDescription)
                        } else {
                            if let imageUrl = url?.absoluteString {
                                
                                // Firestore veritabanına ekleme işlemi
                                let firestoreDatabase = Firestore.firestore()
                                let userEmail = Auth.auth().currentUser!.email
                                let user = Auth.auth().currentUser!.email
                                
                                let query = firestoreDatabase.collection("user").document(user!).collection("Informations")
                                    .whereField("userEmail", isEqualTo: userEmail)
                                
                                
                                
                                query.getDocuments { (querySnapshot, error) in
                                    if let error = error {
                                        print("Firestore'dan verileri alırken hata oluştu: \(error.localizedDescription)")
                                    } else {
                                        if let document = querySnapshot?.documents.first {
                                            // Mevcut belgeyi güncelleyin.
                                            document.reference.updateData([
                                                "imageUrl": imageUrl,
                                                "nameSurname": self.informationTextLabel.text ?? ""
                                            ]) { error in
                                                if let error = error {
                                                    self.makeAlert(titleInput: "Error!", messageInput: error.localizedDescription)
                                                }
                                            }
                                        } else {
                                            // Mevcut belge bulunamadığında yeni belge ekle
                                            let firestoreMedia = [
                                                "imageUrl": imageUrl,
                                                "userEmail": userEmail,
                                                "nameSurname": self.informationTextLabel.text ?? "",
                                                "date": FieldValue.serverTimestamp()
                                            ]
                                            
                                            firestoreDatabase.collection("user").document(user!).collection("Informations").addDocument(data: firestoreMedia) { (error) in
                                                if let error = error {
                                                    self.makeAlert(titleInput: "Error!", messageInput: error.localizedDescription) //yeni belge eklenemediyse hata verir
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        navigationController?.popViewController(animated: true) //geri gider

        
    }
    
}
