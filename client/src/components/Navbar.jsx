import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { FiLogOut, FiMenu, FiX } from 'react-icons/fi';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';

export default function Navbar({ onToggleSidebar, sidebarOpen }) {
  const { user, logout } = useAuth();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const { t, i18n } = useTranslation();

  return (
    <nav className="bg-primary text-white px-4 md:px-6 py-3 flex items-center justify-between sticky top-0 z-50 shadow-md">
      <div className="flex items-center gap-3">
        {user && (
          <button onClick={onToggleSidebar} className="md:hidden p-1 hover:bg-primary-light rounded-lg transition-colors">
            {sidebarOpen ? <FiX size={22} /> : <FiMenu size={22} />}
          </button>
        )}
        <Link to={user ? '/dashboard' : '/'} className="flex items-center gap-2">
          <div className="w-8 h-8 bg-accent rounded-lg flex items-center justify-center font-bold text-sm">ST</div>
          <span className="font-bold text-lg hidden sm:block">ShivaayTailor</span>
        </Link>
      </div>

      <div className="flex items-center gap-3 md:gap-4">
        <select 
          value={i18n.language} 
          onChange={(e) => {
            const lang = e.target.value;
            i18n.changeLanguage(lang);
            localStorage.setItem('i18nextLng', lang);
          }}
          className="bg-white/10 hover:bg-white/20 text-white border border-white/20 rounded-lg px-2 py-1 text-sm outline-none cursor-pointer transition-colors"
        >
          <option value="en" className="text-text-primary">English</option>
          <option value="hi" className="text-text-primary">हिंदी</option>
          <option value="mr" className="text-text-primary">मराठी</option>
        </select>

        {user ? (
          <div className="flex items-center gap-4">
            <span className="text-sm text-white/80 hidden sm:block">{user.shopName}</span>
            <button onClick={logout} className="flex items-center gap-1.5 bg-white/10 hover:bg-white/20 px-3 py-1.5 rounded-lg text-sm transition-colors">
              <FiLogOut size={16} />
              <span className="hidden sm:inline">{t('logout')}</span>
            </button>
          </div>
        ) : (
          <div className="flex items-center gap-3">
            <Link to="/login" className="text-sm font-medium hover:text-accent transition-colors">{t('login')}</Link>
            <Link to="/register" className="bg-accent text-white px-4 py-1.5 rounded-lg text-sm font-semibold hover:bg-accent-light transition-colors">{t('register')}</Link>
          </div>
        )}
      </div>

      {user && mobileMenuOpen && (
        <div className="absolute top-full left-0 w-full bg-primary border-t border-white/10 md:hidden">
          <div className="p-4 space-y-2">
            <Link to="/dashboard" className="block px-4 py-2 rounded-lg hover:bg-primary-light text-sm">{t('dashboard')}</Link>
            <Link to="/customers" className="block px-4 py-2 rounded-lg hover:bg-primary-light text-sm">{t('customers')}</Link>
            <Link to="/customers/add" className="block px-4 py-2 rounded-lg hover:bg-primary-light text-sm">{t('add_customer')}</Link>
          </div>
        </div>
      )}
    </nav>
  );
}
