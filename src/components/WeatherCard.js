import React from 'react';

const WeatherCard = ({ weather, city }) => {
  return (
    <div className="weather-card">
      <h3 className="card-title">
        <i className="fas fa-cloud-sun"></i>
        Hava Durumu
      </h3>
      
      <div className="weather-main">
        <div>
          <div className="weather-temp">{Math.round(weather.temperature)}°C</div>
          <div className="weather-desc">{weather.description}</div>
        </div>
        <div>
          <i className="fas fa-thermometer-half" style={{fontSize: '3rem', opacity: 0.7}}></i>
        </div>
      </div>

      <div className="weather-details">
        <div className="weather-detail">
          <div className="weather-detail-label">
            <i className="fas fa-tint"></i> Nem
          </div>
          <div className="weather-detail-value">{weather.humidity}%</div>
        </div>
        
        <div className="weather-detail">
          <div className="weather-detail-label">
            <i className="fas fa-wind"></i> Rüzgar
          </div>
          <div className="weather-detail-value">{weather.windSpeed} km/h</div>
        </div>
        
        <div className="weather-detail">
          <div className="weather-detail-label">
            <i className="fas fa-eye"></i> Görüş
          </div>
          <div className="weather-detail-value">{weather.visibility} km</div>
        </div>
        
        {weather.uvIndex !== undefined && (
          <div className="weather-detail">
            <div className="weather-detail-label">
              <i className="fas fa-sun"></i> UV İndeksi
            </div>
            <div className="weather-detail-value">{weather.uvIndex}</div>
          </div>
        )}
        
        {weather.cloudCover !== undefined && (
          <div className="weather-detail">
            <div className="weather-detail-label">
              <i className="fas fa-cloud"></i> Bulutluluk
            </div>
            <div className="weather-detail-value">{weather.cloudCover}%</div>
          </div>
        )}
      </div>
    </div>
  );
};

export default WeatherCard;
