const fs = require('node:fs/promises');
const path = require('node:path');
const mysql = require('mysql2/promise');
require('dotenv').config();

const requiredVariables = ['DB_HOST', 'DB_USER', 'DB_PASSWORD', 'DB_NAME'];
for (const name of requiredVariables) {
  if (!process.env[name]) {
    throw new Error(`Missing required database environment variable: ${name}`);
  }
}

async function migrate() {
  const schemaPath = path.resolve(__dirname, '../../database/schema.sql');
  const schema = await fs.readFile(schemaPath, 'utf8');
  const config = {
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl: process.env.DB_SSL === 'true' ? {} : undefined
  };

  for (let attempt = 1; attempt <= 6; attempt += 1) {
    let connection;
    try {
      connection = await mysql.createConnection(config);
      await connection.query(schema);
      console.log(`Database schema is up to date for ${process.env.DB_NAME}.`);
      return;
    } catch (error) {
      if (attempt === 6) throw error;
      const delayMs = Math.min(1000 * (2 ** (attempt - 1)), 30000);
      console.warn(`Database not ready (attempt ${attempt}/6); retrying in ${delayMs / 1000}s.`);
      await new Promise((resolve) => setTimeout(resolve, delayMs));
    } finally {
      if (connection) await connection.end();
    }
  }
}

migrate().catch((error) => {
  console.error('Database migration failed:', error.message);
  process.exitCode = 1;
});
