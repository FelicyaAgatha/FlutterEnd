import { NextResponse } from 'next/server';
import type { ResultSetHeader } from 'mysql2';
import database from '../../../lib/database';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

function kirim(data: object, status: number) {
  return NextResponse.json(data, {
    status,
    headers: corsHeaders,
  });
}

export async function OPTIONS() {
  return new Response(null, {
    status: 204,
    headers: corsHeaders,
  });
}

// Menampilkan seluruh siswa
export async function GET() {
  try {
    const [rows] = await database.query(`
      SELECT
        id, nipd, nama_lengkap, jenis_kelamin,
        alamat, kelas, jurusan
      FROM siswa
      ORDER BY id ASC
    `);

    return kirim({
      status: true,
      message: 'Data siswa berhasil diambil',
      data: rows,
    }, 200);
  } catch (error) {
    console.error('Gagal mengambil siswa:', error);

    return kirim({
      status: false,
      message: 'Data siswa gagal diambil',
    }, 500);
  }
}

// Menambahkan siswa
export async function POST(request: Request) {
  let body;

  try {
    body = await request.json();
  } catch {
    return kirim({
      status: false,
      message: 'Body harus berupa JSON yang valid',
    }, 400);
  }

  if (!body || typeof body !== 'object' || Array.isArray(body)) {
    return kirim({
      status: false,
      message: 'Body harus berupa objek JSON',
    }, 400);
  }

  const fields = [
    'nipd',
    'nama_lengkap',
    'jenis_kelamin',
    'alamat',
    'kelas',
    'jurusan',
  ] as const;

  for (const field of fields) {
    if (typeof body[field] !== 'string' || !body[field].trim()) {
      return kirim({
        status: false,
        message: `${field} wajib diisi dengan teks`,
      }, 400);
    }
  }

  const nipd = body.nipd.trim();
  const nama_lengkap = body.nama_lengkap.trim();
  const jenis_kelamin = body.jenis_kelamin.trim();
  const alamat = body.alamat.trim();
  const kelas = body.kelas.trim();
  const jurusan = body.jurusan.trim();

  if (!['Laki-laki', 'Perempuan'].includes(jenis_kelamin)) {
    return kirim({
      status: false,
      message: 'Jenis kelamin harus Laki-laki atau Perempuan',
    }, 400);
  }

  if (
    nipd.length > 30 ||
    nama_lengkap.length > 100 ||
    kelas.length > 20 ||
    jurusan.length > 100
  ) {
    return kirim({
      status: false,
      message: 'NIPD maksimal 30, nama dan jurusan 100, kelas 20 karakter',
    }, 400);
  }

  try {
    const [result] = await database.execute<ResultSetHeader>(
      `INSERT INTO siswa
        (nipd, nama_lengkap, jenis_kelamin, alamat, kelas, jurusan)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [nipd, nama_lengkap, jenis_kelamin, alamat, kelas, jurusan]
    );

    return kirim({
      status: true,
      message: 'Data siswa berhasil ditambahkan',
      data: {
        id: result.insertId,
        nipd,
        nama_lengkap,
        jenis_kelamin,
        alamat,
        kelas,
        jurusan,
      },
    }, 201);
  } catch (error) {
    if (
      error !== null &&
      typeof error === 'object' &&
      'code' in error &&
      error.code === 'ER_DUP_ENTRY'
    ) {
      return kirim({
        status: false,
        message: 'NIPD sudah digunakan siswa lain',
      }, 409);
    }

    console.error('Gagal menambahkan siswa:', error);

    return kirim({
      status: false,
      message: 'Data siswa gagal ditambahkan',
    }, 500);
  }
}