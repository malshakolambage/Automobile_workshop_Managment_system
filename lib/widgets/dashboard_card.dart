import 'dart:ui';
import 'package:flutter/material.dart';

enum CardType {
  vehicles,
  services,
  analytics,
  customers,
}

class DashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final CardType type;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.type,
    this.onTap,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  double scale = 1.0;

  Color getColor() {
    switch (widget.type) {
      case CardType.vehicles:
        return const Color(0xFF3DDCFF); // Cyan

      case CardType.services:
        return const Color(0xFF8B5CF6); // Purple

      case CardType.analytics:
        return const Color(0xFF34D399); // Emerald

      case CardType.customers:
        return const Color(0xFFFFB74D); // Amber
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getColor();

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20,
            sigmaY: 20,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),

              onTapDown: (_) => setState(() => scale = 0.96),
              onTapUp: (_) => setState(() => scale = 1),
              onTapCancel: () => setState(() => scale = 1),
              onTap: widget.onTap,

              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),

                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.18),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),

                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 1.2,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.30),
                      blurRadius: 25,
                      spreadRadius: 1,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),

                child: Stack(
                  children: [
                    // Top glossy highlight
                    Positioned(
                      top: -40,
                      left: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),

                    // Bottom glow
                    Positioned(
                      bottom: -40,
                      right: -40,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(0.12),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          // Center Icon Circle
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              gradient: RadialGradient(
                                colors: [
                                  color.withOpacity(0.35),
                                  color.withOpacity(0.08),
                                ],
                              ),

                              border: Border.all(
                                color: color.withOpacity(0.35),
                                width: 1,
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.35),
                                  blurRadius: 18,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),

                            child: Icon(
                              widget.icon,
                              color: color,
                              size: 22,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}