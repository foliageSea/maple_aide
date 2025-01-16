import 'package:flutter/material.dart';

class CustomTag extends StatefulWidget {
  const CustomTag(
    this.id, {
    super.key,
  });

  final int id;

  @override
  State<CustomTag> createState() => _CustomTagState();
}

class _CustomTagState extends State<CustomTag> {
  @override
  Widget build(BuildContext context) {
    return _buildTag();
  }

  Widget _buildTag() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${widget.id}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
