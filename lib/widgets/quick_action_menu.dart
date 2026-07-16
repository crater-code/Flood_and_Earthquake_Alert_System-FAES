import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class QuickActionMenu extends StatefulWidget {
  final Function(String)? onNavigate;

  const QuickActionMenu({
    super.key,
    this.onNavigate,
  });

  @override
  State<QuickActionMenu> createState() => _QuickActionMenuState();
}

class _QuickActionMenuState extends State<QuickActionMenu> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isVisible = !_isVisible;
      if (_isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _onActionTap(String route) {
    HapticFeedback.lightImpact();
    _toggleMenu();
    
    // Small delay for animation
    Future.delayed(const Duration(milliseconds: 200), () {
      widget.onNavigate?.call(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isNGO = ApiService.currentRole == 'NGO';
    
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Backdrop
        if (_isVisible)
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        
        // Quick actions grid
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              alignment: Alignment.bottomCenter,
              child: Visibility(
                visible: _isVisible,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isNGO ? 'NGO Actions' : 'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.slate800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildActionGrid(isNGO),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Floating Action Button
        Positioned(
          bottom: 80,
          child: GestureDetector(
            onTap: _toggleMenu,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isVisible
                      ? [AppTheme.error, AppTheme.error.withOpacity(0.8)]
                      : [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isVisible ? AppTheme.error : AppTheme.primary)
                        .withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: AnimatedRotation(
                turns: _isVisible ? 0.125 : 0.0, // 45 degrees when open
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _isVisible ? Icons.close : Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid(bool isNGO) {
    final actions = isNGO ? _getNGOActions() : _getCitizenActions();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionItem(action);
      },
    );
  }

  Widget _buildActionItem(QuickAction action) {
    return GestureDetector(
      onTap: () => _onActionTap(action.route),
      child: Container(
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: action.color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                action.icon,
                color: action.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: action.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  List<QuickAction> _getCitizenActions() {
    return [
      QuickAction(
        icon: Icons.report,
        label: 'Report\nDisaster',
        route: 'report',
        color: AppTheme.error,
      ),
      QuickAction(
        icon: Icons.map,
        label: 'View\nMap',
        route: 'map',
        color: AppTheme.info,
      ),
      QuickAction(
        icon: Icons.forum,
        label: 'Community',
        route: 'community',
        color: AppTheme.primary,
      ),
      QuickAction(
        icon: Icons.smart_toy,
        label: 'AI\nAssistant',
        route: 'chatbot',
        color: AppTheme.accent,
      ),
      QuickAction(
        icon: Icons.phone,
        label: 'Emergency\nHotline',
        route: 'hotline',
        color: AppTheme.error,
      ),
      QuickAction(
        icon: Icons.location_on,
        label: 'Location\nSetup',
        route: 'location',
        color: AppTheme.success,
      ),
    ];
  }

  List<QuickAction> _getNGOActions() {
    return [
      QuickAction(
        icon: Icons.dashboard,
        label: 'NGO\nDashboard',
        route: 'ngo_dashboard',
        color: AppTheme.primary,
      ),
      QuickAction(
        icon: Icons.assignment,
        label: 'Manage\nReports',
        route: 'manage_reports',
        color: AppTheme.info,
      ),
      QuickAction(
        icon: Icons.inventory,
        label: 'Inventory',
        route: 'inventory',
        color: AppTheme.success,
      ),
      QuickAction(
        icon: Icons.campaign,
        label: 'Post\nUpdate',
        route: 'post_updates',
        color: AppTheme.accent,
      ),
      QuickAction(
        icon: Icons.forum,
        label: 'Community',
        route: 'community',
        color: AppTheme.warning,
      ),
      QuickAction(
        icon: Icons.analytics,
        label: 'Heat\nMaps',
        route: 'heatmaps',
        color: AppTheme.error,
      ),
    ];
  }
}

class QuickAction {
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  QuickAction({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });
}

// Enhanced navigation helper for better transitions
class SmartNavigationHelper {
  static void navigateWithTransition(
    BuildContext context,
    Widget destination, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: duration,
      ),
    );
  }

  static void showBottomSheetNavigation(BuildContext context) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
            Expanded(
              child: QuickActionMenu(),
            ),
          ],
        ),
      ),
    );
  }
}