import dotenv from "dotenv";
dotenv.config();
const envconfig={
    PORT: process.env.PORT || 5000,
    CONNECTION_STRING: process.env.CONNECTION_STRING || "",
    SUPABASE_KEY: process.env.SUPABASE_KEY || "",
    SUPABASE_URL: process.env.SUPABASE_URL || "",
}


export const config = Object.freeze(envconfig);