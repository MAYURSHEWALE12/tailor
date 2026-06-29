import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { FiArrowLeft, FiCopy, FiExternalLink, FiCpu } from 'react-icons/fi';
import { getCustomer } from '../api/customerApi';
import { getCustomerMeasurements } from '../api/measurementApi';
import Navbar from '../components/Navbar';
import Sidebar from '../components/Sidebar';
import Loader from '../components/Loader';

const styleOptions = ['Formal', 'Casual', 'Traditional'];
const colorOptions = [
  { name: 'Navy Blue', hex: '#1A3A5C' },
  { name: 'White', hex: '#FFFFFF' },
  { name: 'Black', hex: '#000000' },
  { name: 'Gray', hex: '#808080' },
  { name: 'Beige', hex: '#F5F5DC' },
  { name: 'Maroon', hex: '#800000' },
  { name: 'Forest Green', hex: '#228B22' },
  { name: 'Burgundy', hex: '#800020' },
];

export default function DesignGeneratorPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [customer, setCustomer] = useState(null);
  const [measurements, setMeasurements] = useState([]);
  const [loading, setLoading] = useState(true);
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [style, setStyle] = useState('Formal');
  const [color, setColor] = useState('#1A3A5C');
  const [prompt, setPrompt] = useState('');
  const [selectedMeas, setSelectedMeas] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [custRes, measRes] = await Promise.all([
          getCustomer(id),
          getCustomerMeasurements(id),
        ]);
        setCustomer(custRes.data);
        setMeasurements(measRes.data);
        if (measRes.data.length > 0) {
          setSelectedMeas(measRes.data[0]._id);
        }
      } catch {
        toast.error('Failed to load data');
        navigate('/customers');
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [id, navigate]);

  useEffect(() => {
    if (!selectedMeas || !customer) return;
    const meas = measurements.find((m) => m._id === selectedMeas);
    if (!meas) return;

    const m = meas.measurements;
    const lines = [
      `Professional ${style.toLowerCase()} ${meas.garmentType} design for men`,
      `Color: ${colorOptions.find((c) => c.hex === color)?.name || 'Navy Blue'}`,
      `Style: ${style} fit with clean elegant finish`,
      `Measurements:`,
    ];

    const labelMap = {
      length: 'Length (लांबी)',
      chest: 'Chest (छाती)',
      waist: 'Waist (कंबर)',
      stomach: 'Stomach (पोट)',
      shoulder: 'Shoulder (खांदा)',
      sleeve: 'Sleeve (बाही)',
      collar: 'Collar (गळा)',
      pantLength: 'Length',
      seat: 'Seat',
      thigh: 'Thigh',
      knee: 'Knee',
      bottom: 'Bottom',
      rise: 'Rise',
      kurtalength: 'Length (लांबी)',
      kurtaghera: 'Ghera (घेरा)',
      blouseLength: 'Length (लांबी)',
      bust: 'Bust (बस्ट)',
      blouseWaist: 'Waist (कंबर)',
      hip: 'Hip',
      backNeck: 'Back Neck',
      frontNeck: 'Front Neck',
      blouseSleeve: 'Sleeve (बाही)',
    };

    Object.entries(m).filter(([, v]) => v != null && v !== '').forEach(([k, v]) => {
      const label = labelMap[k] || k.replace(/([A-Z])/g, ' $1');
      lines.push(`- ${label}: ${v}"`);
    });

    lines.push(`High quality, photorealistic product shot on mannequin, professional studio lighting, clean white background, sharp details, fashion catalog quality, 8K, hyperrealistic`);

    setPrompt(lines.join('\n'));
  }, [selectedMeas, style, color, customer, measurements]);

  const copyPrompt = () => {
    navigator.clipboard.writeText(prompt);
    toast.success('Prompt copied to clipboard!');
  };

  if (loading) return <Loader />;

  return (
    <div className="min-h-screen bg-background">
      <Navbar onToggleSidebar={() => setSidebarOpen(!sidebarOpen)} sidebarOpen={sidebarOpen} />
      <div className="flex">
        <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />
        <main className="flex-1 p-4 md:p-6">
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
                  <h1 className="text-xl font-bold text-primary">AI Design Generator</h1>
                  <p className="text-sm text-text-secondary">{customer.name} — Generating for {style} style</p>
                </div>
              </div>
            </div>
          )}

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div className="lg:col-span-1 space-y-4">
              <div className="card">
                <h3 className="font-semibold text-text-primary mb-3">Select Measurement</h3>
                <select
                  value={selectedMeas || ''}
                  onChange={(e) => setSelectedMeas(e.target.value)}
                  className="input-field"
                >
                  {measurements.map((m) => (
                    <option key={m._id} value={m._id}>
                      {m.garmentType.toUpperCase()} — {new Date(m.createdAt).toLocaleDateString('en-IN')}
                    </option>
                  ))}
                </select>
              </div>

              <div className="card">
                <h3 className="font-semibold text-text-primary mb-3">Style Profile</h3>
                <div className="flex flex-wrap gap-2">
                  {styleOptions.map((s) => (
                    <button
                      key={s}
                      onClick={() => setStyle(s)}
                      className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                        style === s ? 'bg-primary text-white' : 'bg-gray-100 text-text-secondary hover:bg-gray-200'
                      }`}
                    >
                      {s}
                    </button>
                  ))}
                </div>
              </div>

              <div className="card">
                <h3 className="font-semibold text-text-primary mb-3">Color Palette</h3>
                <div className="flex flex-wrap gap-3">
                  {colorOptions.map((c) => (
                    <button
                      key={c.hex}
                      onClick={() => setColor(c.hex)}
                      className={`w-10 h-10 rounded-full border-2 transition-all ${
                        color === c.hex ? 'border-primary ring-2 ring-primary ring-offset-2' : 'border-gray-300'
                      }`}
                      style={{ backgroundColor: c.hex }}
                      title={c.name}
                    />
                  ))}
                </div>
              </div>
            </div>

            <div className="lg:col-span-2 space-y-4">
              <div className="card">
                <div className="flex items-center justify-between mb-3">
                  <h3 className="font-semibold text-text-primary flex items-center gap-2">
                    <FiCpu className="text-accent" /> Generated Prompt
                  </h3>
                  <button onClick={copyPrompt} className="flex items-center gap-1 text-sm text-primary hover:text-primary-light transition-colors">
                    <FiCopy size={14} /> Copy
                  </button>
                </div>
                <textarea
                  readOnly
                  value={prompt}
                  className="w-full h-64 bg-gray-50 border border-gray-200 rounded-lg p-4 text-sm font-mono resize-none focus:outline-none"
                />
              </div>

              <div className="card">
                <h3 className="font-semibold text-text-primary mb-3">Use With AI Tools</h3>
                <p className="text-sm text-text-secondary mb-4">Copy the prompt above and use it with your preferred AI image generator.</p>
                <div className="flex flex-wrap gap-3">
                  {[
                    { name: 'DALL-E 3', url: 'https://chat.openai.com' },
                    { name: 'Midjourney', url: 'https://www.midjourney.com' },
                    { name: 'Stable Diffusion', url: 'https://stability.ai' },
                    { name: 'Leonardo AI', url: 'https://leonardo.ai' },
                  ].map((tool) => (
                    <a
                      key={tool.name}
                      href={tool.url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="flex items-center gap-2 px-4 py-2 bg-gray-100 rounded-lg text-sm font-medium text-text-secondary hover:bg-primary hover:text-white transition-colors"
                    >
                      {tool.name} <FiExternalLink size={14} />
                    </a>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}
