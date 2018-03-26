//
//  WeatherInfoTableViewCell.swift
//  Openweather
//
//  Created by Raviraju Vysyaraju on 23/03/2018.
//  Copyright © 2018 Raviraju Vysyaraju. All rights reserved.
//

import UIKit

class WeatherInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var weatherIcon: UIImageView!
    
    @IBOutlet weak var weatheLabelDetailsTitle: UILabel!
    @IBOutlet weak var weatherLabelTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
