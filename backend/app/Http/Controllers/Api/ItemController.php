<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Item;
use Illuminate\Http\Request;

class ItemController extends Controller
{
    // Ambil semua data barang
    public function index()
    {
        $items = Item::with('user')->latest()->get();
        return response()->json([
            'success' => true,
            'data'    => $items
        ], 200);
    }

    // Simpan laporan barang baru
    public function store(Request $request)
    {
        $item = Item::create([
            'user_id'     => 1, // Untuk uji coba, asumsikan user ID 1 yang login
            'title'       => $request->title,
            'category'    => $request->category,
            'description' => $request->description,
            'location'    => $request->location,
            'status'      => 'active'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Laporan berhasil ditambahkan',
            'data'    => $item
        ], 201);
    }
}