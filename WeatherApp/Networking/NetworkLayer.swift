//
//  NetworkLayer.swift
//  WeatherApp
//
//  Created by Viacheslav Tolstopianteko on 29.09.2022.
//

import UIKit

struct Resource<T: Codable> {
	let url: URL
	var method: HttpMethod = .get([])
}

protocol Webservice {
	func load<T: Codable>(_ resource: Resource<T>) async throws -> T
}

class WebserviceImpl: Webservice {
	
	func load<T: Codable>(_ resource: Resource<T>) async throws -> T {
		var request = URLRequest(url: resource.url)
		
		switch resource.method {
			case .post(let data):
				request.httpMethod = resource.method.name
				request.httpBody = data
			case .get(let queryItems):
				var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)
				components?.queryItems = queryItems
				guard let url = components?.url else {
					throw NetworkError.badUrl
				}
				request = URLRequest(url: url)
		}
		
		// create the URLSession configuration
		let configuration = URLSessionConfiguration.default
		// add default headers
		configuration.httpAdditionalHeaders = ["Content-Type": "application/json"]
		let session = URLSession(configuration: configuration)
		
		let (data, response) = try await session.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse,
			  httpResponse.statusCode == 200
		else {
			throw NetworkError.invalidResponse
		}
		
		do {
			let result = try JSONDecoder().decode(T.self, from: data)
			return result
		} catch(let error) {
			throw NetworkError.decodingError
		}
	}
	
}

enum NetworkError: Error {
	case invalidResponse
	case badUrl
	case decodingError
}

enum HttpMethod {
	case get([URLQueryItem])
	case post(Data?)
	
	var name: String {
		switch self {
			case .get:
				return "GET"
			case .post:
				return "POST"
		}
	}
}



