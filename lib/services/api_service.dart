import 'package:dio/dio.dart';

const _kApiBaseUrl = 'https://nl-api.yellowriver-4dd2d26f.australiaeast.azurecontainerapps.io';

class EncryptedResultPayload {
  final String patientId;
  final String encryptedResultB64;
  final String resultNonceB64;
  final String wrappedResultKeyB64;
  final String patientKeyEnvelopeB64;
  final String createdAt;

  const EncryptedResultPayload({
    required this.patientId,
    required this.encryptedResultB64,
    required this.resultNonceB64,
    required this.wrappedResultKeyB64,
    required this.patientKeyEnvelopeB64,
    required this.createdAt,
  });

  factory EncryptedResultPayload.fromJson(Map<String, dynamic> json) {
    return EncryptedResultPayload(
      patientId: json['patient_id']?.toString() ?? '',
      encryptedResultB64: json['encrypted_result_b64']?.toString() ?? '',
      resultNonceB64: json['result_nonce_b64']?.toString() ?? '',
      wrappedResultKeyB64: json['wrapped_result_key_b64']?.toString() ?? '',
      patientKeyEnvelopeB64: json['patient_key_envelope_b64']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _kApiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  Future<({String patientId, String password, String resultKeyB64})?> registerPatient({
    required String patientId,
    String? doctorId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/patient/register',
      data: {
        'patient_id': patientId,
        if (doctorId != null) 'doctor_id': doctorId,
      },
    );

    if (response.statusCode == 201 && response.data != null) {
      final data = response.data!;
      return (
        patientId: data['patient_id']?.toString() ?? '',
        password: data['password']?.toString() ?? '',
        resultKeyB64: data['result_key_b64']?.toString() ?? '',
      );
    }

    if (response.statusCode == 409) return null;

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      error: 'Register failed with ${response.statusCode}: ${response.data}',
    );
  }

  Future<({String token, String? resultKeyB64})> authenticatePatient({
    required String patientId,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/patient/auth',
      data: {'patient_id': patientId, 'password': password},
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data!;
      return (
        token: data['access_token']?.toString() ?? '',
        resultKeyB64: data['result_key_b64']?.toString(),
      );
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      error: 'Auth failed with ${response.statusCode}: ${response.data}',
    );
  }

  Future<EncryptedResultPayload?> fetchLatestResult({
    required String patientId,
    required String token,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/results/$patientId/latest',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200 && response.data != null) {
      return EncryptedResultPayload.fromJson(response.data!);
    }
    if (response.statusCode == 404) return null;

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      error: 'Result fetch failed with ${response.statusCode}: ${response.data}',
    );
  }

  Future<List<EncryptedResultPayload>> fetchResultHistory({
    required String patientId,
    required String token,
    int limit = 50,
  }) async {
    final response = await _dio.get<dynamic>(
      '/v1/results/$patientId',
      queryParameters: {'limit': limit},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      List<dynamic> rawItems;

      if (data is List) {
        rawItems = data;
      } else if (data is Map<String, dynamic>) {
        final items = data['items'];
        rawItems = items is List ? items : const [];
      } else if (data is Map) {
        final mapData = Map<String, dynamic>.from(data);
        final items = mapData['items'];
        rawItems = items is List ? items : const [];
      } else {
        rawItems = const [];
      }

      return rawItems
          .whereType<Map>()
          .map((json) => EncryptedResultPayload.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }

    if (response.statusCode == 404) return [];

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      error: 'Result history fetch failed with ${response.statusCode}: ${response.data}',
    );
  }
}