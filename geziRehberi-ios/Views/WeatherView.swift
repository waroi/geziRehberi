//
//  WeatherView.swift
//  geziRehberi-ios
//
//  Created by ALI CAN TOZLU on 2.10.2025.
//

import UIKit

class WeatherView: UIView {
    
    // MARK: - Properties
    private let cityLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let weatherConditionLabel = UILabel()
    private let weatherIconView = UIImageView()
    private let humidityLabel = UILabel()
    private let windLabel = UILabel()
    private let cardView = UIView()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        // Setup card view
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        addSubview(cardView)
        
        // Setup city label
        cityLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        cityLabel.textAlignment = .center
        cardView.addSubview(cityLabel)
        
        // Setup temperature label
        temperatureLabel.font = UIFont.systemFont(ofSize: 42, weight: .medium)
        temperatureLabel.textAlignment = .center
        cardView.addSubview(temperatureLabel)
        
        // Setup weather icon
        weatherIconView.contentMode = .scaleAspectFit
        cardView.addSubview(weatherIconView)
        
        // Setup weather condition label
        weatherConditionLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        weatherConditionLabel.textAlignment = .center
        cardView.addSubview(weatherConditionLabel)
        
        // Setup humidity label
        humidityLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        humidityLabel.textAlignment = .center
        cardView.addSubview(humidityLabel)
        
        // Setup wind label
        windLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        windLabel.textAlignment = .center
        cardView.addSubview(windLabel)
        
        // Setup constraints
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherIconView.translatesAutoresizingMaskIntoConstraints = false
        weatherConditionLabel.translatesAutoresizingMaskIntoConstraints = false
        humidityLabel.translatesAutoresizingMaskIntoConstraints = false
        windLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            cityLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            cityLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cityLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            weatherIconView.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 8),
            weatherIconView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            weatherIconView.widthAnchor.constraint(equalToConstant: 80),
            weatherIconView.heightAnchor.constraint(equalToConstant: 80),
            
            temperatureLabel.topAnchor.constraint(equalTo: weatherIconView.bottomAnchor, constant: 8),
            temperatureLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            
            weatherConditionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 8),
            weatherConditionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            weatherConditionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            humidityLabel.topAnchor.constraint(equalTo: weatherConditionLabel.bottomAnchor, constant: 16),
            humidityLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            humidityLabel.trailingAnchor.constraint(equalTo: cardView.centerXAnchor, constant: -8),
            
            windLabel.topAnchor.constraint(equalTo: weatherConditionLabel.bottomAnchor, constant: 16),
            windLabel.leadingAnchor.constraint(equalTo: cardView.centerXAnchor, constant: 8),
            windLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            windLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configure View
    func configure(with weatherData: CurrentWeatherCondition, cityName: String) {
        cityLabel.text = cityName
        temperatureLabel.text = "\(Int(weatherData.Temperature.Metric.Value))°C"
        weatherConditionLabel.text = weatherData.WeatherText
        
        // Set humidity if available
        if let humidity = weatherData.RelativeHumidity {
            humidityLabel.text = "Nem: %\(humidity)"
        } else {
            humidityLabel.text = "Nem: -"
        }
        
        // Set wind if available
        if let windSpeed = weatherData.Wind?.Speed.Metric.Value {
            windLabel.text = "Rüzgar: \(Int(windSpeed)) \(weatherData.Wind!.Speed.Metric.Unit)"
        } else {
            windLabel.text = "Rüzgar: -"
        }
        
        // Set weather icon - in a real app, you would use a proper icon library
        // For now, we'll use SF Symbols based on the WeatherIcon code
        switch weatherData.WeatherIcon {
        case 1, 2, 3, 4, 30, 31, 32, 33, 34: // Sunny/Clear
            weatherIconView.image = UIImage(systemName: "sun.max.fill")
            weatherIconView.tintColor = .systemYellow
        case 5, 6, 7, 8, 35, 36, 37, 38: // Partially sunny/cloudy
            weatherIconView.image = UIImage(systemName: "cloud.sun.fill")
            weatherIconView.tintColor = .systemYellow
        case 11, 12, 13, 14, 19, 20, 21, 22, 23, 43, 44: // Cloudy/Overcast
            weatherIconView.image = UIImage(systemName: "cloud.fill")
            weatherIconView.tintColor = .systemGray
        case 15, 16, 17, 18, 41, 42: // Thunderstorms
            weatherIconView.image = UIImage(systemName: "cloud.bolt.fill")
            weatherIconView.tintColor = .systemGray
        case 24, 25, 26, 29: // Ice/Snow
            weatherIconView.image = UIImage(systemName: "snow")
            weatherIconView.tintColor = .systemBlue
        default: // Rain
            weatherIconView.image = UIImage(systemName: "cloud.rain.fill")
            weatherIconView.tintColor = .systemBlue
        }
    }
}