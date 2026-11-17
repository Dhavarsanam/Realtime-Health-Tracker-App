import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';
import '../../widgets/chat_widgets.dart';
import '../../widgets/common.dart';

class ChatRoomScreen extends StatefulWidget {
  final Conversation conversation;
  final bool doctor;
  const ChatRoomScreen({super.key, required this.conversation, this.doctor = false});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  late final List<ChatMessage> _msgs = widget.doctor
      ? MockData.chatThread.map((m) => ChatMessage(m.text, !m.mine, m.time)).toList()
      : List.of(MockData.chatThread);
  bool _typing = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _msgs.add(ChatMessage(t, true, DateTime.now()));
      _typing = true;
    });
    _end();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() {
      _typing = false;
      _msgs.add(ChatMessage(widget.doctor ? 'Thank you doctor, I\'ll follow that.' : 'Noted. I\'ll review your latest readings and get back to you shortly.', false, DateTime.now()));
    });
    _end();
  }

  void _end() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent + 200, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
        }
      });

  @override
  Widget build(BuildContext context) {
    final c = widget.conversation;
    final g = widget.doctor ? AppColors.doctor : AppColors.brand;
    return Scaffold(
      body: AuroraBackground(
        showGrid: false,
        child: Column(children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: Row(children: [
                GlassIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.pop(context)),
                const SizedBox(width: 12),
                Avatar(initials: c.initials, color: c.color, size: 46, online: c.online),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    Text(_typing ? 'typing…' : (c.online ? 'Online' : 'Last seen recently'), style: TextStyle(color: _typing || c.online ? AppColors.emerald : AppColors.textMuted, fontSize: 12)),
                  ]),
                ),
                GlassIconButton(icon: Icons.call_rounded, onTap: () {}),
                const SizedBox(width: 8),
                GlassIconButton(icon: Icons.videocam_rounded, onTap: () {}),
              ]),
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scroll,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.lock_rounded, size: 12, color: AppColors.textMuted),
                      SizedBox(width: 6),
                      Flexible(child: Text('Messages are end-to-end encrypted · Today', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                    ]),
                  ),
                ),
                for (final m in _msgs) ChatBubble(text: m.text, mine: m.mine, time: m.time, gradient: g),
                if (_typing) const TypingIndicator(),
              ],
            ),
          ),
          ChatComposer(controller: _ctrl, onSend: _send, gradient: g),
        ]),
      ),
    );
  }
}
