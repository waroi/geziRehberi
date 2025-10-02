//
//  WeatherModels.swift
//  geziRehberi-ios
//
//  Created by ALI CAN TOZLU on 2.10.2025.
//

import Foundation

struct LocationSearchResult: Codable {
    let Key: String
    let LocalizedName: String
    let Country: CountryInfo
    
    struct CountryInfo: Codable {
        let LocalizedName: String
    }
}

struct CurrentWeatherCondition: Codable {
    let WeatherText: String
    let WeatherIcon: Int
    let Temperature: TemperatureInfo
    let RelativeHumidity: Int?
    let Wind: WindInfo?
    
    struct TemperatureInfo: Codable {
        let Metric: MetricValue
        
        struct MetricValue: Codable {
            let Value: Double
            let Unit: String
        }
    }
    
    struct WindInfo: Codable {
        let Speed: SpeedInfo
        
        struct SpeedInfo: Codable {
            let Metric: MetricValue
            
            struct MetricValue: Codable {
                let Value: Double
                let Unit: String
            }
        }
    }
}