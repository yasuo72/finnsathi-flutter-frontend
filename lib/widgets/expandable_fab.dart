import 'package:flutter/material.dart';
import 'dart:math' as math;

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen = false,
    required this.distance,
    required this.children,
    this.backgroundColor,
    this.foregroundColor,
  });

  final bool initialOpen;
  final double distance;
  final List<Widget> children;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.secondary;
    final foregroundColor = widget.foregroundColor ?? theme.colorScheme.onSecondary;
    
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomLeft,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(backgroundColor, foregroundColor),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ),
      ),
    ).scaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(_expandAnimation),
    );
  }

  Widget _buildTapToOpenFab(Color backgroundColor, Color foregroundColor) {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            onPressed: _toggle,
            child: const Icon(Icons.menu),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    
    for (var i = 0; i < count; i++) {
      final double angleInDegrees = 0.0 + (step * i);
      final double angleInRadians = angleInDegrees * math.pi / 180;
      
      final child = ExpandingActionButton(
        directionInDegrees: angleInDegrees,
        maxDistance: widget.distance,
        progress: _expandAnimation,
        child: widget.children[i],
      );
      
      children.add(child);
    }
    
    return children;
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.color,
    this.elevation = 4,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final Color? color;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: color ?? theme.colorScheme.secondary,
      elevation: elevation,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: theme.colorScheme.onSecondary,
      ),
    );
  }
}

@immutable
class ExpandingActionButton extends StatelessWidget {
  const ExpandingActionButton({
    super.key,
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        
        return Positioned(
          left: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

extension on Widget {
  Widget scaleTransition({
    required Animation<double> scale,
  }) {
    return AnimatedBuilder(
      animation: scale,
      builder: (context, child) => Transform.scale(
        scale: scale.value,
        child: child,
      ),
      child: this,
    );
  }
}
