import { createClient } from "@supabase/supabase-js";   // Factory that builds the Supabase client
import { config } from "../config/config";              // Central place where env variables are loaded

const supabaseUrl = config.SUPABASE_URL;                // Project API URL (https://xxxx.supabase.co)
const supabaseKey = config.SUPABASE_KEY;                // Secret key, server-side only

if (!supabaseUrl || !supabaseKey) {                     // Check the variables we pass in, so TypeScript narrows them to string
  throw new Error("SUPABASE_URL or SUPABASE_KEY is missing in the environment variables.");
}

export const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: { persistSession: false },                      // A server has no browser session to store
});

export async function checkDatabase(): Promise<void> {
  const { error } = await supabase.auth.admin.listUsers({ page: 1, perPage: 1 });   // Cheap query to test URL
  if (error) {
    throw new Error(`Supabase check failed: ${error.message}`);           // Let the caller stop the app
  }
  console.log("Supabase connected");                                      // No data logged
}