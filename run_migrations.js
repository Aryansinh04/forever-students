require('dotenv').config();
const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const connectionString = process.env.SUPABASE_DB_URL;

if (!connectionString) {
  console.error("No SUPABASE_DB_URL found in .env");
  process.exit(1);
}

const client = new Client({
  connectionString: connectionString + "?sslmode=require"
});

async function runSQL() {
  try {
    await client.connect();
    console.log("Connected to Supabase PostgreSQL.");

    // Update with the correct path to the requested file
    const sqlPath = "C:\\Users\\thako\\.gemini\\antigravity\\brain\\db95be18-d58f-4ffb-9934-1b385d47aab3\\supabase_final_schema_and_seed.sql";
    
    if (!fs.existsSync(sqlPath)) {
      console.error("SQL file not found at path:", sqlPath);
      process.exit(1);
    }
    
    const sql = fs.readFileSync(sqlPath, 'utf8');
    
    console.log("Executing SQL...");
    await client.query(sql);
    console.log("SQL executed successfully! Database schema and data have been created.");
  } catch (error) {
    console.error("Error executing SQL:", error);
  } finally {
    await client.end();
  }
}

runSQL();
