import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'dart:convert';
import '../../../../constants/systems_design.dart';

class SignLanguageVideoPage extends StatefulWidget {
  final String text;

  const SignLanguageVideoPage({super.key, required this.text});

  @override
  State<SignLanguageVideoPage> createState() => _SignLanguageVideoPageState();
}

class _SignLanguageVideoPageState extends State<SignLanguageVideoPage> {
  bool _isLoading = false;
  String? _error;
  List<String> _videoUrls = []; // Danh sách URLs
  int _currentVideoIndex = 0; // Video hiện tại đang phát
  String? _language = 'vi_VN';
  VideoPlayerController? _videoPlayerController;
  bool _isVideoPlaying = false;

  // Backend API endpoint
  static const String API_BASE_URL = 'http://192.168.73.101:5000';

  @override
  void initState() {
    super.initState();
    _fetchSignLanguageVideo();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  // Khởi tạo video player
  void _initializeVideoPlayer(String videoUrl) {
    // Giải phóng video player cũ nếu có
    _videoPlayerController?.dispose();

    _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      )
      ..initialize()
          .then((_) {
            setState(() {
              _isVideoPlaying = true;
            });
            _videoPlayerController!.play();

            // Lắng nghe sự kiện kết thúc video
            _videoPlayerController!.addListener(_onVideoEnd);
          })
          .catchError((error) {
            setState(() {
              _error = '❌ Lỗi phát video: $error';
            });
            print('❌ Video player error: $error');
          });
  }

  // Kiểm tra video có kết thúc không, nếu có thì phát video tiếp theo
  void _onVideoEnd() {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.position >=
            _videoPlayerController!.value.duration) {
      _playNextVideo();
    }
  }

  // Phát video tiếp theo
  void _playNextVideo() {
    if (_currentVideoIndex < _videoUrls.length - 1) {
      setState(() {
        _currentVideoIndex++;
      });
      print('▶️  Phát video ${_currentVideoIndex + 1}/${_videoUrls.length}');
      _initializeVideoPlayer(_videoUrls[_currentVideoIndex]);
    } else {
      setState(() {
        _isVideoPlaying = false;
      });
      print('✅ Đã phát xong tất cả ${_videoUrls.length} video');
    }
  }

  // Gọi API từ backend để lấy video ký hiệu
  Future<void> _fetchSignLanguageVideo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔄 Gọi API: $API_BASE_URL/api/generate-video');
      print('📝 Text: ${widget.text}');

      final response = await http
          .post(
            Uri.parse('$API_BASE_URL/api/generate-video'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': widget.text, 'language': _language}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout:
                () =>
                    throw Exception(
                      'Request timeout - Backend không phản hồi. Đảm bảo backend chạy tại $API_BASE_URL',
                    ),
          );

      print('✅ Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          // Lấy danh sách video URLs
          final videoUrls = List<String>.from(jsonResponse['videoUrls'] ?? []);

          if (videoUrls.isEmpty) {
            throw Exception('Không có video nào được tìm thấy');
          }

          setState(() {
            _videoUrls = videoUrls;
            _currentVideoIndex = 0;
            _isLoading = false;
          });

          print('✅ Nhận được ${videoUrls.length} video(s)');
          for (int i = 0; i < videoUrls.length; i++) {
            print('   Video ${i + 1}: ${videoUrls[i]}');
          }

          // 🎬 Khởi tạo video đầu tiên
          _initializeVideoPlayer(_videoUrls[0]);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Đã tải ${videoUrls.length} video ký hiệu!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          throw Exception(jsonResponse['error'] ?? 'Lỗi không xác định');
        }
      } else if (response.statusCode == 404) {
        final jsonResponse = jsonDecode(response.body);
        final missingWords = jsonResponse['missing_words'] ?? [];

        setState(() {
          _error =
              '❌ Không tìm thấy video cho các từ: ${missingWords.join(", ")}';
          _isLoading = false;
        });
      } else {
        throw Exception('❌ Lỗi từ server: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      setState(() {
        _error =
            '❌ Lỗi kết nối: Không thể kết nối đến backend.\n'
            'Backend URL: $API_BASE_URL\n'
            'Error: $e\n\n'
            'Đảm bảo:\n'
            '1. Backend đang chạy\n'
            '2. Emulator có kết nối internet\n'
            '3. Firewall cho phép port 5000';
        _isLoading = false;
      });
      print('❌ Connection error: $e');
    } catch (e) {
      setState(() {
        _error = '❌ Lỗi: $e';
        _isLoading = false;
      });
      print('❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade600,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.videocam, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Video Ký Hiệu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text being signed
            _buildTextCard(),
            SizedBox(height: 24),
            // Video section
            _buildVideoSection(),
            SizedBox(height: 24),
            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Văn bản:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    // Loading state
    if (_isLoading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.orange),
              SizedBox(height: 16),
              Text('Đang tải video...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    // Error state
    if (_error != null) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lỗi',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
      );
    }

    // Video player
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child:
          _videoPlayerController != null &&
                  _videoPlayerController!.value.isInitialized
              ? Column(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: _videoPlayerController!.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController!),
                    ),
                  ),
                  Container(
                    color: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _videoPlayerController!.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.orange,
                          ),
                          onPressed: () {
                            setState(() {
                              _videoPlayerController!.value.isPlaying
                                  ? _videoPlayerController!.pause()
                                  : _videoPlayerController!.play();
                            });
                          },
                        ),
                        Expanded(
                          child: VideoProgressIndicator(
                            _videoPlayerController!,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: Colors.orange,
                              bufferedColor: Colors.orange.withValues(
                                alpha: 0.5,
                              ),
                              backgroundColor: Colors.grey.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'Khởi tạo (${_currentVideoIndex + 1}/${_videoUrls.length})',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.refresh,
            label: 'Tải lại',
            onTap: _fetchSignLanguageVideo,
            color: Colors.orange,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.arrow_back,
            label: 'Quay lại',
            onTap: () => Navigator.pop(context),
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
