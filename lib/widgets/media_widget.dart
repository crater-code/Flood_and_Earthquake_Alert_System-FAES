import 'dart:io';
import 'package:flutter/material.dart';
import '../services/media_service.dart';
import '../theme/app_theme.dart';

class MediaWidget extends StatelessWidget {
  final MediaFile mediaFile;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool showRemoveButton;
  final bool showFileInfo;

  const MediaWidget({
    super.key,
    required this.mediaFile,
    this.onRemove,
    this.onTap,
    this.width = 120,
    this.height = 120,
    this.borderRadius,
    this.showRemoveButton = true,
    this.showFileInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: borderRadius ?? BorderRadius.circular(12),
                child: _buildMediaContent(),
              ),
            ),
            if (showRemoveButton && onRemove != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (showFileInfo)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: borderRadius?.bottomLeft ?? const Radius.circular(12),
                      bottomRight: borderRadius?.bottomRight ?? const Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mediaFile.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mediaFile.sizeString,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (mediaFile.isVideo)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        mediaFile.isVideo ? 'VIDEO' : 'PHOTO',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    if (mediaFile.isImage) {
      return _buildImageContent();
    } else if (mediaFile.isVideo) {
      return _buildVideoContent();
    } else {
      return _buildUnknownContent();
    }
  }

  Widget _buildImageContent() {
    return Image.file(
      File(mediaFile.path),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppTheme.slate100,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 32,
                  color: AppTheme.slate400,
                ),
                const SizedBox(height: 4),
                Text(
                  'Failed to load',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.slate500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoContent() {
    return Container(
      color: AppTheme.slate100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.videocam,
                size: 32,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'VIDEO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.slate600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mediaFile.sizeString,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnknownContent() {
    return Container(
      color: AppTheme.slate100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attachment,
              size: 32,
              color: AppTheme.slate400,
            ),
            const SizedBox(height: 4),
            Text(
              'FILE',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaGridWidget extends StatelessWidget {
  final List<MediaFile> mediaFiles;
  final Function(MediaFile)? onRemove;
  final Function(MediaFile)? onTap;
  final VoidCallback? onAddMedia;
  final int maxFiles;
  final bool showAddButton;

  const MediaGridWidget({
    super.key,
    required this.mediaFiles,
    this.onRemove,
    this.onTap,
    this.onAddMedia,
    this.maxFiles = 5,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final canAddMore = mediaFiles.length < maxFiles;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Existing media files
        ...mediaFiles.map((file) => MediaWidget(
          mediaFile: file,
          onRemove: onRemove != null ? () => onRemove!(file) : null,
          onTap: onTap != null ? () => onTap!(file) : null,
        )),
        // Add button
        if (showAddButton && canAddMore && onAddMedia != null)
          GestureDetector(
            onTap: onAddMedia,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.slate50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.slate200,
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add Media',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.slate600,
                    ),
                  ),
                  Text(
                    '${mediaFiles.length}/$maxFiles',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.slate500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class MediaPreviewDialog extends StatelessWidget {
  final MediaFile mediaFile;

  const MediaPreviewDialog({
    super.key,
    required this.mediaFile,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: mediaFile.isImage
                  ? Image.file(
                      File(mediaFile.path),
                      fit: BoxFit.contain,
                    )
                  : Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.videocam,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Video Preview',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mediaFile.name,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension methods for easier usage
extension MediaFileListExtension on List<MediaFile> {
  List<MediaFile> get images => where((file) => file.isImage).toList();
  List<MediaFile> get videos => where((file) => file.isVideo).toList();
  
  int get totalSize => fold(0, (sum, file) => sum + file.size);
  String get totalSizeString => MediaService.getFileSizeString(totalSize);
}