class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      message: json['message'] as String?,
      error: json['error'] as String?,
      statusCode: json['status_code'] as int?,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      success: false,
      error: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final itemsList = (json['items'] as List<dynamic>)
        .map((e) => fromJsonT(e))
        .toList();
    return PaginatedResponse(
      items: itemsList,
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }
}
