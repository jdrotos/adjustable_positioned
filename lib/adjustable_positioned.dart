library adjustable_positioned;

import 'dart:math';

import 'package:flutter/material.dart';

import 'drag_handle_container.dart';

typedef ActiveAdjustmentCallback = void Function(Rect activePosition);
typedef FinishedAdjustmentCallback = void Function(Rect position);

class AdjustablePositionedWidget<T extends Object> extends StatefulWidget {
  final Widget child;
  final T? dragData;
  final ActiveAdjustmentCallback activeAdjustmentCallback;
  final FinishedAdjustmentCallback finishedAdjustmentCallback;
  final HandleWidgetBuilder handleWidgetBuilder;

  final double minW;
  final double minH;

  // In some situations (interactive viewer) your widget may be zoomed in a way where the size on screen is different than
  // the size that is defined. This can result in a jump in size when dragging, which we don't want.
  final double dragScale;

  final double startX;
  final double startY;
  final double startW;
  final double startH;

  final double handleSize;

  final bool dragEnabled, handlesEnabled;

  // If this is set to true, we will update our state based on the widget args
  final bool consumeArgumentUpdates;

  const AdjustablePositionedWidget({
    super.key,
    required this.startX,
    required this.startY,
    required this.startW,
    required this.startH,
    required this.minW,
    required this.minH,
    required this.child,
    required this.activeAdjustmentCallback,
    required this.finishedAdjustmentCallback,
    required this.handleWidgetBuilder,
    required this.handleSize,
    required this.dragData,
    this.dragEnabled = true,
    this.handlesEnabled = true,
    this.consumeArgumentUpdates = false,
    this.dragScale = 1.0,
  });

  @override
  State<AdjustablePositionedWidget> createState() => _AdjustablePositionedWidgetState<T>();
}

class _AdjustablePositionedWidgetState<T extends Object> extends State<AdjustablePositionedWidget> {
  late double x, y, w, h;
  bool dragging = false;

  @override
  void initState() {
    _consumeWidgetValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.consumeArgumentUpdates) {
      _consumeWidgetValues();
    }
    return Positioned(
        left: x,
        top: y,
        width: max(w, widget.minW),
        height: max(h, widget.minH),
        child: _wrapWithHandlesIfEnabled(_wrapWithDraggableIfEnabled(widget.child)));
  }

  void _consumeWidgetValues() {
    x = widget.startX;
    y = widget.startY;
    w = widget.startW;
    h = widget.startH;
  }

  Widget _wrapWithHandlesIfEnabled(Widget child) {
    if (!widget.handlesEnabled) {
      return child;
    }
    return DragHandleContainer(
        dragHandleSize: widget.handleSize,
        handleWidgetBuilder: (BuildContext context, HandleId handleId) {
          if (dragging) {
            return Container();
          }
          return widget.handleWidgetBuilder(context, handleId);
        },
        handleDragCallback: (HandleId handleId, DragUpdateDetails details) {
          double x = this.x;
          double y = this.y;
          double w = this.w;
          double h = this.h;

          if (handleId == HandleId.N || handleId == HandleId.NE || handleId == HandleId.NW) {
            y += details.delta.dy;
            h -= details.delta.dy;
          }
          if (handleId == HandleId.W || handleId == HandleId.NW || handleId == HandleId.SW) {
            x += details.delta.dx;
            w -= details.delta.dx;
          }
          if (handleId == HandleId.E || handleId == HandleId.NE || handleId == HandleId.SE) {
            w += details.delta.dx;
          }
          if (handleId == HandleId.S || handleId == HandleId.SW || handleId == HandleId.SE) {
            h += details.delta.dy;
          }

          setState(() {
            this.x = x;
            this.y = y;
            this.h = h;
            this.w = w;
          });

          widget.activeAdjustmentCallback(Rect.fromLTWH(x, y, max(w, widget.minW), max(h, widget.minH)));
        },
        handleDragCompleteCallback: () {
          widget.finishedAdjustmentCallback(Rect.fromLTWH(x, y, max(w, widget.minW), max(h, widget.minH)));
        },
        child: child);
  }

  Widget _wrapWithDraggableIfEnabled(Widget child) {
    if (!widget.dragEnabled) {
      return child;
    }

    return Draggable<T>(
        data: widget.dragData as T?,
        dragAnchorStrategy: (draggable, context, position) {
          var anchorStrategy = childDragAnchorStrategy(draggable, context, position);
          // Because the anchorStrategy is effectively a touch offset, we need to scale that.
          // Note: the feedback scale works in coordination with this (so continue using a topLeft alignment there)
          return anchorStrategy * widget.dragScale;
        },
        onDragStarted: () {
          setState(() {
            dragging = true;
          });
        },
        onDragEnd: (_) {
          setState(() {
            dragging = false;
          });
          widget.finishedAdjustmentCallback(Rect.fromLTWH(x, y, max(w, widget.minW), max(h, widget.minH)));
        },
        onDragUpdate: (details) {
          setState(() {
            x += details.delta.dx / widget.dragScale;
            y += details.delta.dy / widget.dragScale;
          });
          widget.activeAdjustmentCallback(Rect.fromLTWH(x, y, max(w, widget.minW), max(h, widget.minH)));
        },
        feedback: Transform.scale(
          scale: widget.dragScale,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: max(w, widget.minW),
            height: max(h, widget.minH),
            // NOTE: Need the Material widget to have proper theme data
            child: Material(
              color: Colors.transparent,
              child: widget.child,
            ),
          ),
        ),
        childWhenDragging: Container(),
        child: child);
  }
}
