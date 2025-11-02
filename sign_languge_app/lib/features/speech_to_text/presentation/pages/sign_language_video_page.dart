import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchSignLanguageVideo();
  }

  // TODO: Gọi API từ backend để lấy video ký hiệu
  Future<void> _fetchSignLanguageVideo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Placeholder API call
      // final response = await signLanguageApi.getVideo(widget.text);
      // _videoUrl = response.videoUrl;

      // Tạm thời sử dụng delay để mô phỏng API call
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        // TODO: _videoUrl = response.videoUrl từ backend
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Không thể tải video: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Gradient AppBar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.md,
                    top: AppSpacing.md,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.videocam, color: Colors.white, size: 28),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Video Ký Hiệu',
                              style: AppTypography.h2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Xem cách biểu diễn ký hiệu',
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text being signed
                  _buildTextCard(),
                  SizedBox(height: AppSpacing.xxl),
                  // Video or Loading/Error
                  _buildVideoSection(),
                  SizedBox(height: AppSpacing.xxl),
                  // Action Buttons
                  _buildActionButtons(),
                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextCard() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.text_fields, color: Colors.orange, size: 24),
              ),
              SizedBox(width: AppSpacing.md),
              Text(
                'Văn bản',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            widget.text,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    if (_isLoading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Đang tải video...',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Colors.red, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 24),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Lỗi',
                    style: AppTypography.h4.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: AppTypography.bodyLarge.copyWith(color: Colors.red),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.play_circle_filled,
              size: 60,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Video Demo Ký Hiệu',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Nhấn để phát video',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hành động',
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.refresh,
                label: 'Tải lại',
                onTap: _fetchSignLanguageVideo,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildActionButton(
                icon: Icons.download,
                label: 'Tải xuống',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tải xuống video sắp ra mắt'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                color: Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.share,
                label: 'Chia sẻ',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Chia sẻ sắp ra mắt'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
                color: Colors.purple,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildActionButton(
                icon: Icons.arrow_back,
                label: 'Quay lại',
                onTap: () => Navigator.pop(context),
                color: AppColors.textSecondary,
              ),
            ),
          ],
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
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
