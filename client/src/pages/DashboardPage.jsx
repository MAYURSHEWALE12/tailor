import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { FiUsers, FiBarChart2, FiClock, FiCheckCircle, FiPlus, FiEye, FiEdit2 } from 'react-icons/fi';
import { useAuth } from '../context/AuthContext';
import { getDashboardStats } from '../api/measurementApi';
import Navbar from '../components/Navbar';
import Sidebar from '../components/Sidebar';
import StatsCard from '../components/StatsCard';
import Loader from '../components/Loader';
import { useTranslation } from 'react-i18next';

export default function DashboardPage() {
  const { user } = useAuth();
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const { t } = useTranslation();

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const { data } = await getDashboardStats();
        setStats(data);
      } catch (error) {
        console.error('Failed to fetch stats:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, []);

  if (loading) return <Loader />;

  return (
    <div className="min-h-screen bg-background">
      <Navbar onToggleSidebar={() => setSidebarOpen(!sidebarOpen)} sidebarOpen={sidebarOpen} />
      <div className="flex">
        <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />
        <main className="flex-1 p-4 md:p-6">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h1 className="text-2xl font-bold text-primary">{t('welcome')}, {user?.name}</h1>
              <p className="text-text-secondary text-sm">{user?.shopName}</p>
            </div>
            <Link to="/customers/add" className="btn-primary flex items-center gap-2 text-sm">
              <FiPlus size={16} /> {t('add_customer')}
            </Link>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
            <StatsCard icon={FiUsers} label={t('total_customers')} value={stats?.totalCustomers || 0} color="primary" />
            <StatsCard icon={FiBarChart2} label={t('measurements_this_month')} value={stats?.measurementsThisMonth || 0} color="accent" />
            <StatsCard icon={FiClock} label={t('pending_orders')} value={stats?.pendingOrders || 0} color="warning" />
            <StatsCard icon={FiCheckCircle} label={t('ready_for_delivery')} value={stats?.readyForDelivery || 0} color="success" />
          </div>

          <div className="card">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-semibold text-text-primary">{t('recent_customers')}</h2>
              <Link to="/customers" className="text-sm text-primary font-medium hover:text-primary-light">{t('view_all')}</Link>
            </div>
            {stats?.recentCustomers?.length > 0 ? (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-gray-100">
                      <th className="text-left py-3 font-medium text-text-secondary">{t('name')}</th>
                      <th className="text-left py-3 font-medium text-text-secondary">{t('phone')}</th>
                      <th className="text-left py-3 font-medium text-text-secondary">{t('date')}</th>
                      <th className="text-right py-3 font-medium text-text-secondary">{t('actions')}</th>
                    </tr>
                  </thead>
                  <tbody>
                    {stats.recentCustomers.map((customer) => (
                      <tr key={customer._id} className="border-b border-gray-50 hover:bg-gray-50 transition-colors">
                        <td className="py-3 font-medium text-text-primary">{customer.name}</td>
                        <td className="py-3 text-text-secondary">{customer.phone}</td>
                        <td className="py-3 text-text-secondary">{new Date(customer.createdAt).toLocaleDateString('en-IN')}</td>
                        <td className="py-3 text-right">
                          <Link to={`/customers/${customer._id}`} className="text-primary hover:text-primary-light inline-flex items-center gap-1 mr-3">
                            <FiEye size={14} /> {t('view')}
                          </Link>
                          <Link to={`/customers/${customer._id}/measurements/add`} className="text-accent hover:text-accent-light inline-flex items-center gap-1">
                            <FiEdit2 size={14} /> {t('measure')}
                          </Link>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ) : (
              <div className="text-center py-8">
                <p className="text-text-secondary mb-4">{t('no_customers_yet')}</p>
                <Link to="/customers/add" className="btn-primary inline-flex items-center gap-2">
                  <FiPlus size={16} /> {t('add_customer')}
                </Link>
              </div>
            )}
          </div>
        </main>
      </div>
    </div>
  );
}
