import 'package:flutter/material.dart';
import 'package:frontend/widgets/bottom_nav_bar.dart';

import '../logic/answers_given_logic.dart';

class AnswersGivenPage extends StatefulWidget {
  const AnswersGivenPage({super.key});

  @override
  State<AnswersGivenPage> createState() => _AnswersGivenPageState();
}

class _AnswersGivenPageState extends State<AnswersGivenPage> {
  final AnswersGivenLogic _logic = AnswersGivenLogic();

  @override
  void initState() {
    super.initState();
    _logic.fetchData(
      onUpdate: () => mounted ? setState(() {}) : null,
      onErrorRedirect: (msg) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
          Navigator.pushReplacementNamed(context, '/start');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_logic.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Answers Given')),
      bottomNavigationBar: const MyBottomNavigationBar(currentIndex: 1),
      body: _logic.answers.isEmpty
          ? const Center(child: Text('No answers found'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _logic.answers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final a = _logic.answers[index];
                final answerId = a['_id']?.toString();
                final content = a['content'] ?? 'No content';
                final questionId = a['questionid']?.toString();

                if (answerId == null || questionId == null)
                  return const SizedBox.shrink();

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.blue[100],
                  child: ListTile(
                    title: Text(
                      content,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/question_details',
                        arguments: {
                          'questionid': questionId,
                          'highlightAnswerId': answerId,
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
