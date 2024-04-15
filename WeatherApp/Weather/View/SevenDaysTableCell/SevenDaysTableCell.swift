//
//  SevenDaysTableCell.swift
//  WeatherApp
//
//  Created by Yusuf Tarık Gün on 31.03.2024.
//

import UIKit
import Kingfisher

class SevenDaysTableCell: UITableViewCell {
    static let identifier = "SevenDaysTableCell"
    @IBOutlet weak private var dayLabel: UILabel!
    @IBOutlet weak private var maxTempLabel: UILabel!
    @IBOutlet weak private var minTempLabel: UILabel!
    @IBOutlet weak private var iconView: UIImageView!
    
    var weatherData: WeatherForecast? {
        didSet {
            dayLabel.text = weatherData?.date
            maxTempLabel.text = weatherData?.max
            minTempLabel.text = weatherData?.min
            
            if let iconCode = weatherData?.iconCode{
                let iconURLString = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
                    if let iconURL = URL(string: iconURLString) {
                            iconView.kf.setImage(with: iconURL)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
    }
}
