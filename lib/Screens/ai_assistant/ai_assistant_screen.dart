import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:snapcraft/core/constant.dart';
import 'package:snapcraft/widget/gradient_text.dart';
import 'ai_provider.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen>
    with TickerProviderStateMixin {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late AnimationController _pulseCtrl;

  final List<String> _suggestions = [
    'Enhance my photo automatically',
    'Make it look cinematic',
    'Apply a vintage look',
    'Boost colors naturally',
    'Add dramatic shadows',
    'Make it black & white',
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    ref.read(aiProvider.notifier).connect();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _msgCtrl.clear();
    ref.read(aiProvider.notifier).sendMessage(text);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiProvider);

    // Auto scroll on new messages
    ref.listen(aiProvider, (_, next) {
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    });

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.surfaceGradient,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Gap(80), // Space for floating header
                if (aiState.messages.isEmpty) _buildWelcome(aiState),
                Expanded(child: _buildChatList(aiState)),
                if (aiState.messages.isEmpty) _buildSuggestions(),
                _buildInputBar(aiState),
              ],
            ),
          ),

          // Floating Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(aiState),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AiState state) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 1),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.text1, size: 20),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Snap AI',
                          style: GoogleFonts.syne(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.text1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: state.isConnected
                                    ? AppTheme.success
                                    : AppTheme.text3,
                                shape: BoxShape.circle,
                                boxShadow: state.isConnected
                                    ? [
                                        BoxShadow(
                                          color:
                                              AppTheme.success.withOpacity(0.4),
                                          blurRadius: 6,
                                        )
                                      ]
                                    : null,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              state.isConnected ? 'AI Online' : 'Connecting...',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.text2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref.read(aiProvider.notifier).clearMessages(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 1),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppTheme.text2, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome(AiState state) {
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.4),
                      blurRadius: 35,
                      offset: const Offset(0, 15),
                    )
                  ],
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 48),
              ),
              const Gap(40),
              Text(
                'How can I help?',
                style: GoogleFonts.syne(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.text1,
                  letterSpacing: -1,
                ),
              ),
              const Gap(16),
              Text(
                'I can transform your photos with AI magic. Remove backgrounds, apply artistic filters, or enhance every detail with a simple request.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: AppTheme.text2,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(AiState state) {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: state.messages.length,
      itemBuilder: (_, i) => _MessageBubble(message: state.messages[i]),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(bottom: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _suggestions.length,
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () => _sendMessage(_suggestions[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: Center(
                child: Text(
                  _suggestions[i],
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(AiState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
                border: Border.all(color: AppTheme.border, width: 1.5),
              ),
              child: TextField(
                controller: _msgCtrl,
                style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: AppTheme.text1,
                    fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Ask AI magic...',
                  hintStyle: GoogleFonts.dmSans(
                      color: AppTheme.text3, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                onSubmitted: _sendMessage,
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const Gap(12),
          GestureDetector(
            onTap: () => _sendMessage(_msgCtrl.text),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final AiMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.2),
                    blurRadius: 10,
                  )
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 16),
            ),
            const Gap(12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: isUser ? AppTheme.brandGradient : null,
                color: isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isUser ? 24 : 6),
                  bottomRight: Radius.circular(isUser ? 6 : 24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
                border: isUser
                    ? null
                    : Border.all(color: AppTheme.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: isUser ? Colors.white : AppTheme.text1,
                      height: 1.6,
                      fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (message.imageFile != null) ...[
                    const Gap(12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(message.imageFile!,
                          width: 220, fit: BoxFit.cover),
                    ),
                  ],
                  if (message.suggestions != null) ...[
                    const Gap(14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: message.suggestions!
                          .map((s) => GestureDetector(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? Colors.white.withOpacity(0.15)
                                        : AppTheme.bg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: (isUser
                                                ? Colors.white
                                                : AppTheme.accentSecondary)
                                            .withOpacity(0.3),
                                        width: 1),
                                  ),
                                  child: Text(s,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isUser
                                            ? Colors.white
                                            : AppTheme.accentSecondary,
                                      )),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) const Gap(12),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
              gradient: AppTheme.brandGradient, shape: BoxShape.circle),
          child: const Icon(Icons.auto_awesome_rounded,
              color: Colors.white, size: 13),
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
                3, (i) => _Dot(delay: Duration(milliseconds: i * 200))),
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatefulWidget {
  final Duration delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.text2.withOpacity(0.4 + 0.6 * _anim.value),
        ),
        transform: Matrix4.translationValues(0, -4 * _anim.value, 0),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Icon(icon, color: AppTheme.text2, size: 18),
      ),
    );
  }
}
