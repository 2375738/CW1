import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _locationSharing = false;
  bool _preciseLocation = false;
  bool _sosLocation = true;
  bool _shareLastSeen = true;

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Control what you share and when.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Location sharing'),
                    subtitle: const Text('Share your location with family.'),
                    value: _locationSharing,
                    onChanged: (value) => setState(() => _locationSharing = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Precise location'),
                    subtitle: const Text('Use GPS accuracy when sharing.'),
                    value: _preciseLocation,
                    onChanged: (value) => setState(() => _preciseLocation = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show last updated time'),
                    subtitle: const Text('Display when your location was last refreshed.'),
                    value: _shareLastSeen,
                    onChanged: (value) => setState(() => _shareLastSeen = value),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Share duration'),
                    subtitle: const Text('Off · 1 hour · Until end of day'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share duration picker placeholder.')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Safety',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Include location in SOS'),
                    subtitle: const Text('Attach your last known location in alerts.'),
                    value: _sosLocation,
                    onChanged: (value) => setState(() => _sosLocation = value),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Trusted contacts'),
                    subtitle: const Text('Manage who receives SOS alerts.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Trusted contacts placeholder.')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            child: Column(
              children: [
                ListTile(
                  title: const Text('App permissions'),
                  subtitle: const Text('Review camera, location, and notifications.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Permissions overview placeholder.')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Delete location history'),
                  subtitle: const Text('Remove saved location entries.'),
                  trailing: const Icon(Icons.delete_outline),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Delete history placeholder.')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'You can use FamilyHub without sharing your location.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
