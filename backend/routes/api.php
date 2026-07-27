<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ItemController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);

Route::get('/items', [ItemController::class, 'index']);
Route::post('/items', [ItemController::class, 'store']);
Route::delete('/items/{id}', [ItemController::class, 'destroy']);
Route::put('/items/{id}/status', [ItemController::class, 'updateStatus']);

// 🟢 Langsung arahkan ke method getImage di ItemController
Route::get('/items/image/{filename}', [ItemController::class, 'getImage']);