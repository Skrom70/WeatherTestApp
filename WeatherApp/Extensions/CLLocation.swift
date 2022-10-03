//
//  CLLocation.swift
//  WeatherApp
//
//  Created by Viacheslav Tolstopianteko on 02.10.2022.
//

import CoreLocation

extension CLLocation {
	func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
		CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
	}
}
