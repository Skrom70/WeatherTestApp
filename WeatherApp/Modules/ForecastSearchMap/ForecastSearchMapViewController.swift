//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by Viacheslav Tolstopianteko on 28.09.2022.
//

import UIKit
import MapKit
import EasyTipView

class ForecastSearchMapViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var currentLocationButton: UIButton!
	@IBOutlet weak var infoButton: UIButton!
	
	var isSearching: Bool = false {
		didSet {
			if tableView != nil {
				if self.isSearching {
					self.mapView.isHidden = true
					self.currentLocationButton.isHidden = true
					self.infoButton.isHidden = true
					self.tableView.isHidden = false
				} else {
					self.mapView.isHidden = false
					self.currentLocationButton.isHidden = false
					self.infoButton.isHidden = false
					self.tableView.isHidden = true
					self.searchResults = []
				}
				self.tableView.reloadData()
			}
		}
	}
	
	let locationManager = CLLocationManager()
	let searchBar = UISearchBar()
	var searchResults: [(String, CLLocationCoordinate2D)] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupViews()
    }
	
	private func setupViews() {
		let app = UINavigationBarAppearance()
		app.backgroundColor = #colorLiteral(red: 0.2921853065, green: 0.5625540614, blue: 0.8852232099, alpha: 1)
		self.navigationController?.navigationBar.scrollEdgeAppearance = app
		
		let searchBar = UISearchBar()
		
		searchBar.searchTextField.backgroundColor = .white
		searchBar.setImage(UIImage(), for: .search, state: .normal)
		searchBar.sizeToFit()
		searchBar.tintColor = .black
		searchBar.delegate = self
		
		navigationItem.titleView = searchBar
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_back"), primaryAction: UIAction(handler: { action in
			self.navigationController?.popViewController(animated: true)
		}))
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_search"))
		
		tableView.register(UINib(nibName: "SearchCell", bundle: Bundle.main), forCellReuseIdentifier: "SearchCell")
		tableView.delegate = self
		tableView.dataSource = self
		
		let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addWaypoint(longGesture:)))
		mapView.addGestureRecognizer(longGesture)
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		
		setRegion(location: CurrentWeatherLocation.shared.location, animated: false)
	}
	
	private func setRegion(location: CLLocationCoordinate2D, animated: Bool = true) {
		var mapRegion = MKCoordinateRegion()
		mapRegion.center = location
		mapRegion.span.latitudeDelta = 0.2
		mapRegion.span.longitudeDelta = 0.2
		
		mapView.setRegion(mapRegion, animated: true)
	}
	
	private func setWeatherLocation(_ location: CLLocationCoordinate2D) {
		
		setRegion(location: location)
		
		CurrentWeatherLocation.shared.location = location
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			self.navigationController?.popViewController(animated: true)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	
	
	@IBAction func currentLocationAction(_ sender: UIButton) {
		if let currentLocation = locationManager.location?.coordinate {
			setWeatherLocation(currentLocation)
		} else {
			var preferences = EasyTipView.Preferences()
			preferences.drawing.font = .systemFont(ofSize: 14)
			preferences.drawing.foregroundColor = UIColor.white
			preferences.drawing.backgroundColor = #colorLiteral(red: 0.2345964909, green: 0.2345964909, blue: 0.2345964909, alpha: 0.85)
			preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.right
			
			let tipView = EasyTipView(text: "Please allow access to geolocation data in the settings", preferences: preferences)
			tipView.show(forView: self.currentLocationButton, withinSuperview: self.view)
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
				tipView.dismiss()
			}
		}
	}
	
	@IBAction func infoAction(_ sender: UIButton) {
		var preferences = EasyTipView.Preferences()
		preferences.drawing.font = .systemFont(ofSize: 14)
		preferences.drawing.foregroundColor = UIColor.white
		preferences.drawing.backgroundColor = #colorLiteral(red: 0.2345964909, green: 0.2345964909, blue: 0.2345964909, alpha: 0.85)
		preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.right
		
		let tipView = EasyTipView(text: "To select a point on the map, long press the selected area", preferences: preferences)
		tipView.show(forView: self.infoButton, withinSuperview: self.view)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			tipView.dismiss()
		}
	}
	
	@objc func addWaypoint(longGesture: UIGestureRecognizer) {
		let touchPoint = longGesture.location(in: mapView)
		let wayCoords = mapView.convert(touchPoint, toCoordinateFrom: mapView)
		let wayAnnotation = MKPointAnnotation()
		wayAnnotation.coordinate = wayCoords
		wayAnnotation.title = "Pin"
		mapView.addAnnotation(wayAnnotation)
		
		setWeatherLocation(wayCoords)
	}
}

extension ForecastSearchMapViewController: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = searchText
		let search = MKLocalSearch(request: request)
		
		search.start { response, _ in
			guard let response = response else {
				return
			}
			
			if !response.mapItems.isEmpty {
				var filter: [String: CLLocationCoordinate2D] = [:]
				
				response.mapItems.forEach { item in
					if let city = item.placemark.locality, let country = item.placemark.country, let coordinate = item.placemark.location?.coordinate {
						filter[city + ", " + country] = coordinate
					}
				}
				self.searchResults = filter.map({($0, $1)})
				
				self.isSearching = true
			} else {
				self.isSearching = false
			}
		}
		
		if searchText == "" {
			self.isSearching = false
		}
	}
}

extension ForecastSearchMapViewController : CLLocationManagerDelegate {
	private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			locationManager.requestLocation()
		}
	}
	
	private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.first {
			let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
			let region = MKCoordinateRegion(center: location.coordinate, span: span)
			mapView.setRegion(region, animated: true)
		}
	}
}

extension ForecastSearchMapViewController: UITableViewDelegate, UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchResults.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as? SearchCell else {
			return UITableViewCell()
		}
		
		cell.label.text = searchResults[indexPath.row].0
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		setWeatherLocation(searchResults[indexPath.row].1)
		self.isSearching = false
	}
}

extension ForecastSearchMapViewController: EasyTipViewDelegate {
	func easyTipViewDidTap(_ tipView: EasyTipView) {
		
	}
	
	func easyTipViewDidDismiss(_ tipView: EasyTipView) {
		
	}

	
	
}
