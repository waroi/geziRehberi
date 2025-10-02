import React, { useState } from 'react';
import { getWeatherByCityName, getTouristPlaces, getTravelPlan, getPlaceCoordinates, TOURISM_TYPES } from './services/apiService';
import WeatherCard from './components/WeatherCard';
import PlacesCard from './components/PlacesCard';
import FilterButtons from './components/FilterButtons';
import TravelPlanCard from './components/TravelPlanCard';
import SearchModeToggle from './components/SearchModeToggle';
import MapCard from './components/MapCard';

function App() {
  const [searchMode, setSearchMode] = useState('city'); // 'city' veya 'freetext'
  const [city, setCity] = useState('');
  const [freeText, setFreeText] = useState('');
  const [currentCity, setCurrentCity] = useState('');
  const [weather, setWeather] = useState(null);
  const [places, setPlaces] = useState([]);
  const [travelPlan, setTravelPlan] = useState([]);
  const [mapData, setMapData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [selectedFilter, setSelectedFilter] = useState('all');
  const [placesLoading, setPlacesLoading] = useState(false);
  const [mapLoading, setMapLoading] = useState(false);

  const handleSearch = async (e) => {
    e.preventDefault();
    
    // Arama moduna göre validasyon
    if (searchMode === 'city' && !city.trim()) {
      setError('Lütfen bir şehir adı girin');
      return;
    }
    
    if (searchMode === 'freetext' && !freeText.trim()) {
      setError('Lütfen seyahat isteğinizi yazın');
      return;
    }

    setLoading(true);
    setError('');
    setWeather(null);
    setPlaces([]);
    setTravelPlan([]);
    setSelectedFilter('all');

    try {
      if (searchMode === 'city') {
        // Şehir modu - hava durumu ve gezilecek yerler
        const [weatherData, placesData] = await Promise.all([
          getWeatherByCityName(city),
          getTouristPlaces(city, 'all')
        ]);

        setCurrentCity(city);
        setWeather(weatherData);
        setPlaces(placesData);
        
        // Harita verilerini arka planda yükle
        loadMapData(city, placesData);
      } else {
        // Serbest metin modu - seyahat planı oluştur
        const planData = await getTravelPlan(freeText);
        setTravelPlan(planData);
        setCurrentCity(''); // Şehir spesifik değil
        setMapData(null); // Harita verisini temizle
      }
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
      
      // Harita verilerini de güncelle
      loadMapData(currentCity, placesData);
    } catch (err) {
      setError(err.message || 'Filtre uygulanırken bir hata oluştu.');
    } finally {
      setPlacesLoading(false);
    }
  };

  const handleModeChange = (mode) => {
    setSearchMode(mode);
    setError('');
    setWeather(null);
    setPlaces([]);
    setTravelPlan([]);
    setMapData(null);
    setCurrentCity('');
    setCity('');
    setFreeText('');
  };

  const loadMapData = async (cityName, placesData) => {
    setMapLoading(true);
    try {
      const coordinates = await getPlaceCoordinates(cityName, placesData);
      setMapData(coordinates);
    } catch (err) {
      console.error('Harita verileri yüklenirken hata:', err);
      // Harita hatası uygulamayı durdurmasın
    } finally {
      setMapLoading(false);
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

      {/* Arama modu seçici */}
      <SearchModeToggle 
        searchMode={searchMode} 
        onModeChange={handleModeChange}
        disabled={loading}
      />

      <div className="search-container">
        <form onSubmit={handleSearch} className="search-form">
          {searchMode === 'city' ? (
            <input
              type="text"
              value={city}
              onChange={(e) => setCity(e.target.value)}
              placeholder="Hangi şehri keşfetmek istiyorsun? (örn: İstanbul, Paris, Tokyo)"
              className="search-input"
              disabled={loading}
            />
          ) : (
            <textarea
              value={freeText}
              onChange={(e) => setFreeText(e.target.value)}
              placeholder="Seyahat isteğinizi detaylı yazın... Örnek: 'Karadeniz tatili yapmak istiyorum, hangi sıra ile turu düzenlemeli, nerelerde kalmalı, nerelerde yemek yemeliyim?'"
              className="search-textarea"
              disabled={loading}
              rows={4}
            />
          )}
          
          <button 
            type="submit" 
            className="search-btn"
            disabled={loading}
          >
            {loading ? (
              <>
                <div className="spinner"></div>
                {searchMode === 'city' ? 'Araştırılıyor...' : 'Plan hazırlanıyor...'}
              </>
            ) : (
              <>
                <i className={`fas ${searchMode === 'city' ? 'fa-search' : 'fa-route'}`}></i>
                {searchMode === 'city' ? 'Keşfet' : 'Plan Oluştur'}
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

      {/* Şehir modu sonuçları */}
      {searchMode === 'city' && currentCity && (weather || places.length > 0) && (
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

          {/* Harita bölümü */}
          {(mapData || mapLoading) && (
            <div className="map-section fade-in">
              <MapCard 
                mapData={mapData}
                city={currentCity}
                loading={mapLoading}
                tourismType={TOURISM_TYPES[selectedFilter]}
              />
            </div>
          )}
        </>
      )}

      {/* Serbest metin modu sonuçları */}
      {searchMode === 'freetext' && travelPlan.length > 0 && (
        <>
          <h2 className="city-title fade-in">
            <i className="fas fa-route"></i>
            Seyahat Planınız
          </h2>
          
          <div className="travel-plan-container fade-in">
            <TravelPlanCard travelPlan={travelPlan} />
          </div>
        </>
      )}
    </div>
  );
}

export default App;
