class BookingFlowData {
  String sessionType;
  List<String> groupMembers;
  DateTime? selectedMonth;
  DateTime? selectedDate;
  String topic;
  String topicTitle;
  String visibility;
  String backupPerson;

  BookingFlowData({
    this.sessionType = 'individual',
    this.groupMembers = const [],
    this.selectedMonth,
    this.selectedDate,
    this.topic = '',
    this.topicTitle = '',
    this.visibility = 'Public',
    this.backupPerson = '',
  });
}