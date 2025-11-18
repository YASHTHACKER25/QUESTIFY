import mongoose from "mongoose";

export const dbconnect = async (url) => {
  try {
    await mongoose.connect(url, {
      // Force modern SSL/TLS connection
      ssl: true,
      tlsAllowInvalidCertificates: false,
      serverSelectionTimeoutMS: 5000, // Fail faster if can't connect
      retryWrites: true,
      w: "majority",
    });

    console.log("✅ DATABASE CONNECTED");
  } catch (error) {
    console.error("❌ DATABASE CONNECTION ERROR:", error.message);
    console.error(error); // Optional: print full details
    process.exit(1);
  }
};
