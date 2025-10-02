//
//  PlaceView.swift
//  geziRehberi-ios
//
//  Created by ALI CAN TOZLU on 2.10.2025.
//

import UIKit
import SafariServices

protocol PlaceViewDelegate: AnyObject {
    func placeView(_ placeView: PlaceView, didToggleFavorite place: Place)
}

class PlaceView: UIView {
    
    // MARK: - Properties
    private let titleLabel = UILabel()
    private let categoryBadge = UILabel()
    private let descriptionLabel = UILabel()
    private let durationLabel = UILabel()
    private let locationButton = UIButton(type: .system)
    private let favoriteButton = UIButton(type: .system)
    private let cardView = UIView()
    
    weak var delegate: PlaceViewDelegate?
    private var place: Place?
    
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
        
        // Setup title label
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.numberOfLines = 0
        cardView.addSubview(titleLabel)
        
        // Setup category badge
        categoryBadge.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        categoryBadge.textColor = .white
        categoryBadge.backgroundColor = .systemBlue
        categoryBadge.layer.cornerRadius = 8
        categoryBadge.clipsToBounds = true
        categoryBadge.textAlignment = .center
        cardView.addSubview(categoryBadge)
        
        // Setup description label
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .darkGray
        cardView.addSubview(descriptionLabel)
        
        // Setup duration label
        durationLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        durationLabel.textColor = .darkGray
        cardView.addSubview(durationLabel)
        
        // Setup location button
        locationButton.setTitle("Haritada Aç", for: .normal)
        locationButton.setImage(UIImage(systemName: "map"), for: .normal)
        locationButton.backgroundColor = .systemBlue
        locationButton.setTitleColor(.white, for: .normal)
        locationButton.tintColor = .white
        locationButton.layer.cornerRadius = 8
        locationButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        cardView.addSubview(locationButton)
        
        // Setup favorite button
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = .systemRed
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        cardView.addSubview(favoriteButton)
        
        // Setup constraints
        cardView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryBadge.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            categoryBadge.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            categoryBadge.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            categoryBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            categoryBadge.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: categoryBadge.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            durationLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            durationLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            
            locationButton.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 8),
            locationButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            locationButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            
            favoriteButton.centerYAnchor.constraint(equalTo: locationButton.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Configure View
    func configure(with place: Place, isFavorite: Bool = false) {
        self.place = place
        
        titleLabel.text = place.name
        categoryBadge.text = place.category.displayName
        descriptionLabel.text = place.shortDescription
        
        if let durationMinutes = place.suggestedDurationMin {
            let hours = durationMinutes / 60
            let minutes = durationMinutes % 60
            
            if hours > 0 {
                durationLabel.text = "Süre: \(hours) saat \(minutes) dk"
            } else {
                durationLabel.text = "Süre: \(minutes) dk"
            }
        } else {
            durationLabel.text = "Süre: -"
        }
        
        // Set favorite state
        if isFavorite {
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        // Set category colors
        switch place.category {
        case .history:
            categoryBadge.backgroundColor = .systemBrown
        case .museum:
            categoryBadge.backgroundColor = .systemIndigo
        case .nature:
            categoryBadge.backgroundColor = .systemGreen
        case .family:
            categoryBadge.backgroundColor = .systemOrange
        case .food:
            categoryBadge.backgroundColor = .systemPink
        case .free:
            categoryBadge.backgroundColor = .systemPurple
        case .other:
            categoryBadge.backgroundColor = .systemGray
        }
    }
    
    // MARK: - Actions
    @objc private func locationButtonTapped() {
        guard let mapUrlString = place?.mapUrl, let url = URL(string: mapUrlString) else {
            let googleMapsURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(place?.name ?? "")")
            if let url = googleMapsURL {
                openURL(url)
            }
            return
        }
        
        openURL(url)
    }
    
    @objc private func favoriteButtonTapped() {
        guard let place = place else { return }
        
        // Toggle favorite state
        let currentState = favoriteButton.image(for: .normal) == UIImage(systemName: "heart.fill")
        if currentState {
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        
        delegate?.placeView(self, didToggleFavorite: place)
    }
    
    private func openURL(_ url: URL) {
        if let topVC = UIApplication.shared.windows.first?.rootViewController {
            let safariVC = SFSafariViewController(url: url)
            topVC.present(safariVC, animated: true, completion: nil)
        }
    }
}