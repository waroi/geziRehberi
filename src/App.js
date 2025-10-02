import React, { useState } from 'react';
import { getWeatherByCityName, getTouristPlaces, TOURISM_TYPES } from './services/apiService';
import WeatherCard from './components/WeatherCard';
import PlacesCard from './components/PlacesCard';
import FilterButtons from './components/FilterButtons';

function App() {
  const [city, setCity] = useState('');
  const [currentCity, setCurrentCity] = useState('');
  const [weather, setWeather] = useState(null);
  const [places, setPlaces] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [selectedFilter, setSelectedFilter] = useState('all');
  const [placesLoading, setPlacesLoading] = useState(false);

  const handleSearch = async (e) => {
    e.preventDefault();
    
    if (!city.trim()) {
      setError('Lütfen bir şehir adı girin');
      return;
    }

    setLoading(true);
    setError('');
    setWeather(null);
    setPlaces([]);
    setSelectedFilter('all');

    try {
      // Hava durumu ve gezilecek yerleri paralel olarak al
      const [weatherData, placesData] = await Promise.all([
        getWeatherByCityName(city),
        getTouristPlaces(city, 'all')
      ]);

      setCurrentCity(city);
      setWeather(weatherData);
      setPlaces(placesData);
    } catch (err) {
      setError(err.message || 'Bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
    } finally {
      setLoading(false);
    }
  };

  const handleFilterChange = async (filterType) => {
    if (!currentCity || selectedFilter === filterType) return;

    setSelectedFilter(filterType);
    setPlacesLoading(true);
    setError('');

    try {
      const placesData = await getTouristPlaces(currentCity, filterType);
      setPlaces(placesData);
    } catch (err) {
      setError(err.message || 'Filtre uygulanırken bir hata oluştu.');
    } finally {
      setPlacesLoading(false);
    }
  };

  return (
    <div className="container">
      <header className="header">
        <h1>
          <i className="fas fa-map-marked-alt"></i>
          Gezi Rehberi
        </h1>
        <p>Şehirleri keşfet, hava durumu öğren ve gezilecek yerleri bul</p>
      </header>

      <div className="search-container">
        <form onSubmit={handleSearch} className="search-form">
          <input
            type="text"
            value={city}
            onChange={(e) => setCity(e.target.value)}
            placeholder="Hangi şehri keşfetmek istiyorsun? (örn: İstanbul, Paris, Tokyo)"
            className="search-input"
            disabled={loading}
          />
          <button 
            type="submit" 
            className="search-btn"
            disabled={loading}
          >
            {loading ? (
              <>
                <div className="spinner"></div>
                Araştırılıyor...
              </>
            ) : (
              <>
                <i className="fas fa-search"></i>
                Keşfet
              </>
            )}
          </button>
        </form>
      </div>

      {loading && (
        <div className="loading">
          <div className="spinner"></div>
          <span>Bilgiler getiriliyor, lütfen bekleyin...</span>
        </div>
      )}

      {error && (
        <div className="error">
          <i className="fas fa-exclamation-triangle"></i>
          {error}
        </div>
      )}

      {currentCity && (weather || places.length > 0) && (
        <>
          <h2 className="city-title fade-in">
            <i className="fas fa-map-marker-alt"></i>
            {currentCity}
          </h2>
          
          {/* Turizm türü filtreleri */}
          <FilterButtons 
            selectedFilter={selectedFilter}
            onFilterChange={handleFilterChange}
            disabled={loading || placesLoading}
          />
          
          <div className="results-container fade-in">
            {weather && <WeatherCard weather={weather} city={currentCity} />}
            {(places.length > 0 || placesLoading) && (
              <PlacesCard 
                places={places} 
                city={currentCity} 
                loading={placesLoading}
                tourismType={TOURISM_TYPES[selectedFilter]}
              />
            )}
          </div>
        </>
      )}
    </div>
  );
}

export default App;
