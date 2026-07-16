import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'media_service.dart';
import 'api_service.dart';

class MediaUploadService {
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedVideoTypes = ['mp4', 'mov', 'avi', 'mkv'];

  /// Upload a single media file (MOCK DEMO MODE)
  static Future<MediaUploadResult> uploadMediaFile(MediaFile mediaFile) async {
    try {
      // Mock delay to simulate upload
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Validate file
      final validation = await _validateFile(mediaFile);
      if (!validation.isValid) {
        return MediaUploadResult(
          success: false,
          error: validation.error!,
        );
      }

      final file = File(mediaFile.path);
      if (!await file.exists()) {
        return MediaUploadResult(
          success: false,
          error: 'File not found',
        );
      }

      // Generate mock upload response
      final mockId = 'media_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
      final mockUrl = 'https://demo.faeas.com/media/$mockId.${mediaFile.path.split('.').last}';
      final mockThumbnail = mediaFile.isImage 
          ? 'https://demo.faeas.com/thumbnails/thumb_$mockId.jpg'
          : null;

      return MediaUploadResult(
        success: true,
        mediaUrl: mockUrl,
        mediaId: mockId,
        thumbnailUrl: mockThumbnail,
      );
    } catch (e) {
      debugPrint('Mock media upload error: $e');
      return MediaUploadResult(
        success: false,
        error: 'Upload failed: ${e.toString()}',
      );
    }
  }

  /// Upload multiple media files
  static Future<List<MediaUploadResult>> uploadMultipleFiles(
    List<MediaFile> mediaFiles, {
    Function(int current, int total)? onProgress,
  }) async {
    final results = <MediaUploadResult>[];
    
    for (int i = 0; i < mediaFiles.length; i++) {
      onProgress?.call(i + 1, mediaFiles.length);
      
      final result = await uploadMediaFile(mediaFiles[i]);
      results.add(result);
      
      // Add a small delay to avoid overwhelming the server
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    return results;
  }

  /// Create a report with media attachments
  static Future<Map<String, dynamic>> createReportWithMedia({
    required String title,
    required String description,
    required String type,
    required double latitude,
    required double longitude,
    String? locationName,
    List<MediaFile>? mediaFiles,
    Function(String stage, int current, int total)? onProgress,
  }) async {
    try {
      List<String> mediaUrls = [];
      List<String> mediaIds = [];

      // Upload media files first if provided
      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        onProgress?.call('Uploading media', 0, mediaFiles.length);
        
        final uploadResults = await uploadMultipleFiles(
          mediaFiles,
          onProgress: (current, total) {
            onProgress?.call('Uploading media', current, total);
          },
        );

        // Check for upload failures
        final failedUploads = uploadResults.where((r) => !r.success).toList();
        if (failedUploads.isNotEmpty) {
          throw Exception('Failed to upload ${failedUploads.length} media files');
        }

        // Extract URLs and IDs
        mediaUrls = uploadResults
            .where((r) => r.mediaUrl != null)
            .map((r) => r.mediaUrl!)
            .toList();
        mediaIds = uploadResults
            .where((r) => r.mediaId != null)
            .map((r) => r.mediaId!)
            .toList();
      }

      onProgress?.call('Creating report', 1, 1);

      // Create report with media URLs
      final reportData = await ApiServiceMediaExtension.createReportWithMedia(
        title: title,
        description: description,
        type: type,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        mediaUrls: mediaUrls,
        mediaIds: mediaIds,
      );

      return reportData;
    } catch (e) {
      debugPrint('Create report with media error: $e');
      rethrow;
    }
  }

  /// Validate media file before upload
  static Future<FileValidationResult> _validateFile(MediaFile mediaFile) async {
    // Check file size
    if (mediaFile.size > maxFileSize) {
      return FileValidationResult(
        isValid: false,
        error: 'File too large. Maximum size is ${MediaService.getFileSizeString(maxFileSize)}',
      );
    }

    // Check file extension
    final extension = mediaFile.path.split('.').last.toLowerCase();
    
    if (mediaFile.isImage && !allowedImageTypes.contains(extension)) {
      return FileValidationResult(
        isValid: false,
        error: 'Invalid image format. Allowed: ${allowedImageTypes.join(', ')}',
      );
    }

    if (mediaFile.isVideo && !allowedVideoTypes.contains(extension)) {
      return FileValidationResult(
        isValid: false,
        error: 'Invalid video format. Allowed: ${allowedVideoTypes.join(', ')}',
      );
    }

    // Check if file exists and is readable
    final file = File(mediaFile.path);
    if (!await file.exists()) {
      return FileValidationResult(
        isValid: false,
        error: 'File not found',
      );
    }

    return FileValidationResult(isValid: true);
  }

  /// Compress media if needed before upload
  static Future<MediaFile> prepareForUpload(MediaFile mediaFile) async {
    try {
      if (mediaFile.isImage && mediaFile.size > 2 * 1024 * 1024) {
        // Compress images larger than 2MB
        final compressedFile = await MediaService.compressImage(mediaFile.path);
        return MediaFile(
          path: compressedFile.path,
          name: mediaFile.name,
          type: MediaType.image,
        );
      }
      
      return mediaFile;
    } catch (e) {
      debugPrint('Error preparing file for upload: $e');
      return mediaFile; // Return original file if compression fails
    }
  }

  /// Delete media file (MOCK DEMO MODE)
  static Future<bool> deleteMediaFile(String mediaId) async {
    try {
      // Mock delay to simulate deletion
      await Future.delayed(const Duration(milliseconds: 500));
      
      debugPrint('Mock: Deleted media file $mediaId');
      return true;
    } catch (e) {
      debugPrint('Mock error deleting media file: $e');
      return false;
    }
  }

  /// Get upload progress for multiple files
  static Stream<UploadProgress> uploadWithProgress(List<MediaFile> mediaFiles) async* {
    int totalFiles = mediaFiles.length;
    
    for (int i = 0; i < mediaFiles.length; i++) {
      yield UploadProgress(
        currentFile: i + 1,
        totalFiles: totalFiles,
        currentFileName: mediaFiles[i].name,
        status: UploadStatus.uploading,
      );

      final result = await uploadMediaFile(mediaFiles[i]);

      if (result.success) {
        yield UploadProgress(
          currentFile: i + 1,
          totalFiles: totalFiles,
          currentFileName: mediaFiles[i].name,
          status: UploadStatus.completed,
          result: result,
        );
      } else {
        yield UploadProgress(
          currentFile: i + 1,
          totalFiles: totalFiles,
          currentFileName: mediaFiles[i].name,
          status: UploadStatus.failed,
          error: result.error,
        );
      }
    }

    yield UploadProgress(
      currentFile: totalFiles,
      totalFiles: totalFiles,
      currentFileName: '',
      status: UploadStatus.allCompleted,
    );
  }
}

class MediaUploadResult {
  final bool success;
  final String? mediaUrl;
  final String? mediaId;
  final String? thumbnailUrl;
  final String? error;

  MediaUploadResult({
    required this.success,
    this.mediaUrl,
    this.mediaId,
    this.thumbnailUrl,
    this.error,
  });
}

class FileValidationResult {
  final bool isValid;
  final String? error;

  FileValidationResult({
    required this.isValid,
    this.error,
  });
}

class UploadProgress {
  final int currentFile;
  final int totalFiles;
  final String currentFileName;
  final UploadStatus status;
  final MediaUploadResult? result;
  final String? error;

  UploadProgress({
    required this.currentFile,
    required this.totalFiles,
    required this.currentFileName,
    required this.status,
    this.result,
    this.error,
  });

  double get progress => totalFiles > 0 ? currentFile / totalFiles : 0.0;
}

enum UploadStatus {
  waiting,
  uploading,
  completed,
  failed,
  allCompleted,
}

// Extension to ApiService for media support (MOCK DEMO MODE)
extension ApiServiceMediaExtension on ApiService {
  static Future<Map<String, dynamic>> createReportWithMedia({
    required String title,
    required String description,
    required String type,
    required double latitude,
    required double longitude,
    String? locationName,
    List<String>? mediaUrls,
    List<String>? mediaIds,
  }) async {
    // Mock delay to simulate network request
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Use the existing mock createReport method
    final baseReport = await ApiService.createReport(
      title: title,
      description: description,
      type: type,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );
    
    // Add media URLs to the mock response
    if (mediaUrls != null && mediaUrls.isNotEmpty) {
      baseReport['data']['mediaUrls'] = mediaUrls;
    }
    
    if (mediaIds != null && mediaIds.isNotEmpty) {
      baseReport['data']['mediaIds'] = mediaIds;
    }
    
    return baseReport;
  }
}