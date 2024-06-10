require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const multer = require('multer');
const mysql = require('mysql');
const bcrypt = require('bcrypt');
const app = express();

app.use(bodyParser.json());
app.use(cors());
app.use('/uploads', express.static('uploads'));

// Create a MySQL connection
const connection = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT
});

// Connect to the database
connection.connect((err) => {
  if (err) {
    console.error('Error connecting to MySQL database:', err);
    return;
  }
  console.log('Connected to MySQL database');
});

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname);
  }
});

const upload = multer({ storage: storage });

// Route to handle user registration
app.post('/api/register', async (req, res) => {
  const { name, email, password } = req.body;

  // Check if user already exists with the provided email
  connection.query('SELECT * FROM users WHERE email = ?', [email], async (error, results) => {
    if (error) {
      console.error('Error querying user:', error);
      res.status(500).send('Internal Server Error');
      return;
    }

    if (results.length > 0) {
      return res.status(400).json({ error: 'User already exists with this email' });
    }

    // Hash the password before storing
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert the new user into the database
    connection.query('INSERT INTO users (name, email, password) VALUES (?, ?, ?)', [name, email, hashedPassword], (error, results) => {
      if (error) {
        console.error('Error inserting user:', error);
        res.status(500).send('Internal Server Error');
        return;
      }

      // Return success response with user details
      res.status(201).json({ message: 'User registered successfully', user: { id: results.insertId, name, email } });
    });
  });
});

// Route to handle user login
app.post('/api/login', (req, res) => {
  const { email, password } = req.body;

  // Query the database to find the user with the provided email
  connection.query('SELECT * FROM users WHERE email = ?', [email], async (error, results) => {
    if (error) {
      console.error('Error querying user:', error);
      res.status(500).send('Internal Server Error');
      return;
    }

    if (results.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Check if the provided password matches the hashed password
    const user = results[0];
    const match = await bcrypt.compare(password, user.password);

    if (!match) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Return success response with user details
    res.status(200).json({ message: 'Login successful', user: { id: user.id, name: user.name, email: user.email } });
  });
});

// Route to handle art description and image upload
app.post('/api/upload', upload.single('image'), (req, res) => {
  const { description } = req.body;
  const imagePath = req.file.path;

  // Construct the full URL of the uploaded image
  const imageUrl = `http://localhost:${process.env.PORT}/${imagePath}`;

  // Insert the art details into the database
  const insertQuery = 'INSERT INTO arts (description, image_path) VALUES (?, ?)';
  connection.query(insertQuery, [description, imagePath], (error, results) => {
    if (error) {
      console.error('Error inserting art:', error);
      res.status(500).send('Internal Server Error');
      return;
    }

    // Return success response with art details
    res.status(201).json({
      message: 'Art uploaded successfully',
      art: { id: results.insertId, description, imageUrl }, // Return the complete image URL
    });
  });
});

// Route to delete an art entry from the database
app.delete('/api/delete/:id', (req, res) => {
  const artId = req.params.id;

  // Delete the art entry from the database
  const deleteQuery = 'DELETE FROM arts WHERE id = ?';
  connection.query(deleteQuery, [artId], (error, results) => {
    if (error) {
      console.error('Error deleting art:', error);
      res.status(500).send('Internal Server Error');
      return;
    }

    if (results.affectedRows === 0) {
      // If no rows were affected, it means the art entry with the provided ID does not exist
      res.status(404).json({ error: 'Art not found' });
      return;
    }

    // Return success response
    res.status(200).json({ message: 'Art deleted successfully' });
  });
});

// Route to fetch all uploaded arts
app.get('/api/arts', (req, res) => {
  // Query the database to fetch all arts
  connection.query('SELECT * FROM arts', (error, results) => {
    if (error) {
      console.error('Error querying arts:', error);
      res.status(500).send('Internal Server Error');
      return;
    }

    // Send the retrieved arts as a JSON response
    res.json(results);
  });
});

// Start the server
const PORT = process.env.PORT || 8000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
