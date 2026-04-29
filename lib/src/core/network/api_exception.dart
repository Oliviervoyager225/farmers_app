import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiException.fromDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] as String? ?? e.message ?? 'Erreur inconnue';
      final errors = data['errors'] as Map<String, dynamic>?;
      return ApiException(message: message, statusCode: statusCode, errors: errors);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(message: 'Délai de connexion dépassé');
      case DioExceptionType.connectionError:
        return const ApiException(message: 'Impossible de se connecter au serveur');
      default:
        return ApiException(
          message: e.message ?? 'Erreur inconnue',
          statusCode: statusCode,
        );
    }
  }

  /// Retourne la première erreur de validation pour un champ donné.
  String? fieldError(String field) {
    final list = errors?[field];
    if (list is List && list.isNotEmpty) return list.first as String;
    return null;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
