/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#1A3A5C',
        'primary-light': '#2A4A6C',
        accent: '#D4A017',
        'accent-light': '#E4B027',
        success: '#22C55E',
        warning: '#F59E0B',
        error: '#EF4444',
        background: '#F8FAFC',
        'card-bg': '#FFFFFF',
        'text-primary': '#1A1A1A',
        'text-secondary': '#64748B',
      },
      fontFamily: {
        sans: ['Poppins', 'sans-serif'],
      },
      borderRadius: {
        card: '12px',
        input: '8px',
      },
      boxShadow: {
        card: '0 2px 12px rgba(0,0,0,0.08)',
      },
    },
  },
  plugins: [],
};
