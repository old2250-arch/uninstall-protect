#!/bin/bash
clear
echo "----------------------------------------------"
echo "      🗑️ UNINSTALL PTERODACTYL PROTECT"
echo "----------------------------------------------"

DB_USER="root"
PANEL_DIR="/var/www/pterodactyl"
ENV_FILE="$PANEL_DIR/.env"
TARGET_FILE="$PANEL_DIR/app/Repositories/Eloquent/ServerRepository.php"
BACKUP_FILE="$TARGET_FILE.bak"

# ===========================================================
# 🔍 Ambil database dari .env
# ===========================================================
if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ Tidak menemukan .env — batal."
  exit 1
fi

DB=$(grep DB_DATABASE "$ENV_FILE" | cut -d '=' -f2)

if [[ -z "$DB" ]]; then
  echo "❌ Tidak dapat membaca DB dari .env"
  exit 1
fi

echo "📦 Database aktif: $DB"
echo ""

# ===========================================================
# 💣 Hapus semua trigger protect
# ===========================================================
echo "🗑️ Menghapus trigger proteksi..."

mysql -u $DB_USER <<EOF
USE $DB;
DROP TRIGGER IF EXISTS prevent_user_delete;
DROP TRIGGER IF EXISTS prevent_server_delete;
DROP TRIGGER IF EXISTS prevent_node_delete;
DROP TRIGGER IF EXISTS prevent_egg_delete;
DROP TRIGGER IF EXISTS prevent_setting_edit;
EOF

echo "✅ Semua trigger MySQL dihapus."
echo ""

# ===========================================================
# 🕶️ Mengembalikan file Laravel dari backup
# ===========================================================
echo "🗑️ Mengembalikan file Laravel..."

if [[ -f "$BACKUP_FILE" ]]; then
    cp "$BACKUP_FILE" "$TARGET_FILE"
    echo "✅ File asli dipulihkan dari backup."
else
    echo "⚠️ Backup tidak ditemukan, tidak bisa restore file Laravel."
fi

echo ""

# ===========================================================
# ♻️ Bersihkan cache Laravel
# ===========================================================
echo "♻️ Membersihkan cache Laravel..."
cd "$PANEL_DIR"

php artisan config:clear
php artisan cache:clear

echo "✅ Cache Laravel dibersihkan."
echo ""

# ===========================================================
# Selesai
# ===========================================================
echo "----------------------------------------------"
echo "   ✅ PROTEKSI BERHASIL DI-UNINSTALL"
echo "----------------------------------------------"
