import API from './axios';

export const createMeasurement = (data) => API.post('/measurements', data);
export const getCustomerMeasurements = (customerId) => API.get(`/measurements/customer/${customerId}`);
export const getMeasurement = (id) => API.get(`/measurements/${id}`);
export const updateMeasurement = (id, data) => API.put(`/measurements/${id}`, data);
export const deleteMeasurement = (id) => API.delete(`/measurements/${id}`);
export const getDashboardStats = () => API.get('/measurements/stats/dashboard');

export const addPayment = (id, data) => API.post(`/measurements/${id}/payments`, data);

export const uploadImage = (file) => {
  const formData = new FormData();
  formData.append('image', file);
  return API.post('/upload', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });
};
