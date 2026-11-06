import { NextResponse } from 'next/server';
import type { RowDataPacket } from 'mysql2';
import { compare } from 'bcryptjs';
import { SignJWT } from 'jose';
import database from '../../../lib/database';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Cache-Control': 'no-store',
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

  if (
    !body ||
    typeof body !== 'object' ||
    Array.isArray(body) ||
    typeof body.email !== 'string' ||
    typeof body.password !== 'string'
  ) {
    return kirim({
      status: false,
      message: 'Email dan password wajib diisi',
    }, 400);
  }

  const email = body.email.trim().toLowerCase();
  const password = body.password;

  if (
    !email ||
    email.length > 100 ||
    !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) ||
    !password ||
    Buffer.byteLength(password, 'utf8') > 72
  ) {
    return kirim({
      status: false,
      message: 'Email atau password tidak valid',
    }, 400);
  }

  const secret = process.env.JWT_SECRET;

  if (!secret || Buffer.byteLength(secret, 'utf8') < 32) {
    console.error('JWT_SECRET belum diatur dengan benar');

    return kirim({
      status: false,
      message: 'Konfigurasi login belum lengkap',
    }, 500);
  }

  try {
    const [rows] = await database.execute<RowDataPacket[]>(
      `SELECT id, nama, email, password, status
       FROM users
       WHERE email = ?
       LIMIT 1`,
      [email]
    );

    const user = rows[0];

    if (!user || user.status !== 'Aktif') {
      return kirim({
        status: false,
        message: 'Email atau password salah, atau akun tidak aktif',
      }, 401);
    }

    const passwordCocok = await compare(password, user.password);

    if (!passwordCocok) {
      return kirim({
        status: false,
        message: 'Email atau password salah, atau akun tidak aktif',
      }, 401);
    }

    const token = await new SignJWT({
      nama: user.nama,
    })
      .setProtectedHeader({ alg: 'HS256' })
      .setSubject(String(user.id))
      .setIssuedAt()
      .setExpirationTime('8h')
      .sign(new TextEncoder().encode(secret));

    return kirim({
      status: true,
      message: 'Login berhasil',
      data: {
        id: user.id,
        nama: user.nama,
        email: user.email,
        token,
      },
    }, 200);
  } catch (error) {
    console.error('Gagal login:', error);

    return kirim({
      status: false,
      message: 'Login gagal diproses oleh server',
    }, 500);
  }
}