//
// This class shows the weather for the city chosen as well as closeby cities
//based on current location
//MyCityWeather

import UIKit
import CoreLocation

class NearbyLocationsTableViewController: UITableViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "MyCityWeather"
        
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        
        //Setup the UIRefresh Control
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: NSLocalizedString("LocationsListVCT_RefreshPullHandle", comment: ""))
        refreshControl?.addTarget(self, action: #selector(NearbyLocationsTableViewController.refreshContent(refreshControl:)), for: UIControlEvents.valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NearbyLocationsTableViewController.reloadTableViewDataWithDataPull(_:)), name: Notification.Name(rawValue: KeyValues.weatherServiceUpdated_dataPullRequired.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NearbyLocationsTableViewController.reloadTableViewData(_:)), name: Notification.Name(rawValue: KeyValues.weatherServiceUpdated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NearbyLocationsTableViewController.reloadTableViewData(_:)), name: Notification.Name(rawValue: KeyValues.apiKeyUpdated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NearbyLocationsTableViewController.reloadTableViewData(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.value(forKey: "mycity_weather.isInitialLaunch") == nil {
            startActivityIndicator()
            //Check whether its an initial launch
            WeatherDetail.current.fetchDataWith {
                UserDefaults.standard.set(false, forKey: "mycity_weather.isInitialLaunch")
                self.stopActivityIndicator()
            }
        }
    }
    
    //Display the table views to display weather data for one or more cities

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !WeatherDetail.current.singleLocWeatherData.isEmpty && !WeatherDetail.current.multiLocWeatherData.isEmpty {
            switch section {
            case 0:
                return NSLocalizedString("LocationsListVCT_TableViewSectionHeader1", comment: "")
            case 1:
                return NSLocalizedString("LocationsListVCT_TableViewSectionHeader2", comment: "")
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    //Set the number of sections in the table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !WeatherDetail.current.singleLocWeatherData.isEmpty && !WeatherDetail.current.multiLocWeatherData.isEmpty {
            return 2
        }
        return 1
    }
    
    //Setup the tableview methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !WeatherDetail.current.singleLocWeatherData.isEmpty && !WeatherDetail.current.multiLocWeatherData.isEmpty {
            if section == 0 {
                return WeatherDetail.current.singleLocWeatherData.count
            }
            return WeatherDetail.current.multiLocWeatherData.count
        }
        return 1
        
    }
    
    //Setup the view cell properties like colors, text, styles etc
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !WeatherDetail.current.singleLocWeatherData.isEmpty && !WeatherDetail.current.multiLocWeatherData.isEmpty {
            var weatherData: WeatherData!
            if indexPath.section == 0 {
                weatherData = WeatherDetail.current.singleLocWeatherData[indexPath.row]
            } else {
                weatherData = WeatherDetail.current.multiLocWeatherData[indexPath.row]
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as! WeatherCell
            
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            
            cell.backgroundColorView.layer.cornerRadius = 5.0
            cell.backgroundColorView.layer.backgroundColor = UIColor(red: 23/255, green: 134/255, blue: 10, alpha: 1.0).cgColor
            
            cell.cityNameLabel.textColor = .white
            cell.cityNameLabel.font = .preferredFont(forTextStyle: .headline)
            
            cell.temperatureLabel.textColor = .white
            cell.temperatureLabel.font = .preferredFont(forTextStyle: .subheadline)
            
            cell.cloudCoverLabel.textColor = .white
            cell.cloudCoverLabel.font = .preferredFont(forTextStyle: .subheadline)
            
            cell.humidityLabel.textColor = .white
            cell.humidityLabel.font = .preferredFont(forTextStyle: .subheadline)
            
            cell.windspeedLabel.textColor = .white
            cell.windspeedLabel.font = .preferredFont(forTextStyle: .subheadline)
            
            cell.weatherConditionLabel.text! = weatherData.condition
            cell.cityNameLabel.text! = weatherData.cityName
            cell.temperatureLabel.text! = "☀️ \(weatherData.determineTemperatureForUnit())"
            cell.cloudCoverLabel.text! = "☁️ \(weatherData.cloudCoverage)%"
            cell.humidityLabel.text! = "💦 \(weatherData.humidity)%"
            cell.windspeedLabel.text! = "🌬 \(weatherData.windspeed) km/h"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as! AlertCell
            
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            
            cell.noticeLabel.text! = NSLocalizedString("LocationsListVCT_AlertNoData", comment: "")
            cell.backgroundColorView.layer.cornerRadius = 5.0
            return cell
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
   //These are the generic helper functions to reload the table view on refresh
    
    @objc private func refreshContent(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        
        WeatherDetail.current.fetchDataWith {
            refreshControl.endRefreshing()
        }
    }
    
    @objc func reloadTableViewDataWithDataPull(_ notification: Notification) {
        startActivityIndicator()
        WeatherDetail.current.fetchDataWith {
            UserDefaults.standard.set(false, forKey: "mycity_weather.isInitialLaunch")
            self.stopActivityIndicator()
            self.tableView.reloadData()
        }
    }
    
    @objc func reloadTableViewData(_ notification: Notification) {
        tableView.reloadData()
    }
    
    //Function to show the acitivity indicator
    private func startActivityIndicator() {
        guard tableView != nil else {
            return
        }
        
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        activityIndicator.layer.cornerRadius = 10
        
        tableView?.addSubview(activityIndicator)
        if let superViewCenter = activityIndicator.superview?.center {
            activityIndicator.center = superViewCenter
        }
        activityIndicator.startAnimating()
        
        
    }
    
    //Stop the activity indicator
    private func stopActivityIndicator() {
        guard let subviews = tableView?.subviews else {
            return
        }
        for subview in subviews where subview is UIActivityIndicatorView {
            subview.removeFromSuperview()
        }
    }
    

    
    //Navigate to the settings page on selecting the settings button
    
    @IBAction func didTapSettingsButton(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = storyboard.instantiateViewController(withIdentifier: "SettingsVCT") as! SettingsTableViewController
        let destinationNavigationController = UINavigationController(rootViewController: destinationViewController)
        destinationNavigationController.navigationBar.tintColor = .white
        
        let rootController = self as UITableViewController
        rootController.present(destinationNavigationController, animated: true, completion: nil)
    }
    
}
