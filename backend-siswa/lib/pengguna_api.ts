import { NextResponse } from 'next/server';
import type { RowDataPacket } from 'mysql2';
import { jwtVerify } from 'jose';
import database from './database';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Cache-Control': 'no-store',
};

export function kirim(
  status: number,
  message: string,
  data?: unknown
) {
  return NextResponse.json(
    {
      status: status >= 200 && status < 300,
      message,
      ...(data !== undefined ? { data } : {}),
    },
    { status, headers: corsHeaders }
  );
}

export function options() {
  return new Response(null, {
    status: 204,
    headers: corsHeaders,
  });
}

export class Kesalahan extends Error {
  status: number;

  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

export function tanganiError(error: unknown) {
  if (error instanceof Kesalahan) {
    return kirim(error.status, error.message);
  }

  if (
    error &&
    typeof error === 'object' &&
    'code' in error &&
    error.code === 'ER_DUP_ENTRY'
  ) {
    return kirim(409, 'Email sudah digunakan.');
  }

  console.error('API pengguna:', error);

  return kirim(
    500,
    'Data gagal diproses. Periksa terminal backend dan koneksi MySQL.'
  );
}

export async function periksaLogin(request: Request) {
  const secret = process.env.JWT_SECRET;

  if (!secret || Buffer.byteLength(secret, 'utf8') < 32) {
    throw new Kesalahan(500, 'Konfigurasi login belum lengkap.');
  }

  const authorization = request.headers.get('Authorization');

  if (!authorization?.startsWith('Bearer ')) {
    throw new Kesalahan(401, 'Silakan login terlebih dahulu.');
  }

  let id: number;

  try {
    const { payload } = await jwtVerify(
      authorization.slice(7),
      new TextEncoder().encode(secret),
      { algorithms: ['HS256'] }
    );

    id = Number(payload.sub);

    if (!Number.isSafeInteger(id) || id < 1) {
      throw new Error('ID token tidak valid');
    }
  } catch {
    throw new Kesalahan(
      401,
      'Sesi berakhir. Keluar dan login kembali.'
    );
  }

  const [rows] = await database.execute<RowDataPacket[]>(
    'SELECT id FROM users WHERE id = ? AND status = ?',
    [id, 'Aktif']
  );

  if (!rows.length) {
    throw new Kesalahan(401, 'Akun sudah tidak aktif.');
  }

  return id;
}

export function bacaId(value: string) {
  const id = Number(value);

  if (!/^[1-9]\d*$/.test(value) || !Number.isSafeInteger(id)) {
    throw new Kesalahan(400, 'ID pengguna tidak valid.');
  }

  return id;
}

export async function bacaInput(
  request: Request,
  membuatBaru: boolean
) {
  let body;

  try {
    body = await request.json();
  } catch {
    throw new Kesalahan(400, 'Body harus berupa JSON yang valid.');
  }

  if (!body || typeof body !== 'object' || Array.isArray(body)) {
    throw new Kesalahan(400, 'Body harus berupa objek JSON.');
  }

  const nama =
    typeof body.nama === 'string' ? body.nama.trim() : '';

  const email =
    typeof body.email === 'string'
      ? body.email.trim().toLowerCase()
      : '';

  const status = body.status ?? 'Aktif';

  const password =
    typeof body.password === 'string' ? body.password : '';

  if (!nama || nama.length > 100) {
    throw new Kesalahan(400, 'Nama wajib diisi, maksimal 100 karakter.');
  }

  if (
    email.length > 100 ||
    !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
  ) {
    throw new Kesalahan(400, 'Email tidak valid.');
  }

  if (!['Aktif', 'Tidak Aktif'].includes(status)) {
    throw new Kesalahan(400, 'Status pengguna tidak valid.');
  }

  if (membuatBaru || password !== '') {
    if (
      password.length < 8 ||
      Buffer.byteLength(password, 'utf8') > 72
    ) {
      throw new Kesalahan(
        400,
        'Password minimal 8 karakter dan maksimal 72 byte.'
      );
    }
  }

  return { nama, email, status, password };
}

export async function periksaEmail(email: string, id = 0) {
  const [rows] = await database.execute<RowDataPacket[]>(
    'SELECT id FROM users WHERE email = ? AND id <> ? LIMIT 1',
    [email, id]
  );

  if (rows.length) {
    throw new Kesalahan(409, 'Email sudah digunakan pengguna lain.');
  }
}