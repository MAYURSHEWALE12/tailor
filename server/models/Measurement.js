const mongoose = require('mongoose');

const measurementSchema = new mongoose.Schema({
  customer: { type: mongoose.Schema.Types.ObjectId, ref: 'Customer', required: true },
  tailor: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  garmentType: {
    type: String,
    enum: ['shirt', 'pant', 'kurta', 'blouse', 'sadra'],
    required: [true, 'Garment type is required'],
  },
  measurements: {
    length: Number,
    chest: Number,
    waist: Number,
    stomach: Number,
    shoulder: Number,
    sleeve: Number,
    collar: Number,
    pantLength: Number,
    seat: Number,
    thigh: Number,
    knee: Number,
    bottom: Number,
    rise: Number,
    kurtalength: Number,
    kurtaghera: Number,
    blouseLength: Number,
    bust: Number,
    blouseWaist: Number,
    hip: Number,
    backNeck: Number,
    frontNeck: Number,
    blouseSleeve: Number,
  },
  unit: { type: String, enum: ['inches', 'cm'], default: 'inches' },
  specialInstructions: { type: String, trim: true },
  orderStatus: {
    type: String,
    enum: ['pending', 'cutting', 'stitching', 'ready', 'delivered'],
    default: 'pending',
  },
  deliveryDate: Date,
  price: { type: Number, default: 0 },
  advancePaid: { type: Number, default: 0 },
  designImage: { type: String },
  payments: [{
    amount: { type: Number, required: true },
    date: { type: Date, default: Date.now },
    method: { type: String, enum: ['cash', 'online', 'upi', 'other'], default: 'cash' },
    notes: { type: String, trim: true },
  }],
}, { timestamps: true });

measurementSchema.index({ customer: 1, createdAt: -1 });

module.exports = mongoose.model('Measurement', measurementSchema);
