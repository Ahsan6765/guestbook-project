-- Create the Guestbook Database
CREATE DATABASE IF NOT EXISTS guestbook_db;
USE guestbook_db;

-- Create the entries table
CREATE TABLE IF NOT EXISTS entries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
