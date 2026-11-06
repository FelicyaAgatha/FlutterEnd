import type { RowDataPacket, ResultSetHeader } from 'mysql2';
import { hash } from 'bcryptjs';
import database from '../../../../lib/database';

import {
  kirim,
  options,
  periksaLogin,
  bacaId,
  bacaInput,
  periksaEmail,
  tanganiError,
  Kesalahan,
} from '../../../../lib/pengguna_api';

type Context = {
  params: Promise<{ id: string }>;
};

export async function OPTIONS() {
  return options();
}

export async function PUT(request: Request, context: Context) {
  try {
    const akunLogin = await periksaLogin(request);
    const params = await context.params;
    const id = bacaId(params.id);
    const input = await bacaInput(request, false);

    if (id === akunLogin && input.status !== 'Aktif') {
      throw new Kesalahan(
        400,
        'Akun yang sedang digunakan tidak boleh dinonaktifkan.'
      );
    }

    const [rows] = await database.execute<RowDataPacket[]>(
      'SELECT id FROM users WHERE id = ?',
      [id]
    );

    if (!rows.length) {
      throw new Kesalahan(404, 'Pengguna tidak ditemukan.');
    }

    await periksaEmail(input.email, id);

    if (input.password) {
      const passwordHash = await hash(input.password, 10);

      await database.execute(
        `UPDATE users
         SET nama = ?, email = ?, password = ?, status = ?
         WHERE id = ?`,
        [
          input.nama,
          input.email,
          passwordHash,
          input.status,
          id,
        ]
      );
    } else {
      await database.execute(
        `UPDATE users
         SET nama = ?, email = ?, status = ?
         WHERE id = ?`,
        [
          input.nama,
          input.email,
          input.status,
          id,
        ]
      );
    }

    return kirim(200, 'Pengguna berhasil diperbarui.', {
      id,
      nama: input.nama,
      email: input.email,
      status: input.status,
    });
  } catch (error) {
    return tanganiError(error);
  }
}

export async function DELETE(request: Request, context: Context) {
  try {
    const akunLogin = await periksaLogin(request);
    const params = await context.params;
    const id = bacaId(params.id);

    if (id === akunLogin) {
      throw new Kesalahan(
        400,
        'Akun yang sedang digunakan tidak boleh dihapus.'
      );
    }

    const [result] = await database.execute<ResultSetHeader>(
      'DELETE FROM users WHERE id = ?',
      [id]
    );

    if (result.affectedRows === 0) {
      throw new Kesalahan(404, 'Pengguna tidak ditemukan.');
    }

    return kirim(200, 'Pengguna berhasil dihapus.', { id });
  } catch (error) {
    return tanganiError(error);
  }
}