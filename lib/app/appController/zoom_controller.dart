import 'dart:html' as html;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Global zoom service that handles zoom functionality
/// Supports:
/// - CTRL + Mouse Wheel zoom
/// - CTRL + Plus/Minus/0 keyboard shortcuts
/// - UI zoom controls
/// Provides smooth zoom in/out behavior that mimics browser zoom
class GlobalZoomService extends GetxController {
  static GlobalZoomService get instance => Get.find<GlobalZoomService>();

  // Reactive zoom level - starts at 1.0 (100%)
  final RxDouble _zoomLevel = 1.0.obs;

  double get zoomLevel => _zoomLevel.value;

  // Zoom constraints
  static const double minZoom = 0.25; // 25%
  static const double maxZoom = 5.0; // 500%
  static const double zoomStep = 0.1; // 10% per step

  // Performance optimization - debounce zoom changes
  static const Duration debounceDelay = Duration(milliseconds: 16); // ~60fps

  // Track if CTRL key is pressed
  bool isCtrlPressed = false;

  @override
  void onInit() {
    super.onInit();
    _initializeWebListeners();
  }

  @override
  void onClose() {
    _removeWebListeners();
    super.onClose();
  }

  /// Initialize web-specific event listeners
  void _initializeWebListeners() {
    if (kIsWeb) {
      // Listen for keyboard events to track CTRL key
      html.document.addEventListener('keydown', _handleKeyDown);
      html.document.addEventListener('keyup', _handleKeyUp);

      // Listen for wheel events on the entire document with capture
      html.document.addEventListener('wheel', _handleWheel, true);

      // Handle browser's default zoom shortcuts (Ctrl+Plus, Ctrl+Minus, Ctrl+0)
      html.document.addEventListener('keydown', _preventBrowserZoom, false);
    }
  }

  /// Remove web event listeners
  void _removeWebListeners() {
    if (kIsWeb) {
      html.document.removeEventListener('keydown', _handleKeyDown);
      html.document.removeEventListener('keyup', _handleKeyUp);
      html.document.removeEventListener('wheel', _handleWheel);
      html.document.removeEventListener('keydown', _preventBrowserZoom);
    }
  }

  /// Handle keydown events to track CTRL key
  void _handleKeyDown(html.Event event) {
    final keyEvent = event as html.KeyboardEvent;
    if (keyEvent.ctrlKey || keyEvent.metaKey) {
      isCtrlPressed = true;
    }
  }

  /// Handle keyup events to track CTRL key
  void _handleKeyUp(html.Event event) {
    final keyEvent = event as html.KeyboardEvent;
    if (!keyEvent.ctrlKey && !keyEvent.metaKey) {
      isCtrlPressed = false;
    }
  }

  /// Handle browser's default zoom shortcuts
  void _preventBrowserZoom(html.Event event) {
    final keyEvent = event as html.KeyboardEvent;

    // Handle CTRL + Plus/Minus/0 (browser zoom shortcuts)
    if ((keyEvent.ctrlKey || keyEvent.metaKey)) {
      if (keyEvent.key == '+' || keyEvent.key == '=') {
        // Zoom in
        event.preventDefault();
        zoomIn();
      } else if (keyEvent.key == '-') {
        // Zoom out
        event.preventDefault();
        zoomOut();
      } else if (keyEvent.key == '0') {
        // Reset zoom
        event.preventDefault();
        resetZoom();
      }
    }
  }

  /// Handle mouse wheel events for zoom
  void _handleWheel(html.Event event) {
    final wheelEvent = event as html.WheelEvent;

    // Check if CTRL or CMD key is pressed during wheel event
    final isCtrlPressed = wheelEvent.ctrlKey || wheelEvent.metaKey;

    // Only handle zoom when CTRL is pressed
    if (!isCtrlPressed) return;

    // Prevent browser's default zoom
    event.preventDefault();
    event.stopPropagation();

    // Determine zoom direction based on wheel delta
    final delta = wheelEvent.deltaY;
    final shouldZoomIn = delta < 0;

    // Apply zoom change
    if (shouldZoomIn) {
      zoomIn();
    } else {
      zoomOut();
    }
  }

  /// Zoom in by one step
  void zoomIn() {
    final newZoom = math.min(maxZoom, _zoomLevel.value + zoomStep);
    _updateZoom(newZoom);
  }

  /// Zoom out by one step
  void zoomOut() {
    final newZoom = math.max(minZoom, _zoomLevel.value - zoomStep);
    _updateZoom(newZoom);
  }

  /// Reset zoom to 100%
  void resetZoom() {
    _updateZoom(1.0);
  }

  /// Set specific zoom level
  void setZoom(double zoom) {
    final clampedZoom = math.max(minZoom, math.min(maxZoom, zoom));
    _updateZoom(clampedZoom);
  }

  /// Update zoom level with debouncing for performance
  void _updateZoom(double newZoom) {
    if (newZoom != _zoomLevel.value) {
      _zoomLevel.value = newZoom;
    }
  }

  /// Get zoom level as observable
  RxDouble get zoomLevelObs => _zoomLevel;

  /// Get zoom percentage as string
  String get zoomPercentage => '${(_zoomLevel.value * 100).round()}%';

  /// Check if at minimum zoom
  bool get isAtMinZoom => _zoomLevel.value <= minZoom;

  /// Check if at maximum zoom
  bool get isAtMaxZoom => _zoomLevel.value >= maxZoom;
}
