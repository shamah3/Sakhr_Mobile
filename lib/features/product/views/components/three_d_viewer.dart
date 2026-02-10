import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bytore/core/constants/constants.dart';

class ThreeDProductViewer extends StatefulWidget {
  final List<String> images;
  final double height;

  const ThreeDProductViewer({
    super.key,
    required this.images,
    this.height = 300,
  });

  @override
  State<ThreeDProductViewer> createState() => _ThreeDProductViewerState();
}

class _ThreeDProductViewerState extends State<ThreeDProductViewer> {
  int _currentIndex = 0;
  double _lastPos = 0.0;
  bool _isLoading = true;
  int _imagesLoaded = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImages();
    });
  }

  void _preloadImages() {
    for (String url in widget.images) {
      precacheImage(CachedNetworkImageProvider(url), context).then((_) {
        setState(() {
          _imagesLoaded++;
          if (_imagesLoaded == widget.images.length) {
            _isLoading = false;
          }
        });
      });
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isLoading) return;
    
    // Sensitivity: for 36 frames, we want a smoother, more responsive feel
    // Total width of container / number of images gives pixels per image
    final boxWidth = context.size?.width ?? 300.0;
    final sensitivity = boxWidth / (widget.images.length * 1.5); // Adjust multiplier for feel
    
    _lastPos += details.delta.dx;

    if (_lastPos.abs() > sensitivity) {
      setState(() {
        if (_lastPos > 0) {
          // Dragging right -> rotate counter-clockwise or clockwise depending on user expectation
          // For most 3D viewers, dragging right moves the product to show its right side (which is decrementing index in many sequences)
          _currentIndex = (_currentIndex - 1 + widget.images.length) % widget.images.length;
        } else {
          _currentIndex = (_currentIndex + 1) % widget.images.length;
        }
        _lastPos = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isLoading)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: kPrimaryColor),
                const SizedBox(height: 10),
                Text(
                  "جاري تحميل العرض 3D... (${(_imagesLoaded / widget.images.length * 100).toInt()}%)",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          
          GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            child: Image(
              image: CachedNetworkImageProvider(widget.images[_currentIndex]),
              gaplessPlayback: true, // Prevents flickering
              fit: BoxFit.contain,
              height: widget.height,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.error_outline, color: Colors.red),
              ),
            ),
          ),

          // Instruction Overlay
          Positioned(
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swipe_outlined, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    "اسحب للتدوير 360 درجة",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Angle Indicators (Optional)
          Positioned(
            right: 20,
            top: 20,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_motion_rounded, color: kPrimaryColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
