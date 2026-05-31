//
//  OWMResponse.swift
//  OWMCall
//
//  Created by Ringo Wathelet on 2022/10/01.
//

import Foundation

// info from: https://openweathermap.org/current

// MARK: - OWMResponse
public struct OWMResponse: Identifiable, Decodable, Sendable {
    public let coord: Coord
    public let weather: [Weather]?
    public let base: String
    public let main: Main?
    public let visibility: Int
    public let wind: Wind?
    public let rain: Rain?
    public let snow: Snow?
    public let clouds: Clouds?
    public let dt: Int
    public let sys: Sys?
    public let timezone, cod: Int
    public let name: String
    public let id: Int
    
    
    public init(lat: Double = 0.0, lon: Double = 0.0,
                timezone: Int = 0, weather: [Weather]? = nil,
                base: String = "", main: Main? = nil, visibility: Int = 0,
                wind: Wind? = nil, rain: Rain? = nil, snow: Snow? = nil,
                clouds: Clouds? = nil, dt: Int = 0,
                sys: Sys? = nil, id: Int = 0, name: String = "", cod: Int = 0) {
        
        self.coord = Coord(lon: lon, lat: lat)
        self.timezone = timezone
        self.weather = weather
        self.base = base
        self.main = main
        self.visibility = visibility
        self.wind = wind
        self.clouds = clouds
        self.dt = dt
        self.sys = sys
        self.id = id
        self.name = name
        self.cod = cod
        self.rain = rain
        self.snow = snow
    }
    
    public func weatherInfo() -> String {
        if let info = weather?.first {
            return info.weatherDescription
        } else {
            return "no info"
        }
    }
    
    /// return `dt` as a Date
    public func getDate() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(dt))
    }
   
}

// MARK: - Clouds
public struct Clouds: Decodable, Sendable {
    public let all: Int
    
    public init() {
        self.all = 0
    }
}

// MARK: - Coord
public struct Coord: Decodable, Sendable {
    public let lon, lat: Double
    
    public init(lon: Double = 0.0, lat: Double = 0.0) {
        self.lon = lon
        self.lat = lat
    }
}

// MARK: - Main
public struct Main: Decodable, Sendable {
    public let temp, feelsLike, tempMin, tempMax: Double
    public let pressure, humidity: Int?
    public let seaLevel, grndLevel: Int?
    
    public init() {
        self.temp = 0.0
        self.feelsLike = 0.0
        self.tempMin = 0.0
        self.tempMax = 0.0
        self.pressure = 0
        self.humidity = 0
        self.seaLevel = 0
        self.grndLevel = 0
    }

    enum CodingKeys: String, CodingKey {
        case temp, pressure, humidity
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

// MARK: - Sys
public struct Sys: Decodable, Sendable {
    public let type, id: Int
    public let country: String
    public let sunrise, sunset: Int
    
    public init() {
        self.type = 0
        self.id = 0
        self.country = ""
        self.sunrise = 0
        self.sunset = 0
    }
}

// MARK: - Weather
public struct Weather: Identifiable, Decodable, Sendable {
    public let id: Int
    public let main, weatherDescription, icon: String
    
    public init() {
        self.id = 0
        self.main = ""
        self.weatherDescription = ""
        self.icon = ""
    }
    
    /// the SFSymbol name to use as the default icon name
    public static let defaultIcon = "questionmark"
    
    enum CodingKeys: String, CodingKey {
        case id, main, icon
        case weatherDescription = "description"
    }
    
    /// return the equivalent SFSymbol name from the weather condition `id` number
    public var iconNameFromId: String {
        return switch id {
            case 200...232: "cloud.bolt.rain"
            case 300...301: "cloud.rain"
            case 500...504: "cloud.heavyrain"
            case 511: "cloud.snow"
            case 520...531: "cloud.rain"
            case 600...622: "cloud.snow"
            case 701...781: "cloud.fog"
            case 800: "sun.max"
            case 801: "cloud.sun"
            case 802...804: "cloud"
            default: Weather.defaultIcon
        }
    }
    
    /// return the equivalent SFSymbol name from the `icon` name
    public var iconSymbolName: String {
        return switch icon {
            case "01d","01n": "sun.max"
            case "02d","02n": "cloud.sun"
            case "03d","03n": "cloud"
            case "04d","04n": "cloud"
            case "09d","09n": "cloud.rain"
            case "10d","10n": "cloud.heavyrain"
            case "11d","11n": "cloud.bolt.rain"
            case "13d","13n": "cloud.snow"
            case "50d","50n": "cloud.fog"
            default: Weather.defaultIcon
        }
    }

}

// MARK: - Wind
public struct Wind: Decodable, Sendable {
    public let speed: Double?
    public let deg: Int?
    public let gust: Double?
    
    public init() {
        self.speed = 0.0
        self.deg = 0
        self.gust = 0.0
    }
    
}

// MARK: - Rain
public struct Rain: Decodable, Sendable {
    public let the1H: Double?
    public let the3H: Double?
    
    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
        case the3H = "3h"
    }
    
    // for the case where we have:  "rain": { }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let theRain = try? values.decode(Rain.self, forKey: .the1H) {
            self.the1H = theRain.the1H
        } else {
            self.the1H = nil
        }
        if let theRain = try? values.decode(Rain.self, forKey: .the3H) {
            self.the3H = theRain.the3H
        } else {
            self.the3H = nil
        }
    }
     
}

// MARK: - Snow
public struct Snow: Decodable, Sendable {
    public let the1H: Double?
    public let the3H: Double?
    
    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
        case the3H = "3h"
    }

    // for the case where we have:  "snow": { }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let theSnow = try? values.decode(Snow.self, forKey: .the1H) {
            self.the1H = theSnow.the1H
        } else {
            self.the1H = nil
        }
        if let theSnow = try? values.decode(Snow.self, forKey: .the3H) {
            self.the3H = theSnow.the3H
        } else {
            self.the3H = nil
        }
    }

}
