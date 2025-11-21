#!/bin/bash

echo "=== PROTECT ADMIN PANEL (Hanya Admin ID 1 Full Access) ==="
echo "Lokasi Panel: /var/www/pterodactyl"
cd /var/www/pterodactyl || { echo "Panel tidak ditemukan!"; exit 1; }

FILE="resources/scripts/components/Navigation/AdminNavigation.tsx"

if [ ! -f "$FILE" ]; then
    echo "File AdminNavigation.tsx tidak ditemukan!"
    echo "Panel kamu mungkin versi lain. Kirim screenshot folder Navigation."
    exit 1
fi

echo "Menambahkan proteksi ke AdminNavigation.tsx..."

cat << 'EOF' > /tmp/protect_patch.txt
// === PROTEKSI SIDEBAR ADMIN (AUTOMATIS DARI SCRIPT) ===
import { useStoreState } from '@/state/hooks';
const user = useStoreState((state) => state.user.data);
const protectedAdmin = user && user.id !== 1;
EOF

# Inject proteksi setelah baris import React
sed -i "/import React/a $(sed 's/\//\\\//g' /tmp/protect_patch.txt)" "$FILE"

# Menyembunyikan semua menu admin kecuali overview
sed -i "s/<NavigationItem to=\"\/admin\/settings\".*/{ !protectedAdmin \&\& <NavigationItem to=\"\/admin\/settings\" name=\"Settings\" icon={SettingsIcon} \/> }/g" "$FILE"
sed -i "s/<NavigationItem to=\"\/admin\/api\".*/{ !protectedAdmin \&\& <NavigationItem to=\"\/admin\/api\" name=\"Application API\" icon={ApiIcon} \/> }/g" "$FILE"
sed -i "s/<NavigationItem to=\"\/admin\/databases\".*/{ !protectedAdmin \&\& <NavigationItem to=\"\/admin\/databases\" name=\"Databases\" icon={DatabaseIcon} \/> }/g" "$FILE"
sed -i "s/<NavigationItem to=\"\/admin\/locations\".*/{ !protectedAdmin \&\& <NavigationItem to=\"\/admin\/locations\" name=\"Locations\" icon={GlobeIcon} \/> }/g" "$FILE"
sed -i "s/<NavigationItem to=\"\/admin\/nodes\".*/{ !protectedAdmin \&\& <NavigationItem to=\"\/admin\/nodes\" name=\"Nodes\" icon={NetworkIcon} \/> }/g" "$FILE"
sed -i "s/<NavigationItem to=\"\/admin\/servers\".*/{ !protectedAdmin \&\& <NavigationItem to=\"\/admin\/servers\" name=\"Servers\" icon={ServerIcon} \/> }/g" "$FILE"
sed -i "s/<NavigationItem to=\"\/admin\/users\".*/{ !protectedAdmin \&\& <NavigationItem to=\"\/admin\/users\" name=\"Users\" icon={UsersIcon} \/> }/g" "$FILE"
sed -i "s/<NavigationItem to=\"\/admin\/mounts\".*/{ !protectedAdmin \&\& <NavigationItem to=\"\/admin\/mounts\" name=\"Mounts\" icon={LayersIcon} \/> }/g" "$FILE"
sed -i "s/<NavigationItem to=\"\/admin\/nests\".*/{ !protectedAdmin \&\& <NavigationItem to=\"\/admin\/nests\" name=\"Nests\" icon={GridIcon} \/> }/g" "$FILE"

echo "Build ulang panel..."
NODE_OPTIONS="--max-old-space-size=4096" npm run build:production

echo "Membersihkan cache..."
php artisan view:clear
php artisan cache:clear

echo "=== SELESAI! ==="
echo "Hanya Admin ID 1 yang bisa lihat semua menu admin."
