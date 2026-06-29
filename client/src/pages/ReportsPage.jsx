import { useState, useEffect, useCallback } from 'react';
import { FiDollarSign, FiPieChart, FiGrid, FiUsers, FiCalendar, FiTrendingUp, FiClock, FiCheckCircle, FiXCircle } from 'react-icons/fi';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Legend } from 'recharts';
import { getRevenueReport, getOrderStatusReport, getGarmentWiseReport, getPendingDues, getDeliverySchedule, getTopCustomers } from '../api/reportApi';
import Navbar from '../components/Navbar';
import Sidebar from '../components/Sidebar';
import Loader from '../components/Loader';

const tabs = [
  { key: 'revenue', label: 'Revenue', icon: FiDollarSign },
  { key: 'order-status', label: 'Order Status', icon: FiPieChart },
  { key: 'garment-wise', label: 'Garments', icon: FiGrid },
  { key: 'pending-dues', label: 'Pending Dues', icon: FiClock },
  { key: 'delivery', label: 'Delivery Schedule', icon: FiCalendar },
  { key: 'top-customers', label: 'Top Customers', icon: FiTrendingUp },
];

const STATUS_COLORS = {
  pending: '#F59E0B',
  cutting: '#3B82F6',
  stitching: '#8B5CF6',
  ready: '#10B981',
  delivered: '#6B7280',
};

const GARMENT_COLORS = ['#1A3A5C', '#D4A017', '#10B981', '#F59E0B', '#EF4444'];

const PIE_COLORS = ['#F59E0B', '#3B82F6', '#8B5CF6', '#10B981', '#6B7280'];

export default function ReportsPage() {
  const [activeTab, setActiveTab] = useState('revenue');
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [loading, setLoading] = useState(true);
  const [revenueData, setRevenueData] = useState(null);
  const [orderStatusData, setOrderStatusData] = useState([]);
  const [garmentData, setGarmentData] = useState([]);
  const [pendingDues, setPendingDues] = useState(null);
  const [deliveryData, setDeliveryData] = useState(null);
  const [topCustomers, setTopCustomers] = useState([]);
  const [dateRange, setDateRange] = useState({ startDate: '', endDate: '' });

  const fetchAll = useCallback(async () => {
    setLoading(true);
    try {
      const params = {};
      if (dateRange.startDate) params.startDate = dateRange.startDate;
      if (dateRange.endDate) params.endDate = dateRange.endDate;

      const [rev, status, garment, dues, delivery, top] = await Promise.all([
        getRevenueReport(params).catch(() => null),
        getOrderStatusReport().catch(() => null),
        getGarmentWiseReport(params).catch(() => null),
        getPendingDues().catch(() => null),
        getDeliverySchedule(7).catch(() => null),
        getTopCustomers().catch(() => null),
      ]);

      if (rev?.data) setRevenueData(rev.data);
      if (status?.data) setOrderStatusData(status.data);
      if (garment?.data) setGarmentData(garment.data);
      if (dues?.data) setPendingDues(dues.data);
      if (delivery?.data) setDeliveryData(delivery.data);
      if (top?.data) setTopCustomers(top.data);
    } catch (error) {
      console.error('Failed to fetch reports:', error);
    } finally {
      setLoading(false);
    }
  }, [dateRange]);

  useEffect(() => {
    fetchAll();
  }, [fetchAll]);

  const statusLabel = (s) => s.charAt(0).toUpperCase() + s.slice(1);
  const garmentLabel = (g) => {
    const labels = { shirt: 'Shirt', pant: 'Pant', kurta: 'Kurta', blouse: 'Blouse', sadra: 'Sadra' };
    return labels[g] || g;
  };

  const renderTab = () => {
    switch (activeTab) {
      case 'revenue':
        return (
          <div className="space-y-6">
            {revenueData?.summary && (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                <div className="card text-center">
                  <p className="text-text-secondary text-sm font-medium">Total Revenue</p>
                  <p className="text-2xl font-bold text-primary mt-1">₹{revenueData.summary.totalRevenue.toLocaleString('en-IN')}</p>
                </div>
                <div className="card text-center">
                  <p className="text-text-secondary text-sm font-medium">Total Advance</p>
                  <p className="text-2xl font-bold text-accent mt-1">₹{revenueData.summary.totalAdvance.toLocaleString('en-IN')}</p>
                </div>
                <div className="card text-center">
                  <p className="text-text-secondary text-sm font-medium">Pending Balance</p>
                  <p className="text-2xl font-bold text-red-600 mt-1">₹{revenueData.summary.totalBalance.toLocaleString('en-IN')}</p>
                </div>
                <div className="card text-center">
                  <p className="text-text-secondary text-sm font-medium">Total Orders</p>
                  <p className="text-2xl font-bold text-text-primary mt-1">{revenueData.summary.orderCount}</p>
                </div>
              </div>
            )}
            {revenueData?.daily?.length > 0 && (
              <div className="card">
                <h3 className="font-semibold text-text-primary mb-4">Daily Revenue</h3>
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={revenueData.daily}>
                    <XAxis dataKey="_id" tick={{ fontSize: 11 }} />
                    <YAxis tick={{ fontSize: 11 }} />
                    <Tooltip />
                    <Bar dataKey="revenue" fill="#1A3A5C" name="Revenue" radius={[4, 4, 0, 0]} />
                    <Bar dataKey="advance" fill="#D4A017" name="Advance" radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            )}
            {(!revenueData?.daily || revenueData.daily.length === 0) && (
              <div className="card text-center py-8 text-text-secondary">No revenue data for the selected period</div>
            )}
          </div>
        );

      case 'order-status':
        return (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div className="card">
              <h3 className="font-semibold text-text-primary mb-4">Status Distribution</h3>
              {orderStatusData.length > 0 ? (
                <ResponsiveContainer width="100%" height={300}>
                  <PieChart>
                    <Pie data={orderStatusData} dataKey="count" nameKey="status" cx="50%" cy="50%" outerRadius={100} label={({ status, count }) => `${statusLabel(status)}: ${count}`}>
                      {orderStatusData.map((entry) => (
                        <Cell key={entry.status} fill={STATUS_COLORS[entry.status] || '#6B7280'} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              ) : (
                <p className="text-text-secondary text-center py-8">No orders yet</p>
              )}
            </div>
            <div className="card">
              <h3 className="font-semibold text-text-primary mb-4">Status Breakdown</h3>
              {orderStatusData.length > 0 ? (
                <div className="space-y-3">
                  {orderStatusData.map((item) => (
                    <div key={item.status} className="flex items-center justify-between p-3 rounded-lg bg-gray-50">
                      <div className="flex items-center gap-2">
                        <div className="w-3 h-3 rounded-full" style={{ backgroundColor: STATUS_COLORS[item.status] }} />
                        <span className="font-medium text-text-primary">{statusLabel(item.status)}</span>
                      </div>
                      <span className="font-bold text-text-primary">{item.count}</span>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="text-text-secondary text-center py-8">No orders yet</p>
              )}
            </div>
          </div>
        );

      case 'garment-wise':
        return (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div className="card">
              <h3 className="font-semibold text-text-primary mb-4">Orders by Garment</h3>
              {garmentData.length > 0 ? (
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={garmentData}>
                    <XAxis dataKey="garmentType" tickFormatter={garmentLabel} tick={{ fontSize: 11 }} />
                    <YAxis tick={{ fontSize: 11 }} />
                    <Tooltip formatter={(value, name) => [value, name === 'count' ? 'Orders' : 'Revenue']} labelFormatter={garmentLabel} />
                    <Bar dataKey="count" fill="#1A3A5C" name="count" radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              ) : (
                <p className="text-text-secondary text-center py-8">No data available</p>
              )}
            </div>
            <div className="card">
              <h3 className="font-semibold text-text-primary mb-4">Revenue by Garment</h3>
              {garmentData.length > 0 ? (
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={garmentData}>
                    <XAxis dataKey="garmentType" tickFormatter={garmentLabel} tick={{ fontSize: 11 }} />
                    <YAxis tick={{ fontSize: 11 }} />
                    <Tooltip formatter={(value) => [`₹${value.toLocaleString('en-IN')}`, 'Revenue']} labelFormatter={garmentLabel} />
                    <Bar dataKey="revenue" fill="#D4A017" name="revenue" radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              ) : (
                <p className="text-text-secondary text-center py-8">No data available</p>
              )}
            </div>
            {garmentData.length > 0 && (
              <div className="card lg:col-span-2">
                <h3 className="font-semibold text-text-primary mb-4">Garment Summary</h3>
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="border-b border-gray-100">
                        <th className="text-left py-3 font-medium text-text-secondary">Garment</th>
                        <th className="text-center py-3 font-medium text-text-secondary">Orders</th>
                        <th className="text-right py-3 font-medium text-text-secondary">Revenue</th>
                      </tr>
                    </thead>
                    <tbody>
                      {garmentData.map((item, i) => (
                        <tr key={item.garmentType} className="border-b border-gray-50 hover:bg-gray-50 transition-colors">
                          <td className="py-3 font-medium text-text-primary">{garmentLabel(item.garmentType)}</td>
                          <td className="py-3 text-center">{item.count}</td>
                          <td className="py-3 text-right">₹{item.revenue.toLocaleString('en-IN')}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}
          </div>
        );

      case 'pending-dues':
        return (
          <div className="space-y-6">
            {pendingDues && (
              <div className="card text-center max-w-xs mx-auto">
                <p className="text-text-secondary text-sm font-medium">Total Pending Dues</p>
                <p className="text-3xl font-bold text-red-600 mt-1">₹{pendingDues.totalDues.toLocaleString('en-IN')}</p>
              </div>
            )}
            {pendingDues?.orders?.length > 0 ? (
              <div className="card">
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead>
                      <tr className="border-b border-gray-100">
                        <th className="text-left py-3 font-medium text-text-secondary">Customer</th>
                        <th className="text-left py-3 font-medium text-text-secondary">Phone</th>
                        <th className="text-left py-3 font-medium text-text-secondary">Garment</th>
                        <th className="text-right py-3 font-medium text-text-secondary">Total</th>
                        <th className="text-right py-3 font-medium text-text-secondary">Advance</th>
                        <th className="text-right py-3 font-medium text-text-secondary">Balance</th>
                      </tr>
                    </thead>
                    <tbody>
                      {pendingDues.orders.map((order) => (
                        <tr key={order._id} className="border-b border-gray-50 hover:bg-gray-50 transition-colors">
                          <td className="py-3 font-medium text-text-primary">{order.customerName}</td>
                          <td className="py-3 text-text-secondary">{order.customerPhone}</td>
                          <td className="py-3 text-text-secondary">{garmentLabel(order.garmentType)}</td>
                          <td className="py-3 text-right">₹{order.price.toLocaleString('en-IN')}</td>
                          <td className="py-3 text-right">₹{order.advancePaid.toLocaleString('en-IN')}</td>
                          <td className="py-3 text-right font-bold text-red-600">₹{order.balance.toLocaleString('en-IN')}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            ) : (
              <div className="card text-center py-8">
                <FiCheckCircle size={48} className="mx-auto text-green-500 mb-3" />
                <p className="text-text-secondary font-medium">No pending dues! All orders are paid in full.</p>
              </div>
            )}
          </div>
        );

      case 'delivery':
        return (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div className="card">
              <div className="flex items-center gap-2 mb-4">
                <FiCalendar className="text-accent" size={20} />
                <h3 className="font-semibold text-text-primary">Upcoming Deliveries (7 days)</h3>
              </div>
              {deliveryData?.upcoming?.length > 0 ? (
                <div className="space-y-2">
                  {deliveryData.upcoming.map((item) => (
                    <div key={item._id} className="flex items-center justify-between p-3 rounded-lg bg-blue-50 border border-blue-100">
                      <div>
                        <p className="font-medium text-text-primary">{item.customer?.name}</p>
                        <p className="text-xs text-text-secondary">{item.customer?.phone} — {garmentLabel(item.garmentType)}</p>
                      </div>
                      <span className="text-sm font-semibold text-blue-600">{new Date(item.deliveryDate).toLocaleDateString('en-IN')}</span>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="text-text-secondary text-center py-8">No upcoming deliveries</p>
              )}
            </div>
            <div className="card">
              <div className="flex items-center gap-2 mb-4">
                <FiXCircle className="text-red-500" size={20} />
                <h3 className="font-semibold text-text-primary">Overdue Deliveries</h3>
              </div>
              {deliveryData?.overdue?.length > 0 ? (
                <div className="space-y-2">
                  {deliveryData.overdue.map((item) => (
                    <div key={item._id} className="flex items-center justify-between p-3 rounded-lg bg-red-50 border border-red-100">
                      <div>
                        <p className="font-medium text-text-primary">{item.customer?.name}</p>
                        <p className="text-xs text-text-secondary">{item.customer?.phone} — {garmentLabel(item.garmentType)}</p>
                      </div>
                      <span className="text-sm font-semibold text-red-600">{new Date(item.deliveryDate).toLocaleDateString('en-IN')}</span>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="text-text-secondary text-center py-8">
                  <FiCheckCircle size={24} className="inline text-green-500 mr-1" /> No overdue deliveries
                </p>
              )}
            </div>
          </div>
        );

      case 'top-customers':
        return (
          <div className="card">
            <h3 className="font-semibold text-text-primary mb-4">Top Customers by Orders</h3>
            {topCustomers.length > 0 ? (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-gray-100">
                      <th className="text-left py-3 font-medium text-text-secondary">#</th>
                      <th className="text-left py-3 font-medium text-text-secondary">Name</th>
                      <th className="text-left py-3 font-medium text-text-secondary">Phone</th>
                      <th className="text-center py-3 font-medium text-text-secondary">Orders</th>
                      <th className="text-right py-3 font-medium text-text-secondary">Total Spent</th>
                    </tr>
                  </thead>
                  <tbody>
                    {topCustomers.map((customer, i) => (
                      <tr key={customer.customerId} className="border-b border-gray-50 hover:bg-gray-50 transition-colors">
                        <td className="py-3 font-bold text-text-secondary">{i + 1}</td>
                        <td className="py-3 font-medium text-text-primary">{customer.customerName}</td>
                        <td className="py-3 text-text-secondary">{customer.customerPhone}</td>
                        <td className="py-3 text-center font-semibold">{customer.orderCount}</td>
                        <td className="py-3 text-right">₹{customer.totalSpent.toLocaleString('en-IN')}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ) : (
              <p className="text-text-secondary text-center py-8">No data available</p>
            )}
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <Navbar onToggleSidebar={() => setSidebarOpen(!sidebarOpen)} sidebarOpen={sidebarOpen} />
      <div className="flex">
        <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />
        <main className="flex-1 p-4 md:p-6">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
            <h1 className="text-2xl font-bold text-primary">Reports</h1>
            <div className="flex items-center gap-2">
              <input type="date" value={dateRange.startDate} onChange={(e) => setDateRange((p) => ({ ...p, startDate: e.target.value }))} className="input-field text-sm w-36" />
              <span className="text-text-secondary">to</span>
              <input type="date" value={dateRange.endDate} onChange={(e) => setDateRange((p) => ({ ...p, endDate: e.target.value }))} className="input-field text-sm w-36" />
            </div>
          </div>

          <div className="flex overflow-x-auto gap-2 mb-6 pb-2">
            {tabs.map((tab) => {
              const Icon = tab.icon;
              return (
                <button
                  key={tab.key}
                  onClick={() => setActiveTab(tab.key)}
                  className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium whitespace-nowrap transition-colors ${
                    activeTab === tab.key ? 'bg-primary text-white' : 'bg-white text-text-secondary hover:bg-gray-100 border border-gray-200'
                  }`}
                >
                  <Icon size={16} />
                  {tab.label}
                </button>
              );
            })}
          </div>

          {loading ? <Loader /> : renderTab()}
        </main>
      </div>
    </div>
  );
}
