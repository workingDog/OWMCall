//
//  OWMOptions.swift
//  OWMCall
//
//  Created by Ringo Wathelet on 2022/10/01.
//

import Foundation


/// convenience
extension Array where Element == URLQueryItem {
    
    mutating func append<T>(name: String, value: T?) {
        guard let value else { return }
        append(URLQueryItem(name: name, value: String(describing: value)))
    }
    
}

/*
 * parameters for units, Standard (Kelvin), metric (Celsius), or imperial (Fahrenheit) units
 */
public enum Units: String {
    case metric
    case imperial
    case standard
}

/*
 * Options to use for retrieving current weather data
 */
public class OWMOptions {
    
    private var units: Units?
    private var lang: String?
    
    public init(units: Units, lang: String) {
        self.units = units
        self.lang = lang
    }
 
    public init() { }
    
    public func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        if let units {
            items.append(name: "units", value: units.rawValue)
        }
        if let lang {
            items.append(name: "lang", value: lang)
        }
       
        return items
    }
    
    public static func metric(lang: String = Locale.current.language.languageCode?.identifier ?? "en") -> OWMOptions {
        return OWMOptions(units: .metric, lang: lang)
    }

}
