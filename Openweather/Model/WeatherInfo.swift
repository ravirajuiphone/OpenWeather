//
//  WeatherInfo.swift
//  Openweather
//
//  Created by Raviraju Vysyaraju on 22/03/2018.
//  Copyright © 2018 Raviraju Vysyaraju. All rights reserved.
//

import Foundation
struct WeatherFullInfo: Decodable {
    let list:[WeatherDetails]?
    let cnt: Int?
    let message: Double?
    let cod: String?
    let city: City?
}

struct City: Decodable {
    let name: String?
    let coord: CityCoord?
    let country: String?
}

struct CityCoord: Decodable {
    let lon: Double?
    let lat: Double?
    
}

struct WeatherDetails: Decodable {
    let dt: TimeInterval?
    let main: WeatherTemp?
    let weather: [WeatherInfo]?
    let clouds: CloudInfo?
    let wind: Wind?
    let rain: Rain?
    let sys: Sys?
    let dt_txt: String?
}

struct WeatherTemp: Decodable {
    let temp: Double?
    let temp_min: Double?
    let temp_max: Double?
    let pressure: Double?
    let sea_level: Double?
    let grnd_level: Double?
    let humidity: Double?
    let temp_kf: Double?
}

struct WeatherInfo: Decodable {
    let id: Int?
    let main: String?
    let description: String?
    let icon: String?
}

struct CloudInfo: Decodable {
    let all: Int?
}

struct Wind: Decodable {
    let speed: Double?
    let deg: Double?
}
struct Rain: Decodable {
}
struct Sys: Decodable {
    let pod: String?
}

extension WeatherDetails {
    var weatherDate: Date? {
        guard let timeInterval = self.dt, let date: Date = Date(timeIntervalSince1970: timeInterval) else {
            return Date()
        }
        return date

    }
    var weatherDateString: String {
        let date = self.weatherDate
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let dateString: String = dateFormatter.string(from: date!) else {
            return ""
        }
        return dateString
    }
    
    var weakName: String {
        let dateFormatter = DateFormatter()
        return dateFormatter.weekdaySymbols[Calendar.current.component(.weekday, from: weatherDate!)]
    }
    
}

