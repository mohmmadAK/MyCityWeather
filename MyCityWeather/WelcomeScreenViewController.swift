//
//  WelcomeScreenViewController.swift
//MyCityWeather Welcome Screen View Controller displays the welcome screen
//in the app when the app is launched. It shows a welcome message

import UIKit

class WelcomeScreenViewController: UIViewController {
    
    //Outlets
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup the navigation bar title
        navigationItem.title = NSLocalizedString("WelcomeScreenVC_NavigationBarTitle", comment: "")
        setUpView()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    

    //Setup the view of the Welcome Screen
    func setUpView() {
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionLabel.text! = NSLocalizedString("WelcomeScreenVC_Description", comment: "")
        
        nextButton.setTitle(NSLocalizedString("WelcomeScreenVC_SaveButtonTitle", comment: ""), for: .normal)
        nextButton.setTitleColor(UIColor(red: 23/255, green: 134/255, blue: 10, alpha: 1.0), for: .normal)
        nextButton.setTitleColor(.white, for: .highlighted)
        nextButton.setTitleColor(.gray, for: .disabled)
        nextButton.layer.cornerRadius = 5.0
        nextButton.layer.borderColor = UIColor.lightGray.cgColor
        nextButton.layer.borderWidth = 1.0
        
    }
    
    
    
    // IBAction method when next is tapped
    
    @IBAction func didTapNext(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        let destinationViewController = storyboard.instantiateViewController(withIdentifier: "SetPermissionsVC") as! SetPermissionsViewController
        
        navigationController?.pushViewController(destinationViewController, animated: true)
    }

    
}
