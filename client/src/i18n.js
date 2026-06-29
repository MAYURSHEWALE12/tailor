import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

const resources = {
  en: {
    translation: {
      welcome: 'Welcome',
      add_customer: 'Add Customer',
      total_customers: 'Total Customers',
      measurements_this_month: 'Measurements This Month',
      pending_orders: 'Pending Orders',
      ready_for_delivery: 'Ready for Delivery',
      recent_customers: 'Recent Customers',
      view_all: 'View All',
      name: 'Name',
      phone: 'Phone',
      date: 'Date',
      actions: 'Actions',
      view: 'View',
      measure: 'Measure',
      no_customers_yet: 'No customers yet. Add your first customer!',
      logout: 'Logout',
      login: 'Login',
      register: 'Register',
      dashboard: 'Dashboard',
      customers: 'Customers',
      select_language: 'Language',
    },
  },
  hi: {
    translation: {
      welcome: 'स्वागत है',
      add_customer: 'ग्राहक जोड़ें',
      total_customers: 'कुल ग्राहक',
      measurements_this_month: 'इस महीने के माप',
      pending_orders: 'लंबित ऑर्डर',
      ready_for_delivery: 'डिलिवरी के लिए तैयार',
      recent_customers: 'हाल के ग्राहक',
      view_all: 'सभी देखें',
      name: 'नाम',
      phone: 'फ़ोन',
      date: 'दिनांक',
      actions: 'कार्रवाई',
      view: 'देखें',
      measure: 'माप लें',
      no_customers_yet: 'अभी तक कोई ग्राहक नहीं है। अपना पहला ग्राहक जोड़ें!',
      logout: 'लॉगआउट',
      login: 'लॉगिन',
      register: 'रजिस्टर',
      dashboard: 'डैशबोर्ड',
      customers: 'ग्राहक',
      select_language: 'भाषा',
    },
  },
  mr: {
    translation: {
      welcome: 'स्वागत आहे',
      add_customer: 'ग्राहक जोडा',
      total_customers: 'एकूण ग्राहक',
      measurements_this_month: 'या महिन्याचे माप',
      pending_orders: 'प्रलंबित ऑर्डर',
      ready_for_delivery: 'डिलिव्हरीसाठी तयार',
      recent_customers: 'अलीकडील ग्राहक',
      view_all: 'सर्व पहा',
      name: 'नाव',
      phone: 'फोन',
      date: 'दिनांक',
      actions: 'कृती',
      view: 'पहा',
      measure: 'माप घ्या',
      no_customers_yet: 'अद्याप कोणतेही ग्राहक नाहीत. तुमचा पहिला ग्राहक जोडा!',
      logout: 'बाहेर पडा',
      login: 'लॉगिन',
      register: 'नोंदणी',
      dashboard: 'डॅशबोर्ड',
      customers: 'ग्राहक',
      select_language: 'भाषा',
    },
  },
};

// Retrieve language from localStorage or default to English
const savedLang = localStorage.getItem('i18nextLng') || 'en';

i18n
  .use(initReactI18next)
  .init({
    resources,
    lng: savedLang,
    fallbackLng: 'en',
    interpolation: {
      escapeValue: false, // React already protects from XSS
    },
  });

export default i18n;
