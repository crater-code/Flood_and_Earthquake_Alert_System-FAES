import 'dotenv/config';
import pkg from '@prisma/client';
const { PrismaClient } = pkg;

const prisma = new PrismaClient();

// Connection logic
async function connectDB() {
  try {
    // Manually trigger the connection
    await prisma.$connect();
    console.log("✅ Database connection established successfully via Prisma.");
  } catch (error) {
    console.error("❌ Failed to connect to the database:");
    console.error(error);
    process.exit(1); // Stop the app if DB connection fails
  }
}

connectDB();

// Disconnect Logic
const gracefulShutdown = async (signal) => {
  console.log(`\nReceived ${signal}. Shutting down...`);
  
  try {
    // Disconnect Prisma
    await prisma.$disconnect();
    
    console.log("Database disconnected from the Application");
    process.exit(0);
  } catch (err) {
    console.error("Error during disconnection:", err);
    process.exit(1);
  }
};

// Listen for termination signals (Ctrl+C or Kill command)
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));

export default prisma;