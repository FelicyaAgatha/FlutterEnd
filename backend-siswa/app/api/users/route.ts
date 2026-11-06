import type { ResultSetHeader } from 'mysql2';
import { hash } from 'bcryptjs';
import database from '../../../lib/database';

import {
  kirim,
  options,
  periksaLogin,
  bacaInput,
  periksaEmail,
  tanganiError,
} from '../../../lib/pengguna_api';

export async function OPTIONS() {
  return options();
}

export async function GET(request: Request) {
  try {
    await periksaLogin(request);

    const [rows] = await database.query(
      `SELECT id, nama, email, status
       FROM users
       ORDER BY nama ASC`
    );

    return kirim(200, 'Data pengguna berhasil diambil.', rows);
  } catch (error) {
    return tanganiError(error);
  }
}

export async function POST(request: Request) {
  try {
    await periksaLogin(request);

    const input = await bacaInput(request, true);

    await periksaEmail(input.email);

    const passwordHash = await hash(input.password, 10);

    const [result] = await database.execute<ResultSetHeader>(
      `INSERT INTO users (nama, email, password, status)
       VALUES (?, ?, ?, ?)`,
      [
        input.nama,
        input.email,
        passwordHash,
        input.status,
      ]
    );

    return kirim(201, 'Pengguna berhasil ditambahkan.', {
      id: result.insertId,
      nama: input.nama,
      email: input.email,
      status: input.status,
    });
  } catch (error) {
    return tanganiError(error);
  }
}