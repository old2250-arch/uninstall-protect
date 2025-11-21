#!/bin/bash

PANEL_PATH="/var/www/pterodactyl"
TARGET_FILE="$PANEL_PATH/resources/scripts/components/NavigationBar.tsx"
BACKUP_FILE="$TARGET_FILE.protect-backup"

echo "🔍 Mengecek file NavigationBar.tsx..."
if [ ! -f "$TARGET_FILE" ]; then
    echo "❌ ERROR: File NavigationBar.tsx tidak ditemukan!"
    exit 1
fi

echo "🗂 Membuat backup..."
cp "$TARGET_FILE" "$BACKUP_FILE"

echo "⚙️ Menerapkan proteksi menu admin..."
cat > "$TARGET_FILE" << 'EOF'
import React from 'react';
import { NavLink } from 'react-router-dom';
import useUser from '@/state/user';
import SubNavigation from '@/components/SubNavigation';

export default function NavigationBar() {
    const user = useUser();
    const isMainAdmin = user?.id === 1;

    return (
        <div className='navigation-bar'>
            <NavLink to='/' className='navigation-link'>Dashboard</NavLink>

            {isMainAdmin && (
                <>
                    <NavLink to='/admin/locations' className='navigation-link'>Locations</NavLink>
                    <NavLink to='/admin/nodes' className='navigation-link'>Nodes</NavLink>
                    <NavLink to='/admin/servers' className='navigation-link'>Servers</NavLink>
                    <NavLink to='/admin/users' className='navigation-link'>Users</NavLink>
                    <NavLink to='/admin/databases' className='navigation-link'>Databases</NavLink>
                    <NavLink to='/admin/nests' className='navigation-link'>Nests</NavLink>
                    <NavLink to='/admin/mounts' className='navigation-link'>Mounts</NavLink>
                </>
            )}
        </div>
    );
}
EOF

echo "🚀 Proteksi berhasil dipasang!"
echo "🔧 Jalankan: cd /var/www/pterodactyl && yarn build && php artisan cache:clear"
