//
//  OWMClient.swift
//  OWMCall
//
//  Created by Ringo Wathelet on 2022/10/01.
//

import Foundation


/*
 * error during a connection
 */
public enum APIError: Swift.Error, LocalizedError {
    
    case unknown, apiError(reason: String), parserError(reason: String), networkError(from: URLError)
    
    public var errorDescription: String? {
        return switch self {
            case .unknown:  "Unknown error"
            case .apiError(let reason), .parserError(let reason): reason
            case .networkError(let from): from.localizedDescription
        }
    }
}

/*
 * a network connection to openweather Current weather data API server
 * info at: https://openweathermap.org/api/weather
 */
public class OWMClient {
    
    public let sessionManager: URLSession
    public let acceptType: String
    public let contentType: String
    public let userAgent: String
    
    private let apiKey: String
    public let baseURL: URL


    public init(apiKey: String, baseURL: URL = URL(string: "https://api.openweathermap.org/data/2.5/weather")!) {
        self.apiKey = apiKey
        self.baseURL = baseURL

        self.acceptType = "application/json; charset=utf-8"
        self.contentType = "application/json; charset=utf-8"
        self.userAgent = "OWMCall"

        self.sessionManager = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30  // seconds
            configuration.timeoutIntervalForResource = 30 // seconds
            return URLSession(configuration: configuration)
        }()
    }
    
    /*
     * fetch data from the server. A GET request with the chosen parameters is sent to the server.
     * The server response is returned as Data.
     *
     * @components the URLComponents
     * @options OWMOptions
     * @return Data
     */
    public func fetchThisAsync(components: URLComponents, options: OWMOptions) async throws -> Data {
        
        guard let _ = components.url else {
            throw APIError.apiError(reason: "Unable to create URL components")
        }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue(acceptType, forHTTPHeaderField: "Accept")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
  //      print("\n---> url: \(components.url!.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
  //          print("---> data: \(String(data: data, encoding: .utf8) as AnyObject)")
            
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
            
            return data
        }
        catch let error as APIError {
            throw APIError.apiError(reason: error.localizedDescription)
        }
        catch {
            throw APIError.unknown
        }
    }
    
    /*
     * fetch data from the server. A GET request with the chosen parameters is sent to the server.
     * The server response is parsed then converted to an object, typically OWMResponse.
     *
     * @param parameters
     * @options OWMOptions
     * @return a T
     */
    public func fetchThisAsync<T: Decodable>(lat: Double, lon: Double, options: OWMOptions) async throws -> T {

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!

        var queryItems: [URLQueryItem] = options.toQueryItems()
        queryItems.append(name: "appid", value: apiKey)
        queryItems.append(name: "lat", value: lat)
        queryItems.append(name: "lon", value: lon)

        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        
        do {
            let data = try await fetchThisAsync(components: components, options: options)
            
            return try JSONDecoder().decode(T.self, from: data)
        }
        catch {
            throw APIError.apiError(reason: error.localizedDescription)
        }
    }
    
    /// Note this is deprecated, should use the Geocoding API instead
    public func fetchThisAsync<T: Decodable>(query: String, options: OWMOptions) async throws -> T {

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!

        var queryItems: [URLQueryItem] = options.toQueryItems()
        queryItems.append(name: "appid", value: apiKey)
        queryItems.append(name: "q", value: query)

        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        
        do {
            let data = try await fetchThisAsync(components: components, options: options)
            
            return try JSONDecoder().decode(T.self, from: data)
        }
        catch {
            throw APIError.apiError(reason: error.localizedDescription)
        }
    }
 
}
