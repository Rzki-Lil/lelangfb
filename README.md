# Lelang FB - Proyek Akhir Mobile Programming

## Deskripsi
Lelang FB adalah aplikasi lelang online berbasis mobile yang dikembangkan menggunakan Flutter dengan GetX sebagai state management dan Firebase sebagai backend. Aplikasi ini merupakan proyek tugas akhir untuk mata kuliah Mobile Programming dan bertujuan untuk memenuhi persyaratan submisi tugas akhir.

## Fitur Utama
- **Registrasi dan Login**: Autentikasi pengguna dengan Firebase Authentication.
- **Pengelolaan Barang Lelang**:
  - Menambahkan barang lelang dengan atribut seperti waktu mulai, waktu selesai, harga awal, dan status.
  - Pembaruan status barang secara otomatis di Cloud Firestore tanpa memerlukan aplikasi aktif.
- **Penawaran**:
  - Pengguna dapat memberikan penawaran (bid) secara real-time.
  - Lelang dengan bid tertinggi akan tercatat sebagai pemenang setelah waktu lelang selesai.
- **Notifikasi**: Notifikasi real-time untuk setiap aktivitas penting seperti penawaran baru atau lelang yang dimenangkan.
- **Favorit**: Menandai barang favorit untuk memudahkan akses di masa depan.
- **Manajemen Profil Pengguna**: Meliputi informasi pribadi, saldo, dan riwayat transaksi.
- **Sistem Rating Penjual**: Memberikan rating untuk penjual setelah lelang selesai.

## Teknologi yang Digunakan
- **Frontend**: Flutter dengan GetX untuk state management
- **Backend**: Firebase Authentication, Cloud Firestore, Firebase Cloud Messaging

## Struktur Data Firebase

### Koleksi `items`
- **Fields**:
  - bid_count
  - category
  - created_at
  - current_price
  - description
  - imageUrl[]
  - jamMulai
  - jamSelesai
  - last_bidder
  - lokasi
  - name
  - rarity
  - seller_id
  - starting_price
  - status
  - tanggal
  - updated_at
  - winner_id
- **Subcollection `bids`**:
  - amount
  - bidder_id
  - bidder_name
  - bidder_photo
  - timestamp

### Koleksi `users`
- **Fields**:
  - balance
  - displayName
  - email
  - isVerified
  - phoneNumber
  - photoURL
  - provider[]
  - rating
  - ratingCount
  - updatedAt
  - verified_buyer_seller
- **Subcollections**:
  - `notifications`
  - `favorites`
  - `addresses`

### Koleksi `transactions`
- **Fields**:
  - amount
  - itemId
  - status
  - timestamp
  - type
  - userId

### Koleksi `seller_ratings`
- **Fields**:
  - auction_id
  - seller_id
  - timestamp
  - user_id

## Cara Menjalankan
1. Clone repositori ini.
2. Pastikan Flutter sudah terinstal di sistem Anda.
3. Konfigurasi Firebase di proyek Flutter dengan file `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS).
4. Jalankan perintah berikut di terminal:
   ```bash
   flutter pub get
   flutter run
