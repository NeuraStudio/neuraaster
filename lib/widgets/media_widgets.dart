import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../services/file_service.dart';
import '../theme/app_theme.dart';

class GeneratedImage extends StatefulWidget {
  final String url;
  final FileService fileService;

  const GeneratedImage({super.key, required this.url, required this.fileService});

  @override
  State<GeneratedImage> createState() => _GeneratedImageState();
}

class _GeneratedImageState extends State<GeneratedImage> {
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final result = await widget.fileService.saveImageToGallery(widget.url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result ? 'Image saved to gallery' : 'Could not save image')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: CachedNetworkImage(
            imageUrl: widget.url,
            fit: BoxFit.cover,
            placeholder: (_, __) => const AspectRatio(
              aspectRatio: 1,
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (_, __, ___) => const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Image could not be loaded.'),
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.download_rounded, size: 18),
          label: const Text('Download HD'),
        ),
      ],
    );
  }
}

class GeneratedVideo extends StatefulWidget {
  final String url;
  final FileService fileService;

  const GeneratedVideo({super.key, required this.url, required this.fileService});

  @override
  State<GeneratedVideo> createState() => _GeneratedVideoState();
}

class _GeneratedVideoState extends State<GeneratedVideo> {
  VideoPlayerController? _video;
  ChewieController? _chewie;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final video = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await video.initialize();
      final chewie = ChewieController(
        videoPlayerController: video,
        autoPlay: false,
        looping: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.white,
          handleColor: Colors.white,
          backgroundColor: const Color(0xFF44464D),
          bufferedColor: const Color(0xFF777A83),
        ),
      );
      if (!mounted) {
        chewie.dispose();
        await video.dispose();
        return;
      }
      setState(() {
        _video = video;
        _chewie = chewie;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/neuraaster_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await Dio().download(widget.url, path);
      final saved = await widget.fileService.saveVideoToGallery(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(saved ? 'Video saved to gallery' : 'Could not save video')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _chewie?.dispose();
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: _loading
              ? const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(child: CircularProgressIndicator()),
                )
              : _chewie == null
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Video could not be loaded.'),
                    )
                  : Chewie(controller: _chewie!),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download_rounded, size: 18),
            label: const Text('Save Video'),
          ),
        ),
      ],
    );
  }
}

class AudioReply extends StatefulWidget {
  final String url;

  const AudioReply({super.key, required this.url});

  @override
  State<AudioReply> createState() => _AudioReplyState();
}

class _AudioReplyState extends State<AudioReply> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
      setState(() => _playing = false);
      return;
    }
    await _player.play(UrlSource(widget.url));
    setState(() => _playing = true);
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.surface2,
        foregroundColor: AppTheme.text,
      ),
      onPressed: _toggle,
      icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
      label: Text(_playing ? 'Pause audio' : 'Play audio'),
    );
  }
}
