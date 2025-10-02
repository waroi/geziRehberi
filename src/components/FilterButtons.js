import React from 'react';
import { TOURISM_TYPES } from '../services/apiService';

const FilterButtons = ({ selectedFilter, onFilterChange, disabled }) => {
  return (
    <div className="filter-container fade-in">
      <h3 className="filter-title">
        <i className="fas fa-filter"></i>
        Turizm Türünü Seçin
      </h3>
      
      <div className="filter-buttons">
        {Object.values(TOURISM_TYPES).map((type) => (
          <button
            key={type.id}
            className={`filter-btn ${selectedFilter === type.id ? 'active' : ''}`}
            onClick={() => onFilterChange(type.id)}
            disabled={disabled}
            style={{
              '--filter-color': type.color
            }}
          >
            <i className={`fas ${type.icon}`}></i>
            <span>{type.name}</span>
          </button>
        ))}
      </div>
    </div>
  );
};

export default FilterButtons;
