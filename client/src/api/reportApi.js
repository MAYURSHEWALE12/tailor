import API from './axios';

export const getRevenueReport = (params) => API.get('/reports/revenue', { params });
export const getOrderStatusReport = () => API.get('/reports/order-status');
export const getGarmentWiseReport = (params) => API.get('/reports/garment-wise', { params });
export const getPendingDues = () => API.get('/reports/pending-dues');
export const getDeliverySchedule = (days) => API.get('/reports/delivery-schedule', { params: { days } });
export const getTopCustomers = () => API.get('/reports/top-customers');
