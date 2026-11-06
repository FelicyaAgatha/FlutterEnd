# Backend Manajemen Sekolah

REST API untuk aplikasi Manajemen Sekolah menggunakan Next.js, TypeScript, dan MySQL. Backend ini digunakan oleh aplikasi Flutter untuk login serta pengelolaan data pengguna dan siswa.

## Teknologi

- Next.js App Router
- TypeScript
- MySQL
- mysql2
- bcryptjs untuk hash password
- jose untuk token JWT
- Postman untuk pengujian API

## Fitur

### Autentikasi
- Login menggunakan email dan password.
- Pemeriksaan password menggunakan bcrypt.
- Login hanya untuk pengguna berstatus Aktif.
- Token login berlaku selama 8 jam.

### Data Pengguna
- Menampilkan daftar pengguna.
- Menambahkan pengguna.
- Mengedit nama, email, password, dan status.
- Menghapus pengguna.
- Password disimpan dalam bentuk hash dan tidak dikirim dalam respons API.
- Akun yang sedang digunakan tidak dapat dihapus atau dinonaktifkan.
- Saat edit, password dapat dikosongkan agar password lama tetap digunakan.

### Data Siswa
- Menampilkan seluruh siswa.
- Menampilkan detail siswa berdasarkan ID.
- Menambahkan siswa.
- Mengedit siswa.
- Menghapus siswa.
- Validasi NIPD duplikat.

## Struktur Utama

- `app/api/login/route.ts` — API login.
- `app/api/users/route.ts` — daftar dan tambah pengguna.
- `app/api/users/[id]/route.ts` — edit dan hapus pengguna.
- `app/api/siswa/route.ts` — daftar dan tambah siswa.
- `app/api/siswa/[id]/route.ts` — detail, edit, dan hapus siswa.
- `lib/database.ts` — koneksi MySQL.
- `lib/pengguna_api.ts` — autentikasi dan validasi API pengguna.
- `database/` — berkas SQL.
- `postman/` — collection Postman.
- `docs/postman/` — dokumentasi pengujian API.

## Persiapan

Siapkan:

1. Node.js dan npm yang kompatibel dengan versi Next.js proyek.
2. MySQL, misalnya melalui Laragon.
3. Git.
4. Postman untuk mencoba endpoint.

## Menjalankan Backend

### 1. Clone repository

```bash
git clone https://github.com/FelicyaAgatha/backend-siswa.git
cd backend-siswa
```

### 2. Install dependensi

Untuk Windows PowerShell:

```powershell
npm.cmd install
```

### 3. Siapkan database

Jalankan MySQL melalui Laragon.

Siapkan database `db_toko` dengan tabel:

| Tabel | Kolom |
|---|---|
| `users` | `id`, `nama`, `email`, `password`, `created_at`, `status` |
| `siswa` | `id`, `nipd`, `nama_lengkap`, `jenis_kelamin`, `alamat`, `kelas`, `jurusan` |

Gunakan berkas SQL yang tersedia di folder `database/` untuk tabel yang disertakan.

Tabel `users` dan akun login perlu disiapkan apabila belum tersedia. Password akun harus berupa hash bcrypt, bukan teks biasa.

Install dependensi tidak otomatis membuat database atau akun pengguna.

### 4. Atur environment

Salin `.env.example` menjadi `.env.local`:

```powershell
Copy-Item .env.example .env.local
```

Sesuaikan isinya:

```dotenv
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=db_toko
JWT_SECRET=
```

Buat nilai acak untuk `JWT_SECRET`:

```powershell
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Tempel hasil perintah tersebut sebagai nilai `JWT_SECRET`.

Sesuaikan `DB_PASSWORD` dengan password MySQL di komputer masing-masing. File `.env.local` tidak boleh diunggah ke repository.

### 5. Jalankan server

```powershell
npm.cmd run dev -- --port 3001
```

Alamat backend:

```text
http://localhost:3001
```

Biarkan terminal server dan MySQL tetap berjalan selama aplikasi digunakan.

## Endpoint API

| Method | Endpoint | Fungsi |
|---|---|---|
| POST | `/api/login` | Login pengguna |
| GET | `/api/users` | Menampilkan pengguna |
| POST | `/api/users` | Menambahkan pengguna |
| PUT | `/api/users/{id}` | Memperbarui pengguna |
| DELETE | `/api/users/{id}` | Menghapus pengguna |
| GET | `/api/siswa` | Menampilkan siswa |
| GET | `/api/siswa/{id}` | Menampilkan detail siswa |
| POST | `/api/siswa` | Menambahkan siswa |
| PUT | `/api/siswa/{id}` | Memperbarui siswa |
| DELETE | `/api/siswa/{id}` | Menghapus siswa |

Ganti `{id}` dengan ID data yang tersedia di database.

## Contoh Login

**POST** `http://localhost:3001/api/login`

Pilih **Body → raw → JSON** di Postman:

```json
{
  "email": "email_akun_anda",
  "password": "password_akun_anda"
}
```

Gunakan email dan password asli akun yang berstatus Aktif.

Setelah berhasil, token tersedia pada `data.token`.

## Autentikasi API Pengguna

Endpoint `/api/users` dan `/api/users/{id}` membutuhkan header:

```text
Authorization: Bearer TOKEN_LOGIN
```

Di Postman, pilih **Authorization → Bearer Token**, lalu isi token hasil login.

## Contoh Input Pengguna

```json
{
  "nama": "Pengelola Sekolah",
  "email": "pengelola@example.com",
  "password": "GantiDenganPasswordAnda",
  "status": "Aktif"
}
```

Pilihan status pengguna:

- Aktif
- Tidak Aktif

Saat mengedit pengguna, kosongkan atau jangan sertakan password jika tidak ingin mengubahnya.

## Contoh Input Siswa

```json
{
  "nipd": "24251002",
  "nama_lengkap": "Siswa Contoh",
  "jenis_kelamin": "Perempuan",
  "alamat": "Parungpanjang",
  "kelas": "XII",
  "jurusan": "Rekayasa Perangkat Lunak"
}
```

Pilihan kelas pada aplikasi Flutter:

- X
- XI
- XII

Pilihan jurusan pada aplikasi Flutter:

- Rekayasa Perangkat Lunak
- Teknik Komputer dan Jaringan
- Desain Komunikasi Visual
- Bisnis Digital
- Tax Accounting

Pencarian dan filter daftar dilakukan pada aplikasi Flutter. Endpoint daftar saat ini mengembalikan seluruh data.

## Akses dari HP

HP dan laptop harus berada pada jaringan yang sama.

Jalankan backend agar dapat diakses melalui jaringan lokal:

```powershell
npm.cmd run dev -- --hostname 0.0.0.0 --port 3001
```

Cari IPv4 laptop:

```powershell
ipconfig
```

Gunakan alamat berikut pada konfigurasi API aplikasi:

```text
http://IP_LAPTOP:3001
```

`localhost` pada HP mengarah ke HP itu sendiri, sehingga aplikasi di HP harus menggunakan IP laptop.

## Format Respons

Contoh respons berhasil:

```json
{
  "status": true,
  "message": "Data pengguna berhasil diambil.",
  "data": []
}
```

Contoh respons gagal:

```json
{
  "status": false,
  "message": "Silakan login terlebih dahulu."
}
```

## Penanganan Kendala

| Kendala | Pemeriksaan |
|---|---|
| `ECONNREFUSED` pada port 3306 | Pastikan MySQL aktif dan port database sesuai |
| `405 Method Not Allowed` | Periksa method dan fungsi yang diekspor oleh `route.ts` |
| `401 Unauthorized` | Periksa akun, status pengguna, dan token |
| `500 Internal Server Error` | Baca detail error di terminal backend |
| HP tidak dapat mengakses API | Periksa IP laptop, jaringan, dan izin firewall |

## Status Pengembangan

- Login email dan password tersedia.
- CRUD pengguna dilindungi pemeriksaan token.
- CRUD siswa tersedia.
- Pemeriksaan token pada endpoint siswa masih perlu dilengkapi.
- Status kelulusan siswa belum tersedia pada versi ini.
- Konfigurasi saat ini digunakan untuk pengembangan lokal.

## Tim Pengembang

- Felicya Agatha Susanto Lie
- Ramadhan Agil Siraj