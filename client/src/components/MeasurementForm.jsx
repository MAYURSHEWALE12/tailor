import { useState } from 'react';

const shirtFields = [
  { key: 'length', label: 'लांबी (Length)', marathi: 'लांबी', min: 10, max: 60 },
  { key: 'chest', label: 'छाती (Chest)', marathi: 'छाती', min: 20, max: 60 },
  { key: 'waist', label: 'कंबर (Waist)', marathi: 'कंबर', min: 20, max: 50 },
  { key: 'stomach', label: 'पोट (Stomach)', marathi: 'पोट', min: 20, max: 60 },
  { key: 'shoulder', label: 'खांदा (Shoulder)', marathi: 'खांदा', min: 10, max: 25 },
  { key: 'sleeve', label: 'बाही (Sleeve)', marathi: 'बाही', min: 5, max: 35 },
  { key: 'collar', label: 'गळा (Collar)', marathi: 'गळा', min: 10, max: 22 },
];

const pantFields = [
  { key: 'pantLength', label: 'पायाची लांबी (Length)', min: 20, max: 50 },
  { key: 'seat', label: 'सीट (Seat)', min: 20, max: 50 },
  { key: 'thigh', label: 'मांडी (Thigh)', min: 10, max: 35 },
  { key: 'knee', label: 'गुडघा (Knee)', min: 10, max: 30 },
  { key: 'bottom', label: 'बुट्टम (Bottom)', min: 8, max: 25 },
  { key: 'rise', label: 'राईज (Rise)', min: 5, max: 20 },
];

const kurtaFields = [
  { key: 'kurtalength', label: 'लांबी (Length)', min: 20, max: 60 },
  { key: 'kurtaghera', label: 'घेरा (Ghera)', min: 20, max: 60 },
  { key: 'chest', label: 'छाती (Chest)', min: 20, max: 60 },
  { key: 'shoulder', label: 'खांदा (Shoulder)', min: 10, max: 25 },
  { key: 'sleeve', label: 'बाही (Sleeve)', min: 5, max: 35 },
  { key: 'collar', label: 'गळा (Collar)', min: 10, max: 22 },
  { key: 'waist', label: 'कंबर (Waist)', min: 20, max: 50 },
];

const blouseFields = [
  { key: 'blouseLength', label: 'लांबी (Length)', min: 5, max: 30 },
  { key: 'bust', label: 'बस्ट (Bust)', min: 20, max: 50 },
  { key: 'blouseWaist', label: 'कंबर (Waist)', min: 20, max: 50 },
  { key: 'hip', label: 'हिप (Hip)', min: 20, max: 55 },
  { key: 'backNeck', label: 'मागची गळा (Back Neck)', min: 2, max: 15 },
  { key: 'frontNeck', label: 'पुढची गळा (Front Neck)', min: 2, max: 15 },
  { key: 'blouseSleeve', label: 'बाही (Sleeve)', min: 2, max: 25 },
  { key: 'shoulder', label: 'खांदा (Shoulder)', min: 5, max: 20 },
];

const fieldMap = { shirt: shirtFields, pant: pantFields, kurta: kurtaFields, blouse: blouseFields, sadra: shirtFields };

export default function MeasurementForm({ garmentType, measurements, onChange, unit, onUnitChange }) {
  const fields = fieldMap[garmentType] || [];

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h3 className="font-semibold text-text-primary">Measurements</h3>
        <div className="flex items-center gap-2 bg-gray-100 rounded-lg p-1">
          <button
            type="button"
            onClick={() => onUnitChange('inches')}
            className={`px-3 py-1 rounded-md text-xs font-medium transition-colors ${unit === 'inches' ? 'bg-white shadow-sm text-primary' : 'text-text-secondary'}`}
          >
            Inches
          </button>
          <button
            type="button"
            onClick={() => onUnitChange('cm')}
            className={`px-3 py-1 rounded-md text-xs font-medium transition-colors ${unit === 'cm' ? 'bg-white shadow-sm text-primary' : 'text-text-secondary'}`}
          >
            CM
          </button>
        </div>
      </div>
      {fields.map((field) => (
        <div key={field.key}>
          <label className="block text-sm font-medium text-text-secondary mb-1">{field.label}</label>
          <div className="flex items-center gap-2">
            <input
              type="range"
              min={field.min}
              max={field.max}
              value={measurements[field.key] || ''}
              onChange={(e) => onChange(field.key, Number(e.target.value))}
              className="flex-1 accent-primary"
            />
            <input
              type="number"
              min={field.min}
              max={field.max}
              value={measurements[field.key] || ''}
              onChange={(e) => onChange(field.key, Number(e.target.value))}
              className="w-16 px-2 py-1 border border-gray-300 rounded-input text-center text-sm font-medium focus:outline-none focus:ring-2 focus:ring-primary"
            />
            <span className="text-xs text-text-secondary w-8">{unit === 'inches' ? '"' : 'cm'}</span>
          </div>
        </div>
      ))}
    </div>
  );
}
