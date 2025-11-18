import 'package:flutter/material.dart';

import '../logic/admin_user_details_logic.dart';
import 'question_details_page.dart' as detailsPage;

class AdminUserDetailsPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const AdminUserDetailsPage({super.key, required this.user});

  @override
  State<AdminUserDetailsPage> createState() => _AdminUserDetailsPageState();
}

class _AdminUserDetailsPageState extends State<AdminUserDetailsPage>
    with TickerProviderStateMixin {
  final AdminUserDetailsLogic _logic = AdminUserDetailsLogic();
  late TabController _tabController;
  List<Map<String, dynamic>> questions = [];
  List<Map<String, dynamic>> answers = [];
  List<Map<String, dynamic>> comments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData('question');

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 0:
            _loadData('question');
            break;
          case 1:
            _loadData('answer');
            break;
          case 2:
            _loadData('comment');
            break;
        }
      }
    });
  }

  Future<void> _loadData(String type) async {
    setState(() => loading = true);
    final data = await _logic.fetchUserContent(type, widget.user['_id']);
    setState(() {
      if (type == 'question') questions = data;
      if (type == 'answer') answers = data;
      if (type == 'comment') comments = data;
      loading = false;
    });
  }

  Future<void> _deleteItem(String type, String id) async {
    final ok = await _logic.deleteUserContent(type, id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Deleted successfully ✅' : 'Delete failed ❌'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
    if (ok) _loadData(type);
  }

  Widget _buildList(List<Map<String, dynamic>> items, String type) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No data found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final content = item['content'] ?? '(No content)';

        return Card(
          color: Colors.blue[50],
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            title: Text(
              content,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete',
              onPressed: () => _deleteItem(type, item['_id']),
            ),
            onTap: () {
              if (type == 'question') {
                // Navigate to question details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => detailsPage.QuestionDetailsPage(
                      questionid: item['_id'],
                    ),
                  ),
                );
              } else if (type == 'answer') {
                // Navigate using question ID from answer
                final questionId =
                    item['questionid']?['_id'] ?? item['questionid'];
                if (questionId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => detailsPage.QuestionDetailsPage(
                        questionid: questionId,
                        highlightAnswerId: item['_id'],
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No linked question found ❌')),
                  );
                }
              } else if (type == 'comment') {
                // Safe & reliable handling for comments
                final answer = item['answerId'];
                String? questionId;

                if (answer is Map && answer['questionid'] is Map) {
                  questionId = answer['questionid']['_id'];
                } else if (answer is Map && answer['questionid'] is String) {
                  questionId = answer['questionid'];
                }

                if (questionId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => detailsPage.QuestionDetailsPage(
                        questionid: questionId!,
                        highlightAnswerId: answer['_id'],
                      ),
                    ),
                  );
                } else {
                  print('❌ No valid questionId for comment ${item['_id']}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No linked question found ❌'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('User: ${widget.user['Username'] ?? 'Unknown'}'),
        backgroundColor: Colors.blue[400],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Questions'),
            Tab(text: 'Answers'),
            Tab(text: 'Comments'),
          ],
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(questions, 'question'),
          _buildList(answers, 'answer'),
          _buildList(comments, 'comment'),
        ],
      ),
    );
  }
}
