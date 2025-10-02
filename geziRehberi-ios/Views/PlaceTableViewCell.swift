//
//  PlaceTableViewCell.swift
//  geziRehberi-ios
//
//  Created by ALI CAN TOZLU on 2.10.2025.
//

import UIKit
import SafariServices

protocol PlaceTableViewCellDelegate: AnyObject {
    func placeCell(_ cell: PlaceTableViewCell, didToggleFavorite place: Place)
}

class PlaceTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let categoryIconView = UIImageView()
    private let categoryBadgeView = UIView()
    private let categoryLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let durationView = UIView()
    private let durationIconView = UIImageView()
    private let durationLabel = UILabel()
    private let locationButton = UIButton(type: .system)
    private let favoriteButton = UIButton(type: .system)
    
    // MARK: - Properties
    weak var delegate: PlaceTableViewCellDelegate?
    private var place: Place?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        descriptionLabel.text = nil
        durationLabel.text = nil
        categoryLabel.text = nil
        categoryIconView.image = nil
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Setup container view with card-like appearance
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        contentView.addSubview(containerView)
        
        // Setup category badge view
        categoryBadgeView.layer.cornerRadius = 12
        categoryBadgeView.clipsToBounds = true
        containerView.addSubview(categoryBadgeView)
        
        // Setup category icon view
        categoryIconView.contentMode = .scaleAspectFit
        categoryIconView.tintColor = .white
        categoryBadgeView.addSubview(categoryIconView)
        
        // Setup category label
        categoryLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        categoryLabel.textColor = .white
        categoryLabel.textAlignment = .center
        categoryBadgeView.addSubview(categoryLabel)
        
        // Setup title label
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        containerView.addSubview(titleLabel)
        
        // Setup description label
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        containerView.addSubview(descriptionLabel)
        
        // Setup duration view
        durationView.backgroundColor = .systemGray6
        durationView.layer.cornerRadius = 8
        containerView.addSubview(durationView)
        
        // Setup duration icon
        durationIconView.image = UIImage(systemName: "clock.fill")
        durationIconView.contentMode = .scaleAspectFit
        durationIconView.tintColor = .systemGray
        durationView.addSubview(durationIconView)
        
        // Setup duration label
        durationLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        durationLabel.textColor = .systemGray
        durationView.addSubview(durationLabel)
        
        // Setup location button
        locationButton.setTitle("Haritada Aç", for: .normal)
        locationButton.setImage(UIImage(systemName: "map.fill"), for: .normal)
        locationButton.backgroundColor = .systemBlue
        locationButton.tintColor = .white
        locationButton.setTitleColor(.white, for: .normal)
        locationButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        locationButton.layer.cornerRadius = 12
        locationButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        containerView.addSubview(locationButton)
        
        // Setup favorite button
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = .systemRed
        favoriteButton.backgroundColor = .systemGray6
        favoriteButton.layer.cornerRadius = 20
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        containerView.addSubview(favoriteButton)
        
        // Setup constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        categoryBadgeView.translatesAutoresizingMaskIntoConstraints = false
        categoryIconView.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        durationView.translatesAutoresizingMaskIntoConstraints = false
        durationIconView.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Category badge view
            categoryBadgeView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            categoryBadgeView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            categoryBadgeView.heightAnchor.constraint(equalToConstant: 24),
            
            // Category icon view
            categoryIconView.leadingAnchor.constraint(equalTo: categoryBadgeView.leadingAnchor, constant: 8),
            categoryIconView.centerYAnchor.constraint(equalTo: categoryBadgeView.centerYAnchor),
            categoryIconView.widthAnchor.constraint(equalToConstant: 16),
            categoryIconView.heightAnchor.constraint(equalToConstant: 16),
            
            // Category label
            categoryLabel.leadingAnchor.constraint(equalTo: categoryIconView.trailingAnchor, constant: 4),
            categoryLabel.trailingAnchor.constraint(equalTo: categoryBadgeView.trailingAnchor, constant: -8),
            categoryLabel.centerYAnchor.constraint(equalTo: categoryBadgeView.centerYAnchor),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: categoryBadgeView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Description label
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Duration view
            durationView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            durationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            durationView.heightAnchor.constraint(equalToConstant: 24),
            
            // Duration icon
            durationIconView.leadingAnchor.constraint(equalTo: durationView.leadingAnchor, constant: 8),
            durationIconView.centerYAnchor.constraint(equalTo: durationView.centerYAnchor),
            durationIconView.widthAnchor.constraint(equalToConstant: 12),
            durationIconView.heightAnchor.constraint(equalToConstant: 12),
            
            // Duration label
            durationLabel.leadingAnchor.constraint(equalTo: durationIconView.trailingAnchor, constant: 4),
            durationLabel.trailingAnchor.constraint(equalTo: durationView.trailingAnchor, constant: -8),
            durationLabel.centerYAnchor.constraint(equalTo: durationView.centerYAnchor),
            
            // Location button
            locationButton.topAnchor.constraint(equalTo: durationView.bottomAnchor, constant: 16),
            locationButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            locationButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            locationButton.widthAnchor.constraint(equalToConstant: 130),
            locationButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Favorite button
            favoriteButton.centerYAnchor.constraint(equalTo: locationButton.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 40),
            favoriteButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Configuration
    func configure(with place: Place, isFavorite: Bool = false) {
        self.place = place
        
        titleLabel.text = place.name
        descriptionLabel.text = place.shortDescription
        categoryLabel.text = place.category.displayName
        categoryIconView.image = UIImage(systemName: place.category.iconName)
        
        // Set duration
        if let durationMinutes = place.suggestedDurationMin {
            let hours = durationMinutes / 60
            let minutes = durationMinutes % 60
            
            if hours > 0 {
                durationLabel.text = "\(hours) saat \(minutes) dk"
            } else {
                durationLabel.text = "\(minutes) dk"
            }
        } else {
            durationLabel.text = "Belirtilmemiş"
        }
        
        // Set favorite state
        if isFavorite {
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        // Set category badge colors and expand width based on content
        switch place.category {
        case .history:
            categoryBadgeView.backgroundColor = .systemBrown
        case .museum:
            categoryBadgeView.backgroundColor = .systemIndigo
        case .nature:
            categoryBadgeView.backgroundColor = .systemGreen
        case .family:
            categoryBadgeView.backgroundColor = .systemOrange
        case .food:
            categoryBadgeView.backgroundColor = .systemPink
        case .free:
            categoryBadgeView.backgroundColor = .systemPurple
        case .other:
            categoryBadgeView.backgroundColor = .systemGray
        }
    }
    
    // MARK: - Actions
    @objc private func locationButtonTapped() {
        guard let place = place else { return }
        
        guard let mapUrlString = place.mapUrl, let url = URL(string: mapUrlString) else {
            let encodedQuery = place.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? place.name
            let googleMapsURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(encodedQuery)")
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
        
        delegate?.placeCell(self, didToggleFavorite: place)
    }
    
    private func openURL(_ url: URL) {
        if let topVC = UIApplication.shared.windows.first?.rootViewController {
            let safariVC = SFSafariViewController(url: url)
            topVC.present(safariVC, animated: true, completion: nil)
        }
    }
}