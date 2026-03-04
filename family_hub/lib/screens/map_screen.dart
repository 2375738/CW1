import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/family_provider.dart';
import '../models/app_models.dart';
import '../widgets/avatar_view.dart';
import '../utils/external_actions.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Default center for Swansea area.
  final LatLng _defaultCenter = const LatLng(51.6214, -3.9436);
  final MapController _mapController = MapController();
  String? _focusedSosInitiatorId;

  @override
  Widget build(BuildContext context) {
    final familyData = Provider.of<FamilyProvider>(context);
    final resolvedLocations = _resolveLocations(familyData);
    final resolvedById = <String, _ResolvedLocation>{
      for (final resolved in resolvedLocations) resolved.member.id: resolved,
    };
    final currentUserResolved = resolvedById[familyData.currentUser.id];
    final currentUserLocation = currentUserResolved?.coordinates ?? _defaultCenter;

    final sosInitiator = _findSosInitiator(familyData);
    final sosInitiatorResolved = sosInitiator == null ? null : resolvedById[sosInitiator.id];
    final sosInitiatorId = sosInitiator?.id;
    final isRecipientSosView = familyData.isSosActive &&
        sosInitiator != null &&
        sosInitiator.id != familyData.currentUser.id;
    final sosInitiatorLocation = sosInitiatorResolved?.coordinates;
    _maybeFocusSosInitiator(
      initiator: sosInitiator,
      location: sosInitiatorLocation,
      isRecipientSosView: isRecipientSosView,
    );

    final isCurrentUserSosActive = familyData.isSosActive &&
        sosInitiator != null &&
        sosInitiator.id == familyData.currentUser.id;

    final familyResolved = _orderedResolvedMembersForList(
      resolvedLocations,
      currentUserId: familyData.currentUser.id,
      initiatorId: sosInitiatorId,
    );
    final sharingMembers = familyResolved.where((location) => location.isSharing).length;
    final sharingCount = familyData.isSharingLocation ? sharingMembers + 1 : 0;
    final showFamilyMarkers = familyData.isSharingLocation || isRecipientSosView || isCurrentUserSosActive;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (isRecipientSosView) ...[
              _buildSosAlertBanner(
                context,
                sosInitiator,
                latitude: sosInitiatorLocation?.latitude,
                longitude: sosInitiatorLocation?.longitude,
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Location', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        'See where your family members are in real-time',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 14),
                      const SizedBox(width: 6),
                      Text('$sharingCount sharing', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 240,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: currentUserLocation,
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.familyhub.app',
                    ),
                    if (showFamilyMarkers) ...[
                      MarkerLayer(
                        markers: familyResolved.map((resolved) {
                          final loc = resolved.coordinates;
                          if (loc == null) return null;
                          final shouldShowMarker = resolved.isSharing ||
                              (isRecipientSosView && resolved.member.id == sosInitiatorId);
                          if (!shouldShowMarker) return null;
                          final isSosInitiator = isRecipientSosView && resolved.member.id == sosInitiatorId;
                          return Marker(
                            point: loc,
                            width: isSosInitiator ? 120 : 52,
                            height: isSosInitiator ? 120 : 64,
                            alignment: isSosInitiator ? Alignment.center : Alignment.topCenter,
                            child: isSosInitiator
                                ? _SosPulsingAvatar(
                                    avatarUrl: resolved.member.avatarUrl,
                                    fallbackInitial: resolved.member.name[0],
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
                                        ),
                                        child: AvatarView(
                                          avatarUrl: resolved.member.avatarUrl,
                                          fallbackInitial: resolved.member.name[0],
                                          radius: 16,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down, size: 20, color: Colors.black),
                                    ],
                                  ),
                          );
                        }).whereType<Marker>().toList(),
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: currentUserLocation,
                            width: isCurrentUserSosActive ? 120 : 52,
                            height: isCurrentUserSosActive ? 120 : 64,
                            alignment: isCurrentUserSosActive ? Alignment.center : Alignment.topCenter,
                            child: isCurrentUserSosActive
                                ? _SosPulsingAvatar(
                                    avatarUrl: familyData.currentUser.avatarUrl,
                                    fallbackInitial: familyData.currentUser.name[0],
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
                                        ),
                                        child: AvatarView(
                                          avatarUrl: familyData.currentUser.avatarUrl,
                                          fallbackInitial: familyData.currentUser.name[0],
                                          radius: 16,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down, size: 20, color: Colors.black),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Your Location', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Your Location',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: familyData.isSharingLocation ? Colors.green.shade50 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            familyData.isSharingLocation ? 'Sharing' : 'Off',
                            style: TextStyle(
                              color: familyData.isSharingLocation ? Colors.green.shade700 : Colors.grey.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: familyData.isSharingLocation,
                          onChanged: (value) {
                            if (value) {
                              _showShareDurationDialog(context);
                            } else {
                              familyData.toggleLocationSharing(false);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      familyData.isSharingLocation
                          ? 'Your family can see your location'
                          : 'Turn on to share your location',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => familyData.startLocationSharing(
                            const Duration(hours: 1),
                            'Sharing for 1 hour',
                          ),
                          icon: const Icon(Icons.timer_outlined, size: 14),
                          label: const Text('1 hour'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => familyData.startLocationSharing(
                            const Duration(hours: 4),
                            'Sharing for 4 hours',
                          ),
                          icon: const Icon(Icons.timer_outlined, size: 14),
                          label: const Text('4 hours'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => familyData.startLocationSharing(
                            null,
                            'Sharing until end of day',
                          ),
                          icon: const Icon(Icons.timer_outlined, size: 14),
                          label: const Text('All day'),
                        ),
                      ],
                    ),
                    if (familyData.isSharingLocation && familyData.sharingDurationLabel != 'Off') ...[
                      const SizedBox(height: 8),
                      Text(
                        familyData.sharingDurationLabel,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Privacy first: location sharing is optional and time-limited. You control when and how long you share.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Family Locations', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (!familyData.isSharingLocation)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.privacy_tip_outlined, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(child: Text("Share your location to see others on the map.", style: TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            ...familyResolved.map<Widget>((resolved) {
              final sharing = familyData.isSharingLocation && resolved.isSharing;
              final isSosInitiator = isRecipientSosView && resolved.member.id == sosInitiatorId;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                leading: AvatarView(
                  avatarUrl: resolved.member.avatarUrl,
                  fallbackInitial: resolved.member.name[0],
                  radius: 22,
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(resolved.member.name)),
                    if (isSosInitiator)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _BlinkingDot(color: Colors.red.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'SOS Active',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (resolved.member.relationLabel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(resolved.member.relationLabel, style: const TextStyle(fontSize: 10)),
                      ),
                  ],
                ),
                subtitle: sharing
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('${resolved.locationLabel ?? 'Unknown'} • ${resolved.locationAddress ?? ''}'),
                          const SizedBox(height: 2),
                          Text(_formatLastUpdated(resolved.lastUpdated)),
                          if (resolved.sharingUntil != null)
                            Text('Until ${_formatUntil(resolved.sharingUntil!)}'),
                        ],
                      )
                    : const Text('Location sharing disabled'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: sharing ? Colors.green : Colors.grey,
                    ),
                    IconButton(
                      icon: const Icon(Icons.navigation_outlined),
                      onPressed: sharing
                          ? () => ExternalActions.navigateToMember(
                                context,
                                resolved.member,
                                latitude: resolved.coordinates?.latitude,
                                longitude: resolved.coordinates?.longitude,
                              )
                          : null,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showShareDurationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Share Location", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text("Choose how long to share your real-time location with family."),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text("For 1 Hour"),
                  onTap: () {
                    Provider.of<FamilyProvider>(context, listen: false)
                        .startLocationSharing(const Duration(hours: 1), 'Sharing for 1 hour');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text("For 4 Hours"),
                  onTap: () {
                    Provider.of<FamilyProvider>(context, listen: false)
                        .startLocationSharing(const Duration(hours: 4), 'Sharing for 4 hours');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.all_inclusive),
                  title: const Text("All Day"),
                  onTap: () {
                    Provider.of<FamilyProvider>(context, listen: false)
                        .startLocationSharing(null, 'Sharing until end of day');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatLastUpdated(DateTime? lastUpdated) {
    if (lastUpdated == null) return 'Last updated: unknown';
    final difference = DateTime.now().difference(lastUpdated);
    if (difference.inMinutes < 1) {
      return 'Updated just now';
    }
    if (difference.inMinutes < 60) {
      return 'Updated ${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return 'Updated ${difference.inHours}h ago';
    }
    return 'Updated ${difference.inDays}d ago';
  }

  String _formatUntil(DateTime time) {
    final formatted = TimeOfDay.fromDateTime(time).format(context);
    return formatted;
  }

  FamilyMember? _findSosInitiator(FamilyProvider familyData) {
    final initiatorId = familyData.sosInitiatorId;
    if (initiatorId == null) return null;
    final allMembers = [familyData.currentUser, ...familyData.members];
    for (final member in allMembers) {
      if (member.id == initiatorId) {
        return member;
      }
    }
    return null;
  }

  List<_ResolvedLocation> _resolveLocations(FamilyProvider familyData) {
    final coordinatesByMemberId = <String, LatLng>{
      'u1': const LatLng(51.6214, -3.9436), // Dad
      'u2': const LatLng(51.618804, -3.879423), // Mom
      'u3': const LatLng(51.615183, -3.943576), // Alex
    };
    final allMembers = [familyData.currentUser, ...familyData.members];
    return allMembers.map((member) {
      final coordinates = coordinatesByMemberId[member.id];
      final locationLabel = member.locationLabel;
      final locationAddress = member.locationAddress;
      final hasLocation = coordinates != null && locationLabel != null;
      return _ResolvedLocation(
        member: member,
        coordinates: coordinates,
        locationLabel: locationLabel,
        locationAddress: locationAddress,
        lastUpdated: member.lastUpdated,
        sharingUntil: member.sharingUntil,
        isSharing: hasLocation,
      );
    }).toList();
  }

  List<_ResolvedLocation> _orderedResolvedMembersForList(
    List<_ResolvedLocation> resolvedLocations, {
    required String currentUserId,
    required String? initiatorId,
  }) {
    final familyOnly = resolvedLocations.where((location) => location.member.id != currentUserId).toList();
    if (initiatorId == null) return familyOnly;
    familyOnly.sort((a, b) {
      if (a.member.id == initiatorId) return -1;
      if (b.member.id == initiatorId) return 1;
      return 0;
    });
    return familyOnly;
  }

  void _maybeFocusSosInitiator({
    required FamilyMember? initiator,
    required LatLng? location,
    required bool isRecipientSosView,
  }) {
    if (!isRecipientSosView || initiator == null || location == null) {
      _focusedSosInitiatorId = null;
      return;
    }
    if (_focusedSosInitiatorId == initiator.id) return;
    _focusedSosInitiatorId = initiator.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(location, 15.0);
    });
  }

  Widget _buildSosAlertBanner(
    BuildContext context,
    FamilyMember initiator, {
    double? latitude,
    double? longitude,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Emergency SOS from ${initiator.name}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade800,
                  ),
                ),
              ),
              _BlinkingDot(color: Colors.red.shade700),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ExternalActions.callMember(context, initiator),
                  icon: const Icon(Icons.call, size: 16),
                  label: Text('Call ${initiator.name}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => ExternalActions.navigateToMember(
                    context,
                    initiator,
                    latitude: latitude,
                    longitude: longitude,
                  ),
                  icon: const Icon(Icons.navigation_outlined, size: 16),
                  label: const Text('Navigate'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SosPulsingAvatar extends StatefulWidget {
  final String avatarUrl;
  final String fallbackInitial;

  const _SosPulsingAvatar({
    required this.avatarUrl,
    required this.fallbackInitial,
  });

  @override
  State<_SosPulsingAvatar> createState() => _SosPulsingAvatarState();
}

class _SosPulsingAvatarState extends State<_SosPulsingAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Outer Ripple 1
            Container(
              width: 40 + (_controller.value * 60),
              height: 40 + (_controller.value * 60),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.withValues(alpha: 1.0 - _controller.value),
                  width: 2,
                ),
                color: Colors.red.withValues(alpha: (1.0 - _controller.value) * 0.2),
              ),
            ),
            // Outer Ripple 2 (delayed)
            if (_controller.value > 0.3)
              Container(
                width: 40 + ((_controller.value - 0.3) * 60),
                height: 40 + ((_controller.value - 0.3) * 60),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 1.0 - ((_controller.value - 0.3) / 0.7)),
                    width: 2,
                  ),
                  color: Colors.red.withValues(alpha: (1.0 - ((_controller.value - 0.3) / 0.7)) * 0.1),
                ),
              ),
            // Avatar
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.shade700, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: AvatarView(
                avatarUrl: widget.avatarUrl,
                fallbackInitial: widget.fallbackInitial,
                radius: 18,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  final Color color;

  const _BlinkingDot({required this.color});

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ResolvedLocation {
  final FamilyMember member;
  final LatLng? coordinates;
  final String? locationLabel;
  final String? locationAddress;
  final DateTime? lastUpdated;
  final DateTime? sharingUntil;
  final bool isSharing;

  const _ResolvedLocation({
    required this.member,
    required this.coordinates,
    required this.locationLabel,
    required this.locationAddress,
    required this.lastUpdated,
    required this.sharingUntil,
    required this.isSharing,
  });
}
