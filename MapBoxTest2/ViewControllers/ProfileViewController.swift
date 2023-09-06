import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ProfileViewController: UIViewController {
    
   
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UILabel!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserProfile()
    }
    
    func loadUserProfile() {
        
        //activity Indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
         guard let user = Auth.auth().currentUser?.email else {
             // Kullanıcı oturumu açık değilse işlemi yapamayız.
             return
         }
         
         let db = Firestore.firestore()
         let informationCollection = db.collection("user").document(user).collection("Informations")
         
         // Kullanıcının email adresine göre sorgu yaparak verileri çekiyoruz.
         let query = informationCollection.whereField("userEmail", isEqualTo: user)
            .addSnapshotListener { querySnapshot, error in //firebase'i sürekli dinliyoruz
                guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
             if let document = documents.first {
                 // Firestore'dan gelen verileri kullanıcı arayüzünde gösteriyoruz.
                 let data = document.data()
                 if let nameSurname = data["nameSurname"] as? String,
                    let imageUrlString = data["imageUrl"] as? String,
                    let imageUrl = URL(string: imageUrlString) {
                     
                     self.nameText.text = nameSurname
                     self.imageView.image = nil // Önceki resmi temizle
                     
                    
                     //Image Download işlemi
                     DispatchQueue.global().async {
                         if let data = try? Data(contentsOf: imageUrl) {
                             DispatchQueue.main.async {
                                 self.imageView.image = UIImage(data: data)
                                 
                                 //activity Indicator
                                 activityIndicator.stopAnimating()
                                 activityIndicator.removeFromSuperview()
                             }
                         }
                     }
                 }
             }
         }
     }
    
    

        
        @IBAction func informationClicked(_ sender: Any) {
           performSegue(withIdentifier: "toInformationVC", sender: nil)
        }
        
        
    @IBAction func languagesClicked(_ sender: Any) {
        openAppSettings()
    }
    
    func openAppSettings() {
        if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettingsURL) {
                UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
            }
        }
    } //uygulama ayarlarını açar
    
        @IBAction func logoutClicked(_ sender: Any) {
            
            do {
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "toSignInViewController", sender: nil)
            }  catch {
                print("error")
            }
            
            
            
        }
        
    }

