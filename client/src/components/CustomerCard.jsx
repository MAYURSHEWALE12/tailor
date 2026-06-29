import { Link } from 'react-router-dom';
import { FiEye, FiEdit2, FiTrash2, FiPhone } from 'react-icons/fi';

export default function CustomerCard({ customer, onDelete }) {
  return (
    <div className="card hover:shadow-lg transition-shadow">
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold text-sm">
            {customer.name.charAt(0).toUpperCase()}
          </div>
          <div>
            <h3 className="font-semibold text-text-primary">{customer.name}</h3>
            <p className="text-xs text-text-secondary flex items-center gap-1">
              <FiPhone size={12} />
              {customer.phone}
            </p>
          </div>
        </div>
      </div>
      {customer.notes && (
        <p className="text-xs text-text-secondary mb-3 line-clamp-1">{customer.notes}</p>
      )}
      <p className="text-xs text-text-secondary mb-3">
        Added: {new Date(customer.createdAt).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })}
      </p>
      <div className="flex items-center gap-2 pt-2 border-t border-gray-100">
        <Link to={`/customers/${customer._id}`} className="flex items-center gap-1 text-xs text-primary hover:text-primary-light transition-colors">
          <FiEye size={14} /> View
        </Link>
        <Link to={`/customers/${customer._id}/measurements/add`} className="flex items-center gap-1 text-xs text-accent hover:text-accent-light transition-colors ml-auto">
          <FiEdit2 size={14} /> Add Measurement
        </Link>
        <button onClick={() => onDelete(customer._id)} className="text-xs text-red-500 hover:text-red-600 transition-colors ml-2">
          <FiTrash2 size={14} />
        </button>
      </div>
    </div>
  );
}
