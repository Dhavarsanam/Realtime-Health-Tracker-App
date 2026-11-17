import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/glass.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatelessWidget {
  final bool doctor;
  const ChatListScreen({super.key, this.doctor = false});

  List<Conversation> get _items => doctor
      ? MockData.patients
          .map((p) => Conversation(
                name: p.name,
                role: p.condition,
                lastMessage: p.status.index >= 2 ? 'Doctor, I\'m feeling dizzy today…' : 'Thanks, I logged my vitals.',
                time: p.lastUpdate,
                unread: p.status.index >= 2 ? 1 : 0,
                online: p.status.index.isEven,
                color: p.avatarColor,
              ))
          .toList()
      : MockData.conversations;

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
        children: [
          Entrance(child: Text('Messages', style: Theme.of(context).textTheme.headlineMedium)),
          Entrance(index: 1, child: Text(doctor ? 'Secure chat with your patients' : 'Your care team, end-to-end encrypted', style: const TextStyle(color: AppColors.textSecondary))),
          const SizedBox(height: 18),
          const Entrance(index: 2, child: TextField(decoration: InputDecoration(hintText: 'Search conversations', prefixIcon: Icon(Icons.search_rounded)))),
          const SizedBox(height: 18),
          Entrance(
            index: 3,
            child: SizedBox(
              height: 86,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, i) => Column(children: [
                  Avatar(initials: items[i].initials, color: items[i].color, size: 58, online: items[i].online, ring: items[i].online),
                  const SizedBox(height: 6),
                  Text(items[i].name.replaceAll('Dr. ', '').split(' ').first, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...items.asMap().entries.map((e) {
            final c = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Entrance(
                index: 4 + e.key,
                child: GlassCard(
                  radius: 22,
                  padding: const EdgeInsets.all(14),
                  onTap: () => Navigator.of(context).push(premiumRoute(ChatRoomScreen(conversation: c, doctor: doctor))),
                  child: Row(children: [
                    Avatar(initials: c.initials, color: c.color, size: 52, online: c.online),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(c.role, style: TextStyle(color: c.color, fontSize: 11.5, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Text(c.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                      ]),
                    ),
                    const SizedBox(width: 8),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(c.time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 20,
                        child: c.unread > 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(gradient: AppColors.brand, borderRadius: BorderRadius.circular(10)),
                                child: Text('${c.unread}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                              )
                            : null,
                      ),
                    ]),
                  ]),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
