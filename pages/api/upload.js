import { IncomingForm } from "formidable";
import { uploadImage } from "../../utils/cloudinary";
import { db } from "../../utils/firebase";

export const config = {
  api: {
    bodyParser: false,
  },
};

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ message: "Method not allowed" });
  }

  try {
    const form = new IncomingForm();

    form.parse(req, async (err, fields, files) => {
      if (err) {
        return res.status(500).json({ error: "Error parsing form data" });
      }

      const file = files.image;
      const imageUrl = await uploadImage(file.filepath);

      // Save to Firestore
      await db.collection("items").add({
        ...fields,
        imageUrl,
        createdAt: new Date().toISOString(),
      });

      res.status(200).json({ success: true, imageUrl });
    });
  } catch (error) {
    console.error("Upload error:", error);
    res.status(500).json({ error: "Error uploading file" });
  }
}
