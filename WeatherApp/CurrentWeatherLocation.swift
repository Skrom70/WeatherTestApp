//
//  File.swift
//  WeatherApp
//
//  Created by Viacheslav Tolstopianteko on 02.10.2022.
//

import Foundation
import CoreLocation

class CurrentWeatherLocation {
	
	static let shared = CurrentWeatherLocation()
	var location = CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234)
	
	private init() {
		
	}
}
