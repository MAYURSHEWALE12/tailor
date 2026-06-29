import { Link } from 'react-router-dom';
import { FiArrowRight, FiSmartphone, FiShield, FiDownload, FiGlobe, FiMessageCircle } from 'react-icons/fi';

export default function HomePage() {
  return (
    <div className="min-h-screen bg-background">
      <nav className="bg-primary text-white px-4 md:px-8 py-4 flex items-center justify-between shadow-md">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 bg-accent rounded-lg flex items-center justify-center font-bold text-sm">ST</div>
          <span className="font-bold text-lg">ShivaayTailor</span>
        </div>
        <div className="flex items-center gap-4">
          <Link to="/login" className="text-sm font-medium hover:text-accent transition-colors">Login</Link>
          <Link to="/register" className="bg-accent text-white px-5 py-2 rounded-lg text-sm font-semibold hover:bg-accent-light transition-colors">Get Started</Link>
        </div>
      </nav>

      <section className="px-4 md:px-8 py-16 md:py-24 text-center max-w-4xl mx-auto">
        <div className="w-16 h-16 bg-accent/10 rounded-2xl flex items-center justify-center mx-auto mb-6">
          <FiSmartphone size={32} className="text-accent" />
        </div>
        <h1 className="text-4xl md:text-5xl font-bold text-primary mb-4">
          Your Tailor's <span className="text-accent">Digital Notebook</span>
        </h1>
        <p className="text-lg text-text-secondary max-w-2xl mx-auto mb-8">
          Store customer measurements, manage orders, and generate AI-powered clothing designs — all in one place. 
          <span className="block mt-1 text-primary font-semibold">शिवणकाम सोपे, मापे अचूक</span>
        </p>
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Link to="/register" className="btn-primary flex items-center justify-center gap-2 text-lg px-8 py-3">
            Start Free <FiArrowRight />
          </Link>
          <Link to="/login" className="btn-outline flex items-center justify-center text-lg px-8 py-3">
            Sign In
          </Link>
        </div>
      </section>

      <section className="px-4 md:px-8 py-16 bg-white">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-2xl md:text-3xl font-bold text-primary text-center mb-12">Why ShivaayTailor?</h2>
          <div className="grid md:grid-cols-3 gap-6">
            <div className="card text-center">
              <div className="w-12 h-12 bg-primary/10 rounded-xl flex items-center justify-center mx-auto mb-4">
                <FiShield size={24} className="text-primary" />
              </div>
              <h3 className="font-semibold text-text-primary mb-2">Digital Measurements</h3>
              <p className="text-sm text-text-secondary">Replace old diaries with accurate digital profiles for every client. Never lose a measurement again.</p>
            </div>
            <div className="card text-center">
              <div className="w-12 h-12 bg-accent/10 rounded-xl flex items-center justify-center mx-auto mb-4">
                <FiMessageCircle size={24} className="text-accent" />
              </div>
              <h3 className="font-semibold text-text-primary mb-2">WhatsApp Sharing</h3>
              <p className="text-sm text-text-secondary">Send measurement cards and status updates directly to your customers via WhatsApp.</p>
            </div>
            <div className="card text-center">
              <div className="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center mx-auto mb-4">
                <FiDownload size={24} className="text-green-600" />
              </div>
              <h3 className="font-semibold text-text-primary mb-2">PDF Export</h3>
              <p className="text-sm text-text-secondary">Export professional measurement sheets for your workshop team with one click.</p>
            </div>
          </div>
        </div>
      </section>

      <section className="px-4 md:px-8 py-16 max-w-4xl mx-auto">
        <h2 className="text-2xl md:text-3xl font-bold text-primary text-center mb-12">Simple 3-Step Process</h2>
        <div className="space-y-6">
          {[
            { step: '1', title: 'Add Customer', desc: 'Create a profile with name, phone number, and preferences.' },
            { step: '2', title: 'Enter Measurements', desc: 'Use our visual guide to input precise measurements in inches or cm.' },
            { step: '3', title: 'Generate Design', desc: 'Instantly create a shareable design sheet or print order details.' },
          ].map((item) => (
            <div key={item.step} className="flex items-start gap-4 card">
              <div className="w-10 h-10 rounded-full bg-primary text-white flex items-center justify-center font-bold shrink-0">{item.step}</div>
              <div>
                <h4 className="font-semibold text-text-primary">{item.title}</h4>
                <p className="text-sm text-text-secondary">{item.desc}</p>
              </div>
            </div>
          ))}
        </div>
      </section>

      <section className="bg-primary text-white px-4 md:px-8 py-16 text-center">
        <h2 className="text-2xl md:text-3xl font-bold mb-4">Ready to scale your business?</h2>
        <p className="text-white/80 mb-8 max-w-md mx-auto">Join modern tailors across India using ShivaayTailor.</p>
        <Link to="/register" className="bg-accent text-white px-8 py-3 rounded-card font-semibold text-lg hover:bg-accent-light transition-colors inline-flex items-center gap-2">
          Get Started for Free <FiArrowRight />
        </Link>
      </section>

      <footer className="bg-gray-900 text-white/60 px-4 md:px-8 py-8 text-center text-sm">
        <p>&copy; {new Date().getFullYear()} ShivaayTailor. All rights reserved. Built for the modern Indian artisan.</p>
      </footer>
    </div>
  );
}
