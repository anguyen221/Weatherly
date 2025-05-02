import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'themes.dart';

class CommunityReportsScreen extends StatefulWidget {
  const CommunityReportsScreen({super.key});

  @override
  State<CommunityReportsScreen> createState() => _CommunityReportsScreenState();
}

class _CommunityReportsScreenState extends State<CommunityReportsScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? location;
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = AuthService().currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          username = doc['username'];
          location = doc['location'];
        });
      }
    }
  }

  Future<void> _postReport() async {
    if (_messageController.text.trim().isEmpty || username == null || location == null) return;

    await FirebaseFirestore.instance.collection('community_reports').add({
      'username': username,
      'location': location,
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: AppThemes.selectedTheme ?? ValueNotifier(null),
      builder: (context, selectedTheme, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Community Reports')),
          body: Container(
            decoration: AppThemes.getBackgroundDecoration(selectedTheme),
            width: double.infinity,
            height: double.infinity,
            child: location == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            labelText: 'Enter your report',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _postReport,
                        child: const Text('Post'),
                      ),
                      const Divider(),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('community_reports')
                              .where('location', isEqualTo: location)
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final reports = snapshot.data!.docs;

                            if (reports.isEmpty) {
                              return const Center(child: Text('No reports yet.'));
                            }

                            return ListView.builder(
                              itemCount: reports.length,
                              itemBuilder: (context, index) {
                                final data = reports[index];
                                return ListTile(
                                  title: Text(data['message']),
                                  subtitle: Text('By ${data['username']}'),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}