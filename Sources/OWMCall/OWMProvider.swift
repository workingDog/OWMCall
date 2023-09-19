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
    open func getWeather(lat: Double, lon: Double, weather: Binding<OWMResponse>, options: OWMOptionsProtocol) {
        
        @Sendable
        func updateWith(_ results: OWMResponse) {
            weather.wrappedValue = results
        }
        
        Task { @MainActor in
            if let results: OWMResponse = await getWeather(lat: lat, lon: lon, options: options) {
              //  weather.wrappedValue = results
                updateWith(results)
            }
        }
    }

    /// get the weather at the given location with the given options, with async
    open func getWeather(lat: Double, lon: Double, options: OWMOptionsProtocol) async -> OWMResponse? {
        do {
            let results: OWMResponse = try await client.fetchThisAsync(param: "lat=\(lat)&lon=\(lon)", options: options)
            return results
        } catch {
            return nil
        }
    }
    
    /// get the weather at the given location with the given options, with completion handler
    open func getWeather(lat: Double, lon: Double, options: OWMOptionsProtocol, completion: @escaping (OWMResponse?) -> Void) {
        Task {
            let results: OWMResponse? = await getWeather(lat: lat, lon: lon, options: options)
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
    
}
