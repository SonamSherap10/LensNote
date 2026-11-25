import express from "express";  
import {config} from "./config/config";

const app = express();

const startServer =() =>{
    const PORT = config.PORT;
    app.listen(PORT, () => {
        console.log(`Server is running on port ${PORT}`);
});
}

startServer();
export default app;