//
//  StationDetailViewController.swift
//  favMap
//
//  Created by Şevval Mertoğlu on 17.08.2023.
//

import UIKit
import CoreLocation
import MapboxNavigation
import MapboxDirections
import MapboxMaps
import MapboxCoreNavigation
import MapboxSearch

class StationDetailViewController: UIViewController {

    
    @IBOutlet weak var stationImageView: UIImageView!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var StationAddressLabel: UILabel!
    @IBOutlet weak var stationConnectionTypeLabel: UILabel!
    @IBOutlet weak var stationLevelLabel: UILabel!

    let locationManager = CLLocationManager()
    var place: ChargingStation!
    var destinationLocation = CLLocationCoordinate2D(latitude: 38.4319,longitude: 27.2687)
    var userLocation = CLLocationCoordinate2DMake(38.48625, 27.07225)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInfo()
    }
    
    func setInfo() {
        if place != nil {
            stationNameLabel.text = place.stationName
            StationAddressLabel.text = place.address
            stationConnectionTypeLabel.text = place.connectionType
            stationLevelLabel.text = place.level
        }
        destinationLocation = CLLocationCoordinate2D(latitude: Double(place.latitude)!, longitude: Double(place.longitude)!)
        userLocation = locationManager.location!.coordinate
    }
    
    func getNavigation(userLocation: CLLocationCoordinate2D,destinationLocation: CLLocationCoordinate2D){
        
        //activity Indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
            let origin = Waypoint(coordinate: userLocation)
            let destination = Waypoint(coordinate: destinationLocation)
            let options = NavigationRouteOptions(waypoints:[origin, destination])
            
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

    @IBAction func startNavigationClicked(_ sender: Any) {
      
        self.getNavigation(userLocation: userLocation, destinationLocation: destinationLocation)
    }
    

} //StationDetailViewController ended
