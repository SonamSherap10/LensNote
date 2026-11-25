import express from "express";  
import {config} from "./config/config"; 
import {supabase,checkDatabase} from "./db/dbConfig";


const app = express();

const startServer =() =>{
    const PORT = config.PORT;
    checkDatabase().then(() => {
        app.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}`);
        });
    }).catch((error) => {
        console.error("Failed to start server:", error);
    });
}

startServer();
export default app;