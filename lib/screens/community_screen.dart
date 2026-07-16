// lib/screens/community_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/backend_service.dart';
import '../theme/app_theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with AutomaticKeepAliveClientMixin {
  late Future<List<dynamic>> _reports;
  bool _isUsingBackend = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    // Try backend first with smart fallback
    _reports = _fetchReportsIntelligently();
  }

  /// Intelligently fetch reports: try backend, test if has data, fallback to mock
  Future<List<dynamic>> _fetchReportsIntelligently() async {
    try {
      debugPrint('📡 Attempting to fetch reports from Backend2...');
      
      // Attempt to get data from backend
      final backendReports = await BackendService.getAllReports();
      
      // Check if backend returned actual data (not just fallback to mock)
      if (backendReports.isNotEmpty) {
        debugPrint('✅ Backend2 reports fetched: ${backendReports.length} reports');
        setState(() {
          _isUsingBackend = true;
        });
        return backendReports;
      } else {
        throw Exception('Backend returned empty data');
      }
    } catch (backendError) {
      debugPrint('❌ Backend failed: $backendError');
      debugPrint('📂 Falling back to mock data...');
      
      setState(() {
        _isUsingBackend = false;
      });
      
      // Use mock data as fallback
      return ApiService.getAllReports();
    }
  }

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }

  Color _credibilityColor(int score) {
    if (score >= 75) return AppTheme.success;
    if (score >= 50) return AppTheme.warning;
    return AppTheme.error;
  }

  void _upvote(String id) async {
    try {
      await ApiService.upvoteReport(id);
      setState(() {
        _loadReports();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _downvote(String id) async {
    try {
      await ApiService.downvoteReport(id);
      setState(() {
        _loadReports();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _addComment(String id) async {
    final controller = TextEditingController();
    final res = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add comment'),
        content: TextField(
          controller: controller, 
          autofocus: true, 
          maxLines: 3, 
          decoration: const InputDecoration(hintText: 'Write a comment')
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('Cancel')
          ), 
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()), 
            child: const Text('Post')
          )
        ],
      ),
    );
    if (res != null && res.isNotEmpty) {
      // Mock add comment
      setState(() {});
    }
  }

  void _viewComments(String id) async {
    final mockComments = [
      {
        'id': '1',
        'author': 'Ahmed Khan',
        'avatar': 'A',
        'text': 'This is a serious situation. Please stay safe everyone!',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 45)),
        'likes': 12,
      },
      {
        'id': '2',
        'author': 'Fatima Ali',
        'avatar': 'F',
        'text': 'The relief camps are set up in the main mosque. Check there if needed.',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
        'likes': 28,
      },
      {
        'id': '3',
        'author': 'Hassan Raza',
        'avatar': 'H',
        'text': 'Anyone need help with evacuation? I have a truck available.',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
        'likes': 5,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Comments (${mockComments.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            
            // Comments list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: mockComments.length,
                itemBuilder: (context, index) {
                  final comment = mockComments[index];
                  return _buildCommentTile(context, comment);
                },
              ),
            ),
            
            // Add comment input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primary,
                    child: Text(
                      'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentTile(BuildContext context, Map<String, dynamic> comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primary,
                child: Text(
                  comment['avatar'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment['author'],
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _timeAgo(comment['timestamp']),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment['text'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${comment['likes']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Reply',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
        title: const Text('Community Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadReports();
              });
            },
          ),
        ],
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _reports,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final reports = snapshot.data ?? [];
          
          if (reports.isEmpty) {
            return _buildEmptyState();
          }
          
          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 768;
              final maxWidth = isTablet ? 600.0 : double.infinity;
              
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: ListView.separated(
                    padding: EdgeInsets.only(
                      left: isTablet ? 24 : 16,
                      right: isTablet ? 24 : 16,
                      top: 16,
                      bottom: 120, // Space for expandable bottom nav
                    ),
                    itemCount: reports.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) => _buildPostCard(reports[i], constraints),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  Widget _buildPostCard(Map<String, dynamic> report, BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 400;
    final username = report['userName'] ?? 'Anonymous';
    final initials = username.isNotEmpty ? username[0] : 'U';
    
    return Container(
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
      child: Padding(
        padding: EdgeInsets.all(isNarrow ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(report, initials, isNarrow),
            const SizedBox(height: 12),
            _buildPostContent(report),
            if (report['mediaUrls'] != null && (report['mediaUrls'] as List).isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildMediaPreview(report['mediaUrls']),
            ],
            const SizedBox(height: 16),
            _buildPostActions(report, isNarrow),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(Map<String, dynamic> report, String initials, bool isNarrow) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: isNarrow ? 18 : 20,
          backgroundColor: AppTheme.primary,
          child: Text(
            initials, 
            style: TextStyle(
              color: Colors.white,
              fontSize: isNarrow ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      report['userName'] ?? 'Anonymous',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isNarrow ? 14 : 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getReportColor(report['type']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      report['type'] ?? 'Report',
                      style: TextStyle(
                        color: _getReportColor(report['type']),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      report['locationName'] ?? 'Unknown Location',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isNarrow ? 11 : 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _timeAgo(DateTime.parse(report['createdAt'] ?? DateTime.now().toIso8601String())),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: isNarrow ? 10 : 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildPostContent(Map<String, dynamic> report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report['title'] ?? 'Emergency Report',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          report['description'] ?? 'No description available',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        _buildStatusBadge(report['severity'], report['status']),
      ],
    );
  }

  Widget _buildStatusBadge(String? severity, String? status) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getSeverityColor(severity).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            severity ?? 'Medium',
            style: TextStyle(
              color: _getSeverityColor(severity),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status ?? 'Active',
            style: TextStyle(
              color: AppTheme.success,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
  Color _getSeverityColor(String? severity) {
    switch (severity?.toUpperCase()) {
      case 'HIGH':
      case 'CRITICAL':
        return AppTheme.error;
      case 'MEDIUM':
        return AppTheme.warning;
      case 'LOW':
        return AppTheme.success;
      default:
        return AppTheme.warning;
    }
  }

  Color _getReportColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'FLOOD':
        return Colors.blue;
      case 'EARTHQUAKE':
        return Colors.orange;
      case 'FIRE':
        return Colors.red;
      case 'LANDSLIDE':
        return Colors.brown;
      default:
        return Colors.purple;
    }
  }

  Widget _buildMediaPreview(List mediaUrls) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mediaUrls.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(mediaUrls[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostActions(Map<String, dynamic> report, bool isNarrow) {
    final upvotes = report['upvotes'] ?? 0;
    final downvotes = report['downvotes'] ?? 0;
    final userUpvoted = report['userUpvoted'] ?? false;
    final userDownvoted = report['userDownvoted'] ?? false;
    
    return Row(
      children: [
        GestureDetector(
          onTap: () => _upvote(report['id']),
          child: Row(
            children: [
              Icon(
                Icons.thumb_up_outlined, 
                size: 18, 
                color: userUpvoted ? AppTheme.success : AppTheme.success.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                '$upvotes',
                style: TextStyle(
                  color: userUpvoted ? AppTheme.success : AppTheme.success.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => _downvote(report['id']),
          child: Row(
            children: [
              Icon(
                Icons.thumb_down_outlined,
                size: 18,
                color: userDownvoted ? AppTheme.error : AppTheme.error.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                '$downvotes',
                style: TextStyle(
                  color: userDownvoted ? AppTheme.error : AppTheme.error.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          Icons.comment_outlined,
          '${Random().nextInt(20)}', // Mock comments
          AppTheme.info,
          () => _viewComments(report['id']),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _credibilityColor(Random().nextInt(100)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Credibility: ${Random().nextInt(100)}%',
            style: TextStyle(
              color: _credibilityColor(Random().nextInt(100)),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String count, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.slate100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined, 
                size: 48, 
                color: AppTheme.slate400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Community Posts Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.slate700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share a disaster report with the community!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.slate500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}