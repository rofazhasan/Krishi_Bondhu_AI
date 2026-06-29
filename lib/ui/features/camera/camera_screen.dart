import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:go_router/go_router.dart';
import '../../../core/localization/bangla_strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/providers.dart';
import '../../core_widgets/primary_button.dart';
import '../../core_widgets/voice_feedback_card.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraReady = false;
  bool _hasCameraError = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _hasCameraError = true;
        });
        return;
      }

      // Initialize the back camera
      final backCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) {
        setState(() {
          _hasCameraError = true;
        });
      }
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraReady || _cameraController == null) {
      _simulateCameraCapture(); // Fallback for simulators
      return;
    }

    try {
      final XFile file = await _cameraController!.takePicture();
      _processSelectedImage(file.path);
    } catch (e) {
      debugPrint('Take picture error: $e');
      _simulateCameraCapture(); // Fallback on shutter error
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        _processSelectedImage(file.path);
      }
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
  }

  // Fallback simulator for emulator / desktop environments
  Future<void> _simulateCameraCapture() async {
    try {
      final byteData = await DefaultAssetBundle.of(context).load('assets/images/crop_healthy.jpeg');
      final directory = await getTemporaryDirectory();
      final path = p.join(directory.path, 'simulated_crop_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final file = File(path);
      await file.writeAsBytes(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
      _processSelectedImage(path);
    } catch (e) {
      debugPrint('Simulated photo fail: $e');
    }
  }

  void _processSelectedImage(String path) {
    ref.read(capturedImagePathProvider.notifier).state = path;
    context.pushReplacement('/analysis');
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = ref.watch(textSizeMultiplierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          BanglaStrings.cameraInstruction,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22 * textScale,
            color: isDark ? AppColors.darkTextPrimary : Colors.white,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          const VoiceFeedbackCard(
            textToRead: 'আপনার রোগাক্রান্ত পাতার স্পষ্ট ছবি তুলতে নিচের গোল বোতামটি চাপুন, অথবা গ্যালারি বোতাম চেপে মোবাইল থেকে আগে তোলা ছবি যুক্ত করুন।',
            displayMessage: 'পাতার ছবি স্পষ্ট করুন এবং তুলুন',
          ),
          
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21),
                child: _buildCameraPreview(),
              ),
            ),
          ),
          
          // Action Buttons panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Shutter Button
                PrimaryButton(
                  text: BanglaStrings.cameraShutter,
                  icon: Icons.camera_alt,
                  backgroundColor: AppColors.success,
                  onPressed: _takePicture,
                ),
                const SizedBox(height: 8),
                // Gallery button
                PrimaryButton(
                  text: BanglaStrings.cameraGallerySelect,
                  icon: Icons.photo_library,
                  backgroundColor: AppColors.lightSecondary,
                  onPressed: _pickFromGallery,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_hasCameraError || !_isCameraReady || _cameraController == null) {
      // Mock Camera screen layout for emulator / desktop
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/crop_healthy.jpeg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black45,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off, color: Colors.white, size: 64),
                  SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'সিমুলেটর ক্যামেরা সচল রয়েছে\n(ছবি তুলতে গোল বোতামটি চাপুন)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildScanningOverlay(),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraController!),
        _buildScanningOverlay(),
      ],
    );
  }

  Widget _buildScanningOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.accent, width: 4),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
