import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AvatarView extends StatelessWidget {
  final String avatarUrl;
  final String fallbackInitial;
  final double radius;
  final Color? backgroundColor;

  const AvatarView({
    super.key,
    required this.avatarUrl,
    required this.fallbackInitial,
    this.radius = 20,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    if (avatarUrl.toLowerCase().endsWith('.svg')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        child: ClipOval(
          child: SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: SvgPicture.asset(
              avatarUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
      backgroundImage: AssetImage(avatarUrl),
      child: avatarUrl.isEmpty ? Text(fallbackInitial) : null,
    );
  }
}
