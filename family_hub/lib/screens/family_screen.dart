import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/avatar_view.dart';
import 'package:provider/provider.dart';
import '../providers/family_provider.dart';
import '../models/app_models.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final List<FamilyMember> _availableCandidates = [
    FamilyMember(
      id: 'u5',
      name: 'Mary Smith',
      avatarUrl: 'assets/avatars/sarah.svg',
      relationLabel: 'Grandmother',
      isCloseFamily: true,
    ),
    FamilyMember(
      id: 'u6',
      name: 'Jamie Lee',
      avatarUrl: 'assets/avatars/alex.svg',
      relationLabel: 'Friend',
      isCloseFamily: false,
    ),
  ];

  final List<String> _relationOptions = [
    'Mother',
    'Father',
    'Daughter',
    'Son',
    'Sister',
    'Brother',
    'Wife',
    'Husband',
    'Grandmother',
    'Grandfather',
    'Friend',
  ];

  @override
  Widget build(BuildContext context) {
    final familyData = Provider.of<FamilyProvider>(context);
    final closeFamily = familyData.members.where((m) => m.isCloseFamily).toList();
    final friends = familyData.members.where((m) => !m.isCloseFamily).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: SvgPicture.asset(
                'assets/covers/group_cover.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(
            context,
            title: 'Close Family (${closeFamily.length})',
            badgeText: 'SOS Enabled',
            badgeColor: Colors.red.shade50,
            badgeTextColor: Colors.red.shade700,
          ),
          const SizedBox(height: 8),
          Text(
            'Close family members will receive SOS emergency alerts.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          ...closeFamily.map((member) => _FamilyMemberCard(
                member: member,
                onEdit: () => _openEditDialog(context, familyData, member),
                onRemove: () => _removeMember(context, familyData, member),
              )),
          const SizedBox(height: 24),
          _buildSectionHeader(
            context,
            title: 'Friends & Extended Family (${friends.length})',
          ),
          const SizedBox(height: 12),
          ...friends.map((member) => _FamilyMemberCard(
                member: member,
                onEdit: () => _openEditDialog(context, familyData, member),
                onRemove: () => _removeMember(context, familyData, member),
              )),
          const SizedBox(height: 20),
          if (_availableCandidates.isNotEmpty)
            FilledButton.icon(
              onPressed: () => _openAddDialog(context, familyData),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Family Member or Friend'),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? badgeText,
    Color? badgeColor,
    Color? badgeTextColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (badgeText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor ?? Colors.grey.shade200,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeTextColor ?? Colors.grey.shade700,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  void _openEditDialog(BuildContext context, FamilyProvider provider, FamilyMember member) {
    String relation = member.relationLabel;
    bool isClose = member.isCloseFamily;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Edit Relationship'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: relation,
                  decoration: const InputDecoration(labelText: 'Relationship Type'),
                  items: _relationOptions
                      .map((option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setModalState(() => relation = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Close Family (SOS enabled)'),
                  value: isClose,
                  onChanged: (value) => setModalState(() => isClose = value),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  provider.updateRelationship(member.id, relation, isClose);
                  Navigator.pop(context);
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openAddDialog(BuildContext context, FamilyProvider provider) {
    FamilyMember? selected;
    String relation = _relationOptions.first;
    bool isClose = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final available = _availableCandidates
              .where((candidate) => !provider.members.any((member) => member.id == candidate.id))
              .toList();

          return AlertDialog(
            title: const Text('Add Family Member or Friend'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<FamilyMember>(
                  initialValue: selected,
                  decoration: const InputDecoration(labelText: 'Select Person'),
                  items: available
                      .map((member) => DropdownMenuItem(
                            value: member,
                            child: Text(member.name),
                          ))
                      .toList(),
                  onChanged: (value) => setModalState(() => selected = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: relation,
                  decoration: const InputDecoration(labelText: 'Relationship Type'),
                  items: _relationOptions
                      .map((option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setModalState(() => relation = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Close Family (SOS enabled)'),
                  value: isClose,
                  onChanged: (value) => setModalState(() => isClose = value),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: selected == null
                    ? null
                    : () {
                        provider.addFamilyMember(
                          FamilyMember(
                            id: selected!.id,
                            name: selected!.name,
                            avatarUrl: selected!.avatarUrl,
                            relationLabel: relation,
                            isCloseFamily: isClose,
                            status: selected!.status,
                            lastUpdated: selected!.lastUpdated,
                          ),
                        );
                        Navigator.pop(context);
                      },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _removeMember(BuildContext context, FamilyProvider provider, FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Relationship'),
        content: Text('Remove ${member.name} from your family list?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              provider.removeFamilyMember(member.id);
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  const _FamilyMemberCard({
    required this.member,
    this.onEdit,
    this.onRemove,
  });

  String _statusLabel(SafetyStatus status) {
    switch (status) {
      case SafetyStatus.safe:
        return 'Safe';
      case SafetyStatus.away:
        return 'Away';
      case SafetyStatus.sos:
        return 'SOS';
      case SafetyStatus.unknown:
        return 'Unknown';
    }
  }

  Color _statusColor(BuildContext context, SafetyStatus status) {
    switch (status) {
      case SafetyStatus.safe:
        return Colors.green;
      case SafetyStatus.away:
        return Colors.orange;
      case SafetyStatus.sos:
        return Theme.of(context).colorScheme.error;
      case SafetyStatus.unknown:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context, member.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarView(
              avatarUrl: member.avatarUrl,
              fallbackInitial: member.name[0],
              radius: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          member.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _statusLabel(member.status),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _chip(member.relationLabel, Theme.of(context).colorScheme.primaryContainer),
                      if (member.isCloseFamily)
                        _chip('SOS Enabled', Colors.red.shade50, textColor: Colors.red.shade700),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    member.lastUpdated == null
                        ? 'Last updated: not available'
                        : 'Last updated: ${member.lastUpdated}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Call ${member.name} (placeholder).')),
                          );
                        },
                        icon: const Icon(Icons.call, size: 16),
                        label: const Text('Call'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Message ${member.name} (placeholder).')),
                          );
                        },
                        icon: const Icon(Icons.message, size: 16),
                        label: const Text('Message'),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                      ),
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete_outline, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Open in',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _appShortcut(
                        context,
                        label: 'WhatsApp',
                        icon: FontAwesomeIcons.whatsapp,
                        iconColor: const Color(0xFF25D366),
                      ),
                      _appShortcut(
                        context,
                        label: 'Telegram',
                        icon: FontAwesomeIcons.telegram,
                        iconColor: const Color(0xFF229ED9),
                      ),
                      _appShortcut(
                        context,
                        label: 'Messenger',
                        icon: FontAwesomeIcons.facebookMessenger,
                        iconColor: const Color(0xFF1877F2),
                      ),
                      _appShortcut(
                        context,
                        label: 'Instagram',
                        icon: FontAwesomeIcons.instagram,
                        iconColor: const Color(0xFFE1306C),
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
  }

  Widget _chip(String label, Color background, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }

  Widget _appShortcut(
    BuildContext context, {
    required String label,
    required IconData icon,
    Color? iconColor,
  }) {
    return OutlinedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open $label for ${member.name} (placeholder).')),
        );
      },
      icon: Icon(icon, size: 16, color: iconColor),
      label: Text(label),
    );
  }
}
