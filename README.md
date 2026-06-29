# ShivaayTailor — Your Tailor's Digital Notebook

**शिवणकाम सोपे, मापे अचूक**

A full-stack MERN application for Indian tailors (darzi) to manage customer measurements, orders, and AI-powered clothing designs.

## Features

- **Dashboard** — View stats: total customers, monthly measurements, pending orders, ready for delivery
- **Customer Management** — Add, search, view, edit, and delete customer profiles
- **Measurement Recording** — Digital forms for shirt, pant, kurta, blouse, sadra with Marathi labels
- **Order Tracking** — Status workflow: pending → cutting → stitching → ready → delivered
- **WhatsApp Sharing** — Share measurement cards directly via WhatsApp
- **PDF Export** — Download professional measurement sheets using jsPDF
- **AI Design Generator** — Generate AI image prompts based on measurements
- **JWT Authentication** — Secure login/register for tailors

## Tech Stack

| Layer    | Technology                    |
|----------|-------------------------------|
| Frontend | React 18, Vite, Tailwind CSS  |
| Backend  | Node.js, Express.js           |
| Database | MongoDB, Mongoose             |
| Auth     | JWT (JSON Web Tokens)         |
| HTTP     | Axios                         |
| Extras   | React Router v6, jsPDF, React Hot Toast, React Icons |

## Setup Instructions

### Prerequisites

- Node.js v18 or higher
- MongoDB (local or Atlas)
- npm or yarn

### 1. Clone & Install Dependencies

```bash
# From the project root
cd shivaay-tailor

# Install server dependencies
cd server
npm install

# Install client dependencies
cd ../client
npm install
```

### 2. Configure Environment

Edit `server/.env`:

```env
PORT=5000
MONGO_URI=mongodb://localhost:27017/shivaay-tailor
JWT_SECRET=shivaay_tailor_secret_key_2024
JWT_EXPIRE=30d
NODE_ENV=development
```

### 3. Run the Application

Start MongoDB (if running locally), then:

```bash
# Terminal 1 — Start backend
cd server
npm run dev

# Terminal 2 — Start frontend
cd client
npm run dev
```

The app will be available at:
- Frontend: http://localhost:3000
- Backend API: http://localhost:5000/api

### 4. Build for Production

```bash
cd client
npm run build
```

## API Endpoints

### Auth (`/api/auth`)
| Method | Endpoint      | Description           |
|--------|---------------|-----------------------|
| POST   | `/register`   | Register new tailor   |
| POST   | `/login`      | Login & get JWT       |
| GET    | `/me`         | Get logged-in user    |

### Customers (`/api/customers`) — Protected
| Method | Endpoint      | Description            |
|--------|---------------|------------------------|
| GET    | `/`           | Get all customers      |
| GET    | `/?q=search`  | Search customers       |
| POST   | `/`           | Add new customer       |
| GET    | `/:id`        | Get single customer    |
| PUT    | `/:id`        | Update customer        |
| DELETE | `/:id`        | Delete customer        |

### Measurements (`/api/measurements`) — Protected
| Method | Endpoint                 | Description                 |
|--------|--------------------------|-----------------------------|
| GET    | `/stats/dashboard`       | Dashboard statistics        |
| POST   | `/`                      | Add measurement             |
| GET    | `/customer/:customerId`  | Customer's measurements     |
| GET    | `/:id`                   | Single measurement          |
| PUT    | `/:id`                   | Update measurement          |
| DELETE | `/:id`                   | Delete measurement          |

## Project Structure

```
shivaay-tailor/
├── client/                 # React Frontend
│   ├── src/
│   │   ├── api/            # Axios API calls
│   │   ├── components/     # Reusable components
│   │   ├── context/        # Auth context
│   │   ├── pages/          # All pages
│   │   ├── App.jsx         # Routes
│   │   └── main.jsx        # Entry point
│   └── package.json
├── server/                 # Node + Express Backend
│   ├── config/             # DB config
│   ├── controllers/        # Route handlers
│   ├── middleware/         # JWT auth middleware
│   ├── models/             # Mongoose schemas
│   ├── routes/             # Express routes
│   ├── .env                # Environment variables
│   └── server.js           # Entry point
└── README.md
```

## Design System

- **Primary**: `#1A3A5C` (Navy Blue)
- **Accent**: `#D4A017` (Gold)
- **Font**: Poppins (Google Fonts)
- **Responsive**: Mobile-first with collapsible sidebar
