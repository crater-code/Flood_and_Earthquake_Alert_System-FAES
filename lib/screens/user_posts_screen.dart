// lib/screens/user_posts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class UserPostsScreen extends StatefulWidget {
  const UserPostsScreen({super.key});

  @override
  State<UserPostsScreen> createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends State<UserPostsScreen> with AutomaticKeepAliveClientMixin {
  late Future<List<dynamic>> _userPosts;

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  void _loadUserPosts() {
    _userPosts = ApiService.getAllReports().then((reports) {
      // Filter to only user's posts (those by current user)
      final currentUser = ApiService.currentUser;
      final userName = currentUser?['name'] ?? 'User';
      
      return reports.where((report) {
        return report['userName'] == userName;
      }).toList();
    }).catchError((e) {
      print('Error loading posts: $e');
      return <Map<String, dynamic>>[];
    });
  }

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 30) return '${d.inDays}d ago';
    return '${d.inDays ~/ 30}mo ago';
  }

  void _deletePost(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _loadUserPosts();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Post deleted successfully'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editPost(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEditModal(context, post),
    );
  }

  Widget _buildEditModal(BuildContext context, Map<String, dynamic> post) {
    final titleController = TextEditingController(text: post['title']);
    final descriptionController = TextEditingController(text: post['description']);

    return Container(
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
                  'Edit Post',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Title',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter post title...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Enter post description...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Status: ${post['status']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${post['type']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Post updated successfully'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  },
                  child: const Text('Save Changes'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
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
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text('My Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadUserPosts();
              });
            },
          ),
        ],
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _userPosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return _buildEmptyState(context);
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
                      bottom: 120,
                    ),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => _buildPostCard(context, posts[index]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> post) {
    final createdAt = DateTime.parse(post['createdAt'] ?? DateTime.now().toIso8601String());

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with options menu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'] ?? 'Untitled Post',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(post['status']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              post['status'] ?? 'PENDING',
                              style: TextStyle(
                                color: _getStatusColor(post['status']),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getReportColor(post['type']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              post['type'] ?? 'Report',
                              style: TextStyle(
                                color: _getReportColor(post['type']),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _timeAgo(createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 18),
                          const SizedBox(width: 12),
                          const Text('Edit'),
                        ],
                      ),
                      onTap: () {
                        Future.delayed(
                          const Duration(milliseconds: 100),
                          () => _editPost(post),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                          const SizedBox(width: 12),
                          const Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () {
                        Future.delayed(
                          const Duration(milliseconds: 100),
                          () => _deletePost(post['id']),
                        );
                      },
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, size: 20),
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post['description'] ?? 'No description',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Location
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  post['locationName'] ?? 'Unknown Location',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(Icons.visibility, '234', 'Views'),
                _buildStat(Icons.thumb_up, '45', 'Upvotes'),
                _buildStat(Icons.comment, '12', 'Comments'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String count, String label) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                Icons.article_outlined,
                size: 48,
                color: AppTheme.slate400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Posts Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.slate700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your disaster reports will appear here once you submit them.',
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

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'RESOLVED':
        return AppTheme.success;
      case 'IN_PROGRESS':
        return AppTheme.warning;
      case 'PENDING':
        return AppTheme.info;
      default:
        return Colors.grey;
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

  @override
  bool get wantKeepAlive => true;
}
