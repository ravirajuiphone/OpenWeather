//
//  ViewController.swift
//  Openweather
//
//  Created by Raviraju Vysyaraju on 22/03/2018.
//  Copyright © 2018 Raviraju Vysyaraju. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var reachability: Reachability!
    var imageCache: ImageCache!
    private var weatherList = [WeatherDetails]()
    private var weatherFullInfo: WeatherFullInfo?
    private var weatherDetails: [String: [WeatherDetails]]?
    private var weatherDates: [String]?
    @IBOutlet weak var weatherTabelview: UITableView!
    let apiManager = APIManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageCache = ImageCache(shared: URLSession.shared, sessionTask: URLSessionDataTask())
        self.reachability = Reachability.init()
        let nibName = UINib(nibName: "WeatherInfoTableViewCell", bundle: nil)
        self.weatherTabelview.register(nibName, forCellReuseIdentifier: "WeatherTableviewCell")
        self.weatherTabelview.estimatedRowHeight = 60.0
        self.weatherTabelview.rowHeight = UITableViewAutomaticDimension
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Maps", style: .plain, target: self, action: #selector(showInMapsTapped))
        //NotificationCenter.default.addObserver(self, selector: #selector(loadWeatherInfo), name: NSNotification.Name(rawValue: "WeatherNotification"), object: nil)
        self.loadWeatherInfo()
    }
    @objc func loadWeatherInfo() {
        if self.reachability.isReachable {
            loadWeatherForecaseInfo()
        } else {
            let alert = UIAlertController(title: "Error", message: "Please check your internet connection", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        }
    }
    //
    func loadWeatherForecaseInfo() {
        apiManager.weatherForeCastInfo(completionHandler: { (url, response) in
            if let weatherData = response {
                self.weatherFullInfo = weatherData
                self.weatherList = (weatherData.list?.sorted(by: { (weather1: WeatherDetails, weather2: WeatherDetails) -> Bool in
                    let value =  weather1.dt! < weather2.dt!
                    return value
                }))!
                print(self.weatherList)
                self.weatherDetails = self.getWeatherList()
                if let weather = self.weatherDetails {
                    self.weatherDates = Array(weather.keys.sorted())
                }
                DispatchQueue.main.async() {
                    self.weatherTabelview.reloadData()
                }
            }
        }) { (error) in
            print(error?.localizedDescription ?? "")
        }
    }
    
    func navigateToMapVC(){
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }

    func  getWeatherList() -> [String: [WeatherDetails]]? {
        let dict = self.weatherList.reduce([String: [WeatherDetails]]()) { (key, value: WeatherDetails) -> [String: [WeatherDetails]] in
            var key = key
            if let first = value.dt_txt?.components(separatedBy: " ").first {
                var array = key[first]
                if array == nil {
                    array = []
                }
                array!.append(value)
                key[first] = array!
            }
            return key
        }
        
        print(dict.keys.sorted())
        print(dict)
        return dict
    }
    //Load custome cell
    func loadCustomeCell(cell: WeatherInfoTableViewCell, indexPath: IndexPath) {
        if let weatherInfo = self.weatherDetails,
            let title: String =  self.weatherDates?[indexPath.section],
            let weather: [WeatherDetails] = weatherInfo[title] {
            let weatherDetails = weather[indexPath.row]
            cell.weatherLabelTitle?.text = weatherDetails.dt_txt?.components(separatedBy: " ").last
            cell.tag = indexPath.row
            // Info parts
            var infoParts: [String] = []
            
            // Weather description
            if let weatherDescription = weatherDetails.weather?.first?.description?.capitalized {
                infoParts.append(weatherDescription)
            }
            
            // Temp
            if let temp = weatherDetails.main?.temp {
                infoParts.append("🌡 \(temp)°")
            }
            
            // Wind speed
            if let wind = weatherDetails.wind?.speed {
                infoParts.append("🌬 \(wind)m/s")
            }
            
            // Set labels
            cell.weatheLabelDetailsTitle?.text = infoParts.joined(separator: "   ")
            
            DispatchQueue.global(qos: .background).async {
                if let imgUri = weatherDetails.weather?.first?.icon {
                    self.imageCache.imageFor(uriString: imgUri) { (image, error) in
                        if error == nil {
                            DispatchQueue.main.async() {
                                if cell.tag == indexPath.row {
                                    cell.weatherIcon?.image = image
                                }
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    //MARK: Orientation
    
    override var shouldAutorotate: Bool {
        return true
    }
    //MARK: Show MAP View
    @objc func showInMapsTapped(){
        if LocationManager.sharedInstance.isLocationServicesEnabled(){
            self.navigateToMapVC()
        }else{
            let actionSheetController: UIAlertController = UIAlertController(title: "Location", message: "Please allow location services to continue", preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            actionSheetController.addAction(cancelAction)
            let action = UIAlertAction(title: "Settings", style: .default, handler: { (alert) in
                if let url = URL(string:UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        _ =  UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            })
            actionSheetController.addAction(action)
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let count = self.weatherDates?.count {
            return count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let weatherDates = weatherDates ,let weatherDetails = self.weatherDetails {
            if let weatherInfo = weatherDetails[weatherDates[section]]{
                return weatherInfo.count
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.weatherTabelview.dequeueReusableCell(withIdentifier: "WeatherTableviewCell", for: indexPath) as? WeatherInfoTableViewCell {
            loadCustomeCell(cell: cell, indexPath: indexPath)
            return cell
        }
       return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //var date = NSDate(timeIntervalSinceReferenceDate: 123)
        if let weatherDates = weatherDates ,let weatherDetails = self.weatherDetails {
            if let weatherInfo: WeatherDetails = weatherDetails[weatherDates[section]]?.first{
                return weatherInfo.weatherDateString
            }
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = .left
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    
}
