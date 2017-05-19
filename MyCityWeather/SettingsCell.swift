//
//  SettingsCell.swift
//MyCityWeather Settings cell displays the settings options in the app
//The user can change the city and also the API key from Open weather

import UIKit

class SettingsCell: UITableViewCell {

    
    @IBOutlet weak var contentLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
