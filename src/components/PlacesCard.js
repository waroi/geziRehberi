import React from 'react';

const PlacesCard = ({ places, city, loading, tourismType }) => {
  return (
    <div className="places-card">
      <h3 className="card-title">
        <i className={`fas ${tourismType?.icon || 'fa-map-marked-alt'}`} style={{color: tourismType?.color || '#667eea'}}></i>
        {tourismType?.name || 'Gezilecek Yerler'}
      </h3>
      
      {loading ? (
        <div className="places-loading">
          <div className="spinner"></div>
          <span>Öneriler güncelleniyor...</span>
        </div>
      ) : (
        <div className="places-list">
          {places.map((place, index) => (
            <div key={index} className="place-item">
              <h4 className="place-name">
                <i 
                  className="fas fa-location-dot" 
                  style={{marginRight: '10px', color: tourismType?.color || '#667eea'}}
                ></i>
                {place.name}
              </h4>
              {place.description && (
                <p className="place-description">{place.description}</p>
              )}
            </div>
          ))}
        </div>
      )}
      
      {!loading && places.length === 0 && (
        <div style={{textAlign: 'center', color: '#666', padding: '20px'}}>
          <i className="fas fa-info-circle" style={{marginRight: '10px'}}></i>
          Bu kategoride henüz yer bilgisi bulunamadı.
        </div>
      )}
    </div>
  );
};

export default PlacesCard;
