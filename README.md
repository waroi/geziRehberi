# 🗺️ Gezi Rehberi Uygulaması

Modern ve kullanıcı dostu bir gezi rehberi uygulaması. Şehir adı girerek o şehrin hava durumu bilgilerini ve gezilecek yerlerini keşfedebilirsiniz.

## ✨ Özellikler

- 🌤️ **Gerçek Zamanlı Hava Durumu**: AccuWeather API kullanarak güncel hava durumu bilgileri
- 🏛️ **Gezilecek Yerler**: OpenAI ChatGPT API kullanarak şehre özel gezi önerileri
- 📱 **Responsive Tasarım**: Mobil ve masaüstü cihazlarda mükemmel görünüm
- 🎨 **Modern Arayüz**: Gradient renkler ve animasyonlarla şık tasarım
- ⚡ **Hızlı Performans**: React 18 ve modern JavaScript

## 🚀 Kurulum

1. **Projeyi klonlayın:**

   ```bash
   git clone [repo-url]
   cd geziRehberi
   ```

2. **Bağımlılıkları yükleyin:**

   ```bash
   npm install
   ```

3. **API anahtarlarını ayarlayın:**
   - `.env.example` dosyasını `.env` olarak kopyalayın
   - Gerekli API anahtarlarını edinin ve `.env` dosyasına ekleyin

## 🔑 API Anahtarları

### OpenAI API Key

1. [OpenAI Platform](https://platform.openai.com/api-keys) hesabı oluşturun
2. API key oluşturun
3. `.env` dosyasındaki `REACT_APP_OPENAI_API_KEY` değerini güncelleyin

### AccuWeather API Key

1. [AccuWeather Developer](https://developer.accuweather.com/) hesabı oluşturun
2. Ücretsiz plan ile API key alın
3. `.env` dosyasındaki `REACT_APP_ACCUWEATHER_API_KEY` değerini güncelleyin

## 💻 Çalıştırma

```bash
npm start
```

Uygulama [http://localhost:3000](http://localhost:3000) adresinde çalışmaya başlayacaktır.

## 📦 Build

```bash
npm run build
```

## 🛠️ Kullanılan Teknolojiler

- **React 18**: Modern JavaScript framework
- **CSS3**: Gradient tasarım ve animasyonlar
- **Axios**: HTTP istekleri için
- **OpenAI API**: Gezilecek yerler önerileri
- **AccuWeather API**: Hava durumu bilgileri
- **Font Awesome**: İkonlar
- **Google Fonts**: Poppins font ailesi

## 📱 Özellikler Detayı

### Hava Durumu Kartı

- Güncel sıcaklık ve hava durumu açıklaması
- Nem oranı, rüzgar hızı, görüş mesafesi
- UV indeksi ve bulutluluk oranı
- Görsel iconlar ve renkli tasarım

### Gezilecek Yerler Kartı

- AI destekli akıllı öneriler
- Her yer için detaylı açıklama
- Kolay okunabilir liste formatı
- Hover efektleri ile interaktif deneyim

### Responsive Tasarım

- Mobile-first yaklaşım
- Tablet ve desktop uyumlu
- Esnek grid sistemi
- Touch-friendly butonlar

## 🎨 Tasarım Özellikleri

- **Renk Paleti**: Mor-mavi gradient tema
- **Typography**: Poppins font ailesi
- **Animasyonlar**: Fade-in efektleri, hover animasyonları
- **Shadows**: Depth ve modern görünüm için gölgeler
- **Border Radius**: Yumuşak kenarlar ile modern görünüm

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Branch'i push edin (`git push origin feature/AmazingFeature`)
5. Pull Request açın

## 📞 İletişim

Herhangi bir sorunuz veya öneriniz varsa lütfen issue açın.

---

⭐ **Bu projeyi beğendiyseniz yıldızlamayı unutmayın!**
