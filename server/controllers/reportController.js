const Measurement = require('../models/Measurement');
const Customer = require('../models/Customer');

const getRevenueReport = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    const match = { tailor: req.user._id };
    if (startDate || endDate) {
      match.createdAt = {};
      if (startDate) match.createdAt.$gte = new Date(startDate);
      if (endDate) match.createdAt.$lte = new Date(endDate);
    }
    const revenue = await Measurement.aggregate([
      { $match: match },
      {
        $group: {
          _id: null,
          totalRevenue: { $sum: '$price' },
          totalAdvance: { $sum: '$advancePaid' },
          totalBalance: { $sum: { $subtract: ['$price', '$advancePaid'] } },
          orderCount: { $sum: 1 },
        },
      },
    ]);
    const daily = await Measurement.aggregate([
      { $match: match },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
          revenue: { $sum: '$price' },
          advance: { $sum: '$advancePaid' },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);
    res.json({
      summary: revenue[0] || { totalRevenue: 0, totalAdvance: 0, totalBalance: 0, orderCount: 0 },
      daily,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getOrderStatusReport = async (req, res) => {
  try {
    const data = await Measurement.aggregate([
      { $match: { tailor: req.user._id } },
      { $group: { _id: '$orderStatus', count: { $sum: 1 } } },
    ]);
    const statuses = ['pending', 'cutting', 'stitching', 'ready', 'delivered'];
    const result = statuses.map((s) => ({
      status: s,
      count: data.find((d) => d._id === s)?.count || 0,
    }));
    res.json(result);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getGarmentWiseReport = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    const match = { tailor: req.user._id };
    if (startDate || endDate) {
      match.createdAt = {};
      if (startDate) match.createdAt.$gte = new Date(startDate);
      if (endDate) match.createdAt.$lte = new Date(endDate);
    }
    const data = await Measurement.aggregate([
      { $match: match },
      {
        $group: {
          _id: '$garmentType',
          count: { $sum: 1 },
          revenue: { $sum: '$price' },
        },
      },
    ]);
    const types = ['shirt', 'pant', 'kurta', 'blouse', 'sadra'];
    const result = types.map((t) => ({
      garmentType: t,
      count: data.find((d) => d._id === t)?.count || 0,
      revenue: data.find((d) => d._id === t)?.revenue || 0,
    }));
    res.json(result);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getPendingDues = async (req, res) => {
  try {
    const dues = await Measurement.aggregate([
      { $match: { tailor: req.user._id } },
      { $match: { $expr: { $gt: ['$price', '$advancePaid'] } } },
      {
        $lookup: {
          from: 'customers',
          localField: 'customer',
          foreignField: '_id',
          as: 'customer',
        },
      },
      { $unwind: '$customer' },
      {
        $project: {
          customerName: '$customer.name',
          customerPhone: '$customer.phone',
          garmentType: 1,
          price: 1,
          advancePaid: 1,
          balance: { $subtract: ['$price', '$advancePaid'] },
          deliveryDate: 1,
        },
      },
      { $sort: { balance: -1 } },
    ]);
    const totalDues = dues.reduce((sum, d) => sum + d.balance, 0);
    res.json({ totalDues, orders: dues });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getDeliverySchedule = async (req, res) => {
  try {
    const { days } = req.query;
    const range = parseInt(days) || 7;
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const future = new Date(today);
    future.setDate(future.getDate() + range);
    const upcoming = await Measurement.find({
      tailor: req.user._id,
      deliveryDate: { $gte: today, $lte: future },
      orderStatus: { $ne: 'delivered' },
    })
      .populate('customer', 'name phone')
      .sort({ deliveryDate: 1 });
    const overdue = await Measurement.find({
      tailor: req.user._id,
      deliveryDate: { $lt: today },
      orderStatus: { $ne: 'delivered' },
    })
      .populate('customer', 'name phone')
      .sort({ deliveryDate: 1 });
    res.json({ upcoming, overdue });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getTopCustomers = async (req, res) => {
  try {
    const data = await Measurement.aggregate([
      { $match: { tailor: req.user._id } },
      {
        $group: {
          _id: '$customer',
          orderCount: { $sum: 1 },
          totalSpent: { $sum: '$price' },
        },
      },
      { $sort: { orderCount: -1 } },
      { $limit: 10 },
      {
        $lookup: {
          from: 'customers',
          localField: '_id',
          foreignField: '_id',
          as: 'customer',
        },
      },
      { $unwind: '$customer' },
      {
        $project: {
          customerId: '$_id',
          customerName: '$customer.name',
          customerPhone: '$customer.phone',
          orderCount: 1,
          totalSpent: 1,
        },
      },
    ]);
    res.json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getRevenueReport,
  getOrderStatusReport,
  getGarmentWiseReport,
  getPendingDues,
  getDeliverySchedule,
  getTopCustomers,
};
