//
// This class is used to represent the Settings page in the app
// IT shows 3 options to set city, change API key and also select temperature units
//MyCityWeather

import UIKit

class SettingsTableViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("SettingsVCT_NavigationBarTitle", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SettingsTableViewController.didTapDoneButton(_:)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsTableViewController.reloadTableViewData(_:)), name: Notification.Name(rawValue: KeyValues.weatherServiceUpdated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsTableViewController.reloadTableViewData(_:)), name: Notification.Name(rawValue: KeyValues.apiKeyUpdated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsTableViewController.reloadTableViewData(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    //Load the tableviews and display actions for each section selection
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationViewController = storyboard.instantiateViewController(withIdentifier: "SettingsInputVCT") as! SettingsInputTableViewController
            destinationViewController.mode = .chooseMyCityLocation
            navigationController?.pushViewController(destinationViewController, animated: true)
        case 1:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationViewController = storyboard.instantiateViewController(withIdentifier: "SettingsInputVCT") as! SettingsInputTableViewController
            destinationViewController.mode = .chooseMyAPIKey
            navigationController?.pushViewController(destinationViewController, animated: true)
        case 2:
            WeatherDetail.current.temperatureUnit = TempUnit(rawValue: indexPath.row)
            tableView.reloadData()
            break
        default:
            break
        }
    }
    
    //Set the table view Section Headers
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("SettingsVCT_SectionTitle1", comment: "")
        case 1:
            return NSLocalizedString("SettingsVCT_SectionTitle2", comment: "")
        case 2:
            return NSLocalizedString("SettingsVCT_SectionTitle3", comment: "")
        default:
            return nil
        }
    }
    
    //Set the total number of sections to be displayed
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    //Set the number of rows in each section of the Table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return TempUnit.count
        default:
            return 0
        }
    }
    
    //Based on the row selected process input based on which section row is selected
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        cell.accessoryType = .none
        
        switch indexPath.section {
            //This case is if the user selects to change the city name
        case 0:
            cell.contentLabel.text! = WeatherDetail.current.myCityLocation
            cell.accessoryType = .disclosureIndicator
            return cell
            //This case is if the user selects to edit the OpenWeather API key
        case 1:
            cell.contentLabel.text! = UserDefaults.standard.value(forKey: "mycity_weather.openWeatherMapApiKey") as! String
            cell.accessoryType = .disclosureIndicator
            return cell
            //This case is if the user selects to change the unit of temperature
        case 2:
            let temperatureUnit = TempUnit(rawValue: indexPath.row)
            cell.contentLabel.text! = temperatureUnit.stringValue
            if temperatureUnit.stringValue == WeatherDetail.current.temperatureUnit.stringValue {
                cell.accessoryType = .checkmark
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //Helper methods to reload the table view data
    
    @objc func reloadTableViewData(_ notification: Notification) {
        tableView.reloadData()
    }
    
    
    //Action methods if the Done button is selected
    
    @objc private func didTapDoneButton(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
