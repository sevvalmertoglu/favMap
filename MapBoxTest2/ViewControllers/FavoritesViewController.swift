import UIKit
import CoreLocation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var favoriteLocations: [String] = []
    var selectedFavoriteLocation: String?
    var selectedFavoriteNote: String?
    var selectedLatitude: Double?
    var selectedLongitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchFavoriteLocations()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Kullanıcının bir hücreye tıkladığında detay sayfasına geçiş yapmak için
        let selectedLocation = favoriteLocations[indexPath.row]
        navigateToDetailsPage(for: selectedLocation)
    }
    
    func navigateToDetailsPage(for locationName: String) {
        if let user = Auth.auth().currentUser?.email {
            let db = Firestore.firestore()
            db.collection("user").document(user).collection("favorites").whereField("favoriteLocation", isEqualTo: locationName).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Hata oluştu: \(error.localizedDescription)")
                    return
                }
                
                if let documents = snapshot?.documents, let document = documents.first {
                    let data = document.data()
                    if let favoriteNote = data["favoriteNoteText"] as? String,
                       let latitude = data["latitude"] as? Double,
                       let longitude = data["longitude"] as? Double {
                        self.selectedFavoriteLocation = locationName
                        self.selectedFavoriteNote = favoriteNote
                        self.selectedLatitude = latitude
                        self.selectedLongitude = longitude
                        
                        // Detay sayfasına geçiş yapmak için
                        self.performSegue(withIdentifier: "toDetailsVC", sender: nil)
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            if let destinationVC = segue.destination as? DetailsViewController {
                // Detay sayfasına aktaracağımız verileri göndermek için
                destinationVC.locationName = selectedFavoriteLocation
                destinationVC.favoriteNote = selectedFavoriteNote
                destinationVC.latitude = selectedLatitude
                destinationVC.longitude = selectedLongitude
                destinationVC.coordinate = CLLocationCoordinate2D(latitude: selectedLatitude!, longitude: selectedLongitude!)
            }
        }
    }
    
    
    
    
    
    
    
    // Favori konumları Firebase'den çeken ve TableView'ı güncelleyen fonksiyon
    func fetchFavoriteLocations() {
        
        if let user = Auth.auth().currentUser?.email {
            
            if let userEmail = Auth.auth().currentUser?.email {
                
                let db = Firestore.firestore()
                
                // "favorites" alt koleksiyonundaki favori konumları kullanıcının e-posta adresine göre filtreleyerek çeker
                
                db.collection("user").document(user).collection("favorites").whereField("CurrentUser", isEqualTo: userEmail).addSnapshotListener { snapshot, error in //FireStore'u sürekli dinler ve bilgileri günceller
                    guard let documents = snapshot?.documents else {
                        print("Belgeler alınamadı: \(error?.localizedDescription ?? "Bilinmeyen Hata")")
                        return
                    }
                    
                    self.favoriteLocations.removeAll() //favoriteLocations dizisini güncellemeden önce temizler
                    
                    for document in snapshot?.documents ?? [] {
                        if let location = document.data()["favoriteLocation"] as? String{
                            self.favoriteLocations.append(location)
                        }
                    }
                    
                    // TableView'ı günceller
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = favoriteLocations[indexPath.row]
        return cell
    }
    
    
}






