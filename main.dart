import 'package:flutter/material.dart';
import 'committee_system.dart';

void main() {
  runApp(CommitteeApp());
}

class CommitteeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Committee Management System',
      home: CommitteeHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CommitteeHome extends StatefulWidget {
  @override
  _CommitteeHomeState createState() => _CommitteeHomeState();
}

class _CommitteeHomeState extends State<CommitteeHome> {
  final CommitteeManagementSystem cms = CommitteeManagementSystem(100.0);
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    await cms.loadMembers();
    setState(() {});
  }

  Future<void> _addMember() async {
    if (nameController.text.isNotEmpty) {
      await cms.addMember(nameController.text);
      nameController.clear();
      setState(() {});
    }
  }

  Future<void> _collect() async {
    await cms.collectContributions();
    setState(() {});
  }

  Future<void> _distribute() async {
    await cms.distributeFunds();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Committee Management")),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Enter member name'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: _addMember, child: Text("Add Member")),
                ElevatedButton(onPressed: _collect, child: Text("Collect")),
                ElevatedButton(onPressed: _distribute, child: Text("Distribute")),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cms.members.length,
                itemBuilder: (context, index) {
                  final member = cms.members[index];
                  return ListTile(
                    title: Text("${member.name} (ID: ${member.id})"),
                    subtitle: Text(
                      "Contributed: ${member.totalContributed.toStringAsFixed(2)}, Received: ${member.totalReceived.toStringAsFixed(2)}",
                    ),
                  );
                },
              ),
            ),
            if (cms.allReceived())
              Text("✅ All members have received their share!",
                  style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
