require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const multer = require('multer');
const mysql = require('mysql');
const bcrypt = require('bcryptjs');
const path = require('path');
//const admin = require('firebase-admin');
//const serviceAccount = require('./gallery-85a68-firebase-adminsdk-4qzj1-135b890735.json');

// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount),
//   databaseURL: 'https://gallery-85a68-default-rtdb.firebaseio.com/'
// });

const app = express();

const verifyToken = async (req, res, next) => {
  const idToken = req.headers.authorization?.split('Bearer ')[1];
  if (!idToken) {
    return res.status(401).send('Unauthorized');
  }
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.user = decodedToken;
    next();
  } catch (error) {
    return res.status(401).send('Unauthorized');
  }
};

//app.use('/api', verifyToken);


require('dotenv').config();



app.use(bodyParser.json());
app.use(cors());
app.use('/uploads', express.static(path.join(__dirname, 'uploads'))); // Serve static files

// Create MySQL connection
const connection = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
  port: process.env.DB_PORT
});

// Connect to MySQL database
connection.connect((err) => {
  if (err) {
    console.error('Error connecting to MySQL database:', err);
    return;
  }
  console.log('Connected to MySQL database');
});

// Multer setup for profile picture uploads
const profilePictureStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/profile_pictures');
  },
  filename: function (req, file, cb) {
    cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname));
  }
});

const profilePictureUpload = multer({ storage: profilePictureStorage });


// Profile picture upload endpoint
app.post('/api/upload_profile_picture', profilePictureUpload.single('profile_picture'), (req, res) => {
  const { userId } = req.body;

  // Check if a file was uploaded
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }

  // Construct the profile picture URL
  const profilePictureUrl = `/uploads/profile_pictures/${req.file.filename}`;

  // Update the user's profile picture in the database
  connection.query('UPDATE users SET profile_picture = ? WHERE id = ?', [profilePictureUrl, userId], (error, results) => {
    if (error) {
      console.error('Error updating profile picture:', error);
      return res.status(500).send('Internal Server Error');
    }

    // Send a success response with the profile picture URL
    res.status(200).json({ message: 'Profile picture updated successfully', profilePictureUrl });
  });
});


// Endpoint to fetch profile picture for a user
app.get('/api/profile_picture/:userId', (req, res) => {
  const userId = req.params.userId;

  connection.query('SELECT profile_picture FROM users WHERE id = ?', [userId], (error, results) => {
    if (error) {
      console.error('Error fetching profile picture:', error);
      return res.status(500).send('Internal Server Error');
    }

    if (results.length === 0 || !results[0].profile_picture) {
      return res.status(404).json({ error: 'Profile picture not found' });
    }

    const profilePictureUrl = results[0].profile_picture;
    res.status(200).json({ profile_picture: profilePictureUrl });
  });
});

// Static file serving for uploaded files
app.use('/uploads', express.static('uploads'));

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
const validRoles = ['seller', 'buyer'];

app.post('/api/register1', upload.single('profile_picture'), async (req, res) => {
  const { name, email, password, role = 'buyer' } = req.body; // Default role set to 'buyer'
  const imagePath = req.file ? req.file.path : null;
  const imageUrl = imagePath ? `http://localhost:${process.env.PORT}/${imagePath}` : null;

  if (!validRoles.includes(role)) {
    return res.status(400).json({ error: 'Invalid role' });
  }

  // Check if user already exists with the provided email
  connection.query('SELECT * FROM users WHERE email = ?', [email], async (error, results) => {
    if (error) {
      console.error('Error querying user:', error);
      return res.status(500).send('Internal Server Error');
    }

    if (results.length > 0) {
      return res.status(400).json({ error: 'User already exists with this email' });
    }

    try {
      // Hash the password before storing
      const hashedPassword = await bcrypt.hash(password, 10);

      // Insert the new user into the database
      connection.query(
        'INSERT INTO users (name, email, password, role, profile_picture) VALUES (?, ?, ?, ?, ?)',
        [name, email, hashedPassword, role, imageUrl],
        (error, results) => {
          if (error) {
            console.error('Error inserting user:', error);
            return res.status(500).send('Internal Server Error');
          }

          // Return success response with user details
          res.status(201).json({ message: 'User registered successfully', user: { id: results.insertId, name, email, role, profile_picture: imageUrl } });
        }
      );
    } catch (hashError) {
      console.error('Error hashing password:', hashError);
      return res.status(500).send('Internal Server Error');
    }
  });
});
app.post('/api/register1', async (req, res) => {
  // Use req.user to get the authenticated user's information
  const { name, role } = req.body;
  const email = req.user.email;

  // Handle registration logic

  res.status(201).send({ message: 'User registered successfully' });
});

app.post('/api/upload_profile_picture', async (req, res) => {
  // Use req.user to get the authenticated user's information
  const userId = req.user.uid;

  // Handle profile picture upload logic

  res.status(200).send({ profilePictureUrl: 'URL_TO_PROFILE_PICTURE' });
});


// Route to handle user login
app.post('/api/login1', (req, res) => {
  const { email, password } = req.body;

  connection.query('SELECT * FROM users WHERE email = ?', [email], (error, results) => {
    if (error) {
      console.error('Error fetching user:', error);
      return res.status(500).send('Internal Server Error');
    }

    if (results.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = results[0];

    // Verify password (assuming you are hashing passwords)
    bcrypt.compare(password, user.password, (err, isMatch) => {
      if (err) {
        console.error('Error comparing passwords:', err);
        return res.status(500).send('Internal Server Error');
      }

      if (!isMatch) {
        return res.status(401).json({ error: 'Incorrect password' });
      }

      // Return user details along with role
      res.status(200).json({
        user: {
          id: user.id,
          profile_picture: user.profile_picture,
          role: user.role
        }
      });
    });
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
