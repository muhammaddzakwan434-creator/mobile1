import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/chat_message_model.dart';
import '../../services/chat_service.dart';

class AdminChatInboxScreen extends StatefulWidget {
  final bool isEmbedded;
  const AdminChatInboxScreen({super.key, this.isEmbedded = false});

  @override
  State<AdminChatInboxScreen> createState() => _AdminChatInboxScreenState();
}

class _AdminChatInboxScreenState extends State<AdminChatInboxScreen> {
  final ChatService _chatService = ChatService();

  void _bukaRuangChatAdmin(String threadId, String userName, String topic) {
    _chatService.markAsRead(threadId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminChatRoomScreen(
          threadId: threadId,
          userName: userName,
          topic: topic,
          onMessageSent: (newMsg) {
            _chatService.sendMessage(
              threadId: threadId,
              text: newMsg,
              sender: MessageSender.bot,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0A1E33);
    const accentColor = Color(0xFFE8A33D);

    if (widget.isEmbedded) {
      return _buildMainContent(primaryColor, accentColor);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.headset_mic_rounded, color: accentColor, size: 22),
            SizedBox(width: 10),
            Text(
              'Inbox Live Chat Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
      body: _buildMainContent(primaryColor, accentColor),
    );
  }

  Widget _buildMainContent(Color primaryColor, Color accentColor) {
    return Column(
      children: [
        // HEADER BANNER STATISTIK (DARI FIREBASE)
        StreamBuilder<QuerySnapshot>(
          stream: _chatService.getChatThreads(),
          builder: (context, snapshot) {
            int total = 0;
            int unread = 0;
            if (snapshot.hasData) {
              total = snapshot.data!.docs.length;
              unread = snapshot.data!.docs.where((d) => (d.data() as Map)['unread'] == true).length;
            }

            return Container(
              padding: const EdgeInsets.all(16),
              color: primaryColor,
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Total Pesan', '$total', Icons.chat_rounded, accentColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      'Perlu Balasan',
                      '$unread',
                      Icons.mark_chat_unread_rounded,
                      Colors.redAccent,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // LIST PERCAKAPAN MASUK DARI WARGA (DARI FIREBASE ONLINE)
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _chatService.getChatThreads(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final threads = snapshot.data?.docs ?? [];

              if (threads.isEmpty) {
                return const Center(child: Text('Belum ada chat dari warga.', style: TextStyle(fontFamily: 'Poppins')));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: threads.length,
                itemBuilder: (context, index) {
                  final threadDoc = threads[index];
                  final threadId = threadDoc.id;
                  final threadData = threadDoc.data() as Map<String, dynamic>;
                  final bool isUnread = threadData['unread'] == true;
                  final String userName = threadData['userName'] ?? 'Warga';
                  final String userId = threadData['userId'] ?? 'SOA-GUEST';
                  final String topic = threadData['topic'] ?? 'Umum';
                  final String lastMsg = threadData['lastMessage'] ?? '';
                  
                  String timeStr = 'Baru saja';
                  if (threadData['lastTime'] != null) {
                    final DateTime date = (threadData['lastTime'] as Timestamp).toDate();
                    timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} WIB';
                  }

                  return GestureDetector(
                    onTap: () => _bukaRuangChatAdmin(threadId, userName, topic),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isUnread ? accentColor : Colors.grey.shade200,
                          width: isUnread ? 2 : 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: primaryColor.withOpacity(0.08),
                            child: Icon(Icons.person_rounded, color: primaryColor, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: primaryColor,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          'ID: $userId',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      timeStr,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: isUnread ? accentColor : Colors.grey,
                                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    topic,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  lastMsg,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isUnread ? Colors.black87 : Colors.grey.shade600,
                                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                                    fontFamily: 'Poppins',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'Poppins'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LAYAR RUANG CHAT ADMIN (MEMBALAS PESAN WARGA SECARA LANGSUNG)
// ---------------------------------------------------------------------------
class AdminChatRoomScreen extends StatefulWidget {
  final String threadId;
  final String userName;
  final String topic;
  final ValueChanged<String> onMessageSent;

  const AdminChatRoomScreen({
    super.key,
    required this.threadId,
    required this.userName,
    required this.topic,
    required this.onMessageSent,
  });

  @override
  State<AdminChatRoomScreen> createState() => _AdminChatRoomScreenState();
}

class _AdminChatRoomScreenState extends State<AdminChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _kirimBalasanAdmin() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onMessageSent(text);
    _controller.clear();

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0A1E33);
    const accentColor = Color(0xFFE8A33D);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: accentColor,
              child: Icon(Icons.person, color: primaryColor, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                ),
                Text(
                  'Topik: ${widget.topic}',
                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'Poppins'),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // DAFTAR PESAN OBROLAN (DARI FIREBASE ONLINE)
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(widget.threadId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];
                
                // Scroll ke bawah saat pesan baru masuk
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final bool isAdmin = msg.sender != MessageSender.user;

                    return Align(
                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isAdmin ? primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(14).copyWith(
                            bottomRight: isAdmin ? Radius.zero : const Radius.circular(14),
                            bottomLeft: !isAdmin ? Radius.zero : const Radius.circular(14),
                          ),
                          boxShadow: const [
                            BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 2))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAdmin ? 'Petugas Admin SOA' : widget.userName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isAdmin ? accentColor : primaryColor,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg.text,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isAdmin ? Colors.white : Colors.black87,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // INPUT CHAT BALASAN ADMIN
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      hintText: 'Ketik balasan admin ke warga...',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Poppins'),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      fillColor: const Color(0xFFF4F6F9),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: accentColor, size: 20),
                    onPressed: _kirimBalasanAdmin,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
