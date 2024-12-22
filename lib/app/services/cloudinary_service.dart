import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

class CloudinaryService {
  static const String cloudName = 'dxc6a1qww';
  static const String apiKey = '737978153918162';
  static const String apiSecret = 'W7Fgr9tTSqmmXaW27mDrLzR7uxI';

  static Future<List<String>> uploadImages(List<File> images,
      {String folder = 'lelang_img'}) async {
    List<String> imageUrls = [];

    for (var image in images) {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
        );

        var imageStream = await http.ByteStream(image.openRead());
        var length = await image.length();

        var multipartFile = http.MultipartFile(
          'file',
          imageStream,
          length,
          filename: path.basename(image.path),
        );

        request.files.add(multipartFile);
        request.fields['upload_preset'] = 'lelangfb';
        request.fields['folder'] = folder;

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final url = responseData['secure_url'];
          if (url != null) {
            imageUrls.add(url);
            print('Successfully uploaded image: $url');
          } else {
            throw Exception('No secure_url in response');
          }
        } else {
          print(
              'Upload failed with status ${response.statusCode}: ${response.body}');
          throw Exception('Upload failed with status ${response.statusCode}');
        }
      } catch (e) {
        print('Error uploading to Cloudinary: $e');
        throw e;
      }
    }

    return imageUrls;
  }

  static Future<String> uploadImage(File image,
      {String folder = 'carousel'}) async {
    try {
      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      var request = http.MultipartRequest('POST', url);

      request.fields['upload_preset'] = 'lelangfb';
      request.fields['folder'] = folder;

      if (folder == 'users_profile') {
        request.fields['upload_preset'] =
            'profile_preset'; // preset profile w500 h500
      }

      // Add file
      var length = await image.length();
      var stream = http.ByteStream(image.openRead());
      var multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename:
            '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}',
      );
      request.files.add(multipartFile);

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var result = json.decode(String.fromCharCodes(responseData));

      if (response.statusCode == 200) {
        print('Cloudinary upload successful: ${result['secure_url']}');
        return result['secure_url'];
      } else {
        print('Cloudinary upload failed with status ${response.statusCode}');
        print('Error response: ${String.fromCharCodes(responseData)}');
        throw Exception('Upload failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('Detailed error in uploadImage: $e');
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
