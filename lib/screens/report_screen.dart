// lib/screens/report_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/backend_service.dart';
import '../services/location_weather_service.dart';
import '../services/media_service.dart';
import '../services/media_upload_service.dart';
import '../services/haptic_service.dart';
import '../widgets/media_widget.dart';
import '../theme/app_theme.dart';


class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  String _type = 'FLOOD';
  final TextEditingController _titleController = TextEditingController();
  String _description = '';
  String _locationName = 'Unknown Location';
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto-fill location if already known
    if (LocationWeatherService.lastPosition != null) {
      final p = LocationWeatherService.lastPosition!;
      _latitude = p.latitude;
      _longitude = p.longitude;
      _locationName = '${p.latitude.toStringAsFixed(4)}, ${p.longitude.toStringAsFixed(4)}';
    }
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final position = await LocationWeatherService.getCurrentPosition();
      final address = await LocationWeatherService.getAddressFromCoords(
          position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationName = address;
        });
      }
    } catch (_) {
      // Keep defaults if location fails
    }
  }

  final List<MediaFile> _mediaFiles = [];

  Future<void> _addMedia() async {
    try {
      final mediaFile = await MediaService.showMediaPicker(
        context,
        allowVideo: true,
        allowMultiple: false,
      );
      
      if (mediaFile != null) {
        setState(() {
          _mediaFiles.add(mediaFile);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add media: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _removeMedia(MediaFile mediaFile) {
    setState(() {
      _mediaFiles.remove(mediaFile);
    });
  }

  void _previewMedia(MediaFile mediaFile) {
    showDialog(
      context: context,
      builder: (context) => MediaPreviewDialog(mediaFile: mediaFile),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: Navigator.canPop(context) ? IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ) : null,
        title: const Text('Report Disaster'),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 768;
            final maxWidth = isTablet ? 600.0 : double.infinity;
            final padding = isTablet ? 32.0 : 16.0;
            
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: padding,
                    right: padding,
                    top: padding,
                    bottom: 120, // Space for expandable bottom nav
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeaderCard(context, isTablet),
                        const SizedBox(height: 24),
                        _buildReportForm(context, isTablet),
                        const SizedBox(height: 24),
                        _buildMediaSection(context, isTablet),
                        const SizedBox(height: 24),
                        _buildLocationCard(context, isTablet),
                        const SizedBox(height: 32),
                        _buildActionButtons(context, isTablet),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.report_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Disaster Report',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Help your community by reporting disasters',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportForm(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Disaster Type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.slate800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.slate200),
              borderRadius: BorderRadius.circular(12),
            ),
                          child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'FLOOD', child: Text('Flood')),
                  DropdownMenuItem(value: 'EARTHQUAKE', child: Text('Earthquake')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'FLOOD'),
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: AppTheme.slate400),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Title',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.slate800,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Brief title for your report',
              hintStyle: TextStyle(color: AppTheme.slate400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.slate200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.slate200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primary, width: 2),
              ),
              filled: true,
              fillColor: AppTheme.slate50,
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
          ),
          const SizedBox(height: 24),
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.slate800,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Describe what you observed, including location details, severity, and any immediate dangers...',
              hintStyle: TextStyle(color: AppTheme.slate400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.slate200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.slate200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primary, width: 2),
              ),
              filled: true,
              fillColor: AppTheme.slate50,
            ),
            onChanged: (v) => setState(() => _description = v),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a description' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Media (Optional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.slate800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Photos and videos help verify your report',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.slate500,
            ),
          ),
          const SizedBox(height: 16),
          MediaGridWidget(
            mediaFiles: _mediaFiles,
            onRemove: _removeMedia,
            onTap: _previewMedia,
            onAddMedia: _addMedia,
            maxFiles: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.location_on,
              color: AppTheme.info,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Location',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.slate800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _locationName.isNotEmpty
                      ? _locationName
                      : 'Detecting location...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.slate500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _submitting ? null : _onSubmit,
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_submitting) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Submitting...',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.send, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Submit Report',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.slate200),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _formKey.currentState?.reset();
                setState(() {
                  _type = 'FLOOD';
                  _description = '';
                  _titleController.clear();
                  _mediaFiles.clear();
                });
              },
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, color: AppTheme.slate600, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Reset Form',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.slate600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      // Use the new media upload service for better functionality
      if (_mediaFiles.isNotEmpty) {
        final reportData = await MediaUploadService.createReportWithMedia(
          title: _titleController.text.trim(),
          description: _description,
          type: _type,
          latitude: _latitude,
          longitude: _longitude,
          locationName: _locationName,
          mediaFiles: _mediaFiles,
          onProgress: (stage, current, total) {
            // You could show progress here if needed
            debugPrint('$stage: $current/$total');
          },
        );
        
        // Use the report data as needed
        debugPrint('Report created with media: ${reportData['id']}');
        
        if (!mounted) return;
        
        await HapticService.submit();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Report with media submitted successfully!'),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Submit without media - use Backend2 API (or fallback to mock)
        try {
          await BackendService.createReport(
            title: _titleController.text.trim(),
            description: _description,
            type: _type,
            latitude: _latitude,
            longitude: _longitude,
            locationName: _locationName,
          );
        } catch (backendError) {
          // Fallback to mock data if backend is down
          debugPrint('Backend error, using mock: $backendError');
          await ApiService.createReport(
            title: _titleController.text.trim(),
            description: _description,
            type: _type,
            latitude: _latitude,
            longitude: _longitude,
            locationName: _locationName,
          );
        }
        
        if (!mounted) return;
        
        await HapticService.submit();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Report submitted successfully!'),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      // Reset form
      _formKey.currentState?.reset();
      setState(() {
        _type = 'FLOOD';
        _mediaFiles.clear();
        _description = '';
        _titleController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      
      await HapticService.error();
      
      setState(() {
        _errorMessage = 'Failed to submit report: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}
