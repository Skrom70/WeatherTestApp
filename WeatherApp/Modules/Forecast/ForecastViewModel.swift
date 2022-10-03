//
//  MainViewModel.swift
//  WeatherApp
//
//  Created by Viacheslav Tolstopianteko on 29.09.2022.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

class ForecastViewModel {

	var forecast: BehaviorRelay<ForecastPreview?> = BehaviorRelay<ForecastPreview?>(value: nil)
	var isLoading: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
	var error: PublishRelay<String?> = PublishRelay<String?>()
	var selectedDay: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
	
	private let disposeBag: DisposeBag = DisposeBag()
	private let webService: Webservice
	
	init(webSevice: Webservice) {
		self.webService = webSevice
	}
	
	func loadWeather() {
		self.isLoading.accept(true)
		
		let (latitude, longitude) = (CurrentWeatherLocation.shared.location.latitude, CurrentWeatherLocation.shared.location.longitude)
		
		let resource = Forecast.byCoordinates(latitude: String(latitude), longitude: String(longitude))
		
		Task {
			do {
				let data = try await webService.load(resource).preview
				forecast.accept(data)
			} catch (let error){
				self.isLoading.accept(false)
				self.error.accept(error.localizedDescription)
			}
		}
	}
}






















