CREATE DATABASE IF NOT EXISTS db_toko;
USE db_toko;

CREATE TABLE IF NOT EXISTS siswa (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nipd VARCHAR(30) NOT NULL UNIQUE,
    nama_lengkap VARCHAR(100) NOT NULL,
    jenis_kelamin ENUM('Laki-laki', 'Perempuan') NOT NULL,
    alamat TEXT NOT NULL,
    kelas VARCHAR(20) NOT NULL,
    jurusan VARCHAR(100) NOT NULL
);