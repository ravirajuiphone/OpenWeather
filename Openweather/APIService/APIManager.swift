//
//  APIManager.swift
//
//  Created by Rakesh Tatekonda on 11/08/17.
//

import UIKit
import MobileCoreServices

let uriString = "http://samples.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&appid=b6907d289e10d714a6e88b30761fae22"
let urlStringdummy = "http://samples.openweathermap.org/data/2.5/forecast?q=London,usl&appid=b6907d289e10d714a6e88b30761fae22"
class APIManager: NSObject {
    static let shared = APIManager()
    private var session: URLSession!
    private override init() {
        session = URLSession.shared
    }
    
    func getAPIBaseUrl() -> String{
        guard let lat = LocationManager.sharedInstance.lastKnownLocation?.longitude, let long = LocationManager.sharedInstance.lastKnownLocation?.longitude  else {
            return urlStringdummy
        }
       return  String(format: uriString,lat,long)
    }
    
    func weatherForeCastInfo(completionHandler:  @escaping (URL?, WeatherFullInfo?) -> Swift.Void,
                             compltionFailedHandler: @escaping (Error?) -> Swift.Void) {
        guard let url = URL(string:getAPIBaseUrl()) else {
            return
        }
        let task = session.dataTask(with: url) { (data, response, error) in
            //let jsonString = String(data: data!, encoding: .utf8)
            if error == nil {
                let jsonDecoder = JSONDecoder()
                let weatherData = try! jsonDecoder.decode(WeatherFullInfo.self, from: data!)
                if let cod: String = weatherData.cod {
                    print(cod)
                }
                completionHandler(url, weatherData)
            } else {
                compltionFailedHandler(error)
            }
            
        }
        task.resume()
    }
    
}
