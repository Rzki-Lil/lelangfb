const cloudinary = require("cloudinary").v2;

cloudinary.config({
  cloud_name: "dxc6a1qww",
  api_key: "737978153918162",
  api_secret: "W7Fgr9tTSqmmXaW27mDrLzR7uxI",
});

const uploadImage = async (file) => {
  try {
    const result = await cloudinary.uploader.upload(file, {
      folder: "lelangfb",
    });
    return result.secure_url;
  } catch (error) {
    console.error("Error uploading to Cloudinary:", error);
    throw error;
  }
};

module.exports = { uploadImage };
