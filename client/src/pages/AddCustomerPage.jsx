import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { FiUser, FiPhone, FiMail, FiMapPin, FiFileText } from 'react-icons/fi';
import { createCustomer } from '../api/customerApi';
import Navbar from '../components/Navbar';
import Sidebar from '../components/Sidebar';

export default function AddCustomerPage() {
  const navigate = useNavigate();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [form, setForm] = useState({ name: '', phone: '', email: '', address: '', notes: '' });
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.name || !form.phone) {
      toast.error('Name and phone are required');
      return;
    }
    setLoading(true);
    try {
      const { data } = await createCustomer(form);
      toast.success('Customer added successfully!');
      navigate(`/customers/${data._id}`);
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to add customer');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <Navbar onToggleSidebar={() => setSidebarOpen(!sidebarOpen)} sidebarOpen={sidebarOpen} />
      <div className="flex">
        <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />
        <main className="flex-1 p-4 md:p-6 max-w-2xl">
          <h1 className="text-2xl font-bold text-primary mb-6">Add New Customer</h1>

          <form onSubmit={handleSubmit} className="card space-y-4">
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1">Full Name *</label>
              <div className="relative">
                <FiUser className="absolute left-3 top-1/2 -translate-y-1/2 text-text-secondary" size={18} />
                <input name="name" value={form.name} onChange={handleChange} placeholder="Customer name" className="input-field pl-10" required />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1">Phone Number *</label>
              <div className="relative">
                <FiPhone className="absolute left-3 top-1/2 -translate-y-1/2 text-text-secondary" size={18} />
                <input name="phone" value={form.phone} onChange={handleChange} placeholder="Phone number" className="input-field pl-10" required />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1">Email (Optional)</label>
              <div className="relative">
                <FiMail className="absolute left-3 top-1/2 -translate-y-1/2 text-text-secondary" size={18} />
                <input name="email" type="email" value={form.email} onChange={handleChange} placeholder="email@example.com" className="input-field pl-10" />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1">Address (Optional)</label>
              <div className="relative">
                <FiMapPin className="absolute left-3 top-1/2 -translate-y-1/2 text-text-secondary" size={18} />
                <input name="address" value={form.address} onChange={handleChange} placeholder="Full address" className="input-field pl-10" />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1">Notes (Optional)</label>
              <div className="relative">
                <FiFileText className="absolute left-3 top-3 text-text-secondary" size={18} />
                <textarea name="notes" value={form.notes} onChange={handleChange} placeholder="Fabric preferences, style notes..." rows={3} className="input-field pl-10" />
              </div>
            </div>

            <div className="flex items-center gap-4 pt-2">
              <button type="submit" disabled={loading} className="btn-primary flex items-center gap-2 disabled:opacity-60">
                {loading ? <span className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" /> : 'Save Customer'}
              </button>
              <button type="button" onClick={() => navigate('/customers')} className="btn-outline">Cancel</button>
            </div>
          </form>
        </main>
      </div>
    </div>
  );
}
