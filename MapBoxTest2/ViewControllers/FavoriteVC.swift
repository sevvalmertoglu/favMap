import UIKit
import CoreLocation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FavoriteVC: UIViewController {
    
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var favoriteLocationName: UILabel!
    @IBOutlet weak var favoriteLocation: UILabel!
    @IBOutlet weak var favoriteNote: UILabel!
    @IBOutlet weak var favoriteNoteText: UITextField!
    
    var coordinate: CLLocationCoordinate2D? //Konum bilgisi cooedinate'de saklanır
    var favoriteLocationText: String? // Pin'in adını tutacak değişken
    
    override func viewDidLoad() {
        super.viewDidLoad()
      

        favoriteLocation.text = favoriteLocationText // Konumun adını favoriteLocation etiketine yazdır
    }
    

    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title:Localizer.localize( "OK"), style: UIAlertAction.Style.default) { _ in
            if titleInput == Localizer.localize("Successful!") {
                self.dismiss(animated: true)
            }
        }
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func favoriteAddClicked(_ sender: Any) {
        
        if self.favoriteNoteText.text == "" {
            self.makeAlert(titleInput: Localizer.localize("It can't be empty space!"), messageInput:Localizer.localize("Please enter a note or address"))
        } else {
    
        // Favori konum ve notu alır
        let favoriteLocation = favoriteLocation.text ?? ""
        let favoriteNote = favoriteNoteText.text ?? ""
        let latitude = coordinate?.latitude
        let longitude = coordinate?.longitude

        // Kullanıcının kimliğini alır
            if let user = Auth.auth().currentUser?.email {
                // Firestore veritabanına erişim sağlar
                let db = Firestore.firestore()
                
                // Yeni bir "favoriteID" oluşturur
                let newFavoriteRef = db.collection("user").document(user).collection("favorites").document()
                let favoriteID = newFavoriteRef.documentID
                
                // Yeni favori konumu belgesini oluşturur
                let newFavoriteData = [
                    "CurrentUser": Auth.auth().currentUser?.email,
                    "favoriteLocation": favoriteLocation,
                    "favoriteNoteText": favoriteNote,
                    "latitude": latitude,
                    "longitude": longitude
                ] as [String : Any]
                
                // Favori konumu belgesini Firestore'a kaydeder
                newFavoriteRef.setData(newFavoriteData) { error in
                    if let error = error {
                        print("Failed to add favorite: \(error.localizedDescription)")
                    } else {
                        self.makeAlert(titleInput: Localizer.localize("Successful!"), messageInput: Localizer.localize("Favorite added"))
                        
                    }
                }
            }
            
        }
        
        
    }//favoriAddClicked parantezi
    
   

    

}
