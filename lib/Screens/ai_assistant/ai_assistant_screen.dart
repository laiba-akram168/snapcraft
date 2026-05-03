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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(aiState),
            if (aiState.messages.isEmpty) _buildWelcome(aiState),
            Expanded(child: _buildChatList(aiState)),
            if (aiState.messages.isEmpty) _buildSuggestions(),
            _buildInputBar(aiState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AiState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: Row(
        children: [
          // AI Avatar with pulse
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.accentPurple, AppTheme.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: state.isConnected
                    ? [
                        BoxShadow(
                          color: AppTheme.accentPurple
                              .withOpacity(0.3 + 0.2 * _pulseCtrl.value),
                          blurRadius: 12 + 8 * _pulseCtrl.value,
                        )
                      ]
                    : [],
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const Gap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientText(
                'SnapAI',
                gradient: AppTheme.brandGradient,
                style:
                    GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          state.isConnected ? AppTheme.success : AppTheme.text3,
                    ),
                  ),
                  const Gap(5),
                  Text(
                    state.isConnected
                        ? 'Online · Ready to enhance'
                        : 'Connecting...',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color:
                          state.isConnected ? AppTheme.success : AppTheme.text3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          _IconBtn(icon: Icons.settings_outlined, onTap: () {}),
          const Gap(8),
          _IconBtn(icon: Icons.more_vert_rounded, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildWelcome(AiState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentPurple.withOpacity(0.12),
                  AppTheme.accent.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border, width: 0.5),
            ),
            child: Column(
              children: [
                const Icon(Icons.waving_hand_rounded,
                    color: AppTheme.accentPurple, size: 32),
                const Gap(12),
                Text(
                  'Hi! I\'m SnapAI',
                  style: GoogleFonts.syne(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text1),
                ),
                const Gap(8),
                Text(
                  'Your AI-powered photo enhancement assistant. Tell me how you\'d like to transform your photo.',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppTheme.text2, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(AiState state) {
    if (state.messages.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: state.messages.length + (state.isTyping ? 1 : 0),
      itemBuilder: (_, i) {
        if (state.isTyping && i == state.messages.length) {
          return _TypingBubble();
        }
        final msg = state.messages[i];
        return _MessageBubble(message: msg);
      },
    );
  }

  Widget _buildSuggestions() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestions.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _sendMessage(_suggestions[i]),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border, width: 0.5),
            ),
            child: Text(
              _suggestions[i],
              style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(AiState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: Row(
        children: [
          // Attach image button
          GestureDetector(
            onTap: () => ref.read(aiProvider.notifier).attachImage(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border, width: 0.5),
              ),
              child: const Icon(Icons.attach_file_rounded,
                  color: AppTheme.text2, size: 18),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border, width: 0.5),
              ),
              child: TextField(
                controller: _msgCtrl,
                style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text1),
                decoration: InputDecoration(
                  hintText: 'Ask SnapAI anything...',
                  hintStyle:
                      GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text3),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: _sendMessage,
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const Gap(10),
          GestureDetector(
            onTap: () => _sendMessage(_msgCtrl.text),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: AppTheme.accentGradient,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 18),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                gradient: AppTheme.brandGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 13),
            ),
            const Gap(8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isUser ? AppTheme.accentGradient : null,
                color: isUser ? null : AppTheme.card,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(color: AppTheme.border, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  if (message.imageFile != null) ...[
                    const Gap(8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(message.imageFile!,
                          width: 180, fit: BoxFit.cover),
                    ),
                  ],
                  if (message.suggestions != null) ...[
                    const Gap(10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: message.suggestions!
                          .map((s) => GestureDetector(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppTheme.accentPurple
                                            .withOpacity(0.4),
                                        width: 0.5),
                                  ),
                                  child: Text(s,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        color: AppTheme.accentPurple,
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
