//
//  LocationDetail.swift
//  MyCityWeather
//

import CoreLocation

class LocationDetail: CLLocationManager, CLLocationManagerDelegate {
    
    // Store current latitude and longitude values
    
    public static var current: LocationDetail!
    
    public var currentLatitude: Double
    public var currentLongitude: Double
    public var authorizationStatus: CLAuthorizationStatus
    
    
    // Initializers
    
    private init(withLocation latitude: Double, longitude: Double) {
        currentLatitude = latitude
        currentLongitude = longitude
        authorizationStatus = CLLocationManager.authorizationStatus()
        super.init()
    }
    
    
    // Public methods to initialize the service
    
    public static func initializeService() {
        // initialize with example data
        current = LocationDetail(withLocation: 37.3318598, longitude: -122.0302485)
        
        LocationDetail.current.delegate = LocationDetail.current
        LocationDetail.current.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        LocationDetail.current.startUpdatingLocation()
    }
    
    
    // MARK: - Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        NotificationCenter.default.post(name: Notification.Name(rawValue: KeyValues.locationAuthorizationUpdated.rawValue), object: self)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation: CLLocationCoordinate2D = manager.location!.coordinate
        currentLatitude = currentLocation.latitude
        currentLongitude = currentLocation.longitude
    }
}
