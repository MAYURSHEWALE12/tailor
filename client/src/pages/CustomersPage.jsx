import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import toast from 'react-hot-toast';
import { FiPlus, FiSearch, FiUser } from 'react-icons/fi';
import { getCustomers, deleteCustomer } from '../api/customerApi';
import Navbar from '../components/Navbar';
import Sidebar from '../components/Sidebar';
import CustomerCard from '../components/CustomerCard';
import Loader from '../components/Loader';

export default function CustomersPage() {
  const [customers, setCustomers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const fetchCustomers = async (q) => {
    setLoading(true);
    try {
      const { data } = await getCustomers(q);
      setCustomers(data);
    } catch (error) {
      toast.error('Failed to load customers');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCustomers();
  }, []);

  useEffect(() => {
    const timer = setTimeout(() => {
      fetchCustomers(search);
    }, 400);
    return () => clearTimeout(timer);
  }, [search]);

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this customer and all their measurements?')) return;
    try {
      await deleteCustomer(id);
      setCustomers((prev) => prev.filter((c) => c._id !== id));
      toast.success('Customer deleted');
    } catch {
      toast.error('Failed to delete customer');
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <Navbar onToggleSidebar={() => setSidebarOpen(!sidebarOpen)} sidebarOpen={sidebarOpen} />
      <div className="flex">
        <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />
        <main className="flex-1 p-4 md:p-6">
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
            <h1 className="text-2xl font-bold text-primary">Customers</h1>
            <Link to="/customers/add" className="btn-primary flex items-center gap-2 text-sm">
              <FiPlus size={16} /> Add Customer
            </Link>
          </div>

          <div className="relative mb-6 max-w-md">
            <FiSearch className="absolute left-3 top-1/2 -translate-y-1/2 text-text-secondary" size={18} />
            <input
              type="text"
              placeholder="Search by name or phone..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="input-field pl-10"
            />
          </div>

          {loading ? (
            <Loader />
          ) : customers.length === 0 ? (
            <div className="text-center py-16">
              <FiUser size={48} className="mx-auto text-text-secondary mb-4" />
              <p className="text-text-secondary mb-4">
                {search ? 'No customers match your search.' : 'No customers yet.'}
              </p>
              <Link to="/customers/add" className="btn-primary inline-flex items-center gap-2">
                <FiPlus size={16} /> Add Your First Customer
              </Link>
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {customers.map((customer) => (
                <CustomerCard key={customer._id} customer={customer} onDelete={handleDelete} />
              ))}
            </div>
          )}
        </main>
      </div>
    </div>
  );
}
