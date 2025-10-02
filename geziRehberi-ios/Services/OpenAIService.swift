//
//  OpenAIService.swift
//  geziRehberi-ios
//
//  Created by ALI CAN TOZLU on 2.10.2025.
//

import Foundation

class OpenAIService {
    private let apiKey = ""
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    enum OpenAIError: Error {
        case invalidURL
        case noData
        case decodingError
        case serverError(Int)
        case unknown(String)
    }
    
    struct OpenAIRequest: Codable {
        let model: String
        let messages: [Message]
        let temperature: Double
        let response_format: ResponseFormat
        
        struct Message: Codable {
            let role: String
            let content: String
        }
        
        struct ResponseFormat: Codable {
            let type: String
        }
    }
    
    struct OpenAIResponse: Codable {
        let choices: [Choice]
        
        struct Choice: Codable {
            let message: Message
            
            struct Message: Codable {
                let content: String
            }
        }
    }
    
    func getPlaces(city: String, weatherSummary: String, temperatureC: Double) async throws -> PlaceResponse {
        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }
        
        // System prompt design
        let systemPrompt = "Kıdemli bir gezi planlayıcısısın. Kullanıcının girdiği şehir ve hava durumuna göre gezilecek yerler listesi üret. Çıktıyı JSON olarak ver. Detaylı ama öz, güncel genel bilgiler ver; adres/telefon gibi hızla bayatlayan veriler verme. \"mapUrl\" alanına genel bir Google Maps araması koyabilirsin."
        
        // User prompt
        let userPrompt = """
        Şehir: \(city)
        Dil: tr
        Hava özeti: \(weatherSummary), \(temperatureC)°C
        Kısıtlar: Aile dostu seçenekleri önceliklendir, kapalı alan/yağmur alternatifi ekle, bütçe dostu en az 2 seçenek olsun.
        Lütfen şu JSON şemasına UYGUN DÖN:
        {
          "city": string,
          "locale": "tr",
          "items": [
            {
              "id": string,
              "name": string,
              "category": "history"|"museum"|"nature"|"family"|"food"|"free"|"other",
              "shortDescription": string,
              "suggestedDurationMin": number,
              "isOutdoor": boolean,
              "neighborhood": string,
              "mapUrl": string
            }
          ]
        }
        Sadece JSON döndür.
        """
        
        let openAIRequest = OpenAIRequest(
            model: "gpt-4o-mini",
            messages: [
                OpenAIRequest.Message(role: "system", content: systemPrompt),
                OpenAIRequest.Message(role: "user", content: userPrompt)
            ],
            temperature: 0.7,
            response_format: OpenAIRequest.ResponseFormat(type: "json_object")
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(openAIRequest)
            request.httpBody = jsonData
        } catch {
            throw OpenAIError.unknown("Failed to encode request")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.unknown("Invalid response")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw OpenAIError.serverError(httpResponse.statusCode)
        }
        
        do {
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            guard let content = openAIResponse.choices.first?.message.content,
                  let jsonData = content.data(using: .utf8) else {
                throw OpenAIError.noData
            }
            
            let placesResponse = try JSONDecoder().decode(PlaceResponse.self, from: jsonData)
            return placesResponse
        } catch {
            throw OpenAIError.decodingError
        }
    }
}
