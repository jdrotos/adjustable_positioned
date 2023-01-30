library adjustable_positioned;

import 'package:flutter/material.dart';

typedef HandleDragUpdateCallback = void Function(HandleId handleId, DragUpdateDetails details);
typedef HandleWidgetBuilder = Widget Function(BuildContext context, HandleId handleId);
typedef HandleDragCompleteCallback = void Function();

class DragHandleContainer extends StatelessWidget {
  final Widget child;
  final double dragHandleSize;
  final HandleDragUpdateCallback handleDragCallback;
  final HandleWidgetBuilder handleWidgetBuilder;
  final HandleDragCompleteCallback handleDragCompleteCallback;

  const DragHandleContainer(
      {super.key,
        required this.child,
        required this.handleDragCallback,
        required this.handleWidgetBuilder,
        this.dragHandleSize = 16.0,
        required this.handleDragCompleteCallback});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, sizedBox) {
      return Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: sizedBox.maxWidth,
            height: sizedBox.maxHeight,
            child: child,
          ),

          // Corners
          Positioned(
            left: 0,
            top: 0,
            width: dragHandleSize,
            height: dragHandleSize,
            child: DragHandleWidget(
              handleId: HandleId.NW,
              dragCallback: handleDragCallback,
              handleWidgetBuilder: handleWidgetBuilder,
              completeCallback: handleDragCompleteCallback,
            ),
          ),
          Positioned(
            left: sizedBox.maxWidth - dragHandleSize,
            top: 0,
            width: dragHandleSize,
            height: dragHandleSize,
            child: DragHandleWidget(
              handleId: HandleId.NE,
              dragCallback: handleDragCallback,
              handleWidgetBuilder: handleWidgetBuilder,
              completeCallback: handleDragCompleteCallback,
            ),
          ),
          Positioned(
            left: 0,
            top: sizedBox.maxHeight - dragHandleSize,
            width: dragHandleSize,
            height: dragHandleSize,
            child: DragHandleWidget(
              handleId: HandleId.SW,
              dragCallback: handleDragCallback,
              handleWidgetBuilder: handleWidgetBuilder,
              completeCallback: handleDragCompleteCallback,
            ),
          ),
          Positioned(
            left: sizedBox.maxWidth - dragHandleSize,
            top: sizedBox.maxHeight - dragHandleSize,
            width: dragHandleSize,
            height: dragHandleSize,
            child: DragHandleWidget(
              handleId: HandleId.SE,
              dragCallback: handleDragCallback,
              handleWidgetBuilder: handleWidgetBuilder,
              completeCallback: handleDragCompleteCallback,
            ),
          ),

          // Centers
          Positioned(
            left: sizedBox.maxWidth / 2 - dragHandleSize / 2,
            top: 0,
            width: dragHandleSize,
            height: dragHandleSize,
            child: DragHandleWidget(
              handleId: HandleId.N,
              dragCallback: handleDragCallback,
              handleWidgetBuilder: handleWidgetBuilder,
              completeCallback: handleDragCompleteCallback,
            ),
          ),
          Positioned(
            left: sizedBox.maxWidth / 2 - dragHandleSize / 2,
            top: sizedBox.maxHeight - dragHandleSize,
            width: dragHandleSize,
            height: dragHandleSize,
            child: DragHandleWidget(
              handleId: HandleId.S,
              dragCallback: handleDragCallback,
              handleWidgetBuilder: handleWidgetBuilder,
              completeCallback: handleDragCompleteCallback,
            ),
          ),
          Positioned(
            left: 0,
            top: sizedBox.maxHeight / 2 - dragHandleSize / 2,
            width: dragHandleSize,
            height: dragHandleSize,
            child: DragHandleWidget(
              handleId: HandleId.W,
              dragCallback: handleDragCallback,
              handleWidgetBuilder: handleWidgetBuilder,
              completeCallback: handleDragCompleteCallback,
            ),
          ),
          Positioned(
            left: sizedBox.maxWidth - dragHandleSize,
            top: sizedBox.maxHeight / 2 - dragHandleSize / 2,
            width: dragHandleSize,
            height: dragHandleSize,
            child: DragHandleWidget(
              handleId: HandleId.E,
              dragCallback: handleDragCallback,
              handleWidgetBuilder: handleWidgetBuilder,
              completeCallback: handleDragCompleteCallback,
            ),
          ),
        ],
      );
    });
  }
}

enum HandleId { NW, N, NE, E, SE, S, SW, W }

class DragHandleWidget extends StatelessWidget {
  final HandleDragUpdateCallback dragCallback;
  final HandleWidgetBuilder handleWidgetBuilder;
  final HandleDragCompleteCallback completeCallback;

  final HandleId handleId;

  const DragHandleWidget(
      {super.key,
        required this.dragCallback,
        required this.handleId,
        required this.handleWidgetBuilder,
        required this.completeCallback});

  @override
  Widget build(BuildContext context) {
    return Draggable(
      axis: _axis(),
      feedback: Container(),
      childWhenDragging: handleWidgetBuilder(context, handleId),
      child: Container(
        child: handleWidgetBuilder(context, handleId),
      ),
      onDragUpdate: (dragData) {
        dragCallback(
          handleId,
          dragData,
        );
      },
      onDragEnd: (dragData) {
        completeCallback();
      },
    );
  }

  Axis? _axis() {
    if (handleId == HandleId.N || handleId == HandleId.S) {
      return Axis.vertical;
    }
    if (handleId == HandleId.W || handleId == HandleId.E) {
      return Axis.horizontal;
    }
    return null;
  }
}
