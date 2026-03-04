import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/family_provider.dart';
import '../models/app_models.dart';
import '../widgets/avatar_view.dart';
import '../utils/external_actions.dart';

enum SosStatus { idle, activating, sending, sent, failed }

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  SosStatus _status = SosStatus.idle;
  Timer? _vibrationTimer;
  final List<String> _notifiedMemberIds = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _triggerSos();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _vibrationTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final family = Provider.of<FamilyProvider>(context, listen: false);
    if (_status == SosStatus.idle && family.isSosActive && family.sosInitiatorId == family.currentUser.id) {
      _status = SosStatus.sent;
      _notifiedMemberIds.clear();
      for (final member in _closeFamily(family)) {
         _notifiedMemberIds.add(member.id);
      }
    }
  }

  void _triggerSos() {
    setState(() {
      _status = SosStatus.sending;
    });

    HapticFeedback.heavyImpact();

    _notifiedMemberIds.clear();
    final family = Provider.of<FamilyProvider>(context, listen: false);
    final closeFamily = _closeFamily(family);
    for (var i = 0; i < closeFamily.length; i++) {
      Future.delayed(Duration(milliseconds: 600 + (i * 600)), () {
        if (!mounted) return;
        _notifiedMemberIds.add(closeFamily[i].id);
        setState(() {});
        if (_notifiedMemberIds.length == closeFamily.length) {
          setState(() {
            _status = SosStatus.sent;
          });
          family.startSosAlert();
          HapticFeedback.vibrate();
        }
      });
    }
  }

  void _onPressDown(TapDownDetails details) {
    if (_status != SosStatus.idle) return;
    setState(() {
      _status = SosStatus.activating;
    });
    _controller.forward();
    HapticFeedback.selectionClick();
  }

  void _onPressUp(TapUpDetails details) {
    if (_status != SosStatus.activating) return;
    if (_controller.isAnimating) {
      _controller.reverse();
    }
    setState(() {
      _status = SosStatus.idle;
    });
  }

  void _onPressCancel() {
    if (_status != SosStatus.activating) return;
    if (_controller.isAnimating) {
      _controller.reverse();
    }
    setState(() {
      _status = SosStatus.idle;
    });
  }

  void _reset() {
    final family = Provider.of<FamilyProvider>(context, listen: false);
    final wasSent = _status == SosStatus.sent;
    setState(() {
      _status = SosStatus.idle;
      _notifiedMemberIds.clear();
      _controller.reset();
    });
    if (wasSent) {
      family.stopSosAlert();
    }
  }

  void _retry() {
    setState(() {
      _status = SosStatus.sending;
    });
    Future.delayed(const Duration(milliseconds: 200), _triggerSos);
  }

  @override
  Widget build(BuildContext context) {
    final familyData = Provider.of<FamilyProvider>(context, listen: false);
    final background = Colors.grey.shade50;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: _buildBody(familyData),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(FamilyProvider provider) {
    switch (_status) {
      case SosStatus.sending:
        return _buildSendingView(provider);
      case SosStatus.sent:
        return _buildSentView(provider);
      case SosStatus.failed:
        return _buildFailedView(provider);
      default:
        return _buildTriggerView(provider);
    }
  }

  Widget _buildTriggerView(FamilyProvider provider) {
    final members = _closeFamily(provider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSosHeader(),
        const SizedBox(height: 16),
        _buildHoldCard(),
        const SizedBox(height: 20),
        _buildWillBeNotified(members),
        const SizedBox(height: 20),
        _buildWhatHappens(context),
        const SizedBox(height: 16),
        _buildEmergencyCta(context),
        const SizedBox(height: 16),
        _buildManageFamilyCta(context),
      ],
    );
  }

  Widget _buildSendingView(FamilyProvider provider) {
    final members = _closeFamily(provider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSosHeader(),
        const SizedBox(height: 16),
        _buildStatusCard(
          title: 'Sending...',
          subtitle: 'Notifying family members (${_notifiedMemberIds.length}/${members.length})',
          color: Colors.blue.shade50,
          border: Colors.blue.shade200,
          icon: const CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(height: 12),
        Center(
          child: OutlinedButton(
            onPressed: _reset,
            child: const Text('Cancel Alert'),
          ),
        ),
        const SizedBox(height: 20),
        _buildWillBeNotified(
          members,
          statusLabel: 'Sending',
          statusColor: Colors.blue,
          notifiedIds: _notifiedMemberIds,
        ),
        const SizedBox(height: 20),
        _buildWhatHappens(context),
      ],
    );
  }

  Widget _buildSentView(FamilyProvider provider) {
    final members = _closeFamily(provider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSosHeader(),
        const SizedBox(height: 16),
        _buildStatusCard(
          title: 'SOS Alert Sent',
          subtitle: 'All family members have been notified of your emergency',
          color: Colors.green.shade50,
          border: Colors.green.shade200,
          icon: const Icon(Icons.check_circle, color: Colors.green),
        ),
        const SizedBox(height: 12),
        Center(
          child: OutlinedButton(
            onPressed: _reset,
            child: const Text("I'm safe"),
          ),
        ),
        const SizedBox(height: 20),
        _buildWillBeNotified(
          members,
          statusLabel: 'Notified',
          statusColor: Colors.green,
          notifiedIds: _notifiedMemberIds,
        ),
        const SizedBox(height: 20),
        _buildWhatHappens(context),
        const SizedBox(height: 16),
        _buildEmergencyCta(context),
      ],
    );
  }

  Widget _buildFailedView(FamilyProvider provider) {
    final members = _closeFamily(provider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSosHeader(),
        const SizedBox(height: 16),
        _buildStatusCard(
          title: 'Alert Failed',
          subtitle: 'We could not reach everyone. Try again.',
          color: Colors.orange.shade50,
          border: Colors.orange.shade200,
          icon: const Icon(Icons.error_outline, color: Colors.orange),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: _reset, child: const Text('Cancel'))),
            const SizedBox(width: 12),
            Expanded(child: FilledButton(onPressed: _retry, child: const Text('Retry'))),
          ],
        ),
        const SizedBox(height: 20),
        _buildWillBeNotified(
          members,
          statusLabel: 'Retry',
          statusColor: Colors.orange,
          notifiedIds: _notifiedMemberIds,
        ),
        const SizedBox(height: 20),
        _buildWhatHappens(context),
        const SizedBox(height: 16),
        _buildEmergencyCta(context),
        const SizedBox(height: 16),
        _buildManageFamilyCta(context),
      ],
    );
  }

  Widget _buildSosHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'Emergency SOS',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Send an immediate alert to all family members',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildHoldCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_rounded, color: Colors.white, size: 52),
          ),
          const SizedBox(height: 16),
          Text(
            'Send Emergency Alert',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Hold the button for 3 seconds to send SOS',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTapDown: _onPressDown,
            onTapUp: _onPressUp,
            onTapCancel: _onPressCancel,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final isHolding = _status == SosStatus.activating || _controller.value > 0;
                return Column(
                  children: [
                    Container(
                      height: 52,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _controller.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade900,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.warning_amber_rounded, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Press and Hold',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isHolding) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _controller.value,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.red.shade700,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This action will immediately notify all close family members with your location and a request for help.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildWillBeNotified(
    List members, {
    String? statusLabel,
    Color? statusColor,
    List<String> notifiedIds = const [],
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.group_outlined),
            SizedBox(width: 8),
            Text('Will be notified', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ...members.map((member) {
          final isNotified = notifiedIds.contains(member.id);
          final isSending = statusLabel == 'Sending' && !isNotified && _status == SosStatus.sending;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isNotified
                  ? Colors.green.shade50
                  : (isSending ? Colors.blue.shade50 : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                AvatarView(
                  avatarUrl: member.avatarUrl,
                  fallbackInitial: member.name[0],
                  radius: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => ExternalActions.callMember(context, member),
                            icon: const Icon(Icons.call, size: 14),
                            label: const Text('Call'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => ExternalActions.navigateToMember(context, member),
                            icon: const Icon(Icons.navigation_outlined, size: 14),
                            label: const Text('Navigate'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isNotified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text('Notified', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                else if (isSending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sending',
                          style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String subtitle,
    required Color color,
    required Color border,
    required Widget icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          SizedBox(width: 24, height: 24, child: Center(child: icon)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<FamilyMember> _closeFamily(FamilyProvider provider) {
    return [provider.currentUser, ...provider.members.where((m) => m.isCloseFamily)]
        .where((member) => member.id != provider.currentUser.id)
        .toList();
  }

  Widget _buildWhatHappens(BuildContext context, {bool dark = false}) {
    final textColor = dark ? Colors.white70 : Colors.grey.shade700;
    final titleColor = dark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? Colors.white10 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What happens when you activate SOS?', style: TextStyle(color: titleColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildStep('1', 'Urgent alert sent', 'Family receives an immediate SOS notification.', textColor, titleColor),
          _buildStep('2', 'Location shared', 'Your last known location is included if enabled.', textColor, titleColor),
          _buildStep('3', 'Timestamp recorded', 'Alert includes when it was triggered.', textColor, titleColor),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, String body, Color bodyColor, Color titleColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Text(number, style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(body, style: TextStyle(color: bodyColor, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCta(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Life-threatening emergency?', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Call emergency services directly if you are in immediate danger.', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => ExternalActions.callEmergency(context, number: '999'),
            icon: const Icon(Icons.phone),
            label: const Text('Call 999'),
          ),
        ],
      ),
    );
  }

  Widget _buildManageFamilyCta(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.go('/family'),
      icon: const Icon(Icons.group_outlined),
      label: const Text('Manage Family Relationships'),
    );
  }
}
