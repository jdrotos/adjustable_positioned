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

  final double startX;
  final double startY;
  final double startW;
  final double startH;

  final double handleSize;

  final bool dragEnabled, handlesEnabled;

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
  });

  @override
  State<AdjustablePositionedWidget> createState() => _AdjustablePositionedWidgetState<T>();
}

class _AdjustablePositionedWidgetState<T extends Object> extends State<AdjustablePositionedWidget> {
  late double x, y, w, h;
  bool dragging = false;

  @override
  void initState() {
    x = widget.startX;
    y = widget.startY;
    w = widget.startW;
    h = widget.startH;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: x,
        top: y,
        width: max(w, widget.minW),
        height: max(h, widget.minH),
        child: _wrapWithHandlesIfEnabled(_wrapWithDraggableIfEnabled(widget.child)));
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
            x += details.delta.dx;
            y += details.delta.dy;
          });
          widget.activeAdjustmentCallback(Rect.fromLTWH(x, y, max(w, widget.minW), max(h, widget.minH)));
        },
        feedback: SizedBox(
          width: max(w, widget.minW),
          height: max(h, widget.minH),
          // NOTE: Need the Material widget to have proper theme data
          child: Material(child: widget.child),
        ),
        childWhenDragging: Container(),
        child: child);
  }
}
