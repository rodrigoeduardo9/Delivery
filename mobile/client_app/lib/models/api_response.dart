class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'errors': errors,
      };
}

class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final data = json['data'] as List<dynamic>? ?? [];
    return PaginatedResponse(
      items: data.map((e) => fromJsonT(e)).toList(),
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      total: json['total'] as int? ?? 0,
    );
  }
}
