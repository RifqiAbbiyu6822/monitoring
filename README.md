# Monitoring Jalan Tol MBZ

Aplikasi monitoring untuk jalan tol MBZ yang memungkinkan pengguna untuk mencatat temuan, membuat perbaikan, dan melacak progress pekerjaan.

## Fitur Utama

### 1. Manajemen Temuan
- Pencatatan temuan dengan kategori dan subkategori
- Penambahan foto untuk dokumentasi temuan
- Penentuan prioritas dan status temuan
- Lokasi dengan koordinat GPS

### 2. Manajemen Perbaikan
- Pembuatan perbaikan berdasarkan temuan
- Penambahan foto sebelum, progress, dan sesudah perbaikan
- **Fitur Baru: Foto Per Progress** - Menampilkan foto progress pekerjaan dengan informasi tambahan seperti tanggal dan persentase progress
- Tracking progress pekerjaan
- Penentuan kontraktor dan jadwal

### 3. Riwayat dan Laporan
- Riwayat lengkap temuan dan perbaikan
- Filter dan pengurutan data
- Laporan statistik

### 4. Database Management
- Backup dan restore database
- Export data

## Fitur Foto Per Progress

### Detail Temuan
- Menampilkan foto temuan dalam grid 3x3
- Mode view-only dengan kemampuan zoom
- Indikator nomor foto
- Icon view untuk melihat foto dalam layar penuh

### Detail Perbaikan
- **Foto Sebelum**: Menampilkan kondisi awal sebelum perbaikan
- **Foto Progress**: Menampilkan progress pekerjaan dengan layout 2x2 dan informasi tambahan
- **Foto Sesudah**: Menampilkan hasil akhir perbaikan

### Widget Foto Progress
- Layout khusus untuk foto progress dengan aspect ratio 0.8
- Dukungan metadata untuk setiap foto (tanggal, progress percentage, deskripsi)
- Progress bar untuk setiap foto progress
- Tampilan yang lebih informatif untuk tracking progress pekerjaan

## Teknologi

- **Framework**: Flutter
- **Database**: SQLite dengan sqflite
- **State Management**: StatefulWidget
- **UI Components**: Material Design 3

## Struktur Proyek

```
lib/
├── config/           # Konfigurasi kategori
├── model/           # Model data (Temuan, Perbaikan)
├── screens/         # Halaman aplikasi
├── services/        # Layanan (database, storage, location, photo)
├── utils/           # Utilitas (theme, helpers, validators)
└── widgets/         # Komponen UI yang dapat digunakan kembali
    ├── photo_widgets.dart      # Widget untuk menampilkan foto
    ├── PhotoViewerWidget       # Widget view-only untuk foto
    ├── ProgressPhotoViewerWidget # Widget khusus foto progress
    └── PhotoViewerScreen       # Layar penuh untuk melihat foto
```

## Cara Penggunaan

1. **Menambah Temuan**:
   - Pilih menu "Temuan"
   - Klik "Temuan Baru"
   - Isi form dan tambahkan foto
   - Simpan temuan

2. **Membuat Perbaikan**:
   - Pilih menu "Perbaikan"
   - Klik "Perbaikan Baru" atau "Dari Temuan"
   - Isi form dan tambahkan foto sebelum, progress, dan sesudah
   - Update progress secara berkala

3. **Melihat Detail**:
   - Klik pada item temuan atau perbaikan
   - Lihat foto dalam detail view
   - Klik foto untuk melihat dalam layar penuh

4. **Riwayat**:
   - Pilih menu "Riwayat"
   - Filter berdasarkan status
   - Lihat detail lengkap termasuk foto

## Instalasi

1. Clone repository
2. Install dependencies: `flutter pub get`
3. Run aplikasi: `flutter run`

## Kontribusi

Silakan berkontribusi dengan membuat pull request atau melaporkan bug melalui issues.
