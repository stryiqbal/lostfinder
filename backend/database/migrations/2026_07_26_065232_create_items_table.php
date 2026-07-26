<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade'); // Relasi ke users
            $table->string('title'); // Nama barang
            $table->enum('category', ['lost', 'found']); // Kategori (hilang/temuan)
            $table->text('description'); // Ciri-ciri
            $table->string('location'); // Lokasi di kampus
            $table->string('image')->nullable(); // Foto barang
            $table->enum('status', ['pending', 'active', 'resolved'])->default('pending');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('items');
    }
};
