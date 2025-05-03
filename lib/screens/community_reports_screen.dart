import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import 'themes.dart';

class CommunityReportsScreen extends StatefulWidget {
  const CommunityReportsScreen({super.key});

  @override
  State<CommunityReportsScreen> createState() => _CommunityReportsScreenState();
}

class _CommunityReportsScreenState extends State<CommunityReportsScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _location;
  String? _username;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = AuthService().currentUser;
    if (user != null) {
      _uid = user.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _username = doc['username'];
          _location = doc['location'];
        });
      }
    }
  }

  Future<void> _postReport() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _username == null || _location == null) return;

    await FirebaseFirestore.instance.collection('community_reports').add({
      'uid': _uid,
      'username': _username,
      'location': _location,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  Future<void> _deleteReport(String docId) async {
    await FirebaseFirestore.instance.collection('community_reports').doc(docId).delete();
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
            child: _location == null
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
                              .where('location', isEqualTo: _location)
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(child: Text('Error loading reports.'));
                            }
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
                                final report = reports[index];
                                final data = report.data() as Map<String, dynamic>;
                                final timestamp = data['timestamp'] as Timestamp?;
                                final formattedTime = timestamp != null
                                    ? DateFormat.yMMMd().add_jm().format(timestamp.toDate())
                                    : 'Just now';

                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    title: Text(data['message']),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('By ${data['username']}'),
                                        const SizedBox(height: 4),
                                        Text(formattedTime, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                    trailing: data['uid'] == _uid
                                        ? IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.black),
                                            onPressed: () => _deleteReport(report.id),
                                          )
                                        : null,
                                  ),
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