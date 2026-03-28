# Firestore Seed Ornekleri

Asagidaki ornekler mobil uygulama alanlari ile uyumludur.

## settings/app

```json
{
  "appName": "1.5 Adana Teknoloji Takimlari",
  "aboutTitle": "Hakkimizda",
  "aboutContent": "1.5 Adana teknoloji takimlari ogrencilerin proje gelistirme, yarismalara katilma ve Ar-Ge kulturunu guclendirme amaciyla bir aradadir.",
  "contactEmail": "info@15adana.com",
  "contactPhone": "+90 5xx xxx xx xx",
  "contactAddress": "Adana",
  "socialLinks": [
    { "platform": "Instagram", "url": "https://instagram.com/15adana", "visible": true },
    { "platform": "YouTube", "url": "https://youtube.com/@15adana", "visible": true }
  ]
}
```

## announcements/ornek-duyuru

```json
{
  "title": "TEKNOFEST On Duyurusu",
  "summary": "Basvuru sureci acildi.",
  "content": "Takimlarimiz bu yil bircok kategoride yarismaya hazirlaniyor.",
  "imageUrl": "https://.../duyuru.jpg",
  "order": 1,
  "visible": true,
  "buttonText": "Detayli Bilgi",
  "buttonUrl": "https://15adana.com",
  "showAsPopup": true,
  "popupDismissKey": "teknofest-2026"
}
```

## teams/insansiz-hava-araci

```json
{
  "name": "IHA Takimi",
  "logoUrl": "https://.../iha-logo.png",
  "shortDescription": "Insansiz hava araci gelistirme takimi",
  "description": "IHA Takimi sabit kanat ve otonom ucus sistemleri gelistirir.",
  "bannerUrl": "https://.../iha-banner.jpg",
  "homeOrder": 1,
  "visible": true,
  "socialLinks": [
    { "platform": "Instagram", "url": "https://instagram.com/iha", "visible": true }
  ]
}
```
