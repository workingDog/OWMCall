//
//  OWMProvider.swift
//  OWMCall
//
//  Created by Ringo Wathelet on 2022/10/01.
//


import Foundation
import SwiftUI

/**
 * provide access to the OpenWeather Current API Call data using a single function call
 */
open class OWMProvider {
    
    public let client: OWMClient
    
    /// default endpoint, Current Weather API 2.5
    public init(apiKey: String, baseURL: URL = URL(string: "https://api.openweathermap.org/data/2.5/weather")!) {
        self.client = OWMClient(apiKey: apiKey, baseURL: baseURL)
    }
    
    /// get the weather at the given location with the given options, results pass back through the weather binding
    open func getWeather(lat: Double, lon: Double, weather: Binding<OWMResponse>, options: OWMOptions) async {
        let results: OWMResponse? = await getWeather(lat: lat, lon: lon, options: options)
        if let results {
            weather.wrappedValue = results
        }
    }
    
    /// get the weather at the given location with the given options, with async
    open func getWeather(lat: Double, lon: Double, options: OWMOptions) async -> OWMResponse? {
        do {
            let results: OWMResponse = try await client.fetchThisAsync(lat: lat, lon: lon, options: options)
            
            return results
        } catch {
            print(error)
            return nil
        }
    }
    
}
