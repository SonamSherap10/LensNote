import dotenv from "dotenv";
dotenv.config();
const envconfig={
    PORT: process.env.PORT || 5000,
    CONNECTION_URI: process.env.CONNECTION_URI 
}


export const config = Object.freeze(envconfig);