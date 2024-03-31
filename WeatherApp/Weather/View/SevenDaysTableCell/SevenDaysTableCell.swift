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
            let url = URL(string: "https://openweathermap.org/img/wn/10d@2x.png")
            iconView.kf.setImage(with: url)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
