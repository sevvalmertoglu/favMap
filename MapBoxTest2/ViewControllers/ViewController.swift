import UIKit
import MapboxNavigation
import MapboxMaps
import MapboxSearchUI


class ViewController: MapsViewController  {
    
    
    @IBOutlet weak var textLabel: UILabel!
    
    lazy var searchController: MapboxSearchController = {
        let locationManager = CLLocationManager()
        var configuration: Configuration
        
        
        // Konum iznini kontrol edin
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            // Konum izni varsa, kullanıcının konumunu alabilirsiniz
            if let userLocation = locationManager.location?.coordinate {
                // Kullanıcının gerçek konumunu kullanarak PointLocationProvider'ı oluşturun
                let locationProvider = PointLocationProvider(coordinate: userLocation)
                
                // Configuration nesnesini güncelleyin
                configuration = Configuration(locationProvider: locationProvider)
            } else {
                // Kullanıcının konumu kullanılamıyorsa, varsayılan olarak San Francisco konumunu kullanabilirsiniz
                let locationProvider = PointLocationProvider(coordinate: .sanFrancisco)
                
                // Configuration nesnesini güncelleyin
                configuration = Configuration(locationProvider: locationProvider)
            }
        } else {
            // Konum izni yoksa, varsayılan olarak San Francisco konumunu kullanabilirsiniz
            let locationProvider = PointLocationProvider(coordinate: .sanFrancisco)
            
            // Configuration nesnesini güncelleyin
            configuration = Configuration(locationProvider: locationProvider)
        }
        
        return MapboxSearchController(configuration: configuration)
    }()
    
    lazy var panelController = MapboxPanelController(rootViewController: searchController)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cameraOptions = CameraOptions(center: .sanFrancisco, zoom: 15)
        mapView.camera.fly(to: cameraOptions, duration: 1, completion: nil)

        searchController.delegate = self
        addChild(panelController)
        

        
    }
    
    //verileri iletmek için:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tofavoriteVC" {
            if let destinationVC = segue.destination as? FavoriteVC,
               let (coordinate, pinName) = sender as? (CLLocationCoordinate2D, String) {
                destinationVC.coordinate = coordinate
                destinationVC.favoriteLocationText = pinName
            }
        }
    }
}


extension ViewController: SearchControllerDelegate {
    func categorySearchResultsReceived(category: SearchCategory, results: [SearchResult]) {
        showAnnotations(results: results)
    }
    
    func searchResultSelected(_ searchResult: SearchResult) {
        showAnnotation(searchResult)
    }
    
    func userFavoriteSelected(_ userFavorite: FavoriteRecord) {
        showAnnotation(userFavorite)
    }
}





