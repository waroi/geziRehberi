import axios from 'axios';

// OpenAI API Configuration
const OPENAI_API_KEY = process.env.REACT_APP_OPENAI_API_KEY;
const OPENAI_API_URL = 'https://api.openai.com/v1/chat/completions';

// AccuWeather API Configuration  
const ACCUWEATHER_API_KEY = process.env.REACT_APP_ACCUWEATHER_API_KEY;
const ACCUWEATHER_BASE_URL = 'http://dataservice.accuweather.com';

// Turizm türleri tanımları
export const TOURISM_TYPES = {
  ALL: { id: 'all', name: 'Tümü', icon: 'fa-map-marked-alt', color: '#667eea' },
  CULTURE: { id: 'culture', name: 'Kültür Turizmi', icon: 'fa-landmark', color: '#8b5cf6' },
  FOOD: { id: 'food', name: 'Yemek Turizmi', icon: 'fa-utensils', color: '#ef4444' },
  NATURE: { id: 'nature', name: 'Doğa Turizmi', icon: 'fa-tree', color: '#22c55e' },
  HISTORY: { id: 'history', name: 'Tarihi Yerler', icon: 'fa-monument', color: '#f59e0b' },
  SHOPPING: { id: 'shopping', name: 'Alışveriş', icon: 'fa-shopping-bag', color: '#ec4899' },
  NIGHTLIFE: { id: 'nightlife', name: 'Gece Hayatı', icon: 'fa-moon', color: '#6366f1' },
  ADVENTURE: { id: 'adventure', name: 'Macera Turizmi', icon: 'fa-mountain', color: '#059669' }
};

// Turizm türüne göre özelleştirilmiş prompt oluşturma
const createTourismPrompt = (cityName, tourismType) => {
  const prompts = {
    all: `${cityName} şehrinde gezilecek en popüler ve çeşitli yerler nelerdir? Kültürel, tarihi, doğal güzellikler, müzeler, parklar ve önemli yapıları dahil et.`,
    culture: `${cityName} şehrinde kültür turizmi açısından gezilmesi gereken yerler nelerdir? Müzeler, sanat galerileri, kültür merkezleri, opera evleri, tiyatrolar ve kültürel etkinlik alanlarını listele.`,
    food: `${cityName} şehrinde yemek turizmi açısından gidilmesi gereken yerler nelerdir? Ünlü restoranlar, geleneksel mutfak deneyimleri, yerel pazarlar, street food alanları ve gastronomi turları dahil et.`,
    nature: `${cityName} şehrinde doğa turizmi açısından gezilecek yerler nelerdir? Parklar, bahçeler, doğal alanlar, plajlar, göller, nehirler, hiking rotaları ve doğa yürüyüşü alanlarını listele.`,
    history: `${cityName} şehrinde tarihi turizm açısından görülmesi gereken yerler nelerdir? Tarihi yapılar, antik kalıntılar, kaleler, saraylar, tarihi semtler ve arkeolojik alanları dahil et.`,
    shopping: `${cityName} şehrinde alışveriş turizmi açısından gidilecek yerler nelerdir? Alışveriş merkezleri, geleneksel pazarlar, butik mağazalar, antika dükkânları ve yerel el sanatları dükkanlarını listele.`,
    nightlife: `${cityName} şehrinde gece hayatı açısından gidilecek yerler nelerdir? Barlar, kulüpler, canlı müzik mekanları, rooftop barlar, lounge alanları ve gece eğlence merkezlerini listele.`,
    adventure: `${cityName} şehrinde macera turizmi açısından yapılacak aktiviteler nelerdir? Extreme sporlar, tırmanış alanları, su sporları, bisiklet rotaları, zipline ve adrenalin dolu aktiviteleri dahil et.`
  };

  return prompts[tourismType] || prompts.all;
};

// OpenAI API - Gezilecek yerler için (turizm türü filtreli)
export const getTouristPlaces = async (cityName, tourismType = 'all') => {
  try {
    const prompt = createTourismPrompt(cityName, tourismType);
    
    const response = await axios.post(
      OPENAI_API_URL,
      {
        model: "gpt-3.5-turbo",
        messages: [
          {
            role: "system",
            content: "Sen uzman bir gezi rehberisin. Kullanıcının verdiği şehir ve turizm türü için en iyi 8-10 yeri öner. Her yer için kısa ama bilgilendirici açıklama yap. Sadece gerçek ve mevcut yerler öner. Yanıtını numara ile listele."
          },
          {
            role: "user",
            content: prompt
          }
        ],
        max_tokens: 1200,
        temperature: 0.7
      },
      {
        headers: {
          'Authorization': `Bearer ${OPENAI_API_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );

    const content = response.data.choices[0].message.content;
    
    // Response'u parse edip array haline getirme
    const places = parsePlacesFromResponse(content);
    return places;
  } catch (error) {
    console.error('OpenAI API Error:', error);
    throw new Error('Gezilecek yerler alınırken bir hata oluştu. Lütfen daha sonra tekrar deneyin.');
  }
};

// Response'dan yerleri parse etme fonksiyonu
const parsePlacesFromResponse = (content) => {
  const places = [];
  const lines = content.split('\n');
  
  let currentPlace = null;
  
  for (const line of lines) {
    const trimmedLine = line.trim();
    
    // Başlık satırlarını tespit et (genellikle sayı ile başlar veya - ile)
    if (trimmedLine.match(/^\d+\./) || trimmedLine.match(/^-\s*/)) {
      if (currentPlace) {
        places.push(currentPlace);
      }
      
      const name = trimmedLine.replace(/^\d+\.\s*/, '').replace(/^-\s*/, '').replace(/\*\*/g, '').trim();
      const colonIndex = name.indexOf(':');
      
      currentPlace = {
        name: colonIndex > -1 ? name.substring(0, colonIndex).trim() : name,
        description: colonIndex > -1 ? name.substring(colonIndex + 1).trim() : ''
      };
    } else if (trimmedLine && currentPlace && !currentPlace.description) {
      currentPlace.description = trimmedLine;
    } else if (trimmedLine && currentPlace && currentPlace.description) {
      currentPlace.description += ' ' + trimmedLine;
    }
  }
  
  if (currentPlace) {
    places.push(currentPlace);
  }
  
  // Eğer parse işlemi başarısız olduysa, basit bir split yap
  if (places.length === 0) {
    const simplePlaces = content.split('\n')
      .filter(line => line.trim())
      .map(line => {
        const cleaned = line.replace(/^\d+\.\s*/, '').replace(/^-\s*/, '').trim();
        const colonIndex = cleaned.indexOf(':');
        return {
          name: colonIndex > -1 ? cleaned.substring(0, colonIndex).trim() : cleaned,
          description: colonIndex > -1 ? cleaned.substring(colonIndex + 1).trim() : 'Popüler bir gezi noktası'
        };
      });
    
    return simplePlaces.slice(0, 10);
  }
  
  return places.slice(0, 10);
};

// AccuWeather API - Şehir location key bulma
export const getCityLocationKey = async (cityName) => {
  try {
    const response = await axios.get(
      `${ACCUWEATHER_BASE_URL}/locations/v1/cities/search`,
      {
        params: {
          apikey: ACCUWEATHER_API_KEY,
          q: cityName,
          language: 'tr-tr'
        }
      }
    );

    if (response.data && response.data.length > 0) {
      return response.data[0].Key;
    } else {
      throw new Error('Şehir bulunamadı');
    }
  } catch (error) {
    console.error('AccuWeather Location API Error:', error);
    throw new Error('Şehir bilgisi alınırken bir hata oluştu.');
  }
};

// AccuWeather API - Hava durumu bilgisi alma
export const getCurrentWeather = async (locationKey) => {
  try {
    const response = await axios.get(
      `${ACCUWEATHER_BASE_URL}/currentconditions/v1/${locationKey}`,
      {
        params: {
          apikey: ACCUWEATHER_API_KEY,
          language: 'tr-tr',
          details: true
        }
      }
    );

    if (response.data && response.data.length > 0) {
      const weather = response.data[0];
      return {
        temperature: weather.Temperature.Metric.Value,
        description: weather.WeatherText,
        humidity: weather.RelativeHumidity,
        windSpeed: weather.Wind.Speed.Metric.Value,
        visibility: weather.Visibility.Metric.Value,
        uvIndex: weather.UVIndex,
        cloudCover: weather.CloudCover
      };
    } else {
      throw new Error('Hava durumu bilgisi bulunamadı');
    }
  } catch (error) {
    console.error('AccuWeather Current Weather API Error:', error);
    throw new Error('Hava durumu bilgisi alınırken bir hata oluştu.');
  }
};

// Ana fonksiyon - Şehir için hava durumu alma
export const getWeatherByCityName = async (cityName) => {
  try {
    const locationKey = await getCityLocationKey(cityName);
    const weather = await getCurrentWeather(locationKey);
    return weather;
  } catch (error) {
    throw error;
  }
};
