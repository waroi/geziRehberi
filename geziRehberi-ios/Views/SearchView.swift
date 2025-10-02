//
//  SearchView.swift
//  geziRehberi-ios
//
//  Created by ALI CAN TOZLU on 2.10.2025.
//

import UIKit

protocol SearchViewDelegate: AnyObject {
    func searchView(_ searchView: SearchView, didSearchForCity city: String)
}

class SearchView: UIView {
    
    // MARK: - Properties
    private let searchBar = UISearchBar()
    private let searchButton = UIButton(type: .system)
    weak var delegate: SearchViewDelegate?
    
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
        // Set view background to clear (transparent)
        backgroundColor = .clear
        
        // Setup search bar
        searchBar.placeholder = "Şehir adını giriniz..."
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage() // Remove default background
        searchBar.delegate = self
        
        // Make search bar background transparent
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.8)
            textField.layer.cornerRadius = 10
            textField.clipsToBounds = true
        }
        
        addSubview(searchBar)
        
        // Setup search button
        searchButton.setTitle("Ara", for: .normal)
        searchButton.backgroundColor = .systemBlue
        searchButton.setTitleColor(.white, for: .normal)
        searchButton.layer.cornerRadius = 8
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        addSubview(searchButton)
        
        // Setup constraints
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            searchButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            searchButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 120),
            searchButton.heightAnchor.constraint(equalToConstant: 40),
            searchButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Actions
    @objc private func searchButtonTapped() {
        guard let cityName = searchBar.text, !cityName.isEmpty else { return }
        delegate?.searchView(self, didSearchForCity: cityName)
    }
}

// MARK: - UISearchBarDelegate
extension SearchView: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let cityName = searchBar.text, !cityName.isEmpty else { return }
        delegate?.searchView(self, didSearchForCity: cityName)
        searchBar.resignFirstResponder()
    }
}
