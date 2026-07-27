<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // --- 1. FITUR REGISTER ---
    public function register(Request $request)
    {
        $request->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
            'role'     => 'nullable|in:user,admin' // Default 'user' jika tidak diisi
        ]);

        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password), // Password wajib di-hash!
            'role'     => $request->role ?? 'user'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil! Silakan login.',
            'data'    => $user
        ], 201);
    }

    // --- 2. FITUR RESET PASSWORD ---
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email'        => 'required|email',
            'old_password' => 'required',
            'new_password' => 'required|min:6',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Pengguna tidak ditemukan.'
            ], 404);
        }

        // Cek apakah password lama sesuai
        if (!Hash::check($request->old_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Password lama kamu salah!'
            ], 400);
        }

        // Update ke password baru
        $user->password = Hash::make($request->new_password);
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil diperbarui, silakan login kembali!'
        ], 200);
    }

    // --- 3. FITUR FORGOT PASSWORD ---
    public function forgotPassword(Request $request)
    {
        // Validasi input
        $request->validate([
            'email' => 'required|email',
        ]);

        // Cek apakah email ada di database
        $user = User::where('email', $request->email)->first();

        if (!$user) {
            // Jika email TIDAK ada di database
            return response()->json([
                'success' => false,
                'message' => 'Email tidak terdaftar!'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Email terdaftar! Silakan lanjutkan ubah password.'
        ], 200);
    }  

    // --- 4. FITUR LOGIN ---
    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        // Cek ketersediaan user dan kecocokan password
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah!'
            ], 401);
        }

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil!',
            'data'    => [
                'id'    => $user->id,
                'name'  => $user->name,
                'email' => $user->email,
                'role'  => $user->role, // Mengirim role ke Flutter
            ]
        ], 200);
    }
}