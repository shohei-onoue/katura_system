import 'package:flutter/material.dart';
import '../models/staff_model.dart';
import '../services/staff_service.dart';
import '../widgets/k_responsive.dart';

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
    if (!mounted) return;
    setState(() {
      _staffList = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('スタッフ管理', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 18))),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStaff,
            tooltip: '再読み込み',
          ),
          SizedBox(width: rs(context, 16)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(rav(context, 24)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: rs(context, 16),
                mainAxisSpacing: rs(context, 16),
                childAspectRatio: 2.8,
              ),
              itemCount: _staffList.length,
              itemBuilder: (context, index) {
                final staff = _staffList[index];
                return _buildStaffCard(staff);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStaffCard(Staff staff) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: EdgeInsets.all(rs(context, 16)),
      child: Row(
        children: [
          CircleAvatar(
            radius: rs(context, 24),
            backgroundColor: Colors.deepOrange.withValues(alpha: 0.1),
            child: Text(staff.name[0], 
              style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: rf(context, 18))),
          ),
          SizedBox(width: rs(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(staff.name, 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 15)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(staff.role, 
                  style: TextStyle(color: Colors.blueGrey, fontSize: rf(context, 12))),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _statusChip(staff.isActive),
              SizedBox(height: rs(context, 8)),
              Icon(Icons.more_horiz, color: Colors.grey, size: rs(context, 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 2)),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border.all(color: (isActive ? Colors.green : Colors.grey).withValues(alpha: 0.3)),
      ),
      child: Text(isActive ? '在籍中' : '離職', 
        style: TextStyle(fontSize: rf(context, 10), fontWeight: FontWeight.bold, color: isActive ? Colors.green.shade800 : Colors.grey.shade700)),
    );
  }
}
