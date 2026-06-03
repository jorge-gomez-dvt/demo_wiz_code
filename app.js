const express = require('express');
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const exec = require('child_process').exec;
const fs = require('fs');
const path = require('path');
const serialize = require('serialize-javascript');
const eval_ = require('eval');

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Hardcoded secrets
const JWT_SECRET = 'hardcoded_jwt_secret_123';
const DB_URI = 'mongodb://admin:password123@prod-mongo.internal:27017/appdb';
const AWS_ACCESS_KEY = 'AKIAIOSFODNN7EXAMPLE';
const AWS_SECRET_KEY = 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY';
const STRIPE_KEY = 'sk_live_DEMO_FAKE_KEY_FOR_WIZ_SCAN';
const GITHUB_TOKEN = 'ghp_1234567890abcdefghijklmnopqrstuvwxyz12';

mongoose.connect(DB_URI, { useNewUrlParser: true });

// NoSQL Injection vulnerability
app.post('/login', async (req, res) => {
    const { username, password } = req.body;
    // Direct use of user input in MongoDB query
    const user = await mongoose.connection.db.collection('users').findOne({
        username: username,
        password: password
    });
    if (user) {
        const token = jwt.sign({ id: user._id }, JWT_SECRET, { algorithm: 'none' }); // alg:none!
        res.json({ token });
    } else {
        res.status(401).json({ error: 'Invalid credentials' });
    }
});

// Command injection
app.get('/exec', (req, res) => {
    const cmd = req.query.cmd;
    // Direct execution of user input
    exec(cmd, (error, stdout, stderr) => {
        res.send(stdout);
    });
});

// Path traversal
app.get('/file', (req, res) => {
    const filename = req.query.name;
    // No path validation
    const filePath = '/var/www/files/' + filename;
    fs.readFile(filePath, (err, data) => {
        res.send(data);
    });
});

// XSS - reflected
app.get('/search', (req, res) => {
    const query = req.query.q;
    // Unsanitized output
    res.send(`<html><body><h1>Search results for ${query}</h1></body></html>`);
});

// Prototype pollution via lodash merge (old version)
const _ = require('lodash');
app.post('/merge', (req, res) => {
    const obj = {};
    _.merge(obj, req.body); // Prototype pollution with lodash < 4.17.5
    res.json(obj);
});

// Unsafe eval
app.post('/calculate', (req, res) => {
    const formula = req.body.formula;
    // Dangerous eval of user input
    const result = eval(formula);
    res.json({ result });
});

// JWT without verification
app.get('/profile', (req, res) => {
    const token = req.headers.authorization;
    // No signature verification!
    const decoded = jwt.decode(token);
    res.json(decoded);
});

// Insecure random for tokens
const crypto = require('crypto');
app.get('/token', (req, res) => {
    // Math.random() is not cryptographically secure
    const token = Math.random().toString(36).substr(2);
    res.json({ token });
});

// Open redirect
app.get('/redirect', (req, res) => {
    const url = req.query.url;
    // No URL validation
    res.redirect(url);
});

// CORS misconfiguration
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', '*');
    res.header('Access-Control-Allow-Methods', '*');
    next();
});

app.listen(3000, '0.0.0.0', () => {
    console.log('Server running on port 3000');
});
