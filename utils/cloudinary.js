const cloudinary = require("cloudinary").v2;

cloudinary.config({
  cloud_name: "dxc6a1qww",
  api_key: "737978153918162",
  api_secret: "W7Fgr9tTSqmmXaW27mDrLzR7uxI",
});

const uploadImage = async (files) => {
  try {
    if (Array.isArray(files)) {
      const uploadPromises = files.map((file) =>
        cloudinary.uploader.upload(file.filepath, {
          folder: "lelangfb",
          resource_type: "auto",
        })
      );
      const results = await Promise.all(uploadPromises);
      return results.map((result) => result.secure_url);
    } else {
      const result = await cloudinary.uploader.upload(files.filepath, {
        folder: "lelangfb",
        resource_type: "auto",
      });
      return [result.secure_url];
    }
  } catch (error) {
    console.error("Error uploading to Cloudinary:", error);
    throw error;
  }
};

module.exports = { uploadImage };
