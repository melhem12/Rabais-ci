import '../constants/app_constants.dart';

/// Helper class for building full image URLs from relative paths
class ImageUrlHelper {
  /// Build a full image URL from a relative or absolute path
  /// If the URL is already absolute (starts with http:// or https://), return it as is
  /// Otherwise, prepend the base URL
  static String buildImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    
    // If already an absolute URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // If it starts with /, remove it to avoid double slash
    if (imagePath.startsWith('/')) {
      return '${AppConstants.baseUrl}$imagePath';
    }
    
    // Otherwise, add base URL and slash
    return '${AppConstants.baseUrl}/$imagePath';
  }
}








