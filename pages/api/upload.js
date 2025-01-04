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
    const form = new IncomingForm({ multiples: true });

    form.parse(req, async (err, fields, files) => {
      if (err) {
        return res.status(500).json({ error: "Error parsing form data" });
      }

      const imageFiles = files.images;
      const imageUrls = await uploadImage(imageFiles);

      // Save to Firestore
      await db.collection("items").add({
        ...fields,
        imageUrls: imageUrls,
        createdAt: new Date().toISOString(),
      });

      res.status(200).json({ success: true, imageUrls });
    });
  } catch (error) {
    console.error("Upload error:", error);
    res.status(500).json({ error: "Error uploading files" });
  }
}
