import '../../utils/exports.dart';

/// A common scrollable widget with scrollbar that can be used anywhere
/// Wraps content in a SingleChildScrollView with a Scrollbar
class CommonScrollable extends StatefulWidget {
  const CommonScrollable({
    super.key,
    required this.child,
    this.padding,
    this.scrollDirection = Axis.vertical,
    this.controller,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Axis scrollDirection;
  final ScrollController? controller;

  @override
  State<CommonScrollable> createState() => _CommonScrollableState();
}

class _CommonScrollableState extends State<CommonScrollable> {
  ScrollController? _internalController;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = ScrollController();
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  ScrollController get _scrollController {
    return widget.controller ?? _internalController!;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          thickness: 8.0,
          radius: const Radius.circular(4.0),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: widget.padding,
            scrollDirection: widget.scrollDirection,
            child: constraints.maxHeight != double.infinity
                ? ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: widget.child,
                  )
                : widget.child,
          ),
        );
      },
    );
  }
}

