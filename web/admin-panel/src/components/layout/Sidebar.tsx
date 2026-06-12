import { NavLink, useLocation } from 'react-router-dom';
import { cn } from '../../utils/formatters';
import {
  LayoutDashboard,
  Store,
  Bike,
  Users,
  ClipboardList,
  BarChart3,
  Settings,
  ShieldAlert,
  ChevronLeft,
  ChevronRight,
  Package,
} from 'lucide-react';
import { useAuth } from '../../hooks/useAuth';
import { APP_NAME } from '../../config/constants';
import { useState } from 'react';

const navItems: {
  section: string;
  items: { label: string; icon: React.ElementType; path: string; adminOnly?: boolean }[];
}[] = [
  { section: 'Main', items: [{ label: 'Dashboard', icon: LayoutDashboard, path: '/dashboard' }] },
  {
    section: 'Management',
    items: [
      { label: 'Restaurants', icon: Store, path: '/restaurants' },
      { label: 'Drivers', icon: Bike, path: '/drivers' },
      { label: 'Users', icon: Users, path: '/users' },
      { label: 'Orders', icon: ClipboardList, path: '/orders' },
    ],
  },
  {
    section: 'Analytics',
    items: [{ label: 'Reports', icon: BarChart3, path: '/reports' }],
  },
  {
    section: 'Administration',
    items: [
      { label: 'Settings', icon: Settings, path: '/settings', adminOnly: true },
      { label: 'Audit Log', icon: ShieldAlert, path: '/audit-log', adminOnly: true },
    ],
  },
];

export default function Sidebar() {
  const [collapsed, setCollapsed] = useState(false);
  const { user } = useAuth();
  const location = useLocation();

  const isAdmin = user?.role === 'admin' || user?.role === 'superadmin';

  return (
    <aside
      className={cn(
        'fixed left-0 top-0 z-40 flex h-screen flex-col bg-admin-900 text-white transition-all duration-300',
        collapsed ? 'w-16' : 'w-64'
      )}
    >
      <div className="flex h-16 items-center justify-between border-b border-admin-700 px-4">
        {!collapsed && (
          <div className="flex items-center gap-2">
            <Package className="h-6 w-6 text-primary-400" />
            <span className="text-lg font-bold">{APP_NAME}</span>
          </div>
        )}
        <button
          onClick={() => setCollapsed(!collapsed)}
          className="rounded-lg p-1.5 text-admin-400 hover:bg-admin-800 hover:text-white transition-colors"
        >
          {collapsed ? <ChevronRight className="h-4 w-4" /> : <ChevronLeft className="h-4 w-4" />}
        </button>
      </div>

      <nav className="flex-1 overflow-y-auto px-2 py-4 space-y-6">
        {navItems.map((group) => (
          <div key={group.section}>
            {!collapsed && (
              <p className="mb-2 px-3 text-xs font-semibold uppercase tracking-wider text-admin-400">
                {group.section}
              </p>
            )}
            <ul className="space-y-1">
              {group.items
                .filter((item) => !item.adminOnly || isAdmin)
                .map((item) => {
                  const Icon = item.icon;
                  const isActive = location.pathname === item.path || location.pathname.startsWith(item.path + '/');
                  return (
                    <li key={item.path}>
                      <NavLink
                        to={item.path}
                        className={cn(
                          'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                          isActive
                            ? 'bg-primary-600 text-white'
                            : 'text-admin-300 hover:bg-admin-800 hover:text-white'
                        )}
                        title={collapsed ? item.label : undefined}
                      >
                        <Icon className="h-5 w-5 shrink-0" />
                        {!collapsed && <span>{item.label}</span>}
                      </NavLink>
                    </li>
                  );
                })}
            </ul>
          </div>
        ))}
      </nav>

      <div className="border-t border-admin-700 p-4">
        {!collapsed && user && (
          <div className="flex items-center gap-3">
            <div className="flex h-9 w-9 items-center justify-center rounded-full bg-primary-600 text-sm font-bold">
              {(user.name || 'A').charAt(0).toUpperCase()}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium truncate">{user.name}</p>
              <p className="text-xs text-admin-400 truncate">{user.email}</p>
            </div>
          </div>
        )}
      </div>
    </aside>
  );
}
