//
//  AppDelegate.swift
//  WeatherApp
//
//  Created by Viacheslav Tolstopianteko on 27.09.2022.
//

import UIKit
import Swinject

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	let container = Container() { container in
		container.register(Webservice.self) { _ in WebserviceImpl() }

		container.register(ForecastViewModel.self) { resolver in
			ForecastViewModel(webSevice: resolver.resolve(Webservice.self)!)
		}
	}

	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// To change background colour.
		UINavigationBar.appearance().barTintColor = .init(red: 23.0/255, green: 197.0/255, blue: 157.0/255, alpha: 1.0)
		
		// To change colour of tappable items.
		UINavigationBar.appearance().tintColor = .white
		
		// To apply textAttributes to title i.e. colour, font etc.
		UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor.white,
															.font : UIFont.init(name: "AvenirNext-DemiBold", size: 22.0)!]
		// To control navigation bar's translucency.
//		UINavigationBar.appearance().isTranslucent = false
		return true
	}

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}


}

