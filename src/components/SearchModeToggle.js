import React from 'react';

const SearchModeToggle = ({ searchMode, onModeChange, disabled }) => {
  return (
    <div className="mode-toggle-container fade-in">
      <h3 className="mode-toggle-title">
        <i className="fas fa-exchange-alt"></i>
        Arama Türünü Seçin
      </h3>
      
      <div className="mode-toggle-buttons">
        <button
          className={`mode-toggle-btn ${searchMode === 'city' ? 'active' : ''}`}
          onClick={() => onModeChange('city')}
          disabled={disabled}
        >
          <div className="mode-toggle-icon">
            <i className="fas fa-city"></i>
          </div>
          <div className="mode-toggle-content">
            <div className="mode-toggle-name">Şehir Keşfi</div>
            <div className="mode-toggle-desc">Spesifik bir şehri araştır</div>
          </div>
        </button>
        
        <button
          className={`mode-toggle-btn ${searchMode === 'freetext' ? 'active' : ''}`}
          onClick={() => onModeChange('freetext')}
          disabled={disabled}
        >
          <div className="mode-toggle-icon">
            <i className="fas fa-route"></i>
          </div>
          <div className="mode-toggle-content">
            <div className="mode-toggle-name">Seyahat Planı</div>
            <div className="mode-toggle-desc">Detaylı tatil planı oluştur</div>
          </div>
        </button>
      </div>
    </div>
  );
};

export default SearchModeToggle;
