const express = require("express");
const cors = require("cors");
const midtransClient = require("midtrans-client");

const app = express();
app.use(
  cors({
    origin: "*", // Be more restrictive in production
    methods: ["GET", "POST"],
    allowedHeaders: ["Content-Type"],
  })
);
app.use(express.json());

// Create Snap API instance
let snap = new midtransClient.Snap({
  isProduction: false,
  serverKey: "SB-Mid-server-xxbgQY3Vhh8ewNI2IOHiaZad",
  clientKey: "SB-Mid-client-L_J-CtXY1CPdAyfa",
});

// Create Core API instance
let core = new midtransClient.CoreApi({
  isProduction: false,
  serverKey: "SB-Mid-server-xxbgQY3Vhh8ewNI2IOHiaZad",
  clientKey: "SB-Mid-client-L_J-CtXY1CPdAyfa",
});

app.post("/create-payment", async (req, res) => {
  try {
    const { orderId, amount, userId, email, name } = req.body;
    console.log("Creating payment:", { orderId, amount, userId, email, name });

    let parameter = {
      transaction_details: {
        order_id: orderId,
        gross_amount: amount,
      },
      credit_card: {
        secure: true,
      },
      customer_details: {
        email: email,
        first_name: name,
      },
      enabled_payments: ["credit_card", "gopay", "shopeepay", "bank_transfer"],
      callbacks: {
        finish: "lelangfb://payment-complete",
        error: "lelangfb://payment-error",
        pending: "lelangfb://payment-pending",
      },
    };

    const transaction = await snap.createTransaction(parameter);
    console.log("Payment URL created:", transaction.redirect_url);

    res.json({
      token: transaction.token,
      redirectUrl: transaction.redirect_url,
    });
  } catch (error) {
    console.error("Payment creation error:", error);
    res.status(500).json({ error: error.message });
  }
});

app.post("/withdraw", async (req, res) => {
  try {
    const { bankAccount, amount, bankCode, accountName } = req.body;

    await new Promise((resolve) => setTimeout(resolve, 1000));

    res.json({
      status_code: "200",
      status_message: "Success, withdrawal completed",
      order_id: "withdrawal-" + new Date().getTime(),
      gross_amount: amount,
      payment_type: "bank_transfer",
      transaction_time: new Date().toISOString(),
      transaction_status: "success",
      account_name: accountName,
      va_numbers: [
        {
          bank: bankCode,
          va_number: bankAccount,
        },
      ],
      fraud_status: "accept",
      currency: "IDR",
    });
  } catch (error) {
    console.error("Withdrawal error:", error);
    res.status(500).json({ error: error.message });
  }
});

app.get("/status/:orderId", async (req, res) => {
  try {
    const statusResponse = await core.transaction.status(req.params.orderId);
    res.json(statusResponse);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
