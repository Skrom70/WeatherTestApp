//
//  UIImage.swift
//  WeatherApp
//
//  Created by Viacheslav Tolstopianteko on 02.10.2022.
//

import Foundation
import UIKit

extension UIImage {
	static func getWeatherIcon(code: Int, hour: Int) -> UIImage {
		
		let isDay: Bool = hour >= 6 && hour <= 18 ? true : false
		
		switch code {
			case 0: return UIImage(named: isDay ? "ic_white_day_bright" : "ic_white_night_bright")!
			case 1, 2, 3, 45, 48, 51, 53, 55, 56, 57: return UIImage(named: isDay ? "ic_white_day_cloudy" : "ic_white_night_cloudy")!
			case 61, 63, 65, 66, 67, 80, 81, 82: return UIImage(named: isDay ? "ic_white_day_rain" : "ic_white_night_rain")!
			case 71, 73, 75, 77, 85, 86: return UIImage(named: isDay ? "ic_white_day_shower" : "ic_white_night_shower")!
			case 95, 96, 99: return UIImage(named: isDay ? "ic_white_day_thunder" : "ic_white_night_thunder")!
			default: return UIImage(named: isDay ? "ic_white_day_cloudy" : "ic_white_night_cloudy")!
		}
	}
	
	static func getWindDirectionIcon(value: Int) -> UIImage {
		if value >= 0, value <= 45 {
			return UIImage(named: "icon_wind_n")!
		} else if value > 45, value <= 90 {
			return UIImage(named: "icon_wind_ne")!
		} else if value > 90, value <= 135 {
			return UIImage(named: "icon_wind_e")!
		} else if value > 135, value <= 180 {
			return UIImage(named: "icon_wind_se")!
		} else if value > 180, value <= 225 {
			return UIImage(named: "icon_wind_s")!
		} else if value > 225, value <= 270 {
			return UIImage(named: "icon_wind_ws")!
		} else if value > 270, value <= 315 {
			return UIImage(named: "icon_wind_w")!
		} else {
			return UIImage(named: "icon_wind_wn")!
		}
	}
}
