import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

class CloudinaryService {
  static const String cloudName = 'dxc6a1qww';
  static const String apiKey = '737978153918162';
  static const String apiSecret = 'W7Fgr9tTSqmmXaW27mDrLzR7uxI';
  static const String uploadPreset = 'lelangfb';

  static Future<List<String>> uploadImages(List<File> images,
      {String folder = 'lelang_img'}) async {
    List<String> imageUrls = [];

    for (var image in images) {
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = '${timestamp}_${path.basename(image.path)}';

        var uri = Uri.parse(
            'https://api.cloudinary.com/v1_1/$cloudName/image/upload');
        var request = http.MultipartRequest('POST', uri);

        final signature = generateSignature('', timestamp.toString());

        request.fields.addAll({
          'api_key': apiKey,
          'timestamp': timestamp.toString(),
          'signature': signature,
          'folder': folder,
        });

        var multipartFile = await http.MultipartFile.fromPath(
          'file',
          image.path,
          filename: fileName,
        );

        request.files.add(multipartFile);

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          imageUrls.add(jsonResponse['secure_url']);
          print('Successfully uploaded image: ${jsonResponse['secure_url']}');
        } else {
          print('Upload failed with status ${response.statusCode}');
          print('Error response: ${response.body}');
          throw Exception('Upload failed with status ${response.statusCode}');
        }
      } catch (e) {
        print('Error uploading to Cloudinary: $e');
        rethrow;
      }
    }

    return imageUrls;
  }

  static Future<void> deleteImageByUrl(String imageUrl) async {
    try {
      final publicId = getPublicIdFromUrl(imageUrl);
      await deleteImage(publicId);
      print('Successfully deleted image with public ID: $publicId');
    } catch (e) {
      print('Error deleting image by URL: $e');
      throw Exception('Failed to delete image by URL: $e');
    }
  }

  static Future<String> uploadImage(
    File image, {
    String folder = 'carousel',
    String? filename,
    String? previousImageUrl,
  }) async {
    try {
      if (previousImageUrl != null && previousImageUrl.isNotEmpty) {
        try {
          await deleteImageByUrl(previousImageUrl);
        } catch (e) {
          print('Error deleting previous image: $e');
        }
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final finalFilename =
          filename ?? '${timestamp}_${path.basename(image.path)}';

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
      );

      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;
      request.fields['file_name'] = finalFilename;

      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        image.path,
        filename: finalFilename,
      );

      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print('Successfully uploaded image: ${jsonResponse['secure_url']}');
        return jsonResponse['secure_url'];
      } else {
        print('Upload failed with status ${response.statusCode}');
        print('Error response: ${response.body}');
        throw Exception('Upload failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in uploadImage: $e');
      rethrow;
    }
  }

  static Future<void> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final signature = generateSignature(publicId, timestamp);

      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy');

      final response = await http.post(url, body: {
        'public_id': publicId,
        'api_key': apiKey,
        'timestamp': timestamp,
        'signature': signature,
      });

      if (response.statusCode != 200) {
        throw Exception('Failed to delete image');
      }
    } catch (e) {
      throw Exception('Error deleting image: $e');
    }
  }

  static String generateSignature(String publicId, String timestamp) {
    final String stringToSign =
        'public_id=$publicId&timestamp=$timestamp$apiSecret';
    return generateSha1(stringToSign);
  }

  static String generateSha1(String input) {
    final bytes = utf8.encode(input);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  static String getPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Handle items folder structure
      if (pathSegments.contains('items')) {
        final itemsIndex = pathSegments.indexOf('items');
        if (itemsIndex < pathSegments.length - 2) {
          // Return full path including uid subfolder
          return 'items/${pathSegments[itemsIndex + 1]}/${pathSegments.last.split('.').first}';
        }
      }

      // Check for users_profile folder
      final profileIndex = pathSegments.indexOf('users_profile');
      if (profileIndex != -1 && profileIndex < pathSegments.length - 1) {
        final filename = pathSegments.last;
        return 'users_profile/' + filename.split('.').first;
      }

      // Check for carousel folder
      final carouselIndex = pathSegments.indexOf('carousel');
      if (carouselIndex != -1 && carouselIndex < pathSegments.length - 1) {
        final filename = pathSegments.last;
        return 'carousel/' + filename.split('.').first;
      }

      return pathSegments.last.split('.').first;
    } catch (e) {
      print('Error parsing URL: $url');
      throw Exception('Invalid URL format');
    }
  }
}
