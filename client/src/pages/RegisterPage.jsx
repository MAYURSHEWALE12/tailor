import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { FiSmartphone, FiLock, FiUser, FiShoppingBag, FiEye, FiEyeOff } from 'react-icons/fi';

export default function RegisterPage() {
  const { register } = useAuth();
  const [form, setForm] = useState({ name: '', shopName: '', phone: '', email: '', password: '' });
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await register(form);
    } catch {
      // toast handled in context
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-background flex items-center justify-center px-4 py-8">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <div className="w-12 h-12 bg-accent rounded-xl flex items-center justify-center mx-auto mb-4 font-bold text-white text-lg">ST</div>
          <h1 className="text-2xl font-bold text-primary">Create Account</h1>
          <p className="text-text-secondary text-sm mt-1">Start your digital tailoring journey</p>
        </div>

        <form onSubmit={handleSubmit} className="card space-y-4">
          <div>
            <label className="block text-sm font-medium text-text-secondary mb-1">Full Name</label>
            <div className="relative">
              <FiUser className="absolute left-3 top-1/2 -translate-y-1/2 text-text-secondary" size={18} />
              <input type="text" placeholder="Your name" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} className="input-field pl-10" required />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-text-secondary mb-1">Shop Name</label>
            <div className="relative">
              <FiShoppingBag className="absolute left-3 top-1/2 -translate-y-1/2 text-text-secondary" size={18} />
              <input type="text" placeholder="Your tailoring shop name" value={form.shopName} onChange={(e) => setForm({ ...form, shopName: e.target.value })} className="input-field pl-10" required />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-text-secondary mb-1">Phone Number</label>
            <div className="relative">
              <FiSmartphone className="absolute left-3 top-1/2 -translate-y-1/2 text-text-secondary" size={18} />
              <input type="tel" placeholder="Your phone number" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} className="input-field pl-10" required />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-text-secondary mb-1">Email (Optional)</label>
            <input type="email" placeholder="your@email.com" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} className="input-field" />
          </div>

          <div>
            <label className="block text-sm font-medium text-text-secondary mb-1">Password</label>
            <div className="relative">
              <FiLock className="absolute left-3 top-1/2 -translate-y-1/2 text-text-secondary" size={18} />
              <input type={showPassword ? 'text' : 'password'} placeholder="Min 6 characters" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} className="input-field pl-10 pr-10" minLength={6} required />
              <button type="button" onClick={() => setShowPassword(!showPassword)} className="absolute right-3 top-1/2 -translate-y-1/2 text-text-secondary">
                {showPassword ? <FiEyeOff size={18} /> : <FiEye size={18} />}
              </button>
            </div>
          </div>

          <button type="submit" disabled={loading} className="btn-primary w-full flex items-center justify-center gap-2 disabled:opacity-60">
            {loading ? <span className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" /> : 'Create Account'}
          </button>

          <p className="text-center text-sm text-text-secondary">
            Already have an account? <Link to="/login" className="text-primary font-semibold hover:text-primary-light">Sign In</Link>
          </p>
        </form>
      </div>
    </div>
  );
}
