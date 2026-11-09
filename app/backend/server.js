// const express = require('express');
// const mysql = require('mysql2');
// const cors = require('cors');
// const path = require('path'); // Added built-in path module
// require('dotenv').config();

// const app = express();
// const PORT = process.env.PORT || 5000;

// app.use(cors());
// app.use(express.json());

// // 🌟 NEW: Serve static frontend files directly from the backend
// // This points to the sibling 'frontend' directory
// // app.use(express.static(path.join(__dirname, '../frontend')));

// // Initialize Asynchronous Database Connection Pool
// const pool = mysql.createPool({
//   host: process.env.DB_HOST,
//   user: process.env.DB_USER,
//   password: process.env.DB_PASSWORD,
//   database: process.env.DB_NAME,
//   waitForConnections: true,
//   connectionLimit: 10,
//   queueLimit: 0
// }).promise();

// // Verification endpoint
// app.get('/health', async (req, res) => {
//   try {
//     await pool.query('SELECT 1');
//     res.status(200).json({ status: 'OK', database: 'CONNECTED' });
//   } catch (err) {
//     res.status(500).json({ status: 'ERROR', message: err.message });
//   }
// });

// // GET: Fetch all posts
// app.get('/api/posts', async (req, res) => {
//   try {
//     const [rows] = await pool.query('SELECT * FROM entries ORDER BY created_at DESC');
//     res.json(rows);
//   } catch (err) {
//     res.status(500).json({ error: 'Database query failed: ' + err.message });
//   }
// });

// // POST: Accept new guestbook submission
// app.post('/api/posts', async (req, res) => {
//   const { username, message } = req.body;
//   if (!username || !username.trim() || !message || !message.trim()) {
//     return res.status(400).json({ error: 'Username and message fields are required.' });
//   }
//   try {
//     const [result] = await pool.query(
//       'INSERT INTO entries (username, message) VALUES (?, ?)',
//       [username.trim(), message.trim()]
//     );
//     res.status(211).json({
//       id: result.insertId,
//       username,
//       message,
//       created_at: new Date()
//     });
//   } catch (err) {
//     res.status(500).json({ error: 'Failed to save entry: ' + err.message });
//   }
// });

// // 🌟 NEW: Fallback route to serve index.html for any other casual root requests
// // app.get('*', (req, res) => {
// //   res.sendFile(path.join(__dirname, '../frontend/index.html'));
// // });

// // Start Server
// app.listen(PORT, () => {
//   console.log(`🚀 Unified App Engine running on http://localhost:${PORT}`);
// });



const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// 🌟 Serve static frontend files directly from the backend
// Note: This only works if the frontend folder is copied into the backend's Docker image
app.use(express.static(path.join(__dirname, '../frontend')));

// Initialize Asynchronous Database Connection Pool
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
}).promise();

// Verification endpoint
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ status: 'OK', database: 'CONNECTED' });
  } catch (err) {
    console.error('Health Check DB Error:', err);
    res.status(500).json({ status: 'ERROR', message: 'Database connection failed' });
  }
});

// GET: Fetch all posts
app.get('/api/posts', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM entries ORDER BY created_at DESC');
    res.json(rows);
  } catch (err) {
    console.error('Fetch Posts Error:', err);
    res.status(500).json({ error: 'Failed to fetch guestbook entries.' });
  }
});

// POST: Accept new guestbook submission
app.post('/api/posts', async (req, res) => {
  const { username, message } = req.body;
  
  if (!username || !username.trim() || !message || !message.trim()) {
    return res.status(400).json({ error: 'Username and message fields are required.' });
  }
  
  try {
    const [result] = await pool.query(
      'INSERT INTO entries (username, message) VALUES (?, ?)',
      [username.trim(), message.trim()]
    );
    // Fixed: 211 changed to 201 (Standard HTTP Status for Created)
    res.status(201).json({
      id: result.insertId,
      username,
      message,
      created_at: new Date()
    });
  } catch (err) {
    console.error('Save Post Error:', err);
    res.status(500).json({ error: 'Failed to save entry.' });
  }
});

// 🌟 Fallback route to serve index.html for any other frontend routes (SPA behavior)
app.get('*', (req, res, next) => {
  // If the request is for an API route that doesn't exist, send a JSON 404 instead of index.html
  if (req.path.startsWith('/api/')) {
    return res.status(404).json({ error: 'API route not found' });
  }
  // Otherwise, serve the frontend index.html
  res.sendFile(path.join(__dirname, '../frontend/index.html'), (err) => {
    if (err) {
      res.status(500).send("Frontend build not found. Ensure the frontend folder is copied into the Docker container.");
    }
  });
});

// Start Server
app.listen(PORT, () => {
  console.log(`🚀 Unified App Engine running on http://localhost:${PORT}`);
});