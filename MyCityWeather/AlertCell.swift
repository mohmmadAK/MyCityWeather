//
//  AlertCell.swift
//MyCityWeather Alert cell is used to display any alerts in the app

import UIKit

class AlertCell: UITableViewCell {
    
    
    @IBOutlet weak var backgroundColorView: UIView!

    
    @IBOutlet weak var noticeLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
