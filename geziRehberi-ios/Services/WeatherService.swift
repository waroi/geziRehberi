//
//  WeatherService.swift
//  geziRehberi-ios
//
//  Created by ALI CAN TOZLU on 2.10.2025.
//

import Foundation

class WeatherService {
    private let apiKey = ""
    private let baseURL = "https://dataservice.accuweather.com"
    
    enum WeatherError: Error {
        case invalidURL
        case noData
        case decodingError
        case serverError(Int)
        case unknown(String)
    }
    
    func searchLocation(query: String) async throws -> [LocationSearchResult] {
        let endpoint = "/locations/v1/cities/search"
        let urlString = "\(baseURL)\(endpoint)?apikey=\(apiKey)&q=\(query)&language=tr-tr"
        
        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURLString) else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.unknown("Invalid response")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw WeatherError.serverError(httpResponse.statusCode)
        }
        
        do {
            let locations = try JSONDecoder().decode([LocationSearchResult].self, from: data)
            return locations
        } catch {
            throw WeatherError.decodingError
        }
    }
    
    func getCurrentWeather(locationKey: String) async throws -> CurrentWeatherCondition {
        let endpoint = "/currentconditions/v1/\(locationKey)"
        let urlString = "\(baseURL)\(endpoint)?apikey=\(apiKey)&details=true&language=tr-tr"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.unknown("Invalid response")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw WeatherError.serverError(httpResponse.statusCode)
        }
        
        do {
            let weatherData = try JSONDecoder().decode([CurrentWeatherCondition].self, from: data)
            guard let currentWeather = weatherData.first else {
                throw WeatherError.noData
            }
            return currentWeather
        } catch {
            throw WeatherError.decodingError
        }
    }
}
