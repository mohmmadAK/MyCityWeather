//
// This class is used to display the page when the user selects an option in the settings page. There are 2 options the user can change. One is the city and another
// is th API key used to conncet to OpenWeather
//MyCityWeather
import UIKit

public enum DisplayMode: Int {
    case chooseMyCityLocation
    case chooseMyAPIKey
}

class SettingsInputTableViewController: UITableViewController, UITextFieldDelegate {
    
    
    var mode: DisplayMode!

    //IB outlets objects used
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    


    /* Overide functions*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        inputTextField.delegate = self
        switch mode! {
        case .chooseMyCityLocation:
            navigationItem.title = NSLocalizedString("SettingsInputVCT_NavBarTitle_Mode_EnterMyCity", comment: "")
            inputTextField.text! = WeatherDetail.current.myCityLocation
            break
        case .chooseMyAPIKey:
            navigationItem.title = NSLocalizedString("SettingsInputVCT_NavBarTitle_Mode_EnterAPIKey", comment: "")
            inputTextField.text! = UserDefaults.standard.value(forKey: "mycity_weather.openWeatherMapApiKey") as! String
            break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        inputTextField.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsInputTableViewController.reloadTableViewData(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        inputTextField.resignFirstResponder()
        switch mode! {
        case .chooseMyCityLocation:
            let text = inputTextField.text ?? ""
            if !text.isEmpty {
                WeatherDetail.current.myCityLocation = text
            }
            break
        case .chooseMyAPIKey:
            let text = inputTextField.text ?? ""
            if text.characters.count == 32 {
                UserDefaults.standard.set(text, forKey: "mycity_weather.openWeatherMapApiKey")
                NotificationCenter.default.post(name: Notification.Name(rawValue: KeyValues.apiKeyUpdated.rawValue), object: self)
            }
        }
    }
    
    //Setup the table view
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch mode! {
        case .chooseMyCityLocation: return NSLocalizedString("InputSettingsVCT_SectionTitle_Mode_EnterMyCity", comment: "")
        case .chooseMyAPIKey: return NSLocalizedString("InputSettings_SectionTitle_Mode_EnterAPIKey", comment: "")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch mode! {
        case .chooseMyCityLocation: return nil
        case .chooseMyAPIKey: return NSLocalizedString("InputSettings_EnterAPIKey", comment: "")
        }
    }
    
    //Input text field
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.inputTextField.resignFirstResponder()
    }
    

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //Function to reload the table view data
    
    @objc func reloadTableViewData(_ notification: Notification) {
        tableView.reloadData()
    }
    
}
