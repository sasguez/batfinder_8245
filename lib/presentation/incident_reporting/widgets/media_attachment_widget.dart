import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for photo/video attachment with camera integration
class MediaAttachmentWidget extends StatefulWidget {
  final List<XFile> attachedMedia;
  final Function(List<XFile>) onMediaChanged;

  const MediaAttachmentWidget({
    super.key,
    required this.attachedMedia,
    required this.onMediaChanged,
  });

  @override
  State<MediaAttachmentWidget> createState() => _MediaAttachmentWidgetState();
}

class _MediaAttachmentWidgetState extends State<MediaAttachmentWidget> {
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _showCameraPreview = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      if (kIsWeb) {
        _cameras = await availableCameras();
        if (_cameras != null && _cameras!.isNotEmpty) {
          final camera = _cameras!.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras!.first,
          );
          _cameraController = CameraController(camera, ResolutionPreset.medium);
          await _cameraController!.initialize();
          if (mounted) {
            setState(() => _isCameraInitialized = true);
          }
        }
      } else {
        final hasPermission = await _requestCameraPermission();
        if (hasPermission) {
          _cameras = await availableCameras();
          if (_cameras != null && _cameras!.isNotEmpty) {
            final camera = _cameras!.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras!.first,
            );
            _cameraController = CameraController(camera, ResolutionPreset.high);
            await _cameraController!.initialize();
            await _applySettings();
            if (mounted) {
              setState(() => _isCameraInitialized = true);
            }
          }
        }
      }
    } catch (e) {
      _isCameraInitialized = false;
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _applySettings() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {}
    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {}
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      final updatedMedia = List<XFile>.from(widget.attachedMedia)..add(photo);
      widget.onMediaChanged(updatedMedia);
      setState(() => _showCameraPreview = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al capturar foto')));
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        final updatedMedia = List<XFile>.from(widget.attachedMedia)
          ..addAll(images);
        widget.onMediaChanged(updatedMedia);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imágenes')),
        );
      }
    }
  }

  void _removeMedia(int index) {
    final updatedMedia = List<XFile>.from(widget.attachedMedia)
      ..removeAt(index);
    widget.onMediaChanged(updatedMedia);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fotos y Videos',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.5.h),
        _showCameraPreview && _isCameraInitialized
            ? _buildCameraPreview(theme)
            : _buildMediaGrid(theme),
      ],
    );
  }

  Widget _buildCameraPreview(ThemeData theme) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            SizedBox.expand(child: CameraPreview(_cameraController!)),
            Positioned(
              bottom: 2.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () => setState(() => _showCameraPreview = false),
                    icon: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _capturePhoto,
                    icon: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: CustomIconWidget(
                        iconName: 'camera',
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isCameraInitialized
                    ? () => setState(() => _showCameraPreview = true)
                    : null,
                icon: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: _isCameraInitialized
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                label: Text('Cámara'),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: CustomIconWidget(
                  iconName: 'photo_library',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                label: Text('Galería'),
              ),
            ),
          ],
        ),
        if (widget.attachedMedia.isNotEmpty) ...[
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 1.h,
              childAspectRatio: 1,
            ),
            itemCount: widget.attachedMedia.length,
            itemBuilder: (context, index) {
              final media = widget.attachedMedia[index];
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(
                              media.path,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Image.file(
                              File(media.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    ),
                  ),
                  Positioned(
                    top: 1.w,
                    right: 1.w,
                    child: InkWell(
                      onTap: () => _removeMedia(index),
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: 'close',
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
