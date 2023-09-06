import MapboxMaps
import MapboxCoreNavigation
import MapboxSearch
import Foundation
import UIKit
import MapboxNavigation
import MapboxDirections
import UserNotifications
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


class MapsViewController: UIViewController, ExampleController, AnnotationInteractionDelegate {
    
    
    var mapView = MapView(frame: .zero)
    lazy var annotationsManager = mapView.annotations.makePointAnnotationManager()
    var pinName : String = ""
    var coordinate: CLLocationCoordinate2D? //Konum bilgisi cooedinate'de saklanır

   
    let lastLoginKey = "LastLoginDate"
    let userDefaults = UserDefaults.standard

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options = MapInitOptions(styleURI: StyleURI(rawValue: "mapbox://styles/sevval0mertoglu/clloys4zq004001pegccw0u6a"))
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        annotationsManager.delegate = self
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.findFeatures))
        self.mapView.addGestureRecognizer(tapGesture)
        
        //to leave space at the top of the map
        let containerView = UIView(frame: CGRect(x: 0, y: 180, width: view.bounds.width, height: view.bounds.height))
        containerView.addSubview(mapView)
        view.addSubview(containerView)
        
        // Show user location
        mapView.location.options.puckType = .puck2D()
    }
    
    
    
    func showAnnotations(results: [SearchResult], cameraShouldFollow: Bool = true) {
        annotationsManager.annotations = results.map { searchResult -> PointAnnotation in
            var annotation = PointAnnotation(coordinate: searchResult.coordinate)
            annotation.textField = searchResult.name
            annotation.textOffset = [0, 2]
            annotation.textColor = StyleColor(UIColor.red)
            annotation.image = PointAnnotation.Image(image: UIImage(named: "pin")!, name: "pin")
            
            return annotation
        }
        
        if cameraShouldFollow {
            cameraToAnnotations(annotationsManager.annotations)
        }
    }
    
    @objc public func findFeatures(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: mapView)
        mapView.mapboxMap.queryRenderedFeatures(
            with: tapPoint,
            options: RenderedQueryOptions(layerIds: ["new-data-charge-stations"], filter: nil)) { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                case .success(let queriedfeatures):
                    
                    if let stationFeature = queriedfeatures.first?.feature,
                       case .string(let stationName) = stationFeature.properties?["stationName"],
                       case .string(let address) = stationFeature.properties?["stationAddress"],
                       case .point(let point) = stationFeature.geometry,
                       case .string(let connectionType) = stationFeature.properties?["stationPlugType"],
                       case .string(let level) = stationFeature.properties?["stationLevel"]

                    {
    
                        let station = ChargingStation(
                            stationName: stationName,
                            address: address,
                            latitude: String(point.coordinates.latitude),
                            longitude: String(point.coordinates.longitude),
                            connectionType: connectionType,
                            level: level
                        )
                        
                        let mapDetailVC = self.storyboard!.instantiateViewController(withIdentifier: "StationDetailViewController") as! StationDetailViewController
                        mapDetailVC.place = station
                        self.present(mapDetailVC, animated: true, completion: nil)
                        self.navigationController?.pushViewController(mapDetailVC, animated: true)
                       
                    }
                    
                    
                case .failure(let error):
                    print(error)
                }
            }
    } //findFeatures func ended
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StationDetailViewController" {
            if let destinationVC = segue.destination as? StationDetailViewController,
               let station = sender as? ChargingStation {
                destinationVC.place = station
            }
        }
    }

   
    // konum pini seçildiğinde çıkan alert
    func showPinAlert(coordinate: CLLocationCoordinate2D) {
        let alertController = UIAlertController(title: Localizer.localize("location_selected"), message: Localizer.localize("Would you like to start the navigation?"), preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: Localizer.localize("Start Navigation"), style: .default) { (_) in
            self.navigateToOtherPage(coordinate: coordinate)
        }
        
        let favoriteAction = UIAlertAction(title: Localizer.localize("Add to Favorites"), style: .default) { (_) in
            self.favoritePage(coordinate: coordinate, pinName: self.pinName)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(favoriteAction)
        alertController.addAction(UIAlertAction(title: Localizer.localize("Cancel"), style: UIAlertAction.Style.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
    //navigasyon açılması için
    func navigateToOtherPage(coordinate: CLLocationCoordinate2D) {
        
        //activity Indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        let origin = CLLocationCoordinate2DMake(38.48625, 27.07225)
        let destination = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        let options = NavigationRouteOptions(coordinates: [origin, destination])
        
        Directions.shared.calculate(options) { [weak self] (_, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let strongSelf = self else {
                    return
                }
                let indexedRouteResponse = IndexedRouteResponse(routeResponse: response, routeIndex: 0)
                let navigationService = MapboxNavigationService(indexedRouteResponse: indexedRouteResponse,
                                                                customRoutingProvider: NavigationSettings.shared.directions,
                                                                credentials: NavigationSettings.shared.directions.credentials,
                                                                simulating: SimulationMode .onPoorGPS)
                
                let navigationOptions = NavigationOptions(navigationService: navigationService)
                let navigationViewController = NavigationViewController(for: indexedRouteResponse,
                                                                        navigationOptions: navigationOptions)
                navigationViewController.modalPresentationStyle = .fullScreen
                navigationViewController.routeLineTracksTraversal = true
                
                strongSelf.present(navigationViewController, animated: true, completion: nil)
                
                //activity Indicator
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
    
    //favorite ekranına geçiş için
    func favoritePage(coordinate: CLLocationCoordinate2D, pinName: String) {
        performSegue(withIdentifier: "tofavoriteVC", sender: (coordinate, pinName))
    }
    
    //konum pini tıklandığında alert çıkması için
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        guard let pointAnnotation = annotations.first as? PointAnnotation,
              case let .point(geometry) = pointAnnotation.geometry else {
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: geometry.coordinates.latitude, longitude: geometry.coordinates.longitude)
        pinName = pointAnnotation.textField ?? Localizer.localize("name not found") //konum pini ismini diğer sayfaya yazdırmak için
        showPinAlert(coordinate: coordinate)
    }


    
    func cameraToAnnotations(_ annotations: [PointAnnotation]) {
        if annotations.count == 1, let annotation = annotations.first {
            mapView.camera.fly(to: .init(center: annotation.point.coordinates, zoom: 15), duration: 0.25, completion: nil)
        } else {
            let coordinatesCamera = mapView.mapboxMap.camera(for: annotations.map(\.point.coordinates),
                                                             padding: UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24),
                                                             bearing: nil,
                                                             pitch: nil)
            mapView.camera.fly(to: coordinatesCamera, duration: 0.25, completion: nil)
        }
    }
    
    func showAnnotation(_ result: SearchResult) {
        showAnnotations(results: [result])
    }
    
    func showAnnotation(_ favorite: FavoriteRecord) {
        annotationsManager.annotations = [PointAnnotation(favoriteRecord: favorite)]
        
        cameraToAnnotations(annotationsManager.annotations)
    }
    
    func showError(_ error: Error) {
        let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Localizer.localize("OK"), style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}

extension PointAnnotation {
    init(searchResult: SearchResult) {
        self.init(coordinate: searchResult.coordinate)
        textField = searchResult.name
        
    }
    
    init(favoriteRecord: FavoriteRecord) {
        self.init(coordinate: favoriteRecord.coordinate)
        textField = favoriteRecord.name
    }
}


extension CLLocationCoordinate2D {
    static let sanFrancisco = CLLocationCoordinate2D(latitude: 38.4319,longitude: 27.2687)
 }

