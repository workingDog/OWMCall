//
//  OWMOptions.swift
//  October1
//
//  Created by Ringo Wathelet on 2022/10/01.
//

import Foundation

/*
 * parameters for units, Standard (Kelvin), metric (Celsius), or imperial (Fahrenheit) units
 */
public enum Units: String {
    case metric
    case imperial
    case standard
}

public protocol OWMOptionsProtocol {
    func toParamString() -> String
}

/*
 * Options to use for retrieving current weather data
 */
public class OWMOptions: OWMOptionsProtocol {
    private var units: Units?
    private var lang: String?
    
    public init(units: Units, lang: String) {
        self.units = units
        self.lang = lang
    }
 
    public init() { }
    
    public func toParamString() -> String {
        var stringer = ""
        if let wunits = units {
            stringer += "&units=" + wunits.rawValue
        }
        if let wlang = lang {
            stringer += "&lang=" + wlang
        }
        return stringer
    }
    
    public static func metric(lang: String = Locale.current.language.languageCode?.identifier ?? "en") -> OWMOptions {
        return OWMOptions(units: .metric, lang: lang)
    }

}
