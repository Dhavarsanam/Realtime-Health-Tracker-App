import 'package:flutter/material.dart';

import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/chat_widgets.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';
import '../../widgets/orb3d.dart';

/// AI health assistant UI. Responses are mocked on the frontend; wire
/// `_reply` to your Mistral-7B inference endpoint later.
class AiChatbotScreen extends StatefulWidget {
  final VoidCallback? onClose;
  const AiChatbotScreen({super.key, this.onClose});

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <ChatMessage>[];
  bool _typing = false;

  static const _suggestions = [
    'Is my blood pressure healthy?',
    'How can I lower my glucose?',
    'Tips for better sleep',
    'How much water should I drink?',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _reply(String q) {
    final s = q.toLowerCase();
    if (s.contains('pressure') || s.contains('bp')) {
      return 'Your latest reading of 118/76 mmHg is in the optimal range (below 120/80). Your 7-day average is 120/78, so things are stable. Keep sodium under 2,300 mg a day and keep up your current activity.';
    }
    if (s.contains('glucose') || s.contains('sugar')) {
      return 'Your fasting glucose of 108 mg/dL is slightly above optimal (70–99). Three things help most:\n\n• A 10–15 min walk after meals\n• Swapping refined carbs for whole grains\n• Eating protein or fiber before carbs\n\nI\'ll keep an eye on your trend over the next week.';
    }
    if (s.contains('sleep')) {
      return 'You averaged 7.4 h this week, which is good. To improve sleep quality: keep a consistent bedtime, cut caffeine after 2 PM, dim screens an hour before bed, and keep your room around 18 °C.';
    }
    if (s.contains('water') || s.contains('hydrat')) {
      return 'At your weight and activity level, aim for about 2.8 L a day. You\'re at 1.9 L today, so about 4 more glasses. I\'ve set your hydration reminder to every 2 hours.';
    }
    return 'Good question. Based on your recent vitals your overall health score is 92 out of 100. Could you tell me a bit more so I can give you more specific guidance? For anything urgent, please contact your doctor or use SOS.';
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _ctrl.text).trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _messages.add(ChatMessage(text, true, DateTime.now()));
      _typing = true;
    });
    _toEnd();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _typing = false;
      _messages.add(ChatMessage(_reply(text), false, DateTime.now()));
    });
    _toEnd();
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent + 200, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(children: [
              GlassIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: widget.onClose ?? () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 12),
              const HoloOrb(size: 50, colors: [AppColors.violet, AppColors.pink], speed: 2),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Vita AI', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                  Row(children: [
                    Icon(Icons.circle, size: 8, color: AppColors.emerald),
                    SizedBox(width: 5),
                    Flexible(child: Text('Mistral‑7B · on-device context', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5))),
                  ]),
                ]),
              ),
              GlassIconButton(icon: Icons.refresh_rounded, onTap: () => setState(_messages.clear)),
            ]),
          ),
        ),
        Expanded(
          child: _messages.isEmpty
              ? _empty()
              : ListView(
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    for (final m in _messages) ChatBubble(text: m.text, mine: m.mine, time: m.time, gradient: const LinearGradient(colors: [AppColors.violet, AppColors.pink])),
                    if (_typing) const TypingIndicator(),
                  ],
                ),
        ),
        ChatComposer(controller: _ctrl, onSend: _send, hint: 'Ask about your health…', leading: Icons.mic_none_rounded, gradient: const LinearGradient(colors: [AppColors.violet, AppColors.pink])),
      ],
    );

    if (widget.onClose != null) return body;
    return Scaffold(body: AuroraBackground(colors: const [AppColors.violet, AppColors.pink, AppColors.indigo], child: body));
  }

  Widget _empty() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        const Entrance(child: Center(child: HoloOrb(size: 220, colors: [AppColors.violet, AppColors.pink], child: Icon(Icons.auto_awesome_rounded, size: 40, color: Colors.white)))),
        Entrance(
          index: 1,
          child: Center(child: GradientText('How can I help today?', gradient: const LinearGradient(colors: [Colors.white, AppColors.pink]), style: Theme.of(context).textTheme.headlineMedium)),
        ),
        const SizedBox(height: 8),
        const Entrance(
          index: 2,
          child: Text('I can read your logged vitals and give you personal health suggestions.',
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
        ),
        const SizedBox(height: 24),
        ..._suggestions.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Entrance(
                index: 3 + e.key,
                child: GlassCard(
                  radius: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  onTap: () => _send(e.value),
                  child: Row(children: [
                    const Icon(Icons.bolt_rounded, color: AppColors.pink, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600))),
                    const Icon(Icons.north_east_rounded, size: 16, color: AppColors.textMuted),
                  ]),
                ),
              ),
            )),
        const SizedBox(height: 8),
        const Text('Vita AI gives general guidance only and doesn\'t replace your doctor.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}
