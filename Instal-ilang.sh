#!/bin/bash

PANEL="/var/www/pterodactyl"
NAVFILE="$PANEL/resources/scripts/components/NavigationBar.tsx"
BACKUP="$NAVFILE.bak-protect"

echo "=== PROTECT ADMIN PANEL (Hanya Admin ID 1) ==="

if [ ! -f "$NAVFILE" ]; then
    echo "File tidak ditemukan: $NAVFILE"
    exit 1
fi

# Backup dulu
cp "$NAVFILE" "$BACKUP"

echo "Backup dibuat: $BACKUP"
echo "Memodifikasi NavigationBar.tsx..."

cat << 'EOF' > "$NAVFILE"
import React from "react";
import { NavLink } from "react-router-dom";
import { useStoreState } from "@/state";

export default function NavigationBar() {
    const user = useStoreState((state) => state.user.data);

    const isMainAdmin = user && user.id === 1; // HANYA ADMIN ID 1 YANG PUNYA FULL MENU

    return (
        <div>
            {/* Dashboard selalu tampil untuk semua */}
            <NavLink to="/admin">Dashboard</NavLink>

            {/* Jika bukan admin utama, semua menu admin disembunyikan */}
            {isMainAdmin && (
                <>
                    <NavLink to="/admin/settings">Settings</NavLink>
                    <NavLink to="/admin/api">Application API</NavLink>
                    <NavLink to="/admin/databases">Databases</NavLink>
                    <NavLink to="/admin/locations">Locations</NavLink>
                    <NavLink to="/admin/nodes">Nodes</NavLink>
                    <NavLink to="/admin/servers">Servers</NavLink>
                    <NavLink to="/admin/users">Users</NavLink>
                    <NavLink to="/admin/mounts">Mounts</NavLink>
                    <NavLink to="/admin/nests">Nests</NavLink>
                </>
            )}
        </div>
    );
}
EOF

echo "Rebuilding panel..."
cd $PANEL
npm install > /dev/null 2>&1
npm run build:production

chown -R www-data:www-data $PANEL

echo "=== Protect selesai! ==="
