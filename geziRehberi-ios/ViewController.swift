//
//  ViewController.swift
//  geziRehberi-ios
//
//  Created by ALI CAN TOZLU on 2.10.2025.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - UI Components
    private let mainScrollView = UIScrollView()
    private let mainContentView = UIView()
    private let searchView = SearchView()
    private let weatherView = WeatherView()
    private let placesTableView = UITableView()
    private let loadingOverlayView = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let errorLabel = UILabel()

    // MARK: - Services
    private let weatherService = WeatherService()
    private let openAIService = OpenAIService()

    // MARK: - Properties
    private var currentCity: String?
    private var favorites: [String: Bool] = [:] // Dictionary to store favorite places
    private var places: [Place] = []

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }

    // MARK: - UI Setup
    private func setupUI() {
        setupNavigationBar()
        setupMainScrollView()
        setupLoadingOverlay()
        setupErrorLabel()
    }

    private func setupNavigationBar() {
        title = "Gezi Rehberi"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        // Set the appearance of the navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear // Removes the bottom line

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func setupMainScrollView() {
        view.backgroundColor = .systemGroupedBackground

        // Add main scroll view
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.alwaysBounceVertical = true
        view.addSubview(mainScrollView)

        // Add content view to scroll view
        mainScrollView.addSubview(mainContentView)

        // Add search view to content view
        searchView.delegate = self
        searchView.layer.cornerRadius = 12
        searchView.clipsToBounds = true
        searchView.layer.shadowColor = UIColor.black.cgColor
        searchView.layer.shadowOpacity = 0.1
        searchView.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchView.layer.shadowRadius = 4
        mainContentView.addSubview(searchView)

        // Add weather view to content view
        weatherView.isHidden = true
        weatherView.layer.cornerRadius = 16
        weatherView.clipsToBounds = false
        weatherView.layer.shadowColor = UIColor.black.cgColor
        weatherView.layer.shadowOpacity = 0.1
        weatherView.layer.shadowOffset = CGSize(width: 0, height: 4)
        weatherView.layer.shadowRadius = 8
        mainContentView.addSubview(weatherView)

        // Add places table view to content view
        setupTableViewAppearance()
        mainContentView.addSubview(placesTableView)

        // Setup constraints for the scroll view layout
        setupScrollViewConstraints()
    }

    private func setupTableViewAppearance() {
        placesTableView.backgroundColor = .clear
        placesTableView.separatorStyle = .none
        placesTableView.showsVerticalScrollIndicator = false
        placesTableView.isScrollEnabled = false // Disable scrolling as we're using the main scroll view
        placesTableView.estimatedRowHeight = 250
        placesTableView.rowHeight = UITableView.automaticDimension
        placesTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }

    private func setupTableView() {
        placesTableView.delegate = self
        placesTableView.dataSource = self
        placesTableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: "PlaceCell")
    }

    private func setupLoadingOverlay() {
        // Setup loading overlay view (semi-transparent black background)
        loadingOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        loadingOverlayView.layer.cornerRadius = 12
        loadingOverlayView.isHidden = true
        view.addSubview(loadingOverlayView)

        // Setup loading indicator
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .white
        loadingOverlayView.addSubview(loadingIndicator)

        // Setup constraints for loading elements
        loadingOverlayView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loadingOverlayView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingOverlayView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingOverlayView.widthAnchor.constraint(equalToConstant: 120),
            loadingOverlayView.heightAnchor.constraint(equalToConstant: 120),

            loadingIndicator.centerXAnchor.constraint(equalTo: loadingOverlayView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingOverlayView.centerYAnchor)
        ])
    }

    private func setupErrorLabel() {
        errorLabel.textAlignment = .center
        errorLabel.font = UIFont.systemFont(ofSize: 16)
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        errorLabel.layer.cornerRadius = 10
        errorLabel.clipsToBounds = true
        errorLabel.isHidden = true
        view.addSubview(errorLabel)

        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            errorLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])

        // Add padding to error label
        errorLabel.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    private func setupScrollViewConstraints() {
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainContentView.translatesAutoresizingMaskIntoConstraints = false
        searchView.translatesAutoresizingMaskIntoConstraints = false
        weatherView.translatesAutoresizingMaskIntoConstraints = false
        placesTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Main scroll view constraints
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Main content view constraints
            mainContentView.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            mainContentView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            mainContentView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            mainContentView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            mainContentView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor),

            // Search view constraints
            searchView.topAnchor.constraint(equalTo: mainContentView.topAnchor, constant: 16),
            searchView.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor, constant: 16),
            searchView.trailingAnchor.constraint(equalTo: mainContentView.trailingAnchor, constant: -16),

            // Weather view constraints - initially hidden
            weatherView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 16),
            weatherView.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor, constant: 16),
            weatherView.trailingAnchor.constraint(equalTo: mainContentView.trailingAnchor, constant: -16),

            // Places table view constraints
            placesTableView.topAnchor.constraint(equalTo: weatherView.bottomAnchor, constant: 16),
            placesTableView.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor),
            placesTableView.trailingAnchor.constraint(equalTo: mainContentView.trailingAnchor),
            placesTableView.bottomAnchor.constraint(equalTo: mainContentView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Data Fetching
    private func fetchWeatherData(for city: String) {
        weatherView.isHidden = true
        places = []
        placesTableView.reloadData()

        // Show loading overlay
        loadingOverlayView.isHidden = false
        loadingIndicator.startAnimating()
        errorLabel.isHidden = true

        Task {
            do {
                // Step 1: Search for the location
                let locations = try await weatherService.searchLocation(query: city)

                guard let firstLocation = locations.first else {
                    DispatchQueue.main.async {
                        self.showError("Şehir bulunamadı, lütfen başka bir şehir adı deneyin.")
                    }
                    return
                }

                // Step 2: Get current weather conditions
                let currentWeather = try await weatherService.getCurrentWeather(locationKey: firstLocation.Key)

                DispatchQueue.main.async {
                    self.weatherView.configure(with: currentWeather, cityName: firstLocation.LocalizedName)
                    self.weatherView.isHidden = false
                    self.currentCity = firstLocation.LocalizedName

                    // Now fetch places once we have weather data
                    self.fetchPlaces(for: firstLocation.LocalizedName, weatherSummary: currentWeather.WeatherText, temperatureC: currentWeather.Temperature.Metric.Value)
                }

            } catch {
                DispatchQueue.main.async {
                    self.showError("Hava durumu bilgisi alınamadı: \(error.localizedDescription)")
                }
            }
        }
    }

    private func fetchPlaces(for city: String, weatherSummary: String, temperatureC: Double) {
        Task {
            do {
                let placesResponse = try await openAIService.getPlaces(city: city, weatherSummary: weatherSummary, temperatureC: temperatureC)

                DispatchQueue.main.async {
                    self.places = placesResponse.items
                    self.placesTableView.reloadData()
                    self.updateTableViewHeight()

                    // Hide loading overlay
                    self.loadingOverlayView.isHidden = true
                    self.loadingIndicator.stopAnimating()
                }

            } catch {
                DispatchQueue.main.async {
                    self.showError("Gezi önerileri alınamadı: \(error.localizedDescription)")
                }
            }
        }
    }

    private func updateTableViewHeight() {
        // Dynamically adjust table view height based on its content
        placesTableView.layoutIfNeeded()

        var tableHeight: CGFloat = 0
        if places.isEmpty {
            tableHeight = 0
        } else {
            // Height for section header
            tableHeight += 50

            // Height for all rows
            for i in 0..<places.count {
                let indexPath = IndexPath(row: i, section: 0)
                tableHeight += placesTableView.rectForRow(at: indexPath).height
            }

            // Additional padding
            tableHeight += 20
        }

        // Update tableView height constraint
        if let constraint = placesTableView.constraints.first(where: { $0.firstAttribute == .height }) {
            constraint.constant = tableHeight
        } else {
            placesTableView.heightAnchor.constraint(equalToConstant: tableHeight).isActive = true
        }
    }

    // MARK: - UI Updates
    private func showError(_ message: String) {
        // Hide loading overlay
        loadingOverlayView.isHidden = true
        loadingIndicator.stopAnimating()

        // Show error message
        errorLabel.text = message
        errorLabel.isHidden = false

        // Hide error after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.errorLabel.isHidden = true
        }
    }
}

// MARK: - SearchViewDelegate
extension ViewController: SearchViewDelegate {
    func searchView(_ searchView: SearchView, didSearchForCity city: String) {
        fetchWeatherData(for: city)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return places.isEmpty ? 0 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceTableViewCell
        let place = places[indexPath.row]
        cell.configure(with: place, isFavorite: favorites[place.id] ?? false)
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear

        let label = UILabel()
        label.text = "Gezi Önerileri"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label

        headerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

// MARK: - PlaceTableViewCellDelegate
extension ViewController: PlaceTableViewCellDelegate {
    func placeCell(_ cell: PlaceTableViewCell, didToggleFavorite place: Place) {
        // Toggle favorite status
        favorites[place.id] = !(favorites[place.id] ?? false)

        // Here you would typically save this to UserDefaults or another persistent store
        // UserDefaults.standard.set(favorites, forKey: "favorites")
    }
}
