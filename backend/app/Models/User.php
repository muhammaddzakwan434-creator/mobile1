<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasFactory, Notifiable;

    /**
     * Atribut yang dapat diisi (Mass Assignment).
     * Tambahkan 'username' dan 'phone' ke sini.
     */
    protected $fillable = [
        'name',
        'username',
        'email',
        'phone',
        'profile_photo',
        'role',
        'status',
        'password',
        'last_seen',
    ];

    /**
     * Atribut yang harus disembunyikan saat serialisasi.
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Atribut yang harus dikonversi (Casting).
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'last_seen' => 'datetime',
        ];
    }

    /**
     * Helper untuk mengecek apakah user adalah Super Admin (Bisa Semua)
     */
    public function isSuperAdmin()
    {
        return $this->role === 'super_admin';
    }

    /**
     * Helper untuk mengecek apakah user adalah Admin Dinas
     */
    public function isAdminDinas()
    {
        return $this->role === 'admin_dinas';
    }
}
