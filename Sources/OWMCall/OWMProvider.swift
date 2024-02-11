//
//  OWMProvider.swift
//  October1
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

    public init(apiKey: String) {
        self.client = OWMClient(apiKey: apiKey)
    }
    
    /// get the weather at the given location with the given options, results pass back through the weather binding
    open func getWeather(lat: Double, lon: Double, weather: Binding<OWMResponse>, options: OWMOptionsProtocol = OWMOptions.metric()) {
        getWeather(lat: lat, lon: lon, options: options) { results in
            if let results {
                weather.wrappedValue = results
            }
        }
    }

    /// get the weather at the given location with the given options, with async
    open func getWeather(lat: Double, lon: Double, options: OWMOptionsProtocol = OWMOptions.metric()) async -> OWMResponse? {
        do {
            let results: OWMResponse = try await client.fetchThisAsync(param: "lat=\(lat)&lon=\(lon)", options: options)
            return results
        } catch {
            return nil
        }
    }
    
    /// get the weather at the given location with the given options, with completion handler
    open func getWeather(lat: Double, lon: Double, options: OWMOptionsProtocol = OWMOptions.metric(), completion: @escaping (OWMResponse?) -> Void) {
        Task {
            let results: OWMResponse? = await getWeather(lat: lat, lon: lon, options: options)
            completion(results)
        }
    }
    
}
