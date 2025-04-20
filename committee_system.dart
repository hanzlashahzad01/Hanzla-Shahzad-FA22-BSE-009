import 'package:flutter/material.dart';
import 'member.dart';
import 'db_helper.dart';

class CommitteeManagementSystem {
  final DBHelper dbHelper = DBHelper();
  final double fixedContribution;
  int currentMemberIndex = 0;
  List<Member> members = [];

  CommitteeManagementSystem(this.fixedContribution);

  Future<void> loadMembers() async {
    members = await dbHelper.getMembers();
  }

  Future<void> addMember(String name) async {
    final newMember = Member(name: name);
    await dbHelper.insertMember(newMember);
    await loadMembers();
  }

  Future<void> collectContributions() async {
    for (var member in members) {
      member.totalContributed += fixedContribution;
      await dbHelper.updateMember(member);
    }
    await loadMembers();
  }

  Future<void> distributeFunds() async {
    if (members.isEmpty) return;

    double totalFunds = fixedContribution * members.length;
    members[currentMemberIndex].totalReceived += totalFunds;
    await dbHelper.updateMember(members[currentMemberIndex]);
    currentMemberIndex = (currentMemberIndex + 1) % members.length;
    await loadMembers();
  }

  bool allReceived() {
    return members.isNotEmpty &&
        members.every((member) => member.totalReceived > 0);
  }
}
