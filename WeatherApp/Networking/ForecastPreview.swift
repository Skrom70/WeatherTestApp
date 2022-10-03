//
//  Daily.swift
//  WeatherApp
//
//  Created by Viacheslav Tolstopianteko on 29.09.2022.
//

import Foundation

// MARK: - ForecastPreview
struct ForecastPreview {
	let today: TodayWeatherPreview
	let byDays: [DailyWeatherPreview]
}

// MARK: - TodayWeatherPreview
struct TodayWeatherPreview {
	let tempMin, tempMax, humidity, windSpeed: String
	let latitude, longitude: Double
	let weatherCode, windDirection: Int
}

// MARK: - DailyWeatherPreview
struct DailyWeatherPreview {
	let tempMin, tempMax: String
	let date: Date
	let byHours: [HourlyWeatherPreview]
	let weatherCode: Int

}

// MARK: - HourlyWeatherPreview
struct HourlyWeatherPreview {
	let date: Date
	let temp: String
	let weatherCode: Int
}

