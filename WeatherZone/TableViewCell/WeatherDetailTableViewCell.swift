//
//  WeatherDetailTableViewCell.swift
//  WeatherZone
//
//  Created by Nischal Hada on 11/8/19.
//  Copyright © 2019 NischalHada. All rights reserved.
//

import UIKit

class WeatherDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!

    var detailInfo: DetailModel? {
        didSet {
            guard let data = detailInfo else {
                return
            }
            labelTitle.text = data.title
            labelDescription.text = data.description
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.viewBackgroundColor
    }
}