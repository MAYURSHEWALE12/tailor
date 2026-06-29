const express = require('express');
const router = express.Router();
const {
  getRevenueReport,
  getOrderStatusReport,
  getGarmentWiseReport,
  getPendingDues,
  getDeliverySchedule,
  getTopCustomers,
} = require('../controllers/reportController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect);

router.get('/revenue', getRevenueReport);
router.get('/order-status', getOrderStatusReport);
router.get('/garment-wise', getGarmentWiseReport);
router.get('/pending-dues', getPendingDues);
router.get('/delivery-schedule', getDeliverySchedule);
router.get('/top-customers', getTopCustomers);

module.exports = router;
