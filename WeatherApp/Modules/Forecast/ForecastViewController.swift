//
//  ViewController.swift
//  WeatherApp
//
//  Created by Viacheslav Tolstopianteko on 27.09.2022.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import Swinject

class ForecastViewController: UIViewController {

	@IBOutlet weak var nextHoursCollectionView: UICollectionView!
	@IBOutlet weak var nextDaysTableView: UITableView!
	@IBOutlet weak var weather: UIImageView!
	@IBOutlet weak var location: UIButton!
	@IBOutlet weak var date: UILabel!
	@IBOutlet weak var temp: UILabel!
	@IBOutlet weak var humidity: UILabel!
	@IBOutlet weak var wendSpeed: UILabel!
	@IBOutlet weak var windDirection: UIImageView!
	
	private var viewModel: ForecastViewModel = ForecastViewModel(webSevice: WebserviceImpl())
	private let disposeBag = DisposeBag()
	private let locationManager = CLLocationManager()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		setupViews()
		bind()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewModel.loadWeather()
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}
	
	
	private func bind() {
		viewModel.forecast
			.asDriver()
			.drive(onNext: { [weak self] value in
				guard let `self` = self, let forecast = value else { return }
				
				self.temp.text = forecast.today.tempMin + " / " + forecast.today.tempMax
				self.humidity.text = forecast.today.humidity
				self.wendSpeed.text = forecast.today.windSpeed + "м/сек"
				self.windDirection.image = UIImage.getWindDirectionIcon(value: forecast.today.windDirection)
				
				let currentHour = Calendar.current.component(.hour, from: Date())
				
				self.weather.image = UIImage.getWeatherIcon(code: forecast.today.weatherCode, hour: currentHour)
				
				CLLocation(latitude: forecast.today.latitude, longitude: forecast.today.longitude).fetchCityAndCountry { city, country, error in
					self.location.setTitle(city, for: .normal)
				}
				
				self.date.text = Date().getWeekdayDate
				
				self.nextHoursCollectionView.reloadData()
				self.nextDaysTableView.reloadData()
				
				self.nextDaysTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition:	.top)
			})
			.disposed(by: disposeBag)
		
		viewModel.selectedDay
			.asDriver()
			.drive(onNext: { [weak self] _ in
				guard let `self` = self else { return }
				self.nextHoursCollectionView.reloadData()
			})
			.disposed(by: disposeBag)
	}
	
	private func setupViews() {
		self.location.setTitle("", for: .normal)
		self.date.text = ""
		self.temp.text = ""
		self.humidity.text = ""
		self.wendSpeed.text = ""
		
		nextHoursCollectionView.register(UINib(nibName: NextHoursCell.id, bundle: nil), forCellWithReuseIdentifier: NextHoursCell.id)
		nextHoursCollectionView.delegate = self
		nextHoursCollectionView.dataSource = self
		
		nextDaysTableView.register(UINib(nibName: NextDaysCell.id, bundle: nil), forCellReuseIdentifier: NextDaysCell.id)
		nextDaysTableView.delegate = self
		nextDaysTableView.dataSource = self
		
		if (self.view.traitCollection.verticalSizeClass == .compact || (self.view.traitCollection.verticalSizeClass == .regular && self.view.traitCollection.horizontalSizeClass == .regular)) {
			let layout = UICollectionViewFlowLayout()
			layout.itemSize = CGSize(width: NextHoursCell.defaultCellSize.width * 1.5, height: NextHoursCell.defaultCellSize.height * 1.5)
			layout.scrollDirection = .horizontal
			nextHoursCollectionView.setCollectionViewLayout(layout, animated: true)
			nextHoursCollectionView.reloadData()
		}
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
	}
	
	private func updateLayout() {
		let cellSize: CGSize
		if (self.view.traitCollection.verticalSizeClass == .compact || (self.view.traitCollection.verticalSizeClass == .regular && self.view.traitCollection.horizontalSizeClass == .regular)) {
			cellSize = CGSize(width: NextHoursCell.defaultCellSize.width * 1.5, height: NextHoursCell.defaultCellSize.height * 1.5)
		} else {
			cellSize = CGSize(width: NextHoursCell.defaultCellSize.width, height: NextHoursCell.defaultCellSize.height)
		}
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = cellSize
		layout.scrollDirection = .horizontal
		nextHoursCollectionView.setCollectionViewLayout(layout, animated: true)
		nextHoursCollectionView.reloadData()
	}
		
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
		
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		updateLayout()
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		updateLayout()
	}
	
	@IBAction func currentLocationAction(_ sender: UIButton) {
		let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ForecastSearchMapViewController")
		vc.modalPresentationStyle = .fullScreen
		vc.modalTransitionStyle = .crossDissolve
		self.navigationController?.pushViewController(vc, animated: true)

	}
}

extension ForecastViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }

		CurrentWeatherLocation.shared.location = locValue
		
		viewModel.loadWeather()
	}
}

extension ForecastViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let forecast = viewModel.forecast.value {
			let selectedDay = viewModel.selectedDay.value
			return forecast.byDays[selectedDay].byHours.count
		} else {
			return 0
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NextHoursCell.id, for: indexPath) as? NextHoursCell,
				let forecast = viewModel.forecast.value else {
			return UICollectionViewCell()
		}
		
		let selectedDay = viewModel.selectedDay.value
		
		let data = forecast.byDays[selectedDay].byHours[indexPath.row]
		
		let hour = Calendar.current.component(.hour, from: data.date)

		cell.hour.text = "\(hour)"
		cell.temp.text = data.temp
		cell.icon.image = UIImage.getWeatherIcon(code: data.weatherCode, hour: hour)
		
		return cell
	}
}

extension ForecastViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let forecast = viewModel.forecast.value {
			return forecast.byDays.count
		} else {
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: NextDaysCell.id, for: indexPath) as? NextDaysCell,
				let forecast = viewModel.forecast.value else {
			return UITableViewCell()
		}
		
		let data = forecast.byDays[indexPath.row]

		cell.day.text = data.date.getWeekday
		cell.temp.text = data.tempMin + " / " + data.tempMax
		cell.icon.image = UIImage.getWeatherIcon(code: data.weatherCode, hour: 12)
		
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if (viewModel.selectedDay.value != indexPath.row) {
			viewModel.selectedDay.accept(indexPath.row)
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if (self.view.traitCollection.verticalSizeClass == .compact || (self.view.traitCollection.verticalSizeClass == .regular && self.view.traitCollection.horizontalSizeClass == .regular)) {
			return NextDaysCell.defaultRowHeight * 1.5
		}
		return NextDaysCell.defaultRowHeight
	}
}








