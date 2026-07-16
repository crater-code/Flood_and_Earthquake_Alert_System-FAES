import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/location_weather_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _loading = true;
  String _error = '';

  // Use Islamabad as default center instead of generic Pakistan coordinates
  LatLng _center = const LatLng(33.7294, 73.0931); // Islamabad center

  @override
  void initState() {
    super.initState();
    // If we already have a position from a previous screen, use it immediately
    if (LocationWeatherService.lastPosition != null) {
      final p = LocationWeatherService.lastPosition!;
      _center = LatLng(p.latitude, p.longitude);
      _currentPosition = p;
      _loading = false;
    }
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final position = await LocationWeatherService.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _center = LatLng(position.latitude, position.longitude);
          _loading = false;
        });
        _mapController.move(_center, 14);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getAllReports(),
      builder: (context, snapshot) {
        final reports = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, size: 20),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            title: const Text('Disaster Map'),
            backgroundColor: AppTheme.background,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: _fetchLocation,
                tooltip: 'Center on my location',
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Map
                Expanded(
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _center,
                          initialZoom: 13,
                        ),
                        children: [
                          // OpenStreetMap tile layer
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.example.flood_quake_frontend',
                          ),
                          // Mock disaster report markers
                          MarkerLayer(
                            markers: [
                              // Current location marker
                              if (_currentPosition != null)
                                Marker(
                                  point: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  ),
                                  width: 40,
                                  height: 40,
                                  child: _buildMyLocationMarker(),
                                ),
                              // Real disaster markers from API service
                              ...reports.map<Marker>((report) {
                                final lat = report['latitude']?.toDouble() ?? 24.8607;
                                final lng = report['longitude']?.toDouble() ?? 67.2057;
                                final isFlood = report['type']?.toUpperCase() == 'FLOOD';
                                final isEarthquake = report['type']?.toUpperCase() == 'EARTHQUAKE';
                                final isFire = report['type']?.toUpperCase() == 'FIRE';
                                final isLandslide = report['type']?.toUpperCase() == 'LANDSLIDE';
                                
                                Color markerColor;
                                IconData markerIcon;
                                
                                if (isFlood) {
                                  markerColor = Colors.blue;
                                  markerIcon = Icons.water_drop;
                                } else if (isEarthquake) {
                                  markerColor = Colors.orange;
                                  markerIcon = Icons.terrain;
                                } else if (isFire) {
                                  markerColor = Colors.red;
                                  markerIcon = Icons.local_fire_department;
                                } else if (isLandslide) {
                                  markerColor = Colors.brown;
                                  markerIcon = Icons.landscape;
                                } else {
                                  markerColor = Colors.purple;
                                  markerIcon = Icons.warning;
                                }
                                
                                return Marker(
                                  point: LatLng(lat, lng),
                                  width: 36,
                                  height: 36,
                                  child: GestureDetector(
                                    onTap: () => _showReportDetails(context, report),
                                    child: _buildDisasterMarker(markerColor, markerIcon),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ],
                      ),
                      // Loading overlay
                      if (_loading)
                        Container(
                          color: Colors.black26,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      // Error banner
                      if (_error.isNotEmpty)
                        Positioned(
                          top: 8,
                          left: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _error,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      // Legend
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: _buildLegend(),
                      ),
                    ],
                  ),
                ),
                // Report cards at bottom
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: reports.length,
                    itemBuilder: (context, i) => _buildReportCard(context, reports[i], i),
                  ),
                ),
                const SizedBox(height: 65), // bottom nav space
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyLocationMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 8, spreadRadius: 4),
        ],
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 20),
    );
  }

  Widget _buildDisasterMarker(Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, spreadRadius: 2),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _legendItem(Colors.blue, Icons.person, 'You'),
          const SizedBox(height: 4),
          _legendItem(Colors.blue, Icons.water_drop, 'Flood'),
          const SizedBox(height: 4),
          _legendItem(Colors.orange, Icons.terrain, 'Earthquake'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildReportCard(BuildContext context, Map<String, dynamic> report, int i) {
    final type = report['type']?.toString().toUpperCase();
    final isFlood = type == 'FLOOD';
    final isEarthquake = type == 'EARTHQUAKE';
    final isFire = type == 'FIRE';
    
    Color color;
    IconData icon;
    
    if (isFlood) {
      color = AppTheme.info;
      icon = Icons.water_drop;
    } else if (isEarthquake) {
      color = AppTheme.warning;
      icon = Icons.terrain;
    } else if (isFire) {
      color = AppTheme.error;
      icon = Icons.local_fire_department;
    } else {
      color = AppTheme.accent;
      icon = Icons.warning;
    }

    return GestureDetector(
      onTap: () => _showReportDetails(context, report),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    report['type'] ?? 'Unknown',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: color, fontSize: 13),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    report['severity'] ?? 'Medium',
                    style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              report['description'] ?? report['title'] ?? 'No description',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.location_on, size: 11, color: Color(0xFF94A3B8)),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    report['locationName'] ?? 'Unknown Location',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDetails(BuildContext context, Map<String, dynamic> report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
              child: SingleChildScrollView(
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
                    _buildDetailItem('Location', '${report['latitude']?.toStringAsFixed(4) ?? '0.0000'}, ${report['longitude']?.toStringAsFixed(4) ?? '0.0000'}'),
                    
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
                  ],
                ),
              ),
            ),
          ],
        ),
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
}
