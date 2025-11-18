import 'package:flutter/material.dart';

import '../logic/admin_logic.dart';
import 'admin_user_details_page.dart';
import 'report_detail_page.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with TickerProviderStateMixin {
  final AdminLogic _logic = AdminLogic();
  late TabController _mainTabController;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _reports = [];
  bool _loadingUsers = false;
  bool _loadingReports = false;

  String _userSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _fetchUsers();
    _fetchReports();
  }

  Future<void> _fetchUsers() async {
    setState(() => _loadingUsers = true);
    var users = await _logic.fetchUsers(
      onUpdate: () => setState(() {}),
      onErrorRedirect: (msg) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg))),
    );
    setState(() {
      _users = users;
      _loadingUsers = false;
    });
  }

  Future<void> _fetchReports() async {
    setState(() => _loadingReports = true);
    var reports = await _logic.fetchReports(
      onUpdate: () => setState(() {}),
      onErrorRedirect: (msg) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg))),
    );
    setState(() {
      _reports = reports;
      _loadingReports = false;
    });
  }

  Future<void> _deleteUser(String id) async {
    final ok = await _logic.deleteItem('/user/$id');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'User deleted ✅' : 'Delete failed ❌'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
    if (ok) _fetchUsers();
  }

  void _handleLogout() async {
    await _logic.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Filter users based on search query
    final filteredUsers = _userSearchQuery.isEmpty
        ? _users
        : _users.where((user) {
            final username = user['Username']?.toString().toLowerCase() ?? '';
            final email = user['Email']?.toString().toLowerCase() ?? '';
            final query = _userSearchQuery.toLowerCase();
            return username.contains(query) || email.contains(query);
          }).toList();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          backgroundColor: Colors.blue[200],
          bottom: TabBar(
            controller: _mainTabController,
            tabs: const [
              Tab(text: 'Users'),
              Tab(text: 'Reports'),
            ],
            indicatorColor: Colors.white,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _handleLogout,
            ),
          ],
        ),
        body: TabBarView(
          controller: _mainTabController,
          children: [
            // ---------------- Users Tab ----------------
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search users by username or email',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                    ),
                    onChanged: (val) => setState(() => _userSearchQuery = val),
                  ),
                ),
                Expanded(
                  child: _loadingUsers
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: _fetchUsers,
                          child: filteredUsers.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No users found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(12),
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemCount: filteredUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = filteredUsers[index];
                                    return Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                        title: Text(
                                          user['Username'] ?? 'No Username',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          user['Email'] ?? 'No Email',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          tooltip: 'Delete User',
                                          onPressed: () =>
                                              _deleteUser(user['_id']),
                                        ),
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AdminUserDetailsPage(
                                                  user: user,
                                                ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),

            // ---------------- Reports Tab (Improved Layout) ----------------
            _loadingReports
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchReports,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: _reports.length,
                      itemBuilder: (context, index) {
                        final report = _reports[index];

                        // Safe data extraction
                        final reportContent =
                            report['reason'] ?? '(No report content)';
                        final reportedBy =
                            report['reportedBy']?['Username'] ?? 'Unknown User';
                        final reportedEmail =
                            report['reportedBy']?['Email'] ?? '';
                        final targetType =
                            report['targetType']?.toString().toUpperCase() ??
                            'UNKNOWN';
                        final targetContent =
                            report['details']?['content'] ??
                            '(No target content)';

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.blue[50],
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            title: Text(
                              '🚩 $reportContent',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '📨 Reported by: $reportedBy (${reportedEmail.isNotEmpty ? reportedEmail : "no email"})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '🧩 Type: $targetType',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '🗒️ Target: $targetContent',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReportDetailPage(reportId: report['_id']),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
