import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ExpandableInfoCard extends StatefulWidget {
  final String title;
  final Widget child;
  final double collapsedHeight;
  final bool initiallyExpanded;
  final bool showToggle;

  const ExpandableInfoCard({
    super.key,
    required this.title,
    required this.child,
    this.collapsedHeight = 180,
    this.initiallyExpanded = false,
    this.showToggle = true,
  });

  @override
  State<ExpandableInfoCard> createState() => _ExpandableInfoCardState();
}

class _ExpandableInfoCardState extends State<ExpandableInfoCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: ClipRect(
              child: SizedBox(
                height: widget.collapsedHeight,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: widget.child,
                ),
              ),
            ),
            secondChild: widget.child,
          ),

          const SizedBox(height: 12),

          if(widget.showToggle)
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.primary,
                ),
                label: Text(
                  _expanded ? "Voir moins" : "Voir plus",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}