const express = require('express');
const router = express.Router();
const {
  createMeasurement,
  getCustomerMeasurements,
  getMeasurement,
  updateMeasurement,
  deleteMeasurement,
  addPayment,
  getDashboardStats,
} = require('../controllers/measurementController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect);

router.get('/stats/dashboard', getDashboardStats);
router.post('/', createMeasurement);
router.get('/customer/:customerId', getCustomerMeasurements);
router.post('/:id/payments', addPayment);
router.route('/:id').get(getMeasurement).put(updateMeasurement).delete(deleteMeasurement);

module.exports = router;
