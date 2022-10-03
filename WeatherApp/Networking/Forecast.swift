//
//  CurrentWeatherModel.swift
//  WeatherApp
//
//  Created by Viacheslav Tolstopianteko on 29.09.2022.
//

import Foundation
import CoreLocation

// MARK: - Forecast
struct Forecast: Codable {
	let latitude, longitude, generationtimeMS: Double
	let utcOffsetSeconds: Int
	let timezone, timezoneAbbreviation: String
	let elevation: Int
	let currentWeather: CurrentWeather
	let hourlyUnits: HourlyUnits
	let hourly: Hourly
	let dailyUnits: DailyUnits
	let daily: Daily
	
	enum CodingKeys: String, CodingKey {
		case latitude, longitude
		case generationtimeMS = "generationtime_ms"
		case utcOffsetSeconds = "utc_offset_seconds"
		case timezone
		case timezoneAbbreviation = "timezone_abbreviation"
		case elevation
		case currentWeather = "current_weather"
		case hourlyUnits = "hourly_units"
		case hourly
		case dailyUnits = "daily_units"
		case daily
	}
}

// MARK: - CurrentWeather
struct CurrentWeather: Codable {
	let temperature, windspeed: Double
	let winddirection, weathercode: Int
	let time: String
}

// MARK: - Daily
struct Daily: Codable {
	let time: [String]
	let weathercode: [Int]
	let temperature2MMax, temperature2MMin: [Double]
	
	enum CodingKeys: String, CodingKey {
		case time, weathercode
		case temperature2MMax = "temperature_2m_max"
		case temperature2MMin = "temperature_2m_min"
	}
}

// MARK: - DailyUnits
struct DailyUnits: Codable {
	let time, weathercode, temperature2MMax, temperature2MMin: String
	
	enum CodingKeys: String, CodingKey {
		case time, weathercode
		case temperature2MMax = "temperature_2m_max"
		case temperature2MMin = "temperature_2m_min"
	}
}

// MARK: - Hourly
struct Hourly: Codable {
	let time: [String]
	let temperature2M: [Double]
	let relativehumidity2M, weathercode: [Int]
	let windspeed10M: [Double]
	let winddirection10M: [Int]
	
	enum CodingKeys: String, CodingKey {
		case time
		case temperature2M = "temperature_2m"
		case relativehumidity2M = "relativehumidity_2m"
		case weathercode
		case windspeed10M = "windspeed_10m"
		case winddirection10M = "winddirection_10m"
	}
}

// MARK: - HourlyUnits
struct HourlyUnits: Codable {
	let time, temperature2M, relativehumidity2M, weathercode: String
	let windspeed10M, winddirection10M: String
	
	enum CodingKeys: String, CodingKey {
		case time
		case temperature2M = "temperature_2m"
		case relativehumidity2M = "relativehumidity_2m"
		case weathercode
		case windspeed10M = "windspeed_10m"
		case winddirection10M = "winddirection_10m"
	}
}

extension URL {
	static var forForecast: URL {
		var components = URLComponents()
		components.scheme = "https"
		components.host = "api.open-meteo.com"
		components.path = "/v1/forecast"
		
		return components.url!
	}
}

extension Forecast {
	var preview: ForecastPreview {
		var days: [DailyWeatherPreview] = []
		var hours: [HourlyWeatherPreview] = []
		var currentHumidity: String = ""
		
		let hourlyFormatter = DateFormatter()
		hourlyFormatter.dateFormat = "yyyy-MM-dd'T'HH:00"
		
		let dailyFormatter = DateFormatter()
		dailyFormatter.dateFormat = "yyyy-MM-dd"
		
		let currentDateString = hourlyFormatter.string(from: Date())
		
		for (index, value) in hourly.time.enumerated() {
			if value == currentDateString {
				currentHumidity = String(hourly.relativehumidity2M[index])
			}
			
			let hour = hourlyFormatter.date(from: value)!
			
			let weatherCode = hourly.weathercode[index]
			
			if (hour >= hourlyFormatter.date(from: currentDateString)!) {
				let hourlyWeatherPreview = HourlyWeatherPreview(date: hour, temp: "\(Int(hourly.temperature2M[index]))°", weatherCode: weatherCode)
				hours.append(hourlyWeatherPreview)
			}
		}
		
		for (index, value) in daily.time.enumerated() {
			
			let tempMin = "\(Int(daily.temperature2MMin[index]))°"
			let tempMax = "\(Int(daily.temperature2MMax[index]))°"
			
			let day = dailyFormatter.date(from: value)!
			
			var byHours: [HourlyWeatherPreview] = []
			
			hours.forEach { hourPreview in
				if (Calendar.current.component(.day, from: hourPreview.date) == Calendar.current.component(.day, from: day)) {
					byHours.append(hourPreview)
				}
			}
			
			let weatherCode = daily.weathercode[index]
			
			let dailyWeatherPreview = DailyWeatherPreview(tempMin: tempMin, tempMax: tempMax, date: day, byHours: byHours, weatherCode: weatherCode)
			
			days.append(dailyWeatherPreview)
		}
		
		let currentTempMin = "\(Int(daily.temperature2MMin.first!))°"
		let currentTempMax = "\(Int(daily.temperature2MMax.first!))°"
		let humidity  = currentHumidity + "%"
		let currentWindSpeed = String(Int(currentWeather.windspeed))
		
		let today = TodayWeatherPreview(tempMin: currentTempMin, tempMax: currentTempMax, humidity: humidity, windSpeed: currentWindSpeed, latitude: latitude, longitude: longitude, weatherCode: currentWeather.weathercode, windDirection: currentWeather.winddirection)
		 
		let forecast = ForecastPreview(today: today, byDays: days)
			 
		return forecast
	}
}


extension Forecast {
	static func byCoordinates(latitude: String, longitude: String) -> Resource<Forecast> {
		let url = URL.forForecast
		
		let currentWeatherItem = URLQueryItem(name: "current_weather", value: "true")
		let hourlyItem = URLQueryItem(name: "hourly", value: "temperature_2m,relativehumidity_2m,weathercode,windspeed_10m,winddirection_10m")
		let dailyItem = URLQueryItem(name: "daily", value: "weathercode,temperature_2m_max,temperature_2m_min")
		let timeZone = URLQueryItem(name: "timezone", value: TimeZone.current.identifier)
		let (lat, lon) = (URLQueryItem(name: "latitude", value: latitude), URLQueryItem(name: "longitude", value: longitude))
		let queryItems = [currentWeatherItem, lat, lon, hourlyItem, dailyItem, timeZone]
		
		return Resource(url: url, method: .get(queryItems))
	}
	
}

