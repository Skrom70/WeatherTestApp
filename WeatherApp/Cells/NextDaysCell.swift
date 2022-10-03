//
//  NextDaysCell.swift
//  WeatherApp
//
//  Created by Viacheslav Tolstopianteko on 27.09.2022.
//

import UIKit

class NextDaysCell: UITableViewCell {
	
	static let id = "NextDaysCell"
	static let defaultRowHeight: CGFloat = 60
	
	@IBOutlet weak var shadowLayer: UIView!
	@IBOutlet weak var day: UILabel!
	@IBOutlet weak var temp: UILabel!
	@IBOutlet weak var icon: UIImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		let blueView = UIView(frame: bounds)
		blueView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		self.selectedBackgroundView = blueView
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		shadowLayer.isHidden = !selected
		
		guard let shadowLayer = shadowLayer, let day = day, let temperature = temp, let icon = icon else {
			return
		}
		
		if selected {
			shadowLayer.layer.isHidden = false
			shadowLayer.layer.masksToBounds = false
			shadowLayer.layer.shadowOffset = CGSize.zero
			shadowLayer.layer.shadowColor = #colorLiteral(red: 0.2906339467, green: 0.5666438937, blue: 0.8850494027, alpha: 1).cgColor
			shadowLayer.layer.shadowOpacity = 0.23
			shadowLayer.layer.shadowRadius = 8
			day.textColor = #colorLiteral(red: 0.2906339467, green: 0.5666438937, blue: 0.8850494027, alpha: 1)
			temperature.textColor = #colorLiteral(red: 0.2906339467, green: 0.5666438937, blue: 0.8850494027, alpha: 1)
			icon.tintColor =  #colorLiteral(red: 0.2906339467, green: 0.5666438937, blue: 0.8850494027, alpha: 1)
		} else {
			shadowLayer.layer.isHidden = true
			day.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
			temperature.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
			icon.tintColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		}

    }
	
}
