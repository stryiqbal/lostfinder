<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    // Helper function untuk generate full URL photo
    private function getPhotoUrl($photoPath)
    {
        return $photoPath ? url('api/storage/' . $photoPath) : null;
    }

    // --- PATH STORAGE PUBLIK DENGAN CORS ---
    public function getStorageFile($path)
    {
        $disk = Storage::disk('public');

        if (!$disk->exists($path)) {
            return response()->json([
                'success' => false,
                'message' => 'File tidak ditemukan.'
            ], 404);
        }

        $file = $disk->get($path);
        $type = $disk->mimeType($path);

        return response($file, 200)
            ->header('Content-Type', $type)
            ->header('Access-Control-Allow-Origin', '*');
    }

    // --- 1. FITUR REGISTER ---
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name'     => 'required|string|max:255|unique:users,name',
            'email'    => 'required|string|email|max:255|unique:users,email',
            'password' => 'required|string|min:6',
            'role'     => 'nullable|in:user,admin',
            'phone'    => 'nullable|string|max:20',
            'bio'      => 'nullable|string',
        ], [
            'name.unique'  => 'Nama sudah terdaftar!',
            'email.unique' => 'Email sudah terdaftar!',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
                'errors'  => $validator->errors()
            ], 400);
        }

        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
            'role'     => $request->role ?? 'user',
            'phone'    => $request->phone ?? null,
            'bio'      => $request->bio ?? null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil! Silakan login.',
            'data'    => $user
        ], 201);
    }

    // --- 2. FITUR LOGIN ---
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'    => 'required|email',
            'password' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first()
            ], 400);
        }

        $user = User::where('email', $request->email)->first();

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
                'id'        => $user->id,
                'name'      => $user->name,
                'email'     => $user->email,
                'role'      => $user->role,
                'phone'     => $user->phone ?? '',
                'bio'       => $user->bio ?? '',
                'photo_url' => $this->getPhotoUrl($user->photo),
            ]
        ], 200);
    }

    // --- 3. FITUR GET USER PROFILE BY ID ---
    public function getUserProfile($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data'    => [
                'id'        => $user->id,
                'name'      => $user->name,
                'email'     => $user->email,
                'role'      => $user->role,
                'phone'     => $user->phone ?? '',
                'bio'       => $user->bio ?? '',
                'photo_url' => $this->getPhotoUrl($user->photo),
            ]
        ], 200);
    }

    // --- 4. FITUR UPDATE PROFILE ---
    public function updateProfile(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'name'  => 'required|string|max:255|unique:users,name,' . $id,
            'email' => 'required|email|unique:users,email,' . $id,
            'phone' => 'nullable|string|max:20',
            'bio'   => 'nullable|string',
            'photo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048', // Max 2MB
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first()
            ], 400);
        }

        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        // Siapkan data dasar
        $dataToUpdate = [
            'name'  => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'bio'   => $request->bio,
        ];

        // Upload foto jika ada berkas yang dikirim
        if ($request->hasFile('photo')) {
            // Hapus foto lama dari storage jika ada
            if ($user->photo && Storage::disk('public')->exists($user->photo)) {
                Storage::disk('public')->delete($user->photo);
            }

            // Simpan foto baru ke folder storage/app/public/profiles
            $path = $request->file('photo')->store('profiles', 'public');
            $dataToUpdate['photo'] = $path;
        }

        $user->update($dataToUpdate);

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui!',
            'data'    => [
                'id'        => $user->id,
                'name'      => $user->name,
                'email'     => $user->email,
                'role'      => $user->role,
                'phone'     => $user->phone ?? '',
                'bio'       => $user->bio ?? '',
                'photo_url' => $this->getPhotoUrl($user->photo),
            ]
        ], 200);
    }

    // --- 5. FITUR RESET PASSWORD ---
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'        => 'required|email',
            'old_password' => 'required',
            'new_password' => 'required|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first()
            ], 400);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Pengguna tidak ditemukan.'
            ], 404);
        }

        if (!Hash::check($request->old_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Password lama kamu salah!'
            ], 400);
        }

        $user->password = Hash::make($request->new_password);
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil diperbarui, silakan login kembali!'
        ], 200);
    }

    // --- 6. FITUR FORGOT PASSWORD ---
    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first()
            ], 400);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user) {
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
}