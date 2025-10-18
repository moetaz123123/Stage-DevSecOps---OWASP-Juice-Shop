// SQL Injection vulnérable
const express = require('express');
const mysql = require('mysql');

app.get('/user', (req, res) => {
  const query = "SELECT * FROM users WHERE id = " + req.query.id; // VULNÉRABLE
  connection.query(query, (err, results) => {
    res.json(results);
  });
});

// XSS vulnérable
app.get('/search', (req, res) => {
  res.send("<h1>Results for: " + req.query.q + "</h1>"); // VULNÉRABLE
});

// Command Injection
const { exec } = require('child_process');
app.get('/ping', (req, res) => {
  exec('ping ' + req.query.host, (err, stdout) => { // VULNÉRABLE
    res.send(stdout);
  });
});

// Hardcoded secrets
const API_KEY = "sk-1234567890abcdef"; // VULNÉRABLE
const DB_PASSWORD = "admin123"; // VULNÉRABLE