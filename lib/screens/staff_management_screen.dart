import 'package:flutter/material.dart';
import '../models/staff_model.dart';
import '../services/staff_service.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final _staffService = StaffService();
  List<Staff> _staffList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    final list = await _staffService.getAllStaff();
    setState(() {
      _staffList = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スタッフ管理', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStaff,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _staffList.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final staff = _staffList[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    child: Text(staff.name[0], style: const TextStyle(color: Colors.orange)),
                  ),
                  title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(staff.role),
                  trailing: staff.isActive
                      ? Chip(
                          label: const Text('在籍中', style: TextStyle(fontSize: 10, color: Colors.white)),
                          backgroundColor: Colors.green[600],
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                        )
                      : const Chip(
                          label: Text('離職', style: TextStyle(fontSize: 10)),
                          shape: StadiumBorder(),
                        ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
