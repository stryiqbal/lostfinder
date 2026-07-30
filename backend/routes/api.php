<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ItemController;

// Auth Route
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);

// User Profile Route (GET & UPDATE)
Route::get('/users/{id}', [AuthController::class, 'getUserProfile']);
// Menggunakan POST / match agar aman menerima multipart Form-Data foto dari Flutter
Route::post('/users/{id}', [AuthController::class, 'updateProfile']);
Route::put('/users/{id}', [AuthController::class, 'updateProfile']); 

// Storage Route untuk foto profil dan asset lain
Route::get('/storage/{path}', [AuthController::class, 'getStorageFile'])->where('path', '.*');

// Items Route
Route::get('/items', [ItemController::class, 'index']);
Route::post('/items', [ItemController::class, 'store']);
Route::delete('/items/{id}', [ItemController::class, 'destroy']);
Route::put('/items/{id}/status', [ItemController::class, 'updateStatus']);

// Image Route
Route::get('/items/image/{filename}', [ItemController::class, 'getImage']);