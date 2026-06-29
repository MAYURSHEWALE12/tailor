import { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { FiArrowLeft, FiSave, FiImage, FiX } from 'react-icons/fi';
import { getCustomer } from '../api/customerApi';
import { createMeasurement, uploadImage } from '../api/measurementApi';
import Navbar from '../components/Navbar';
import Sidebar from '../components/Sidebar';
import MeasurementForm from '../components/MeasurementForm';
import Loader from '../components/Loader';

const garmentTypes = [
  { value: 'shirt', label: 'Shirt' },
  { value: 'pant', label: 'Pant' },
  { value: 'kurta', label: 'Kurta' },
  { value: 'blouse', label: 'Blouse' },
  { value: 'sadra', label: 'Sadra' },
];

export default function AddMeasurementPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [customer, setCustomer] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [garmentType, setGarmentType] = useState('shirt');
  const [unit, setUnit] = useState('inches');
  const [measurements, setMeasurements] = useState({});
  const [price, setPrice] = useState('');
  const [advancePaid, setAdvancePaid] = useState('');
  const [deliveryDate, setDeliveryDate] = useState('');
  const [specialInstructions, setSpecialInstructions] = useState('');
  const [designImage, setDesignImage] = useState(null);
  const [designPreview, setDesignPreview] = useState('');
  const [uploading, setUploading] = useState(false);
  const fileRef = useRef(null);

  useEffect(() => {
    const fetchCustomer = async () => {
      try {
        const { data } = await getCustomer(id);
        setCustomer(data);
      } catch {
        toast.error('Customer not found');
        navigate('/customers');
      } finally {
        setLoading(false);
      }
    };
    fetchCustomer();
  }, [id, navigate]);

  const handleMeasurementChange = (key, value) => {
    setMeasurements((prev) => ({ ...prev, [key]: value }));
  };

  const handleImageSelect = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (!file.type.startsWith('image/')) {
      toast.error('Please select an image file');
      return;
    }
    setDesignImage(file);
    const reader = new FileReader();
    reader.onload = (ev) => setDesignPreview(ev.target?.result);
    reader.readAsDataURL(file);
  };

  const removeImage = () => {
    setDesignImage(null);
    setDesignPreview('');
    if (fileRef.current) fileRef.current.value = '';
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);

    let imageUrl = '';

    try {
      if (designImage) {
        setUploading(true);
        const { data } = await uploadImage(designImage);
        imageUrl = data.url;
        setUploading(false);
      }

      await createMeasurement({
        customerId: id,
        garmentType,
        measurements,
        unit,
        specialInstructions,
        price: Number(price) || 0,
        advancePaid: Number(advancePaid) || 0,
        deliveryDate: deliveryDate || undefined,
        designImage: imageUrl || undefined,
      });
      toast.success('Measurement saved successfully!');
      navigate(`/customers/${id}`);
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to save measurement');
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <Loader />;

  return (
    <div className="min-h-screen bg-background">
      <Navbar onToggleSidebar={() => setSidebarOpen(!sidebarOpen)} sidebarOpen={sidebarOpen} />
      <div className="flex">
        <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />
        <main className="flex-1 p-4 md:p-6 max-w-3xl">
          <button onClick={() => navigate(`/customers/${id}`)} className="flex items-center gap-1 text-text-secondary hover:text-primary mb-4 transition-colors">
            <FiArrowLeft size={16} /> Back to Customer
          </button>

          {customer && (
            <div className="card mb-6">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold">
                  {customer.name.charAt(0).toUpperCase()}
                </div>
                <div>
                  <h2 className="font-semibold text-text-primary">{customer.name}</h2>
                  <p className="text-sm text-text-secondary">{customer.phone}</p>
                </div>
              </div>
            </div>
          )}

          <form onSubmit={handleSubmit} className="card space-y-6">
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-2">Garment Type</label>
              <div className="flex flex-wrap gap-2">
                {garmentTypes.map((g) => (
                  <button
                    key={g.value}
                    type="button"
                    onClick={() => setGarmentType(g.value)}
                    className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                      garmentType === g.value ? 'bg-primary text-white' : 'bg-gray-100 text-text-secondary hover:bg-gray-200'
                    }`}
                  >
                    {g.label}
                  </button>
                ))}
              </div>
            </div>

            <MeasurementForm
              garmentType={garmentType}
              measurements={measurements}
              onChange={handleMeasurementChange}
              unit={unit}
              onUnitChange={setUnit}
            />

            <div className="border border-dashed border-gray-300 rounded-card p-4">
              <label className="block text-sm font-medium text-text-secondary mb-2">Design Image (Optional)</label>
              {designPreview ? (
                <div className="relative inline-block">
                  <img src={designPreview} alt="Design preview" className="max-h-48 rounded-lg border border-gray-200" />
                  <button type="button" onClick={removeImage} className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-1 shadow hover:bg-red-600 transition-colors">
                    <FiX size={14} />
                  </button>
                </div>
              ) : (
                <div
                  onClick={() => fileRef.current?.click()}
                  className="flex flex-col items-center justify-center py-8 cursor-pointer hover:bg-gray-50 rounded-lg transition-colors"
                >
                  <FiImage size={36} className="text-text-secondary mb-2" />
                  <p className="text-sm text-text-secondary font-medium">Click to upload design image</p>
                  <p className="text-xs text-text-secondary mt-1">JPG, PNG, GIF, WebP up to 5MB</p>
                </div>
              )}
              <input ref={fileRef} type="file" accept="image/*" onChange={handleImageSelect} className="hidden" />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-text-secondary mb-1">Price (₹)</label>
                <input type="number" value={price} onChange={(e) => setPrice(e.target.value)} className="input-field" placeholder="0" min="0" />
              </div>
              <div>
                <label className="block text-sm font-medium text-text-secondary mb-1">Advance Paid (₹)</label>
                <input type="number" value={advancePaid} onChange={(e) => setAdvancePaid(e.target.value)} className="input-field" placeholder="0" min="0" />
              </div>
              <div>
                <label className="block text-sm font-medium text-text-secondary mb-1">Delivery Date</label>
                <input type="date" value={deliveryDate} onChange={(e) => setDeliveryDate(e.target.value)} className="input-field" />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1">Special Instructions (Optional)</label>
              <textarea value={specialInstructions} onChange={(e) => setSpecialInstructions(e.target.value)} className="input-field" rows={3} placeholder="Fabric type, styling preferences, extra notes..." />
            </div>

            <button type="submit" disabled={saving || uploading} className="btn-primary w-full flex items-center justify-center gap-2 disabled:opacity-60 py-3">
              {saving || uploading ? (
                <span className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
              ) : (
                <><FiSave size={18} /> Save Measurements</>
              )}
            </button>
          </form>
        </main>
      </div>
    </div>
  );
}
