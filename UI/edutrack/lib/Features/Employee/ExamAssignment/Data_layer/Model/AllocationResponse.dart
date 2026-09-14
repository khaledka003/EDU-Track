class AllocationResponse {
  String? status;
  String? message;
  int? allocationId;

  AllocationResponse({this.status, this.message, this.allocationId});

  // تحويل JSON القادم من API إلى Object
  factory AllocationResponse.fromJson(Map<String, dynamic> json) {
    return AllocationResponse(
      status: json['status'],
      message: json['message'],
      allocationId: json['allocation_id'],
    );
  }
}
