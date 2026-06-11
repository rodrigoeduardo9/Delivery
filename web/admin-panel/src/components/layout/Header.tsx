import { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Bell, Search, LogOut, User, Settings } from 'lucide-react';
import { useAuth } from '../../hooks/useAuth';
import { cn } from '../../utils/formatters';

export default function Header() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [showDropdown, setShowDropdown] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setShowDropdown(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <header className="sticky top-0 z-30 flex h-16 items-center gap-4 border-b bg-white px-6 shadow-sm">
      <div className="relative flex-1 max-w-md">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-admin-400" />
        <input
          type="text"
          placeholder="Search orders, restaurants, drivers..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="input pl-10"
        />
      </div>

      <div className="flex items-center gap-3">
        <button className="relative rounded-lg p-2 text-admin-500 hover:bg-admin-100 transition-colors">
          <Bell className="h-5 w-5" />
          <span className="absolute right-1.5 top-1.5 flex h-4 w-4 items-center justify-center rounded-full bg-danger-500 text-[10px] font-bold text-white">
            3
          </span>
        </button>

        <div className="relative" ref={dropdownRef}>
          <button
            onClick={() => setShowDropdown(!showDropdown)}
            className="flex items-center gap-2 rounded-lg p-1.5 hover:bg-admin-100 transition-colors"
          >
            <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary-600 text-sm font-bold text-white">
              {user?.name?.charAt(0).toUpperCase() || 'A'}
            </div>
            <div className="hidden text-left sm:block">
              <p className="text-sm font-medium">{user?.name || 'Admin'}</p>
              <p className="text-xs text-admin-500">{user?.role || 'admin'}</p>
            </div>
          </button>

          {showDropdown && (
            <div className="absolute right-0 top-full mt-2 w-56 rounded-xl border bg-white shadow-lg py-2">
              <div className="px-4 py-2 border-b">
                <p className="text-sm font-medium">{user?.name}</p>
                <p className="text-xs text-admin-500">{user?.email}</p>
              </div>
              <button
                onClick={() => { setShowDropdown(false); navigate('/settings'); }}
                className="flex w-full items-center gap-3 px-4 py-2 text-sm text-admin-700 hover:bg-admin-50"
              >
                <Settings className="h-4 w-4" />
                Settings
              </button>
              <button
                onClick={() => { setShowDropdown(false); navigate('/settings'); }}
                className="flex w-full items-center gap-3 px-4 py-2 text-sm text-admin-700 hover:bg-admin-50"
              >
                <User className="h-4 w-4" />
                Profile
              </button>
              <hr className="my-1" />
              <button
                onClick={handleLogout}
                className="flex w-full items-center gap-3 px-4 py-2 text-sm text-danger-600 hover:bg-danger-50"
              >
                <LogOut className="h-4 w-4" />
                Sign out
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
