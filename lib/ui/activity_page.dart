import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('your activities'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings action if needed
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // Logo section -- update to your logo asset path
          Center(child: Image.asset('assets/logo.png', height: 180)),
          const SizedBox(height: 16),
          // Activity buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                ActivityButton(
                  text: 'Questions Asked',
                  onTap: () {
                    Navigator.pushNamed(context, '/questions_asked');
                  },
                ),
                const SizedBox(height: 18),
                ActivityButton(
                  text: 'Answers Given',
                  onTap: () {
                    Navigator.pushNamed(context, '/answers_given');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const ActivityButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.blue),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.blue)),
      ),
    );
  }
}
