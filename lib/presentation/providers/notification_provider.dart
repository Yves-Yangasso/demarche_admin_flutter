import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime date;
  bool isRead;
  final String? dossierId;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.date,
    this.isRead = false,
    this.dossierId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // M4 : contrat backend stabilisé sur snake_case français - titre, message, lu.
    // (cf. app/models/historique_statut.py::Notification.to_dict())
    return AppNotification(
      id: json['id'].toString(),
      title: (json['titre'] ?? 'Notification').toString(),
      body: (json['message'] ?? '').toString(),
      type: (json['type'] ?? 'info').toString(),
      date: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      isRead: json['lu'] == true,
      dossierId: json['dossier_id']?.toString(),
    );
  }
}

class NotificationProvider with ChangeNotifier {
  final ApiClient _apiClient;

  NotificationProvider(this._apiClient);

  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get("/notifications");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List notifsJson = data['notifications'] ?? [];
        _notifications =
            notifsJson.map((json) => AppNotification.fromJson(json)).toList();
      }
    } catch (e) {
      // Ignorer l'erreur pour ne pas bloquer l'UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    // Optimistic update
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }

    try {
      await _apiClient.patch("/notifications/$id/lire", {});
    } catch (e) {
      // Revert si erreur ? Pour les notifications, souvent on laisse.
    }
  }

  Future<void> markAllAsRead() async {
    // Optimistic update
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();

    try {
      await _apiClient.patch("/notifications/tout-lire", {});
    } catch (e) {
      // Ignorer
    }
  }
}
