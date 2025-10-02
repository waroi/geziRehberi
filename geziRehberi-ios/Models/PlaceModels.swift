//
//  PlaceModels.swift
//  geziRehberi-ios
//
//  Created by ALI CAN TOZLU on 2.10.2025.
//

import Foundation

struct PlaceResponse: Codable {
    let city: String
    let locale: String
    let items: [Place]
}

struct Place: Codable {
    let id: String
    let name: String
    let category: Category
    let shortDescription: String
    let suggestedDurationMin: Int?
    let isOutdoor: Bool?
    let neighborhood: String?
    let mapUrl: String?
    
    enum Category: String, Codable, CaseIterable {
        case history
        case museum
        case nature
        case family
        case food
        case free
        case other
        
        var displayName: String {
            switch self {
            case .history: return "Tarihi"
            case .museum: return "Müze"
            case .nature: return "Doğa"
            case .family: return "Aile"
            case .food: return "Gastronomi"
            case .free: return "Ücretsiz"
            case .other: return "Diğer"
            }
        }
        
        var iconName: String {
            switch self {
            case .history: return "building.columns"
            case .museum: return "building.2"
            case .nature: return "leaf"
            case .family: return "figure.2.and.child.holdinghands"
            case .food: return "fork.knife"
            case .free: return "gift"
            case .other: return "mappin"
            }
        }
    }
}