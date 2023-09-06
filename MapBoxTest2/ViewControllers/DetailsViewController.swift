import UIKit
import CoreLocation
import FirebaseCore
import Foundation
import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections


class DetailsViewController: UIViewController {
    
    @IBOutlet weak var detailsImageView: UIImageView!
    @IBOutlet weak var detailsLocationName: UILabel!
    @IBOutlet weak var detailsNote: UILabel!
    
    var locationName: String?
    var favoriteNote: String?
    var latitude: Double?
    var longitude: Double?
    var coordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsLocationName.text = locationName
        detailsNote.text = favoriteNote

    }

    @IBAction func toNavigationClicked(_ sender: Any) {
        //activity Indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        let origin = CLLocationCoordinate2DMake(38.48625, 27.07225)
        let destination = CLLocationCoordinate2DMake(coordinate?.latitude ?? 38.431956, coordinate?.longitude ?? 27.26898)
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
}



    
    
    

