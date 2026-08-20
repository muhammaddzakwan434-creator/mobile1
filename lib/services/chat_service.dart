// =============================================================================
// FILE: lib/services/chat_service.dart
// FUNGSI: Service Pengelola Obrolan Real-Time (Cloud Firestore Engine)
// PATTERN: Singleton Pattern & Reactive Cloud Stream Architecture
// =============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// --------------------------------------------------------------------------
  /// FUNGSI 1: Mengirim Pesan (Sinkronisasi Langsung ke Cloud Firestore)
  /// --------------------------------------------------------------------------
  Future<void> sendMessage({
    required String threadId,
    required String text,
    required MessageSender sender,
    String? userId,
    String? userName,
    String? topic,
  }) async {
    final safeThreadId = threadId.replaceAll(RegExp(r'[^\w\-]'), '_');

    try {
      // 1. Tambahkan pesan ke sub-koleksi 'messages'
      await _firestore
          .collection('chats')
          .doc(safeThreadId)
          .collection('messages')
          .add({
        'text': text,
        'sender': sender == MessageSender.user ? 'user' : 'bot',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Update Dokumen Induk (Metadata Thread) agar Admin tahu ada pesan baru
      await _firestore.collection('chats').doc(safeThreadId).set({
        'threadId': safeThreadId,
        'userId': userId ?? 'SOA-GUEST',
        'userName': userName ?? 'Warga Sukabumi',
        'topic': topic ?? 'Layanan Publik',
        'lastMessage': text,
        'lastTime': FieldValue.serverTimestamp(),
        'unread': sender == MessageSender.user, // Mark unread if sent by user
      }, SetOptions(merge: true));
      
    } catch (e) {
      debugPrint('Cloud Chat Error: $e');
    }
  }

  /// --------------------------------------------------------------------------
  /// FUNGSI 2: Mendapatkan Aliran Pesan Real-Time (Cloud Firestore Stream)
  /// --------------------------------------------------------------------------
  Stream<List<ChatMessage>> getMessages(String threadId) {
    final safeThreadId = threadId.replaceAll(RegExp(r'[^\w\-]'), '_');

    return _firestore
        .collection('chats')
        .doc(safeThreadId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          text: data['text'] ?? '',
          sender: data['sender'] == 'user' ? MessageSender.user : MessageSender.bot,
          timestamp: data['timestamp'] != null 
              ? (data['timestamp'] as Timestamp).toDate() 
              : DateTime.now(),
        );
      }).toList();
    });
  }

  /// --------------------------------------------------------------------------
  /// FUNGSI 3: Mendapatkan Daftar Semua Percakapan (Untuk Inbox Admin)
  /// --------------------------------------------------------------------------
  Stream<QuerySnapshot> getChatThreads() {
    return _firestore
        .collection('chats')
        .orderBy('lastTime', descending: true)
        .snapshots();
  }

  /// --------------------------------------------------------------------------
  /// FUNGSI 4: Tandai Pesan Telah Dibaca oleh Admin
  /// --------------------------------------------------------------------------
  Future<void> markAsRead(String threadId) async {
    try {
      final safeThreadId = threadId.replaceAll(RegExp(r'[^\w\-]'), '_');
      await _firestore.collection('chats').doc(safeThreadId).update({'unread': false});
    } catch (e) {
      debugPrint('Mark as read error: $e');
    }
  }

  void dispose() {
    // Tidak lagi butuh timer polling
  }
}
