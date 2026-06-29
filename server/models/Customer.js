const mongoose = require('mongoose');

const customerSchema = new mongoose.Schema({
  tailor: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  name: { type: String, required: [true, 'Customer name is required'], trim: true },
  phone: { type: String, required: [true, 'Phone is required'], trim: true },
  email: { type: String, trim: true, lowercase: true },
  address: { type: String, trim: true },
  notes: { type: String, trim: true },
}, { timestamps: true });

customerSchema.index({ tailor: 1, name: 'text', phone: 'text' });

module.exports = mongoose.model('Customer', customerSchema);
