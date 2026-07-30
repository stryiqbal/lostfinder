<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Buat akun Admin bawaan sistem
        User::updateOrCreate(
            ['email' => 'admin@gmail.com'], // Cek jika email sudah ada agar tidak duplikat
            [
                'name'     => 'Admin',
                'password' => Hash::make('123456'),
                'role'     => 'admin',
                'phone'    => '081234567890',
                'bio'      => 'Akun Administrator Utama',
            ]
        );
    }
}