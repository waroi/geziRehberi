import React, { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
});


const MapController = ({ center }) => {
  const map = useMap();
  
  useEffect(() => {
    if (center && center.lat && center.lng) {
      map.setView([center.lat, center.lng], 13);
    }
  }, [map, center]);
  
  return null;
};

// Özel marker ikonları
const createCustomIcon = (color = '#667eea', isCenter = false) => {
  const markerHtml = isCenter 
    ? `<div style="
        background-color: ${color};
        width: 20px;
        height: 20px;
        border-radius: 50%;
        border: 3px solid white;
        box-shadow: 0 2px 5px rgba(0,0,0,0.3);
      "></div>`
    : `<div style="
        background-color: ${color};
        width: 16px;
        height: 16px;
        border-radius: 50%;
        border: 2px solid white;
        box-shadow: 0 1px 3px rgba(0,0,0,0.3);
      "></div>`;

  return L.divIcon({
    html: markerHtml,
    className: 'custom-marker',
    iconSize: isCenter ? [20, 20] : [16, 16],
    iconAnchor: isCenter ? [10, 10] : [8, 8]
  });
};

const MapCard = ({ mapData, city, loading, tourismType }) => {
  const [mapCenter, setMapCenter] = useState({ lat: 41.0082, lng: 28.9784 }); // İstanbul default

  useEffect(() => {
    if (mapData && mapData.cityCoords) {
      setMapCenter({
        lat: mapData.cityCoords.lat,
        lng: mapData.cityCoords.lon
      });
    }
  }, [mapData]);

  if (loading) {
    return (
      <div className="map-card">
        <h3 className="card-title">
          <i className="fas fa-map" style={{color: tourismType?.color || '#667eea'}}></i>
          Harita Yükleniyor
        </h3>
        <div className="map-loading">
          <div className="spinner"></div>
          <span>Konum bilgileri getiriliyor...</span>
        </div>
      </div>
    );
  }

  if (!mapData || !mapData.placesWithCoords) {
    return null;
  }

  return (
    <div className="map-card">
      <h3 className="card-title">
        <i className="fas fa-map" style={{color: tourismType?.color || '#667eea'}}></i>
        {city} - Gezilecek Yerler Haritası
      </h3>
      
      <div className="map-container">
        <MapContainer
          center={[mapCenter.lat, mapCenter.lng]}
          zoom={13}
          style={{ height: '400px', width: '100%', borderRadius: '10px' }}
        >
          <MapController center={mapCenter} />
          
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          
          {mapData.placesWithCoords.map((place, index) => (
            <Marker
              key={index}
              position={[place.lat, place.lng]}
              icon={createCustomIcon(
                tourismType?.color || '#667eea',
                place.isCenter
              )}
            >
              <Popup>
                <div className="map-popup">
                  <h4 className="map-popup-title">
                    {place.isCenter && <i className="fas fa-star"></i>}
                    {place.name}
                  </h4>
                  <p className="map-popup-desc">{place.description}</p>
                  {place.isCenter && (
                    <small className="map-popup-note">Şehir Merkezi</small>
                  )}
                </div>
              </Popup>
            </Marker>
          ))}
        </MapContainer>
      </div>
      
      <div className="map-legend">
        <div className="map-legend-item">
          <div 
            className="map-legend-color"
            style={{ backgroundColor: tourismType?.color || '#667eea' }}
          ></div>
          <span>Gezilecek Yerler ({mapData.placesWithCoords.length - 1} konum)</span>
        </div>
      </div>
    </div>
  );
};

export default MapCard;
