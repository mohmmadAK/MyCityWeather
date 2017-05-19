//
//  SetPermissionsViewController.swift
//  NearbyWeather
//MyCityWeather

import UIKit

class SetPermissionsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var askPermissionsButton: UIButton!
    
    
    // Methods to set the API key and ask user for location permissions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Settng the OpenWeather Map api key value
        UserDefaults.standard.set("fab0a4ea9cd550d927728ab984599f88", forKey: "mycity_weather.openWeatherMapApiKey")
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.title = NSLocalizedString("SetPermissionsVC_NavigationBarTitle", comment: "")
        setUp()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SetPermissionsViewController.startApp), name: Notification.Name(rawValue: KeyValues.locationAuthorizationUpdated.rawValue), object: nil)
    }
    
    /* Deinitializer */
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // Helper methods to set the permissions and move to app main screen
    
    func setUp() {
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionLabel.text! = NSLocalizedString("SetPermissionsVC_Description", comment: "")
        
        askPermissionsButton.setTitle(NSLocalizedString("SetPermissionsVC_ButtonTitle", comment: ""), for: .normal)
        askPermissionsButton.setTitleColor(UIColor(red: 23/255, green: 134/255, blue: 10, alpha: 1.0), for: .normal)
        askPermissionsButton.setTitleColor(.white, for: .highlighted)
        askPermissionsButton.layer.cornerRadius = 5.0
        askPermissionsButton.layer.borderColor = UIColor(red: 23/255, green: 134/255, blue: 10, alpha: 1.0).cgColor
        askPermissionsButton.layer.borderWidth = 1.0
    }
    
    //Function to start the application once permissions received
    func startApp() {
        WeatherDetail.attachPersistentObject()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = storyboard.instantiateInitialViewController()
        
        UIApplication.shared.keyWindow?.rootViewController = destinationViewController
    }
    
    
    // IBAction method to check for permissions and  grant to user
    
    @IBAction func didTapAskPermissionsButton(_ sender: UIButton) {
        if LocationDetail.current.authorizationStatus == .notDetermined {
            LocationDetail.current.requestWhenInUseAuthorization()
        } else {
            startApp()
        }
    }
}
