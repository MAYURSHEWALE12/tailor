import { Link, useLocation } from 'react-router-dom';
import { FiGrid, FiUsers, FiUserPlus, FiBarChart2, FiHome } from 'react-icons/fi';

const links = [
  { to: '/dashboard', label: 'Dashboard', icon: FiGrid },
  { to: '/reports', label: 'Reports', icon: FiBarChart2 },
  { to: '/customers', label: 'Customers', icon: FiUsers },
  { to: '/customers/add', label: 'Add Customer', icon: FiUserPlus },
];

export default function Sidebar({ open, onClose }) {
  const location = useLocation();

  const isActive = (path) => location.pathname === path;

  return (
    <>
      {open && (
        <div className="fixed inset-0 bg-black/30 z-40 md:hidden" onClick={onClose} />
      )}
      <aside className={`fixed md:static top-14 left-0 h-[calc(100vh-3.5rem)] w-64 bg-white border-r border-gray-200 shadow-sm z-40 transform transition-transform duration-300 ${open ? 'translate-x-0' : '-translate-x-full md:translate-x-0'}`}>
        <div className="p-4 space-y-1">
          {links.map((link) => (
            <Link
              key={link.to}
              to={link.to}
              onClick={onClose}
              className={`flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium transition-colors ${
                isActive(link.to) ? 'bg-primary text-white' : 'text-text-secondary hover:bg-gray-100'
              }`}
            >
              <link.icon size={18} />
              {link.label}
            </Link>
          ))}
        </div>
        <div className="absolute bottom-4 left-4 right-4">
          <Link to="/" className="flex items-center gap-2 px-4 py-2 text-sm text-text-secondary hover:text-primary transition-colors">
            <FiHome size={16} />
            Home
          </Link>
        </div>
      </aside>
    </>
  );
}
