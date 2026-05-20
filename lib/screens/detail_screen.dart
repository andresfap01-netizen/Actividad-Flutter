// lib/screens/detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../viewmodels/detail_viewmodel.dart';
import '../widgets/avatar_widget.dart';
import 'user_screen.dart';

class DetailScreen extends StatelessWidget {
  final Post post;

  const DetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // Provider local: solo vive mientras DetailScreen esté abierta
    return ChangeNotifierProvider(
      create: (_) => DetailViewModel()..loadData(post.userId, post.id),
      child: _DetailView(post: post),
    );
  }
}

class _DetailView extends StatelessWidget {
  final Post post;

  const _DetailView({required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Consumer<DetailViewModel>(
          builder: (context, vm, _) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAuthorRow(context, vm.user, vm.isLoading),
                      _buildPostContent(),
                      _buildStats(),
                      _buildDivider(),
                      _buildCommentsHeader(vm.comments.length),
                    ],
                  ),
                ),
                if (vm.isLoading)
                  SliverToBoxAdapter(child: _buildCommentsShimmer())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _CommentTile(comment: vm.comments[i]),
                      childCount: vm.comments.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.bgPrimary,
      pinned: true,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.divider),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 16),
        ),
      ),
      title: Text('Post',
          style: GoogleFonts.nunito(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18)),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.divider),
          ),
          child: const Icon(Icons.more_horiz_rounded,
              color: AppTheme.textSecondary, size: 20),
        ),
      ],
    );
  }

  Widget _buildAuthorRow(BuildContext context, User? user, bool loading) {
    return GestureDetector(
      onTap: user != null
          ? () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => UserScreen(user: user)))
          : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          children: [
            if (loading)
              Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppTheme.bgCard))
            else
              AvatarWidget(name: user?.name ?? '', size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (loading) ...[
                    Container(
                        width: 130,
                        height: 13,
                        color: AppTheme.bgCard,
                        margin: const EdgeInsets.only(bottom: 6)),
                    Container(width: 90, height: 11, color: AppTheme.bgCard),
                  ] else ...[
                    Row(
                      children: [
                        Text(user?.name ?? '',
                            style: GoogleFonts.nunito(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded,
                            color: AppTheme.accent, size: 15),
                      ],
                    ),
                    Text('@${user?.username ?? ''}',
                        style: GoogleFonts.nunito(
                            color: AppTheme.textMuted, fontSize: 13)),
                  ],
                ],
              ),
            ),
            if (!loading)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                ),
                child: Text('Ver perfil',
                    style: GoogleFonts.nunito(
                        color: AppTheme.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.title,
              style: GoogleFonts.nunito(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                  letterSpacing: -0.3)),
          const SizedBox(height: 14),
          Text(post.body,
              style: GoogleFonts.nunito(
                  color: AppTheme.textSecondary, fontSize: 15, height: 1.7)),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _statChip(Icons.favorite_rounded, '${(post.id * 13) % 200}',
              const Color(0xFFFF6B6B)),
          const SizedBox(width: 12),
          _statChip(Icons.remove_red_eye_outlined, '${post.id * 47}',
              AppTheme.accentPurple),
          const SizedBox(width: 12),
          _statChip(Icons.share_rounded, 'Compartir', AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.nunito(
                  color: color, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        height: 1,
        color: AppTheme.divider);
  }

  Widget _buildCommentsHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Text('Comentarios',
              style: GoogleFonts.nunito(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(20)),
            child: Text('$count',
                style: GoogleFonts.nunito(
                    color: AppTheme.bgPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsShimmer() {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(14)),
          child: const SizedBox(height: 60),
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(name: comment.name, size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    Text(comment.email,
                        style: GoogleFonts.nunito(
                            color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(comment.body,
              style: GoogleFonts.nunito(
                  color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}