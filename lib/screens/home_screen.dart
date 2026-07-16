import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';
import '../services/location_weather_service.dart';
import '../widgets/alert_card.dart';
import '../widgets/disaster_card.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final Function(String)? onNavigate;
  
  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  late Future<List<Map<String, dynamic>>> _alerts;
  late Future<Map<String, dynamic>> _weatherSummary;
  late Future<List<dynamic>> _reports;

  @override
  void initState() {
    super.initState();
    _alerts = MockDataService.fetchAlerts();
    _weatherSummary = _loadRealWeather();
    _loadReports();
  }

  Future<Map<String, dynamic>> _loadRealWeather() async {
    try {
      final position = await LocationWeatherService.getCurrentPosition();
      return await LocationWeatherService.getWeather(
          position.latitude, position.longitude);
    } catch (_) {
      return MockDataService.fetchWeatherSummary();
    }
  }

  void _loadReports() {
    // Use centralized API service for consistent reports
    _reports = ApiService.getAllReports().then((reports) => 
      reports.map((report) => {
        'id': report['id'],
        'title': report['title'].length > 50 ? report['title'].substring(0, 50) + '...' : report['title'],
        'type': report['type'],
        'locationName': report['locationName'],
        'status': report['status'],
        'severity': report['severity'],
        'userName': report['userName'],
        'createdAt': report['createdAt'],
      }).toList()
    ).catchError((e) {
      print('Error loading reports: $e');
      return <Map<String, dynamic>>[];
    });
  }

  void _refreshData() {
    setState(() {
      _alerts = MockDataService.fetchAlerts();
      _weatherSummary = _loadRealWeather();
      _loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 768;
            final horizontalPadding = isTablet ? 32.0 : 20.0;
            
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: 16,
                bottom: 120, // Space for expandable bottom nav
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildMainWeatherCard(context, isTablet),
                  const SizedBox(height: 24),
                  _buildMetricsRow(context, isTablet),
                  const SizedBox(height: 32),
                  _buildQuickActions(context, isTablet),
                  const SizedBox(height: 32),
                  _buildRecentReports(context, isTablet),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (Navigator.canPop(context))
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF64748B)),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCurrentDateTime(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: AppTheme.primary,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMainWeatherCard(BuildContext context, bool isTablet) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _weatherSummary,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingWeatherCard(context, isTablet);
        }
        
        final weather = snapshot.data!;
        final now = DateTime.now();
        final hour = now.hour;
        final minute = now.minute.toString().padLeft(2, '0');
        final isPM = hour >= 12;
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        
        return Container(
          width: double.infinity,
          height: isTablet ? 440 : 420,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(60),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Beautiful sunset/sunrise gradient background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF0D47A1), // Deep blue top
                        Color(0xFF1565C0), // Blue
                        Color(0xFF42A5F5), // Light blue
                        Color(0xFFFFB74D), // Orange/yellow
                        Color(0xFFFF8A65), // Sunset orange
                      ],
                      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Sun/cloud decoration
                Positioned(
                  right: 20,
                  top: 60,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow.withAlpha(200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withAlpha(100),
                          blurRadius: 40,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                // Cloud decoration
                Positioned(
                  right: 60,
                  top: 80,
                  child: Icon(Icons.cloud, size: 60, color: Colors.white.withAlpha(200)),
                ),
                // Content overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withAlpha(40),
                        Colors.transparent,
                        Colors.black.withAlpha(60),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Main content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top: Location and wind
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            weather['city'] ?? 'Your Location',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.air, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '4.3mph SE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Date
                      Text(
                        _getFullDate(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
                        ),
                      ),
                      // Status info
                      Row(
                        children: [
                          _buildStatusChip('${weather['humidity']}%'),
                          const SizedBox(width: 8),
                          _buildStatusChip('SAT 07:45 AM'),
                          const SizedBox(width: 8),
                          _buildStatusChip('4.4G'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Large time display
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$displayHour:$minute',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 72 : 56,
                              fontWeight: FontWeight.w200,
                              letterSpacing: -2,
                              shadows: [Shadow(color: Colors.black38, blurRadius: 8)],
                            ),
                          ),
                          Text(
                            isPM ? 'PM' : 'AM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
                            ),
                          ),
                          const Spacer(),
                          // Temperature display
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${weather['temp']}°C',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w400,
                                      shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
                                    ),
                                  ),
                                  Text(' 7°\n 1°', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                ],
                              ),
                              Text('Feels like: ${weather['temp']}°C', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              Text(weather['condition'], style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                      // Weather details
                      Row(
                        children: [
                          Icon(Icons.water_drop, color: Colors.white70, size: 12),
                          Text(' ${weather['humidity']}%  ', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          Icon(Icons.speed, color: Colors.white70, size: 12),
                          Text(' 1013 hPa', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                      Text('Duration of day: 9.5Hr', style: TextStyle(color: Colors.white60, fontSize: 10)),
                      Text('Sunrise: 05:55AM    Sunset: 06:35PM', style: TextStyle(color: Colors.white60, fontSize: 10)),
                      const Spacer(),
                      // Forecast row
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.white24)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildForecastDay('FRI', Icons.wb_sunny, '10°/6°', Colors.yellow),
                            _buildForecastDay('SAT', Icons.cloud, '13°/8°', Colors.white),
                            _buildForecastDay('SUN', Icons.grain, '13°/5°', Colors.lightBlue),
                            _buildForecastDay('MON', Icons.thunderstorm, '10°/7°', Colors.amber),
                            _buildForecastDay('TUE', Icons.grain, '12°/9°', Colors.lightBlue),
                          ],
                        ),
                      ),
                      // Bottom info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('UV index: 5', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Row(
                            children: [
                              Text(_getUpdateTime(), style: TextStyle(color: Colors.white60, fontSize: 11)),
                              const SizedBox(width: 6),
                              Icon(Icons.refresh, color: Colors.white60, size: 14),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: Colors.white70, fontSize: 10)),
    );
  }

  Widget _buildForecastDay(String day, IconData icon, String temp, Color iconColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(day, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(height: 4),
        Text(temp, style: TextStyle(color: Colors.white, fontSize: 9)),
      ],
    );
  }

  String _getFullDate() {
    final now = DateTime.now();
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${days[now.weekday - 1]} ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  String _getUpdateTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${now.day}/${now.month} Updated';
  }

  Widget _buildLoadingWeatherCard(BuildContext context, bool isTablet) {
    return Container(
      width: double.infinity,
      height: isTablet ? 200 : 180,
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context, bool isTablet) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _weatherSummary,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingMetrics(context, isTablet);
        }
        
        final weather = snapshot.data!;
        final metrics = [
          {'label': 'Humidity', 'value': '${weather['humidity']}%', 'icon': Icons.water_drop_outlined},
          {'label': 'Wind', 'value': '12 km/h', 'icon': Icons.air},
          {'label': 'Pressure', 'value': '1013 hPa', 'icon': Icons.speed},
          {'label': 'UV Index', 'value': '3', 'icon': Icons.wb_sunny_outlined},
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            if (isTablet) {
              return Row(
                children: metrics.map((metric) => 
                  Expanded(child: _buildMetricCard(context, metric, isTablet))
                ).toList(),
              );
            } else {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard(context, metrics[0], isTablet)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard(context, metrics[1], isTablet)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard(context, metrics[2], isTablet)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard(context, metrics[3], isTablet)),
                    ],
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Widget _buildMetricCard(BuildContext context, Map<String, dynamic> metric, bool isTablet) {
    return Container(
      margin: isTablet ? const EdgeInsets.symmetric(horizontal: 6) : EdgeInsets.zero,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
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
        children: [
          Icon(
            metric['icon'],
            color: const Color(0xFF6366F1),
            size: isTablet ? 28 : 24,
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            metric['value'],
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric['label'],
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMetrics(BuildContext context, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemCount = isTablet ? 4 : 2;
        final rows = isTablet ? 1 : 2;
        
        return Column(
          children: List.generate(rows, (rowIndex) {
            return Column(
              children: [
                if (rowIndex > 0) const SizedBox(height: 12),
                Row(
                  children: List.generate(itemCount, (index) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: isTablet ? 6 : (index == 0 ? 0 : 6)),
                        height: isTablet ? 100 : 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isTablet) {
    final actions = [
      {
        'label': 'Report', 
        'icon': Icons.report_outlined, 
        'color': AppTheme.primary,
        'route': 'report'
      },
      {
        'label': 'Community', 
        'icon': Icons.forum_outlined, 
        'color': AppTheme.info,
        'route': 'community'
      },
      {
        'label': 'Map', 
        'icon': Icons.map_outlined, 
        'color': AppTheme.accent,
        'route': 'map'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Show more actions menu
                _showMoreActionsMenu(context);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.slate100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.more_horiz,
                  size: 20,
                  color: AppTheme.slate600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (isTablet) {
              return Row(
                children: actions.map((action) => 
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: _buildActionCard(context, action, isTablet),
                    ),
                  )
                ).toList(),
              );
            } else {
              return Row(
                children: actions.map((action) => 
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: action == actions.first ? 0 : 6),
                      child: _buildActionCard(context, action, isTablet),
                    ),
                  )
                ).toList(),
              );
            }
          },
        ),
      ],
    );
  }

  void _showMoreActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'More Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildMoreActionsList(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreActionsList(BuildContext context) {
    final moreActions = [
      {
        'icon': Icons.smart_toy,
        'title': 'AI Assistant',
        'subtitle': 'Get emergency guidance',
        'route': 'chatbot',
        'color': AppTheme.primary,
      },
      {
        'icon': Icons.phone,
        'title': 'Emergency Hotline',
        'subtitle': 'Call for immediate help',
        'route': 'hotline',
        'color': AppTheme.error,
      },
      {
        'icon': Icons.location_on,
        'title': 'Location Setup',
        'subtitle': 'Calibrate your location',
        'route': 'location',
        'color': AppTheme.success,
      },
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'subtitle': 'App preferences',
        'route': 'settings',
        'color': AppTheme.slate600,
      },
    ];

    return Column(
      children: moreActions.map((action) => _buildMoreActionTile(context, action)).toList(),
    );
  }

  Widget _buildMoreActionTile(BuildContext context, Map<String, dynamic> action) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // Navigate to the route
        _navigateToRoute(action['route']);
      },
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
                color: (action['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                action['icon'],
                color: action['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action['title'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    action['subtitle'],
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

  void _navigateToRoute(String route) {
    debugPrint('Navigating to: $route');
    
    if (widget.onNavigate != null) {
      widget.onNavigate!(route);
    } else {
      // Fallback navigation if no callback provided
      switch (route.toLowerCase()) {
        case 'report':
          Navigator.pushNamed(context, '/report');
          break;
        case 'map':
          Navigator.pushNamed(context, '/map');
          break;
        case 'community':
          Navigator.pushNamed(context, '/community');
          break;
        default:
          debugPrint('No navigation callback and unknown route: $route');
      }
    }
  }

  Widget _buildActionCard(BuildContext context, Map<String, dynamic> action, bool isTablet) {
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
      child: InkWell(
        onTap: () {
          // Enhanced tap feedback with haptics
          HapticFeedback.lightImpact();
          _navigateToRoute(action['route'] ?? action['label'].toString().toLowerCase());
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (action['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                action['icon'],
                color: action['color'],
                size: isTablet ? 28 : 24,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              action['label'],
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildRecentReports(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Reports',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: _refreshData,
              color: AppTheme.slate400,
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<dynamic>>(
          future: _reports,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard(height: 80);
            }
            
            if (snapshot.hasError) {
              return _buildEmptyState('Failed to load reports', Icons.error_outline);
            }
            
            final reports = snapshot.data ?? [];
            if (reports.isEmpty) {
              return _buildEmptyState('No reports yet', Icons.report_outlined);
            }
            
            final displayReports = reports.take(5).toList();
            return Column(
              children: displayReports.asMap().entries.map((entry) {
                final index = entry.key;
                final report = entry.value;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DisasterCard(
                    type: report['type'] ?? 'Unknown',
                    title: report['title'] ?? 'Untitled',
                    location: report['locationName'] ?? 'Unknown location',
                    status: report['status'] ?? 'PENDING',
                    onTap: () => _showReportDetails(context, reports, index),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingCard({double height = 100}) {
    return Container(
      height: height,
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
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return Container(
      height: 120,
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
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: const Color(0xFF94A3B8)),
            const SizedBox(height: 8),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  @override
  bool get wantKeepAlive => true;
}

  void _showReportDetails(BuildContext context, List<dynamic> reports, int initialIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Content
            Expanded(
              child: PageView.builder(
                controller: PageController(initialPage: initialIndex),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return _buildReportDetailPage(context, report);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportDetailPage(BuildContext context, Map<String, dynamic> report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getReportColor(report['type']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getReportIcon(report['type']),
                  color: _getReportColor(report['type']),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report['title'] ?? 'Emergency Report',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report['locationName'] ?? 'Unknown Location',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            report['description'] ?? 'No description available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          const SizedBox(height: 20),
          
          // Details
          _buildDetailItem('Type', report['type'] ?? 'Unknown'),
          _buildDetailItem('Status', report['status'] ?? 'Active'),
          _buildDetailItem('Severity', report['severity'] ?? 'Medium'),
          _buildDetailItem('Reported by', report['userName'] ?? 'Anonymous'),
          _buildDetailItem('Date', _formatDate(report['createdAt'])),
          
          // Media if available
          if (report['mediaUrls'] != null && (report['mediaUrls'] as List).isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Media',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (report['mediaUrls'] as List).length,
                itemBuilder: (context, index) {
                  final imageUrl = (report['mediaUrls'] as List)[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          
          const SizedBox(height: 40), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
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

  IconData _getReportIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'FLOOD':
        return Icons.water_drop;
      case 'EARTHQUAKE':
        return Icons.terrain;
      case 'FIRE':
        return Icons.local_fire_department;
      case 'LANDSLIDE':
        return Icons.landscape;
      default:
        return Icons.warning;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }