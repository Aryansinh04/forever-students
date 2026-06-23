const { connectStore, updateDb, LEGACY_DB_PATH } = require("./backend/src/data/store");
const fs = require("fs").promises;

async function migrate() {
  console.log("Starting migration to Supabase REST natively...");
  
  // Connect explicitly to instantiate the client
  await connectStore();
  console.log("Connected to Supabase client.");

  // Force an update which reads from local db.json then writes to Supabase
  await updateDb(async (db) => {
     // The db returned by readDb will be empty if Supabase is empty
     // So we MUST strictly read the db.json directly for this 1-time sync
     const raw = await fs.readFile(LEGACY_DB_PATH, "utf8");
     const localDb = JSON.parse(raw);
     console.log(`Found ${localDb.products.length} products locally. Migrating to Supabase...`);
     
     // Merge all models into memory so the subsequent writeDb saves them to Supabase!
     ["products", "users", "chatFaqs", "orders", "carts", "careerApplications"].forEach(collection => {
       if(localDb[collection]) {
         localDb[collection].forEach(item => {
             if (!db[collection].find(remote => remote.id === item.id)) {
                 db[collection].push(item);
             }
         });
       }
     });

     return; 
  });

  console.log("Migration Complete! Your data is fully synced to Supabase.");
  process.exit(0);
}

migrate().catch(err => {
  console.error(err);
  process.exit(1);
});
