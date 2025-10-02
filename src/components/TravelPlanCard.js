import React from 'react';

const TravelPlanCard = ({ travelPlan }) => {
  return (
    <div className="travel-plan-card">
      <h3 className="card-title">
        <i className="fas fa-map-marked-alt"></i>
        Kişiselleştirilmiş Seyahat Planınız
      </h3>
      
      <div className="travel-plan-sections">
        {travelPlan.map((section, sectionIndex) => (
          <div key={sectionIndex} className="travel-plan-section">
            <h4 className="travel-plan-section-title">
              <i className={`fas ${getSectionIcon(section.title)}`}></i>
              {section.title}
            </h4>
            
            <div className="travel-plan-items">
              {section.items.map((item, itemIndex) => (
                <div key={itemIndex} className="travel-plan-item">
                  <div className="travel-plan-item-bullet">
                    <i className="fas fa-chevron-right"></i>
                  </div>
                  <div className="travel-plan-item-text">
                    {item}
                  </div>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
      
      {travelPlan.length === 0 && (
        <div style={{textAlign: 'center', color: '#666', padding: '40px'}}>
          <i className="fas fa-info-circle" style={{marginRight: '10px'}}></i>
          Seyahat planı oluşturulamadı. Lütfen daha detaylı bilgi verin.
        </div>
      )}
    </div>
  );
};

// Bölüm başlıklarına göre ikon seçimi
const getSectionIcon = (title) => {
  const titleLower = title.toLowerCase();
  
  if (titleLower.includes('şehir') || titleLower.includes('rota') || titleLower.includes('güzergah')) {
    return 'fa-route';
  } else if (titleLower.includes('konak') || titleLower.includes('otel') || titleLower.includes('kal')) {
    return 'fa-bed';
  } else if (titleLower.includes('yemek') || titleLower.includes('restoran') || titleLower.includes('mutfak')) {
    return 'fa-utensils';
  } else if (titleLower.includes('gezi') || titleLower.includes('yer') || titleLower.includes('ziyaret')) {
    return 'fa-map-pin';
  } else if (titleLower.includes('ulaşım') || titleLower.includes('taşıma') || titleLower.includes('transport')) {
    return 'fa-car';
  } else if (titleLower.includes('bütçe') || titleLower.includes('maliyet') || titleLower.includes('fiyat')) {
    return 'fa-money-bill';
  } else if (titleLower.includes('tavsiye') || titleLower.includes('öneri') || titleLower.includes('dikkat')) {
    return 'fa-lightbulb';
  } else if (titleLower.includes('program') || titleLower.includes('gün') || titleLower.includes('zaman')) {
    return 'fa-calendar-alt';
  } else {
    return 'fa-info-circle';
  }
};

export default TravelPlanCard;
