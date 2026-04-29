// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/shimmer_card.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _api.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 4),
            _buildTabs(),
            const SizedBox(height: 8),
            Expanded(child: _buildPostList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WEVERSE',
                style: GoogleFonts.nunito(
                  color: AppTheme.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Feed',
                style: GoogleFonts.nunito(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.bgCard,
              border: Border.all(color: AppTheme.divider),
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: AppTheme.textSecondary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _tab('Posts', true),
          const SizedBox(width: 8),
          _tab('Artistas', false),
          const SizedBox(width: 8),
          _tab('Live', false),
        ],
      ),
    );
  }

  Widget _tab(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: active ? AppTheme.accent : AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          color: active ? AppTheme.bgPrimary : AppTheme.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildPostList() {
    return FutureBuilder<List<Post>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            itemCount: 6,
            itemBuilder: (_, __) => const ShimmerCard(),
          );
        }
        if (snapshot.hasError) {
          return _buildError();
        }
        final posts = snapshot.data!;
        return RefreshIndicator(
          color: AppTheme.accent,
          backgroundColor: AppTheme.bgCard,
          onRefresh: () async {
            setState(() {
              _postsFuture = _api.getPosts();
            });
          },
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _PostCard(
                post: posts[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(post: posts[index]),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: AppTheme.textMuted, size: 48),
          const SizedBox(height: 16),
          Text('No se pudo cargar el feed',
              style: GoogleFonts.nunito(
                  color: AppTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _postsFuture = _api.getPosts()),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Reintentar',
                  style: GoogleFonts.nunito(
                      color: AppTheme.bgPrimary,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final List<String> _fakeNames = const [
    'Jeon Jungkook', 'Kim Taehyung', 'Park Jimin', 'Min Yoongi',
    'Jung Hoseok', 'Kim Namjoon', 'Jin Seokjin', 'Son Heung-min',
    'Lee Minho', 'Hwang Hyunjin',
  ];

  const _PostCard({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final authorName = _fakeNames[post.userId % _fakeNames.length];
    final timeAgo = '${(post.id * 7) % 23}h';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  AvatarWidget(name: authorName, size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              authorName,
                              style: GoogleFonts.nunito(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded,
                                color: AppTheme.accent, size: 14),
                          ],
                        ),
                        Text(
                          timeAgo,
                          style: GoogleFonts.nunito(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '#${post.id}',
                      style: GoogleFonts.nunito(
                        color: AppTheme.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Title
              Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                post.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              // Footer
              Row(
                children: [
                  _actionButton(Icons.favorite_border_rounded,
                      '${(post.id * 13) % 200}'),
                  const SizedBox(width: 20),
                  _actionButton(
                      Icons.chat_bubble_outline_rounded, '5'),
                  const SizedBox(width: 20),
                  _actionButton(Icons.share_outlined, ''),
                  const Spacer(),
                  Text(
                    'Ver más →',
                    style: GoogleFonts.nunito(
                      color: AppTheme.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textMuted, size: 18),
        if (count.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(count,
              style: GoogleFonts.nunito(
                  color: AppTheme.textMuted, fontSize: 12)),
        ],
      ],
    );
  }
}
