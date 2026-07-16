import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mime/mime.dart';

class MediaService {
  static final ImagePicker _picker = ImagePicker();

  /// Request necessary permissions for camera and storage
  static Future<bool> requestPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.storage,
      Permission.photos,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    return statuses[Permission.camera] == PermissionStatus.granted &&
           (statuses[Permission.storage] == PermissionStatus.granted ||
            statuses[Permission.photos] == PermissionStatus.granted);
  }

  /// Pick image from camera
  static Future<MediaFile?> pickImageFromCamera() async {
    try {
      if (!await requestPermissions()) {
        throw Exception('Camera permission denied');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return MediaFile(
          path: image.path,
          name: image.name,
          type: MediaType.image,
        );
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      throw Exception('Failed to capture photo: $e');
    }
    return null;
  }

  /// Pick image from gallery
  static Future<MediaFile?> pickImageFromGallery() async {
    try {
      if (!await requestPermissions()) {
        throw Exception('Gallery permission denied');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return MediaFile(
          path: image.path,
          name: image.name,
          type: MediaType.image,
        );
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      throw Exception('Failed to select photo: $e');
    }
    return null;
  }

  /// Pick video from camera
  static Future<MediaFile?> pickVideoFromCamera() async {
    try {
      if (!await requestPermissions()) {
        throw Exception('Camera permission denied');
      }

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        return MediaFile(
          path: video.path,
          name: video.name,
          type: MediaType.video,
        );
      }
    } catch (e) {
      debugPrint('Error picking video from camera: $e');
      throw Exception('Failed to record video: $e');
    }
    return null;
  }

  /// Pick video from gallery
  static Future<MediaFile?> pickVideoFromGallery() async {
    try {
      if (!await requestPermissions()) {
        throw Exception('Gallery permission denied');
      }

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        return MediaFile(
          path: video.path,
          name: video.name,
          type: MediaType.video,
        );
      }
    } catch (e) {
      debugPrint('Error picking video from gallery: $e');
      throw Exception('Failed to select video: $e');
    }
    return null;
  }

  /// Pick multiple images from gallery
  static Future<List<MediaFile>> pickMultipleImages({int limit = 5}) async {
    try {
      if (!await requestPermissions()) {
        throw Exception('Gallery permission denied');
      }

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
        limit: limit,
      );

      return images.map((image) => MediaFile(
        path: image.path,
        name: image.name,
        type: MediaType.image,
      )).toList();
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      throw Exception('Failed to select images: $e');
    }
  }

  /// Get file size in a human readable format
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get mime type of a file
  static String? getMimeType(String filePath) {
    return lookupMimeType(filePath);
  }

  /// Compress image if needed
  static Future<File> compressImage(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    
    // If file is already small enough, return as is
    if (bytes.length < 1024 * 1024) return file;
    
    // For larger files, we'd implement compression here
    // For now, just return the original file
    return file;
  }

  /// Save media file to app directory
  static Future<String> saveMediaFile(MediaFile mediaFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${directory.path}/media');
      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = mediaFile.path.split('.').last;
      final fileName = 'media_${timestamp}.$extension';
      final newPath = '${mediaDir.path}/$fileName';

      final originalFile = File(mediaFile.path);
      await originalFile.copy(newPath);

      return newPath;
    } catch (e) {
      debugPrint('Error saving media file: $e');
      throw Exception('Failed to save media file: $e');
    }
  }

  /// Delete media file
  static Future<void> deleteMediaFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting media file: $e');
    }
  }

  /// Get thumbnail for video (placeholder implementation)
  static Future<Uint8List?> getVideoThumbnail(String videoPath) async {
    // In a real implementation, you'd use a package like video_thumbnail
    // For now, return null (we'll show a video icon instead)
    return null;
  }

  /// Show media picker bottom sheet
  static Future<MediaFile?> showMediaPicker(
    BuildContext context, {
    bool allowVideo = true,
    bool allowMultiple = false,
  }) async {
    return showModalBottomSheet<MediaFile?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MediaPickerBottomSheet(
        allowVideo: allowVideo,
        allowMultiple: allowMultiple,
      ),
    );
  }
}

enum MediaType {
  image,
  video,
}

class MediaFile {
  final String path;
  final String name;
  final MediaType type;
  late final int size;
  late final String? mimeType;

  MediaFile({
    required this.path,
    required this.name,
    required this.type,
  }) {
    final file = File(path);
    size = file.existsSync() ? file.lengthSync() : 0;
    mimeType = MediaService.getMimeType(path);
  }

  String get sizeString => MediaService.getFileSizeString(size);

  bool get isImage => type == MediaType.image;
  bool get isVideo => type == MediaType.video;
}

class MediaPickerBottomSheet extends StatelessWidget {
  final bool allowVideo;
  final bool allowMultiple;

  const MediaPickerBottomSheet({
    super.key,
    this.allowVideo = true,
    this.allowMultiple = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Media',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                _buildOption(
                  context,
                  icon: Icons.camera_alt,
                  title: 'Take Photo',
                  subtitle: 'Capture with camera',
                  onTap: () async {
                    try {
                      final result = await MediaService.pickImageFromCamera();
                      if (context.mounted) {
                        Navigator.pop(context, result);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
                _buildOption(
                  context,
                  icon: Icons.photo_library,
                  title: allowMultiple ? 'Select Photos' : 'Select Photo',
                  subtitle: 'Choose from gallery',
                  onTap: () async {
                    try {
                      if (allowMultiple) {
                        final results = await MediaService.pickMultipleImages();
                        if (context.mounted) {
                          Navigator.pop(context, results.isNotEmpty ? results.first : null);
                        }
                      } else {
                        final result = await MediaService.pickImageFromGallery();
                        if (context.mounted) {
                          Navigator.pop(context, result);
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
                if (allowVideo) ...[
                  _buildOption(
                    context,
                    icon: Icons.videocam,
                    title: 'Record Video',
                    subtitle: 'Capture with camera',
                    onTap: () async {
                      try {
                        final result = await MediaService.pickVideoFromCamera();
                        if (context.mounted) {
                          Navigator.pop(context, result);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                  _buildOption(
                    context,
                    icon: Icons.video_library,
                    title: 'Select Video',
                    subtitle: 'Choose from gallery',
                    onTap: () async {
                      try {
                        final result = await MediaService.pickVideoFromGallery();
                        if (context.mounted) {
                          Navigator.pop(context, result);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}