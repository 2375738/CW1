import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_models.dart';

class ExternalActions {
  static Future<void> callMember(BuildContext context, FamilyMember member) async {
    final number = _phoneByMemberId(member.id);
    if (number == null) {
      _showMessage(context, 'No phone number set for ${member.name}.');
      return;
    }
    await _openUri(
      context,
      Uri(scheme: 'tel', path: number),
      failMessage: 'Could not open dialer for ${member.name}.',
    );
  }

  static Future<void> callEmergency(BuildContext context, {String number = '999'}) async {
    await _openUri(
      context,
      Uri(scheme: 'tel', path: number),
      failMessage: 'Could not open emergency dialer.',
    );
  }

  static Future<void> navigateToMember(
    BuildContext context,
    FamilyMember member, {
    double? latitude,
    double? longitude,
  }) async {
    final query = (latitude != null && longitude != null)
        ? '$latitude,$longitude'
        : (member.locationAddress ?? member.locationLabel);
    if (query == null || query.trim().isEmpty) {
      _showMessage(context, 'No location set for ${member.name}.');
      return;
    }

    final mapsUri = Uri.https(
      'www.google.com',
      '/maps/search/',
      <String, String>{'api': '1', 'query': query},
    );
    await _openUri(
      context,
      mapsUri,
      failMessage: 'Could not open maps for ${member.name}.',
    );
  }

  static String? _phoneByMemberId(String memberId) {
    switch (memberId) {
      case 'u1':
        return '+447700900111';
      case 'u2':
        return '+447700900222';
      case 'u3':
        return '+447700900333';
      case 'u4':
        return '+447700900444';
      default:
        return null;
    }
  }

  static Future<void> _openUri(
    BuildContext context,
    Uri uri, {
    required String failMessage,
  }) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        final fallback = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (!fallback) {
          _showMessageWithMessenger(messenger, failMessage);
        }
      }
    } catch (_) {
      _showMessageWithMessenger(messenger, failMessage);
    }
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static void _showMessageWithMessenger(ScaffoldMessengerState? messenger, String message) {
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }
}
