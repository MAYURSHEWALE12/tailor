import { useState, useEffect } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { FiArrowLeft, FiPlus, FiMessageCircle, FiDownload, FiEdit2, FiTrash2, FiTool, FiDollarSign, FiX } from 'react-icons/fi';
import { jsPDF } from 'jspdf';
import { getCustomer } from '../api/customerApi';
import { getCustomerMeasurements, deleteMeasurement, addPayment } from '../api/measurementApi';
import Navbar from '../components/Navbar';
import Sidebar from '../components/Sidebar';
import Loader from '../components/Loader';

const statusColors = {
  pending: 'bg-yellow-100 text-yellow-700',
  cutting: 'bg-blue-100 text-blue-700',
  stitching: 'bg-purple-100 text-purple-700',
  ready: 'bg-green-100 text-green-700',
  delivered: 'bg-gray-100 text-gray-700',
};

export default function CustomerDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [customer, setCustomer] = useState(null);
  const [measurements, setMeasurements] = useState([]);
  const [loading, setLoading] = useState(true);
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [paymentModal, setPaymentModal] = useState(null);
  const [payAmount, setPayAmount] = useState('');
  const [payMethod, setPayMethod] = useState('cash');
  const [payNotes, setPayNotes] = useState('');
  const [paying, setPaying] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [custRes, measRes] = await Promise.all([
          getCustomer(id),
          getCustomerMeasurements(id),
        ]);
        setCustomer(custRes.data);
        setMeasurements(measRes.data);
      } catch {
        toast.error('Failed to load customer data');
        navigate('/customers');
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [id, navigate]);

  const handleDeleteMeasurement = async (measId) => {
    if (!window.confirm('Delete this measurement record?')) return;
    try {
      await deleteMeasurement(measId);
      setMeasurements((prev) => prev.filter((m) => m._id !== measId));
      toast.success('Measurement deleted');
    } catch {
      toast.error('Failed to delete');
    }
  };

  const whatsappShare = (measurement) => {
    const m = measurement.measurements;
    const totalPaid = (measurement.advancePaid || 0) + (measurement.payments || []).reduce((s, p) => s + p.amount, 0);
    const balance = (measurement.price || 0) - totalPaid;
    const text = [
      `🧵 *ShivaayTailor - Measurement Card*`,
      `👤 Customer: ${customer.name}`,
      `📞 Phone: ${customer.phone}`,
      `👔 Garment: ${measurement.garmentType.toUpperCase()}`,
      `📅 Date: ${new Date(measurement.createdAt).toLocaleDateString('en-IN')}`,
      ``,
      `📏 *Measurements:*`,
      ...Object.entries(m).filter(([, v]) => v != null && v !== '').map(([k, v]) => `- ${k}: ${v}"`),
      ``,
      measurement.price ? `💰 Price: ₹${measurement.price}` : '',
      `💵 Paid: ₹${totalPaid}`,
      `⚖️ Balance: ₹${balance}`,
      measurement.deliveryDate ? `🗓️ Delivery: ${new Date(measurement.deliveryDate).toLocaleDateString('en-IN')}` : '',
      ``,
      `✂️ ShivaayTailor App`,
    ].filter(Boolean).join('\n');

    window.open(`https://wa.me/?text=${encodeURIComponent(text)}`, '_blank');
  };

  const exportPDF = (measurement) => {
    const doc = new jsPDF();
    doc.setFontSize(18);
    doc.text('ShivaayTailor', 105, 20, { align: 'center' });
    doc.setFontSize(12);
    doc.text(`Customer: ${customer.name}`, 20, 35);
    doc.text(`Phone: ${customer.phone}`, 20, 42);
    doc.text(`Garment: ${measurement.garmentType.toUpperCase()}`, 20, 49);
    doc.text(`Date: ${new Date(measurement.createdAt).toLocaleDateString('en-IN')}`, 20, 56);

    const m = measurement.measurements;
    const entries = Object.entries(m).filter(([, v]) => v != null && v !== '');
    doc.text('Measurements:', 20, 66);
    entries.forEach(([k, v], i) => {
      doc.text(`- ${k}: ${v}"`, 20, 74 + i * 7);
    });

    const yOffset = 74 + entries.length * 7 + 10;
    if (measurement.price) doc.text(`Price: ₹${measurement.price}`, 20, yOffset);
    if (measurement.advancePaid) doc.text(`Advance: ₹${measurement.advancePaid}`, 20, yOffset + 7);
    if (measurement.specialInstructions) doc.text(`Notes: ${measurement.specialInstructions}`, 20, yOffset + 14);

    doc.save(`${customer.name}_${measurement.garmentType}.pdf`);
    toast.success('PDF downloaded');
  };

  const calcTotalPaid = (m) => (m.advancePaid || 0) + (m.payments || []).reduce((s, p) => s + p.amount, 0);
  const calcBalance = (m) => (m.price || 0) - calcTotalPaid(m);

  const handleAddPayment = async (measId) => {
    if (!payAmount || Number(payAmount) <= 0) {
      toast.error('Enter a valid amount');
      return;
    }
    setPaying(true);
    try {
      const updated = await addPayment(measId, {
        amount: Number(payAmount),
        method: payMethod,
        notes: payNotes,
      });
      setMeasurements((prev) => prev.map((m) => (m._id === measId ? updated.data : m)));
      toast.success('Payment added');
      setPaymentModal(null);
      setPayAmount('');
      setPayNotes('');
      setPayMethod('cash');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to add payment');
    } finally {
      setPaying(false);
    }
  };

  if (loading) return <Loader />;

  return (
    <div className="min-h-screen bg-background">
      <Navbar onToggleSidebar={() => setSidebarOpen(!sidebarOpen)} sidebarOpen={sidebarOpen} />
      <div className="flex">
        <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />
        <main className="flex-1 p-4 md:p-6">
          <button onClick={() => navigate('/customers')} className="flex items-center gap-1 text-text-secondary hover:text-primary mb-4 transition-colors">
            <FiArrowLeft size={16} /> Back to Customers
          </button>

          <div className="card mb-6">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
              <div className="flex items-center gap-4">
                <div className="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold text-xl">
                  {customer.name.charAt(0).toUpperCase()}
                </div>
                <div>
                  <h1 className="text-2xl font-bold text-primary">{customer.name}</h1>
                  <p className="text-text-secondary">{customer.phone}</p>
                  {customer.email && <p className="text-text-secondary text-sm">{customer.email}</p>}
                  {customer.address && <p className="text-text-secondary text-sm">{customer.address}</p>}
                </div>
              </div>
              <Link to={`/customers/${id}/measurements/add`} className="btn-primary flex items-center gap-2 text-sm">
                <FiPlus size={16} /> New Measurement
              </Link>
            </div>
            {customer.notes && (
              <div className="mt-4 p-3 bg-gray-50 rounded-lg text-sm text-text-secondary">
                <span className="font-medium">Notes:</span> {customer.notes}
              </div>
            )}
          </div>

          <h2 className="text-xl font-bold text-primary mb-4">Measurement Records</h2>

          {measurements.length === 0 ? (
            <div className="card text-center py-12">
              <FiTool size={48} className="mx-auto text-text-secondary mb-4" />
              <p className="text-text-secondary mb-4">No measurements recorded yet.</p>
              <Link to={`/customers/${id}/measurements/add`} className="btn-primary inline-flex items-center gap-2">
                <FiPlus size={16} /> Add First Measurement
              </Link>
            </div>
          ) : (
            <div className="space-y-4">
              {measurements.map((meas) => {
                const totalPaid = calcTotalPaid(meas);
                const balance = calcBalance(meas);
                return (
                  <div key={meas._id} className="card">
                    <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 mb-4">
                      <div className="flex items-center gap-3">
                        <span className="px-3 py-1 rounded-full text-xs font-semibold uppercase bg-primary/10 text-primary">
                          {meas.garmentType}
                        </span>
                        <span className={`px-3 py-1 rounded-full text-xs font-medium ${statusColors[meas.orderStatus]}`}>
                          {meas.orderStatus}
                        </span>
                        <span className="text-xs text-text-secondary">
                          {new Date(meas.createdAt).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })}
                        </span>
                      </div>
                      <div className="flex items-center gap-2">
                        <button onClick={() => { setPaymentModal(meas._id); setPayAmount(''); setPayNotes(''); }} className="p-2 text-green-600 hover:bg-green-50 rounded-lg transition-colors" title="Add Payment">
                          <FiDollarSign size={18} />
                        </button>
                        <button onClick={() => whatsappShare(meas)} className="p-2 text-green-600 hover:bg-green-50 rounded-lg transition-colors" title="Share on WhatsApp">
                          <FiMessageCircle size={18} />
                        </button>
                        <button onClick={() => exportPDF(meas)} className="p-2 text-primary hover:bg-primary/5 rounded-lg transition-colors" title="Download PDF">
                          <FiDownload size={18} />
                        </button>
                        <Link to={`/customers/${id}/design`} className="p-2 text-accent hover:bg-accent/5 rounded-lg transition-colors" title="Generate Design">
                          <FiTool size={18} />
                        </Link>
                        <button onClick={() => handleDeleteMeasurement(meas._id)} className="p-2 text-red-500 hover:bg-red-50 rounded-lg transition-colors" title="Delete">
                          <FiTrash2 size={18} />
                        </button>
                      </div>
                    </div>

                    {meas.designImage && (
                      <div className="mb-4">
                        <img src={meas.designImage} alt="Design reference" className="max-h-40 rounded-lg border border-gray-200 cursor-pointer" onClick={() => window.open(meas.designImage, '_blank')} />
                      </div>
                    )}

                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
                      {Object.entries(meas.measurements).filter(([, v]) => v != null && v !== '').map(([key, value]) => (
                        <div key={key} className="bg-gray-50 rounded-lg p-3">
                          <p className="text-xs text-text-secondary capitalize">{key.replace(/([A-Z])/g, ' $1')}</p>
                          <p className="font-semibold text-text-primary">{value}{meas.unit === 'cm' ? ' cm' : '"'}</p>
                        </div>
                      ))}
                    </div>

                    <div className="mt-4 pt-4 border-t border-gray-100">
                      <div className="grid grid-cols-1 sm:grid-cols-4 gap-3 text-sm mb-3">
                        {meas.price > 0 && <div><span className="text-text-secondary">Price:</span> <span className="font-medium">₹{meas.price}</span></div>}
                        <div><span className="text-text-secondary">Paid:</span> <span className="font-medium text-green-600">₹{totalPaid}</span></div>
                        <div><span className="text-text-secondary">Balance:</span> <span className={`font-medium ${balance > 0 ? 'text-red-600' : 'text-green-600'}`}>₹{balance}</span></div>
                        {meas.deliveryDate && <div><span className="text-text-secondary">Delivery:</span> <span className="font-medium">{new Date(meas.deliveryDate).toLocaleDateString('en-IN')}</span></div>}
                      </div>

                      {/* Payment History */}
                      {meas.payments && meas.payments.length > 0 && (
                        <div className="bg-gray-50 rounded-lg p-3">
                          <p className="text-xs font-semibold text-text-secondary mb-2">Payment History</p>
                          {meas.payments.map((p, i) => (
                            <div key={i} className="flex items-center justify-between text-xs py-1 border-b border-gray-100 last:border-0">
                              <span className="text-text-secondary">{new Date(p.date).toLocaleDateString('en-IN')}</span>
                              <span className="capitalize text-text-secondary">{p.method}</span>
                              <span className="font-semibold text-green-600">+₹{p.amount}</span>
                              {p.notes && <span className="text-text-secondary ml-2">— {p.notes}</span>}
                            </div>
                          ))}
                        </div>
                      )}

                      {meas.specialInstructions && (
                        <div className="mt-2 text-sm"><span className="text-text-secondary">Instructions:</span> {meas.specialInstructions}</div>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </main>
      </div>

      {/* Payment Modal */}
      {paymentModal && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4" onClick={() => setPaymentModal(null)}>
          <div className="bg-white rounded-card p-6 w-full max-w-md shadow-xl" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-semibold text-lg text-text-primary">Add Payment</h3>
              <button onClick={() => setPaymentModal(null)} className="p-1 hover:bg-gray-100 rounded-lg transition-colors">
                <FiX size={20} />
              </button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-text-secondary mb-1">Amount (₹)</label>
                <input type="number" value={payAmount} onChange={(e) => setPayAmount(e.target.value)} className="input-field" placeholder="Enter amount" min="0" autoFocus />
              </div>
              <div>
                <label className="block text-sm font-medium text-text-secondary mb-1">Payment Method</label>
                <select value={payMethod} onChange={(e) => setPayMethod(e.target.value)} className="input-field">
                  <option value="cash">Cash</option>
                  <option value="online">Online</option>
                  <option value="upi">UPI</option>
                  <option value="other">Other</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-text-secondary mb-1">Notes (Optional)</label>
                <input type="text" value={payNotes} onChange={(e) => setPayNotes(e.target.value)} className="input-field" placeholder="e.g., Paid via Google Pay" />
              </div>
              <button onClick={() => handleAddPayment(paymentModal)} disabled={paying} className="btn-primary w-full flex items-center justify-center gap-2 disabled:opacity-60 py-3">
                {paying ? <span className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" /> : 'Add Payment'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
