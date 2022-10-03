//
//  NextHoursCell.swift
//  WeatherApp
//
//  Created by Viacheslav Tolstopianteko on 27.09.2022.
//

import UIKit

class NextHoursCell: UICollectionViewCell {
	
	static let id = "NextHoursCell"
	static let defaultCellSize = CGSize(width: 64, height: 128)
	
	@IBOutlet weak var hour: UILabel!
	@IBOutlet weak var icon: UIImageView!
	@IBOutlet weak var temp: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
