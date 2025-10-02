# Gezi Rehberi Uygulaması — Analiz & Teknik Tasarım

> Amaç: Kullanıcıdan şehir adını alıp (1) AccuWeather üzerinden hava durumunu göstermeyi, ardından (2) ChatGPT API’sinden o şehre uygun gezi önerilerini üretip şık bir arayüzde sunmayı hedefleyen web uygulaması.

---

## 1) Kapsam & Gereksinimler

**Kullanıcı akışı**
1. Anasayfada bir arama kutusundan şehir adını girer (ör. “İstanbul”).
2. Uygulama AccuWeather API ile şehir → `locationKey` eşlemesini bulur ve anlık hava durumu + kısa tahmini gösterir.
3. Hava durumu verisi alındıktan sonra ChatGPT API çağrısı ile **şehre özgü** gezi yerleri, kısa açıklamalar ve kategoriler üretilir.
4. Öneriler kartlar halinde listelenir; kategori ve filtreler ile kullanıcı daraltabilir. Her öneri için “Haritada aç” ve “Favorilere ekle” aksiyonları sunulur.

**Fonksiyonel gereksinimler**
- Şehir arama (otomatik tamamlama opsiyonel)
- Hava durumu: anlık + kısa/bugün/yarın özet (metin + ikon + sıcaklık)
- ChatGPT tabanlı gezi önerileri: başlık, kısa açıklama, tür (tarihî, müze, doğa, aile, gastronomi, ücretsiz vb.), tahmini süre, kapalı/açık alan bilgisi.
- Filtreleme & sıralama (tür, süre, ücretsiz vb.)
- Favorilere ekleme (localStorage/IndexedDB)
- Hata yönetimi, boş durumlar, yüklenme iskeletleri

**Performans & UX**
- İstekleri `react-query` ile önbellekleme; aramayı `debounce` etmek
- Hava durumu ikonlarını ve öneri kartlarını skeleton ile yüklemek
- Mobil öncelikli tasarım, klavye erişilebilir arama

---

## 2) Teknolojiler & Mimarî

**Frontend**: React + TypeScript, Vite veya Next.js (SPA/MPA tercihi)
- **Stil**: Tailwind CSS + shadcn/ui
- **State**: Zustand (global küçük durumlar) + React Query (server state)
- **İkonlar**: lucide-react
- **Harita (opsiyonel)**: Leaflet veya Google Maps link-out

**API katmanı**
- `AccuWeatherClient` (REST):
  - Şehir arama → `GET /locations/v1/cities/search?q={city}` → `locationKey`
  - Anlık durum → `GET /currentconditions/v1/{locationKey}`
  - (Opsiyonel) Günlük/3-5 günlük tahmin → `GET /forecasts/v1/daily/5day/{locationKey}`
- `ChatGPTClient` (OpenAI API):
  - Girdi: şehir, hava özeti, kullanıcı dili
  - Çıktı: **JSON** formatında gezi önerileri

**Config / Env**
- `VITE_ACCUWEATHER_API_KEY`
- `VITE_OPENAI_API_KEY`
- `VITE_DEFAULT_LOCALE=tr`

**Proje yapısı (öneri)**
```
src/
  api/
    accuWeather.ts
    openai.ts
  components/
    CitySearch.tsx
    WeatherCard.tsx
    PlaceCard.tsx
    FiltersBar.tsx
    EmptyState.tsx
  store/
    usePreferences.ts (Zustand: dil, birimler, favoriler)
  pages/ (veya routes/)
    Home.tsx
  hooks/
    useWeather.ts
    usePlaces.ts
  types/
    weather.ts
    places.ts
  utils/
    format.ts
    constants.ts
```

---

## 3) Veri Modelleri (TypeScript)

**Weather**
```ts
export type WeatherNow = {
  summary: string; // “Güneşli”, “Parçalı bulutlu”
  temperatureC: number;
  temperatureFeelsLikeC?: number;
  iconCode?: number; // AccuWeather ikon kodu
  windKph?: number;
  humidity?: number;
};
```

**Place (ChatGPT çıkışı)**
```ts
export type Place = {
  id: string;             // stable slug
  name: string;           // “Topkapı Sarayı”
  category: "history" | "museum" | "nature" | "family" | "food" | "free" | "other";
  shortDescription: string;
  suggestedDurationMin?: number; // 60, 120...
  isOutdoor?: boolean;
  neighborhood?: string;
  mapUrl?: string;        // Google Maps linki
};

export type PlaceResponse = {
  city: string;
  locale: string; // "tr" | "en"
  items: Place[];
};
```

---

## 4) Akışlar

**A) Şehir → Hava**
1. Kullanıcı şehir adını girer.
2. `useWeather(city)` kancası önce `locations/search` ile `locationKey` alır, ardından `currentconditions` çağrısı yapar.
3. Dönen veri `WeatherCard`’a aktarılır.

**B) Hava → Gezi Önerileri**
1. `usePlaces({ city, weatherNow })` tetiklenir.
2. ChatGPT API’ye yapılandırılmış prompt + JSON şemasıyla istek atılır.
3. Dönen `items` liste halinde `PlaceCard` bileşenleri ile gösterilir.
4. `FiltersBar` seçimine göre client-side filtreleme/sıralama yapılır.

**Hata/Boş durumlar**
- Şehir bulunamaz → “Şehri bulamadık, lütfen farklı bir ifade deneyin.”
- Hava verisi başarısız → Retry düğmesi
- ChatGPT boş liste dönerse → “Şu an öneri üretemedik.” alternatif statik öneriler (opsiyonel fallback)

---

## 5) OpenAI (ChatGPT) Prompt Tasarımı

**Model**: `gpt-4.1` veya `gpt-4o-mini` (maliyet için mini)

**System prompt (TR)**
```
Kıdemli bir gezi planlayıcısısın. Kullanıcının girdiği şehir ve hava durumuna göre gezilecek yerler listesi üret. Çıktıyı JSON olarak ver. Detaylı ama öz, güncel genel bilgiler ver; adres/telefon gibi hızla bayatlayan veriler verme. "mapUrl" alanına genel bir Google Maps araması koyabilirsin.
```

**User prompt şablonu**
```
Şehir: {{city}}
Dil: {{locale}}
Hava özeti: {{weather.summary}}, {{weather.temperatureC}}°C
Kısıtlar: Aile dostu seçenekleri önceliklendir, kapalı alan/yağmur alternatifi ekle, bütçe dostu en az 2 seçenek olsun.
Lütfen şu JSON şemasına UYGUN DÖN:
{
  "city": string,
  "locale": "tr"|"en",
  "items": [
    {
      "id": string,
      "name": string,
      "category": "history"|"museum"|"nature"|"family"|"food"|"free"|"other",
      "shortDescription": string,
      "suggestedDurationMin": number,
      "isOutdoor": boolean,
      "neighborhood": string,
      "mapUrl": string
    }
  ]
}
Sadece JSON döndür.
```

**İstek örneği (pseudo)**
```ts
const resp = await openai.responses.create({
  model: 'gpt-4o-mini',
  temperature: 0.7,
  messages: [
    { role: 'system', content: systemPrompt },
    { role: 'user', content: renderUserPrompt({ city, weather, locale: 'tr' }) }
  ],
  response_format: { type: 'json_object' }
});
const places: PlaceResponse = JSON.parse(resp.output_text);
```

---

## 6) AccuWeather Entegrasyonu (Önerilen Akış)

> Not: AccuWeather API’si bir `locationKey` akışı ile çalışır ve sonuçlar için API anahtarı gerekir. Aşağıdaki uç noktalar temsilîdir; lisansınıza göre ücretsiz/ücretli kotaları kontrol edin.

1) **Şehir arama**
```
GET /locations/v1/cities/search?q={city}&apikey=...&language=tr-tr
```
Yanıt → `[ { Key: "318251", LocalizedName: "İstanbul", ... } ]`

2) **Anlık durum**
```
GET /currentconditions/v1/{locationKey}?apikey=...&details=true&language=tr-tr
```
Yanıt → `[ { WeatherText: "Parçalı bulutlu", Temperature: { Metric: { Value: 24 } }, WeatherIcon: 3, ... } ]`

3) **(Opsiyonel) Kısa tahmin**
```
GET /forecasts/v1/daily/1day/{locationKey}?apikey=...&metric=true&language=tr-tr
```

**Ortam değişkenleri**
- `VITE_ACCUWEATHER_API_KEY` (client veya proxy ile güvenli kullanım)

**Güvenlik**
- API anahtarlarını tarayıcıya sızdırmamak için **hafif bir edge/server proxy** önerilir. (Vite dev server proxy veya Netlify/Cloudflare Function)

---

## 7) UI & Bileşenler

**CitySearch**
- Input + arama butonu, Enter ile tetikleme, `debounce(300ms)`
- (Opsiyonel) sonuç listesi, seçince `city` state güncellenir

**WeatherCard**
- Büyük derece yazımı, durum metni, nem/rüzgâr, AccuWeather ikon eşleşmesi
- Küçük/öz tahmin satırı

**FiltersBar**
- Çoklu seçim: kategori (checkbox), süre (select), ücretsiz toggle

**PlaceCard**
- Başlık, rozet (kategori), kısa açıklama
- Alt kısımda: süre (~90 dk), “Haritada Aç”, “Favori”

**EmptyState / ErrorState**
- İlk açılış: “Bir şehir adı yazın”
- Hata/sıfır veri: yönlendirici kısa metin + tekrar dene

**Tema**
- Tailwind + shadcn: kartlar `rounded-2xl shadow`, tipografi ölçekli, grid layout (mobil 1, tablet 2, masaüstü 3 sütun)

---

## 8) Örnek Kod Parçaları (kısaltılmış)

**Zustand store (favoriler & tercih)**
```ts
import { create } from 'zustand';

type Prefs = {
  locale: 'tr' | 'en';
  favorites: Record<string, boolean>;
  toggleFavorite: (id: string) => void;
};

export const usePrefs = create<Prefs>((set) => ({
  locale: 'tr',
  favorites: {},
  toggleFavorite: (id) => set((s) => ({
    favorites: { ...s.favorites, [id]: !s.favorites[id] }
  }))
}));
```

**AccuWeather client**
```ts
const BASE = '/api/accu'; // serverless proxy önerilir

export async function searchCity(q: string) {
  const r = await fetch(`${BASE}/locations?q=${encodeURIComponent(q)}`);
  if (!r.ok) throw new Error('City search failed');
  return r.json();
}

export async function getCurrentConditions(locationKey: string) {
  const r = await fetch(`${BASE}/current?key=${locationKey}`);
  if (!r.ok) throw new Error('Weather failed');
  return r.json();
}
```

**OpenAI client (özet)**
```ts
export async function getPlaces({ city, weather, locale = 'tr' }) {
  const r = await fetch('/api/places', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ city, weather, locale })
  });
  if (!r.ok) throw new Error('Places failed');
  return r.json();
}
```

**useWeather kancası (React Query)**
```ts
import { useQuery } from '@tanstack/react-query';

export function useWeather(city: string) {
  return useQuery({
    queryKey: ['weather', city],
    queryFn: async () => {
      const cities = await searchCity(city);
      const key = cities?.[0]?.Key;
      if (!key) throw new Error('LOCATION_NOT_FOUND');
      const now = await getCurrentConditions(key);
      return { key, now: now?.[0] };
    },
    enabled: !!city,
    staleTime: 1000 * 60 * 10
  });
}
```

**usePlaces kancası**
```ts
import { useQuery } from '@tanstack/react-query';

export function usePlaces(city: string, weatherSummary?: string, tC?: number) {
  return useQuery({
    queryKey: ['places', city, weatherSummary, tC],
    queryFn: () => getPlaces({ city, weather: { summary: weatherSummary, temperatureC: tC }, locale: 'tr' }),
    enabled: !!city && !!weatherSummary,
    staleTime: 1000 * 60 * 60
  });
}
```

**Home sayfası akışı (özet JSX)**
```tsx
export default function Home() {
  const [city, setCity] = useState('');
  const { data: w, isLoading: wLoading } = useWeather(city);
  const weatherSummary = w?.now?.WeatherText;
  const tC = w?.now?.Temperature?.Metric?.Value;
  const { data: places, isLoading: pLoading } = usePlaces(city, weatherSummary, tC);

  return (
    <div className="container mx-auto p-4 space-y-6">
      <CitySearch onSubmit={setCity} />
      {wLoading ? <WeatherSkeleton/> : w ? <WeatherCard data={w}/> : <EmptyState text="Şehir seçin"/>}
      {pLoading ? <PlacesSkeleton/> : places ? <PlacesGrid items={places.items}/> : null}
    </div>
  );
}
```

---

## 9) Güvenlik, Kota, Hata Yönetimi
- AccuWeather ve OpenAI anahtarlarını **server-side** saklayın. Tarayıcıya sızdırmayın.
- Rate limit: Aramayı `debounce` edin; React Query `retry` ve `backoff` kullanın.
- Hata mesajlarını son kullanıcıya sade ve Türkçe iletin; teknik detayları konsola/log’a.

---

## 10) Test & Kalite
- **Unit**: utils ve mapping fonksiyonları
- **Integration**: api client → hooks → component
- **E2E**: Playwright ile şehir gir → hava gelir → öneriler listelenir senaryosu
- **Accessibility**: label’lar, `aria-live` yüklenme durumları, kontrast, klavye navigasyonu

---

## 11) Yol Haritası / İş Listesi (Cursor için hazır görevler)

**MVP (Gün 1)**
- [ ] Proje iskeleti (Vite + TS + Tailwind + shadcn/ui)
- [ ] React Query & Zustand kurulumu
- [ ] `/api/accu` proxy route (location search + current conditions)
- [ ] `/api/places` route (OpenAI çağrısı, JSON schema doğrulama)
- [ ] CitySearch, WeatherCard, PlaceCard, EmptyState
- [ ] Temel akış ve hata durumları

**Ekstra (Gün 2+)**
- [ ] Otomatik tamamlama (şehir)
- [ ] Filtre/Sıralama barı
- [ ] Favoriler (local persist)
- [ ] Basit harita/Maps linkleri
- [ ] i18n (tr/en)

---

## 12) Örnek API Route’ları (Node/Edge, pseudo)

**/api/accu/locations**
```ts
// GET ?q=istanbul
const url = `https://dataservice.accuweather.com/locations/v1/cities/search?q=${q}&apikey=${process.env.ACCU_KEY}&language=tr-tr`;
```

**/api/accu/current**
```ts
// GET ?key=318251
const url = `https://dataservice.accuweather.com/currentconditions/v1/${key}?apikey=${process.env.ACCU_KEY}&details=true&language=tr-tr`;
```

**/api/places (POST)**
```ts
// body: { city, weather: { summary, temperatureC }, locale }
const system = SYSTEM_PROMPT;
const user = renderUserPrompt(...);
const resp = await openai.responses.create({ model: 'gpt-4o-mini', messages: [
  { role: 'system', content: system },
  { role: 'user', content: user }
], response_format: { type: 'json_object' } });
return JSON.parse(resp.output_text);
```

---

## 13) Tasarım Notları
- Kartlar: `rounded-2xl`, gölge, hover’da hafif yükselme
- Tipografi: Başlıklar `text-xl`, kart başlıkları `text-lg`, açıklamalar `text-sm`
- Grid: mobil 1, md 2, lg 3 sütun
- İkonlar: hava durumu için AccuWeather kod → yerel ikon eşleme tablosu

---

## 14) Riskler & Alternatifler
- AccuWeather kota/süre limitleri → OpenWeatherMap alternatifi (benzer akış)
- ChatGPT maliyeti → `gpt-4o-mini` + caching, sonuçları 6-12 saat cache’le
- Şehir ismi belirsizliği → ülke seçimi/dil opsiyonu eklemek

---

## 15) Kabul Kriterleri (MVP)
- [ ] Kullanıcı şehir girer; en geç 2 API çağrısıyla hava durumu görünür.
- [ ] Havanın ardından 6–12 adet öneri JSON olarak gelir ve kartlarda listelenir.
- [ ] Filtre çubuğu ile kategoriye göre daraltılabilir.
- [ ] Hatalar kullanıcı dostu mesajlarla gösterilir.
- [ ] Anahtarlar client’a sızmaz (tüm dış çağrılar backend/proxy üzerinden).

---

Bu doküman, Cursor içinde parça parça görevler açıp hızlı iskelet üretimi için optimize edilmiştir. İstersen anahtar teslim başlangıç kod iskeletini de çıkarabilirim.

