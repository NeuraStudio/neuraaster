import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  CameraController? _camera;
  bool _cameraReady = false;
  bool _cameraOn = true;
  bool _sendingFrame = false;
  String _lastHeard = '';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _camera = controller;
        _cameraReady = true;
      });
    } catch (_) {
      if (mounted) setState(() => _cameraReady = false);
    }
  }

  Future<void> _toggleVoice() async {
    final live = ref.read(liveModeProvider);
    if (live) {
      await ref.read(chatControllerProvider.notifier).stopLive();
      return;
    }

    await ref.read(chatControllerProvider.notifier).startLive(
      onText: (text) {
        if (mounted) setState(() => _lastHeard = text);
      },
    );
  }

  Future<void> _captureAndAsk() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized || _sendingFrame) return;

    setState(() => _sendingFrame = true);
    try {
      final file = await camera.takePicture();
      final bytes = await file.readAsBytes();
      final base64 = base64Encode(bytes);
      final prompt = _lastHeard.trim().isEmpty
          ? 'Analyze the current camera frame and describe what you see.'
          : _lastHeard.trim();
      await ref.read(chatControllerProvider.notifier).send(
        prompt,
        imageBase64: base64,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Frame sent to NeuraAster')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingFrame = false);
    }
  }

  @override
  void dispose() {
    ref.read(chatControllerProvider.notifier).stopLive();
    _camera?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listening = ref.watch(listeningProvider);
    final live = ref.watch(liveModeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_cameraReady && _cameraOn)
            CameraPreview(_camera!)
          else
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Color(0xFF060A24)],
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 29),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .55),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        live ? 'Live' : 'Vision',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
                const Spacer(),
                if (_lastHeard.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .55),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(_lastHeard, style: const TextStyle(fontSize: 15)),
                  ),
                const SizedBox(height: 16),
                _LiveWave(active: listening),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _RoundControl(
                        icon: _cameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                        onTap: () => setState(() => _cameraOn = !_cameraOn),
                      ),
                      _RoundControl(
                        big: true,
                        icon: listening ? Icons.stop_rounded : Icons.mic_rounded,
                        onTap: _toggleVoice,
                      ),
                      _RoundControl(
                        icon: Icons.camera_alt_rounded,
                        loading: _sendingFrame,
                        onTap: _captureAndAsk,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveWave extends StatelessWidget {
  final bool active;

  const _LiveWave({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: active ? 120 : 88,
      height: active ? 54 : 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF27C8FF), Color(0xFF5A3DFF), Color(0xFFFF32D2)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3E67FF).withValues(alpha: active ? .55 : .2),
            blurRadius: 30,
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            9,
            (i) => AnimatedContainer(
              duration: Duration(milliseconds: 180 + i * 20),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3,
              height: active ? 10.0 + ((i % 3) * 10) : 7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool big;
  final bool loading;

  const _RoundControl({
    required this.icon,
    required this.onTap,
    this.big = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = big ? 72.0 : 56.0;
    return Material(
      color: big ? AppTheme.blue : Colors.black.withValues(alpha: .68),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(icon, size: big ? 30 : 25),
          ),
        ),
      ),
    );
  }
}
