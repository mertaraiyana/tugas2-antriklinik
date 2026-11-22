# AntriKlinik - Smart Dental Queue & Weather Assistant

**Tugas 2 – Aplikasi Berbasis Platform (TI253304)**  
**Nama:** I Made Merta Raiyana  
**NIM:** 240040014  
**Kelas:** CA244  
**Program Studi:** Teknologi Informasi – ITB STIKOM Bali  

---

## 1. Deskripsi & Kondisi Awal Project
* **Kondisi Awal:** Project ini dibuat baru dari awal (*clean starter project* Flutter) tanpa menimpa tugas sebelumnya, dengan menerapkan pola arsitektur **MVVM (Model–View–ViewModel) + Repository + Service**.
* **Fungsi Utama:** Aplikasi multiplatform untuk membantu pasien klinik gigi mengambil nomor antrean dari jarak jauh, memantau nomor antrean yang sedang dilayani secara *real-time*, menerima peringatan saat giliran tinggal ≤ 3 nomor lagi, serta mengecek jarak GPS menuju klinik dan kondisi cuaca perjalanan secara langsung.

---

## 2. Integrasi API Eksternal & Fitur Device
1. **API Eksternal (REST API + JSON):**
   * **Open-Meteo Weather Forecast API** (`https://open-meteo.com`): Mengambil suhu dan kondisi cuaca terkini berdasarkan koordinat lokasi perangkat pasien.
   * **JSONPlaceholder REST API** (`https://typicode.com`): Simulasi pengiriman data pendaftaran tiket antrean (`POST`) beserta koordinat GPS dan info cuaca.
   * **Autentikasi / API Key:** Kedua API bersifat publik dan menggunakan protokol **HTTPS** tanpa memerlukan API key (sehingga tidak ada kredensial rahasia di dalam kode maupun repository ini).
2. **Fitur Device (GPS):**
   * Menggunakan package **`geolocator`** untuk membaca koordinat lokasi (`latitude` & `longitude`) perangkat dan menghitung jarak ke Klinik Gigi Denpasar (`-8.6500, 115.2167`), yang langsung digunakan sebagai parameter pemanggilan Open-Meteo API.

---

## 3. Konfigurasi Izin (Permissions)
* **Android (`android/app/src/main/AndroidManifest.xml`):**
  * `android.permission.INTERNET`
  * `android.permission.ACCESS_FINE_LOCATION`
  * `android.permission.ACCESS_COARSE_LOCATION`
* **iOS (`ios/Runner/Info.plist`):**
  * `NSLocationWhenInUseUsageDescription`: Penjelasan alasan akses lokasi GPS untuk menghitung jarak ke klinik dan mengecek kondisi cuaca perjalanan.
* **Penanganan Penolakan Izin:** Jika pengguna menolak izin lokasi atau sensor GPS tidak aktif, aplikasi tidak mengalami *crash* melainkan beralih ke lokasi cadangan (*fallback*) area Klinik Denpasar disertai banner peringatan informatif.

---

## 4. Langkah Instalasi & Cara Menjalankan

Pastikan Flutter SDK sudah terinstal dan perangkat/emulator (Android/iOS/Chrome) sudah aktif, lalu jalankan perintah berikut di terminal:

1. **Clone repository ini:**
   ```bash
   git clone https://github.com
   cd antri_klinik
   ```
2. **Unduh seluruh package dependencies:**
   ```bash
   flutter pub get
   ```
3. **Jalankan pengecekan analisis kode (memastikan 0 error):**
   ```bash
   flutter analyze
   ```
4. **Jalankan pengujian otomatis (Unit Test ViewModel):**
   ```bash
   flutter test
   ```
5. **Jalankan aplikasi:**
   ```bash
   flutter run
   ```
