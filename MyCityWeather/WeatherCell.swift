//
//  WeatherCell.swift
//MyCityWeather uses tableviews to display the list of values for one or more cities
//

import UIKit

class WeatherCell: UITableViewCell {
    
    
    /* View Components */
    
    @IBOutlet weak var backgroundColorView: UIView!
    
    /* Labels used in the weather cell */
    
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windspeedLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
