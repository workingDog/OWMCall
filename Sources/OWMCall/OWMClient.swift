//
//  OWMClient.swift
//  October1
//
//  Created by Ringo Wathelet on 2022/10/01.
//

import Foundation


/*
 * represents an error during a connection
 */
public enum APIError: Swift.Error, LocalizedError {
    
    case unknown, apiError(reason: String), parserError(reason: String), networkError(from: URLError)
    
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(let reason), .parserError(let reason):
            return reason
        case .networkError(let from):
            return from.localizedDescription
        }
    }
}

/*
 * a network connection to openweather Current weather data API server
 * info at: https://openweathermap.org/api/weather
 */
public class OWMClient {
    
    let apiKey: String
    let sessionManager: URLSession
    
    let mediaType = "application/json; charset=utf-8"
    var weatherCallURL = "https://api.openweathermap.org/data/2.5/weather"

    public init(apiKey: String, urlString: String) {
        self.weatherCallURL = urlString
        self.apiKey = "appid=" + apiKey
        self.sessionManager = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30  // seconds
            configuration.timeoutIntervalForResource = 30 // seconds
            return URLSession(configuration: configuration)
        }()
    }

    /*
     * fetch data from the server. A GET request with the chosen parameters is sent to the server.
     * The server response is parsed then converted to an object, typically OWMResponse.
     *
     * @param parameters
     * @return a T
     */
    public func fetchThisAsync<T: Decodable>(param: String, options: OWMOptionsProtocol) async throws -> T {

        guard let url = URL(string: "\(weatherCallURL)?\(param)\(options.toParamString())&\(apiKey)") else {
            throw APIError.apiError(reason: "bad URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(mediaType, forHTTPHeaderField: "Accept")
        request.addValue(mediaType, forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            if (httpResponse.statusCode == 401) {
                throw APIError.apiError(reason: "Unauthorized")
            }
            if (httpResponse.statusCode == 403) {
                throw APIError.apiError(reason: "Resource forbidden")
            }
            if (httpResponse.statusCode == 404) {
                throw APIError.apiError(reason: "Resource not found")
            }
            if (405..<500 ~= httpResponse.statusCode) {
                throw APIError.apiError(reason: "client error")
            }
            if (500..<600 ~= httpResponse.statusCode) {
                throw APIError.apiError(reason: "server error")
            }
            if (httpResponse.statusCode != 200) {
                throw APIError.networkError(from: URLError(.badServerResponse))
            }
            let results = try JSONDecoder().decode(T.self, from: data)
            return results
        }
        catch {
            throw APIError.parserError(reason: "json error")
        }
    }
 
}
