import 'package:flutter/material.dart';

class NavIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final bool isActive;

  const NavIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 22,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: isActive ? Colors.white : (color ?? Colors.grey[600]),
    );
  }
}

class NavIconWithGradient extends StatelessWidget {
  final IconData icon;
  final LinearGradient gradient;
  final double size;

  const NavIconWithGradient({
    super.key,
    required this.icon,
    required this.gradient,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Icon(
        icon,
        size: size,
        color: Colors.white,
      ),
    );
  }
}
