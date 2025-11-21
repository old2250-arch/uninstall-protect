#!/bin/bash
set -e

echo "=== Pterodactyl Hard Admin Protections ==="

cd /var/www/pterodactyl

echo "[*] Backup file..."
mkdir -p storage/protect-backup
cp -r resources/views storage/protect-backup/
cp -r app/Http/Middleware storage/protect-backup/

#############################################
# 1. BUAT SIDEBAR LIMITED UNTUK ADMIN BIASA
#############################################

cat > resources/views/partials/admin/sidebar-limited.blade.php << 'EOF'
<li class="nav-item">
    <a href="/admin" class="nav-link">
        <i class="fas fa-tachometer-alt"></i> Dashboard
    </a>
</li>
EOF


#############################################
# 2. MODIFY admin.blade.php UNTUK SWITCH SIDEBAR
#############################################

ADMIN_FILE="resources/views/layouts/admin.blade.php"

if ! grep -q "sidebar-limited" "$ADMIN_FILE"; then
    sed -i '/@section('\''sidebar'\'')/a \
@php \
    $isMasterAdmin = auth()->user()->id === 1; \
@endphp \
@if($isMasterAdmin) \
    @include('\''partials.admin.sidebar'\'') \
@else \
    @include('\''partials.admin.sidebar-limited'\'') \
@endif \
' "$ADMIN_FILE"
fi


#############################################
# 3. HARD PROTECT BACKEND (AdminAccess.php)
#############################################

MIDDLEWARE="app/Http/Middleware/AdminAuthenticate.php"

if grep -q "Hard Admin Protect" "$MIDDLEWARE"; then
    echo "[✓] Middleware already patched."
else
cat >> "$MIDDLEWARE" << 'EOF'

// Hard Admin Protect
if (auth()->check() && auth()->user()->root_admin) {
    if (auth()->user()->id !== 1) {
        return redirect('/')->with('error', 'Access denied.');
    }
}
EOF
fi


#############################################
# 4. CLEAR CACHE + FIX PERM
#############################################

php artisan optimize:clear
php artisan view:clear

chown -R www-data:www-data /var/www/pterodactyl

echo "==========================================="
echo "[✓] Protection installed successfully!"
echo "Hanya Admin ID 1 yang bisa akses full admin."
echo "==========================================="
