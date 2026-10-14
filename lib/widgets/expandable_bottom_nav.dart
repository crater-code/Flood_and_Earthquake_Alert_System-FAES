// lib/widgets/expandable_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class ExpandableBottomNav extends StatefulWidget {
  final Function(String) onNavigate;
  final String currentRoute;

  const ExpandableBottomNav({
    super.key,
    required this.onNavigate,
    required this.currentRoute,
  });

  @override
  State<ExpandableBottomNav> createState() => _ExpandableBottomNavState();
}

class _ExpandableBottomNavState extends State<ExpandableBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    // Handle swipe gestures - upward swipe expands, downward collapses
    // Use globalPosition for more reliable gesture detection
    if (details.delta.dy < -10) {
      // Swipe up to expand (sufficient upward movement)
      if (!_isExpanded) {
        _toggleExpansion();
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    // If velocity is downward and expanded, collapse
    if (_isExpanded && details.velocity.pixelsPerSecond.dy > 100) {
      _toggleExpansion();
    }
  }

  void _toggleExpansion() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final expandedHeight = screenHeight * 0.55;
    const collapsedHeight = 76.0;

    return GestureDetector(
      onVerticalDragUpdate: _handlePanUpdate,
      onVerticalDragEnd: _handlePanEnd,
      behavior: HitTestBehavior.translucent, // Allow gesture detection through children
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _isExpanded ? expandedHeight : collapsedHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary,
              const Color(0xFF1565C0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Column(
            children: [
              _buildCollapsedNav(),
              if (_isExpanded)
                Expanded(
                  child: _buildExpandedContent(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedNav() {
    final role = ApiService.currentRole ?? 'CITIZEN';
    final items = _getNavItems(role);
    const collapsedHeight = 76.0;
    
    return SizedBox(
      height: collapsedHeight,
      child: Column(
        children: [
          // Swipe indicator handle
          Container(
            margin: const EdgeInsets.only(top: 6, bottom: 2),
            height: 3,
            width: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Navigation items row
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: items.asMap().entries.map((entry) {
                  final item = entry.value;
                  final isSelected = item.route == widget.currentRoute;
                  
                  return Expanded(
                    child: _buildNavItem(item, isSelected),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(NavItem item, bool isSelected) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Fix: Prevent double navigation by checking current route
        if (widget.currentRoute != item.route) {
          HapticFeedback.selectionClick();
          widget.onNavigate(item.route);
        }
        // Auto-collapse drawer after navigation
        if (_isExpanded) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) _toggleExpansion();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.icon,
                size: isSelected ? 20 : 18,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 10 : 9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildExpandedContent() {
    final role = ApiService.currentRole ?? 'CITIZEN';
    final secondaryItems = _getSecondaryItems(role);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User header
            _buildUserHeader(),
            
            const SizedBox(height: 20),
            
            // Secondary navigation items
            Text(
              'More Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.slate800,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Secondary items in a grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: secondaryItems.length,
              itemBuilder: (context, index) {
                return _buildSecondaryItem(secondaryItems[index]);
              },
            ),
            
            const SizedBox(height: 20),
            
            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ApiService.logout();
                  widget.onNavigate('login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppTheme.error),
                  foregroundColor: AppTheme.error,
                ),
              ),
            ),
            
            const SizedBox(height: 16), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    final user = ApiService.currentUser;
    final role = ApiService.currentRole ?? 'CITIZEN';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.1),
            AppTheme.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primary,
            child: Text(
              (user?['name'] as String?)?.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?['name'] ?? 'Demo User',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.slate800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: role == 'NGO' ? AppTheme.primary : AppTheme.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role == 'NGO' ? 'NGO Organization' : 'Citizen',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              widget.onNavigate('profile');
              _toggleExpansion();
            },
            icon: const Icon(Icons.arrow_forward_ios),
            iconSize: 16,
            color: AppTheme.slate500,
          ),
        ],
      ),
    );
  }
  Widget _buildSecondaryItem(NavItem item) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onNavigate(item.route);
        _toggleExpansion();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.slate50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.slate200),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.slate700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<NavItem> _getNavItems(String role) {
    if (role == 'NGO') {
      return [
        NavItem(Icons.dashboard, 'Dashboard', 'ngo_dashboard'),
        NavItem(Icons.warning_amber, 'Reports', 'manage_reports'),
        NavItem(Icons.map, 'Map', 'map'),
        NavItem(Icons.people, 'Community', 'community'),
        NavItem(Icons.person, 'Profile', 'profile'),
      ];
    }
    return [
      NavItem(Icons.home, 'Home', 'home'),
      NavItem(Icons.add_alert, 'Report', 'report'),
      NavItem(Icons.map, 'Map', 'map'),
      NavItem(Icons.people, 'Community', 'community'),
      NavItem(Icons.person, 'Profile', 'profile'),
    ];
  }

  List<NavItem> _getSecondaryItems(String role) {
    if (role == 'NGO') {
      return [
        NavItem(Icons.inventory_2, 'Inventory', 'inventory'),
        NavItem(Icons.campaign, 'Post Updates', 'post_updates'),
        NavItem(Icons.analytics, 'Heatmaps', 'heatmaps'),
        NavItem(Icons.settings, 'Settings', 'settings'),
      ];
    }
    return [
      NavItem(Icons.article, 'My Posts', 'my_posts'),
      NavItem(Icons.smart_toy, 'AI Chatbot', 'chatbot'),
      NavItem(Icons.my_location, 'Location', 'location'),
      NavItem(Icons.phone, 'Hotlines', 'hotline'),
      NavItem(Icons.settings, 'Settings', 'settings'),
    ];
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final String route;

  NavItem(this.icon, this.label, this.route);
}