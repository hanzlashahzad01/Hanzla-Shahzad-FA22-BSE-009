class Member {
  int? id;
  String name;
  double totalContributed;
  double totalReceived;

  Member({
    this.id,
    required this.name,
    this.totalContributed = 0,
    this.totalReceived = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'totalContributed': totalContributed,
      'totalReceived': totalReceived,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      totalContributed: map['totalContributed'],
      totalReceived: map['totalReceived'],
    );
  }
}
