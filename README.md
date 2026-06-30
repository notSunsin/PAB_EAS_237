# 🛒 Pasar Lokal — Marketplace UMKM Digital

Aplikasi mobile marketplace untuk produk UMKM lokal Indonesia, dibangun dengan Flutter.

---

## 🏗️ Arsitektur

Proyek ini menggunakan **Clean Architecture** dengan pola **MVVM + Provider**:

```
lib/
├── core/                     # Konstanta, tema, utilitas
│   ├── constants/
│   ├── theme/
│   └── utils/
├── data/                     # Layer data
│   ├── models/               # Data model (User, Product, CartItem)
│   ├── repositories/         # Business logic & aggregasi data
│   └── services/             # API service (HTTP) & Local Storage
├── presentation/             # Layer UI
│   ├── providers/            # State management (AuthProvider, ProductProvider, CartProvider)
│   ├── screens/              # Layar aplikasi
│   └── widgets/              # Komponen reusable
└── routes/                   # Konfigurasi routing
```

---

## ✅ Fitur Utama

| Fitur | Teknologi |
|-------|-----------|
| Autentikasi (Login, Register, Logout) | SharedPreferences + Custom REST API |
| Daftar & Detail Produk | REST API GET (FakeStoreAPI) |
| Filter Kategori & Pencarian | Provider State Management |
| Keranjang Belanja | Provider + SharedPreferences (cache offline) |
| Checkout & Simulasi Pembayaran | State lokal |
| Foto Profil | image_picker (Kamera & Galeri) |
| Loading State | Shimmer |
| Error Handling (offline, timeout, 4xx, 5xx) | Custom ApiException |

---

## 🔌 API Integration

- **Base URL**: `https://fakestoreapi.com` *(dapat diganti di `lib/core/constants/api_constants.dart`)*
- **Metode HTTP**:
  - `GET /products` — Ambil semua produk
  - `GET /products/{id}` — Detail produk
  - `GET /products/categories` — Daftar kategori
  - `GET /products/category/{cat}` — Filter per kategori
  - `POST /products` — Tambah produk (demo)
  - `PUT /products/{id}` — Update produk (demo)
  - `DELETE /products/{id}` — Hapus produk (demo)
  - `POST /auth/login` — Login token

---

## 🛠️ Instalasi

### Prasyarat
- Flutter SDK ≥ 3.3.0
- Android Studio / VS Code
- Device / Emulator Android atau iOS

### Langkah

```bash
# 1. Clone repo
git clone https://github.com/username/pasar_lokal.git
cd pasar_lokal

# 2. Install dependencies
flutter pub get

# 3. Jalankan
flutter run
```

### Build APK

```bash
flutter build apk --release
# APK tersimpan di: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📦 Dependencies Utama

| Package | Versi | Fungsi |
|---------|-------|--------|
| `provider` | ^6.1.2 | State Management |
| `http` | ^1.2.1 | HTTP Client (REST API) |
| `shared_preferences` | ^2.3.2 | Local Storage |
| `image_picker` | ^1.1.2 | Kamera & Galeri (Native Feature) |
| `cached_network_image` | ^3.3.1 | Cache gambar produk |
| `shimmer` | ^3.0.0 | Loading skeleton |
| `badges` | ^3.1.2 | Badge notifikasi keranjang |
| `intl` | ^0.19.0 | Format mata uang IDR |

---

## 🔑 Akun Demo

Gunakan akun FakeStoreAPI untuk demo login via API endpoint:
- **Email**: `mor_2314@gmail.com`
- **Password**: `83r5^_`

Atau daftarkan akun baru melalui halaman Register.

---

## 📂 State Management (Provider)

```
AuthProvider   — status login, data user, token
ProductProvider — daftar produk, kategori, filter, search, loading/error
CartProvider   — item keranjang, jumlah, subtotal, PPN, total
```

---

*Dibuat untuk EAS Pengembangan Aplikasi Bergerak — Universitas 17 Agustus 1945 Surabaya*
#
