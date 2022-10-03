//
//  String.swift
//  WeatherApp
//
//  Created by Viacheslav Tolstopianteko on 02.10.2022.
//

import Foundation

extension Date {
	var getWeekday: String {
		switch Calendar.current.component(.weekday, from: self) {
			case 1: return "ВС"
			case 2: return "ПН"
			case 3: return "ВТ"
			case 4: return "СД"
			case 5: return "ЧТ"
			case 6: return "ПТ"
			case 7: return "СБ"
			default: return ""
		}
	}
	
	var getWeekdayDate: String {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "ru_RU")
		dateFormatter.dateFormat = "dd MMMM"
		let stringDate = dateFormatter.string(from: Date())
		
		return self.getWeekday + ", " + stringDate
	}
	
	var hour: String {
		return "\(Calendar.current.component(.hour, from: self))"
	}
}
