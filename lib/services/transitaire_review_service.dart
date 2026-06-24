import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tranoo/services/user_service.dart';

class TransitaireReviewData {
  final String id;
  final String reviewerName;
  final String? reviewerPhoto;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  const TransitaireReviewData({
    required this.id,
    required this.reviewerName,
    this.reviewerPhoto,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory TransitaireReviewData.fromJson(Map<String, dynamic> json) {
    return TransitaireReviewData(
      id: json['_id']?.toString() ?? '',
      reviewerName: json['reviewerName']?.toString() ?? 'Utilisateur',
      reviewerPhoto: json['reviewerPhoto']?.toString(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class TransitaireReviewsPayload {
  final double ratingAverage;
  final int reviewCount;
  final List<TransitaireReviewData> reviews;
  final TransitaireReviewData? myReview;

  const TransitaireReviewsPayload({
    required this.ratingAverage,
    required this.reviewCount,
    required this.reviews,
    this.myReview,
  });

  factory TransitaireReviewsPayload.fromJson(Map<String, dynamic> json) {
    final list = (json['reviews'] as List?)
            ?.whereType<Map>()
            .map((e) => TransitaireReviewData.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];
    final my = json['myReview'];
    return TransitaireReviewsPayload(
      ratingAverage: (json['ratingAverage'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      reviews: list,
      myReview: my is Map
          ? TransitaireReviewData.fromJson(Map<String, dynamic>.from(my))
          : null,
    );
  }
}

class TransitaireReviewService {
  TransitaireReviewService._();
  static final TransitaireReviewService instance = TransitaireReviewService._();

  Dio get _dio => UserService().dio;

  Future<Map<String, String>> _headers() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<TransitaireReviewsPayload> fetchForTransitaire(String transitaireId) async {
    final resp = await _dio.get(
      '/transitaire-reviews/transitaire/$transitaireId',
      options: Options(headers: await _headers()),
    );
    if (resp.data is Map) {
      return TransitaireReviewsPayload.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    }
    return const TransitaireReviewsPayload(
      ratingAverage: 0,
      reviewCount: 0,
      reviews: [],
    );
  }

  Future<TransitaireReviewsPayload> fetchReceived() async {
    final resp = await _dio.get(
      '/transitaire-reviews/received',
      options: Options(headers: await _headers()),
    );
    if (resp.data is Map) {
      return TransitaireReviewsPayload.fromJson(
        Map<String, dynamic>.from(resp.data as Map),
      );
    }
    return const TransitaireReviewsPayload(
      ratingAverage: 0,
      reviewCount: 0,
      reviews: [],
    );
  }

  Future<TransitaireReviewsPayload> submitReview({
    required String transitaireId,
    required int rating,
    String comment = '',
  }) async {
    final resp = await _dio.post(
      '/transitaire-reviews',
      data: {
        'transitaireId': transitaireId,
        'rating': rating,
        'comment': comment,
      },
      options: Options(headers: await _headers()),
    );
    if (resp.data is Map) {
      final map = Map<String, dynamic>.from(resp.data as Map);
      final review = map['review'];
      return TransitaireReviewsPayload(
        ratingAverage: (map['ratingAverage'] as num?)?.toDouble() ?? 0,
        reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
        reviews: const [],
        myReview: review is Map
            ? TransitaireReviewData.fromJson(Map<String, dynamic>.from(review))
            : null,
      );
    }
    throw Exception('Réponse invalide');
  }

  Future<void> deleteReview(String reviewId) async {
    await _dio.delete(
      '/transitaire-reviews/$reviewId',
      options: Options(headers: await _headers()),
    );
  }
}
