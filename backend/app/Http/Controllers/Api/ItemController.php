<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Item;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ItemController extends Controller
{
    // Ambil semua data barang
    public function index()
    {
        $items = Item::with('user')->latest()->get();

        // Transformasi URL gambar saja tanpa merusak struktur relasi 'user'
        $items->transform(function ($item) {
            if ($item->image) {
                $item->image = url('api/items/image/' . basename($item->image));
            }
            return $item;
        });

        return response()->json([
            'success' => true,
            'data'    => $items
        ], 200);
    }

    // Simpan laporan barang baru
    public function store(Request $request)
    {
        $request->validate([
            'user_id'     => 'required|exists:users,id',
            'title'       => 'required|string|max:255',
            'category'    => 'required|in:lost,found',
            'description' => 'required|string',
            'location'    => 'required|string|max:255',
            'image'       => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        $imagePath = null;
        if ($request->hasFile('image')) {
            // Simpan file ke folder storage/app/public/items
            $path = $request->file('image')->store('items', 'public');
            // Simpan path relatif ke database
            $imagePath = $path;
        }

        $item = Item::create([
            'user_id'     => $request->user_id,
            'title'       => $request->title,
            'category'    => $request->category,
            'description' => $request->description,
            'location'    => $request->location,
            'image'       => $imagePath,
            'status'      => 'pending'
        ]);

        // Format ulang response image agar langsung bisa dipakai Flutter
        if ($item->image) {
            $item->image = url('api/items/image/' . basename($item->image));
        }

        return response()->json([
            'success' => true,
            'message' => 'Laporan berhasil dibuat (Menunggu Verifikasi Admin)!',
            'data'    => $item->load('user')
        ], 201);
    }

    public function destroy($id)
    {
        $item = Item::find($id);

        if (!$item) {
            return response()->json([
                'success' => false,
                'message' => 'Laporan tidak ditemukan!'
            ], 404);
        }

        // (Opsional) Hapus file gambar di storage jika ada
        if ($item->image) {
            $path = str_replace(asset('storage/'), '', $item->image);
            \Illuminate\Support\Facades\Storage::disk('public')->delete($path);
        }

        $item->delete();

        return response()->json([
            'success' => true,
            'message' => 'Laporan berhasil dihapus!'
        ], 200);
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,active,resolved',
        ]);

        $item = Item::find($id);

        if (!$item) {
            return response()->json([
                'success' => false,
                'message' => 'Laporan tidak ditemukan!'
            ], 404);
        }

        $item->status = $request->status;
        $item->save();

        return response()->json([
            'success' => true,
            'message' => 'Status barang berhasil diperbarui!',
            'data'    => $item
        ], 200);
    }

    // 📸 Method Baru: Menyajikan file gambar dengan Header CORS
    public function getImage($filename)
    {
        $path = 'items/' . $filename;

        if (!Storage::disk('public')->exists($path)) {
            return response()->json(['message' => 'Gambar tidak ditemukan'], 404);
        }

        $file = Storage::disk('public')->get($path);
        $type = Storage::disk('public')->mimeType($path);

        return response($file, 200)
            ->header('Content-Type', $type)
            ->header('Access-Control-Allow-Origin', '*')
            ->header('Access-Control-Allow-Methods', 'GET, OPTIONS');
    }
}