const Measurement = require('../models/Measurement');
const Customer = require('../models/Customer');

const createMeasurement = async (req, res) => {
  try {
    const { customerId, garmentType, measurements, unit, specialInstructions, orderStatus, deliveryDate, price, advancePaid, designImage } = req.body;

    if (!customerId || !garmentType) {
      return res.status(400).json({ message: 'Customer and garment type are required' });
    }

    const customer = await Customer.findOne({ _id: customerId, tailor: req.user._id });
    if (!customer) {
      return res.status(404).json({ message: 'Customer not found' });
    }

    const measurement = await Measurement.create({
      customer: customerId,
      tailor: req.user._id,
      garmentType,
      measurements,
      unit: unit || 'inches',
      specialInstructions,
      orderStatus: orderStatus || 'pending',
      deliveryDate,
      price: price || 0,
      advancePaid: advancePaid || 0,
      designImage,
    });

    const populated = await Measurement.findById(measurement._id).populate('customer', 'name phone');

    res.status(201).json(populated);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getCustomerMeasurements = async (req, res) => {
  try {
    const measurements = await Measurement.find({ customer: req.params.customerId, tailor: req.user._id })
      .populate('customer', 'name phone')
      .sort({ createdAt: -1 });

    res.json(measurements);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getMeasurement = async (req, res) => {
  try {
    const measurement = await Measurement.findOne({ _id: req.params.id, tailor: req.user._id })
      .populate('customer', 'name phone');

    if (!measurement) {
      return res.status(404).json({ message: 'Measurement not found' });
    }

    res.json(measurement);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const updateMeasurement = async (req, res) => {
  try {
    const measurement = await Measurement.findOneAndUpdate(
      { _id: req.params.id, tailor: req.user._id },
      req.body,
      { new: true, runValidators: true }
    ).populate('customer', 'name phone');

    if (!measurement) {
      return res.status(404).json({ message: 'Measurement not found' });
    }

    res.json(measurement);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const addPayment = async (req, res) => {
  try {
    const { amount, method, notes, date } = req.body;
    if (!amount || amount <= 0) {
      return res.status(400).json({ message: 'Valid amount is required' });
    }
    const measurement = await Measurement.findOne({ _id: req.params.id, tailor: req.user._id });
    if (!measurement) {
      return res.status(404).json({ message: 'Measurement not found' });
    }
    measurement.payments.push({
      amount,
      method: method || 'cash',
      notes: notes || '',
      date: date ? new Date(date) : new Date(),
    });
    await measurement.save();
    const populated = await Measurement.findById(measurement._id).populate('customer', 'name phone');
    res.json(populated);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const deleteMeasurement = async (req, res) => {
  try {
    const measurement = await Measurement.findOneAndDelete({ _id: req.params.id, tailor: req.user._id });

    if (!measurement) {
      return res.status(404).json({ message: 'Measurement not found' });
    }

    res.json({ message: 'Measurement deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getDashboardStats = async (req, res) => {
  try {
    const tailorId = req.user._id;

    const totalCustomers = await Customer.countDocuments({ tailor: tailorId });

    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const measurementsThisMonth = await Measurement.countDocuments({
      tailor: tailorId,
      createdAt: { $gte: startOfMonth },
    });

    const pendingOrders = await Measurement.countDocuments({
      tailor: tailorId,
      orderStatus: { $in: ['pending', 'cutting', 'stitching'] },
    });

    const readyForDelivery = await Measurement.countDocuments({
      tailor: tailorId,
      orderStatus: 'ready',
    });

    const recentCustomers = await Customer.find({ tailor: tailorId })
      .sort({ createdAt: -1 })
      .limit(5);

    res.json({
      totalCustomers,
      measurementsThisMonth,
      pendingOrders,
      readyForDelivery,
      recentCustomers,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  createMeasurement,
  getCustomerMeasurements,
  getMeasurement,
  updateMeasurement,
  deleteMeasurement,
  addPayment,
  getDashboardStats,
};
