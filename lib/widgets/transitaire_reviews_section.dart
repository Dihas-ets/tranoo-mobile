import 'package:flutter/material.dart';
import 'package:tranoo/services/transitaire_review_service.dart';
import 'package:tranoo/widgets/transitaire_profile_ui.dart';

class TransitaireInteractiveStarRating extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;
  final double size;

  const TransitaireInteractiveStarRating({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final star = index + 1;
        final filled = star <= value;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: size + 4, minHeight: size + 4),
          onPressed: onChanged == null ? null : () => onChanged!(star),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: kTransitaireAmber,
            size: size,
          ),
        );
      }),
    );
  }
}

class TransitaireReviewsSection extends StatefulWidget {
  final String transitaireId;
  final bool isOwner;

  const TransitaireReviewsSection({
    super.key,
    required this.transitaireId,
    required this.isOwner,
  });

  @override
  State<TransitaireReviewsSection> createState() =>
      _TransitaireReviewsSectionState();
}

class _TransitaireReviewsSectionState extends State<TransitaireReviewsSection> {
  bool _loading = true;
  bool _submitting = false;
  TransitaireReviewsPayload? _payload;
  int _selectedRating = 0;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final payload = widget.isOwner
          ? await TransitaireReviewService.instance.fetchReceived()
          : await TransitaireReviewService.instance.fetchForTransitaire(
              widget.transitaireId,
            );
      if (!mounted) return;
      setState(() {
        _payload = payload;
        _selectedRating = payload.myReview?.rating ?? 0;
        if (payload.myReview?.comment.isNotEmpty == true) {
          _commentController.text = payload.myReview!.comment;
        }
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedRating < 1) {
      showTranooToast(
        context,
        message: 'Choisissez une note entre 1 et 5 étoiles',
        isError: true,
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await TransitaireReviewService.instance.submitReview(
        transitaireId: widget.transitaireId,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
      );
      if (!mounted) return;
      showTranooToast(context, message: 'Votre avis a été enregistré');
      await _load();
    } catch (_) {
      if (!mounted) return;
      showTranooToast(
        context,
        message: 'Impossible d\'enregistrer votre avis',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildStarsRow(int rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: kTransitaireAmber,
        );
      }),
    );
  }

  Widget _buildReviewTile(TransitaireReviewData review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: kTransitaireAmber.withOpacity(0.25),
                backgroundImage: review.reviewerPhoto != null &&
                        review.reviewerPhoto!.isNotEmpty
                    ? NetworkImage(review.reviewerPhoto!)
                    : null,
                child: review.reviewerPhoto == null ||
                        review.reviewerPhoto!.isEmpty
                    ? Text(
                        review.reviewerName.isNotEmpty
                            ? review.reviewerName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kTransitaireNavy,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.reviewerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: kTransitaireNavy,
                  ),
                ),
              ),
              _buildStarsRow(review.rating),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final payload = _payload;
    final avg = payload?.ratingAverage ?? 0;
    final reviews = payload?.reviews ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Avis',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: kTransitaireNavy,
              ),
            ),
            const Spacer(),
            if (avg > 0) TransitaireStarRating(rating: avg, compact: true),
          ],
        ),
        const SizedBox(height: 12),
        if (!widget.isOwner) ...[
          const Text(
            'Noter ce transitaire',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: kTransitaireNavy,
            ),
          ),
          const SizedBox(height: 6),
          TransitaireInteractiveStarRating(
            value: _selectedRating,
            onChanged: (v) => setState(() => _selectedRating = v),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 2,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Commentaire (optionnel)',
              filled: true,
              fillColor: const Color(0xFFF5F6F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: kTransitaireAmber,
                foregroundColor: kTransitaireNavy,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _submitting ? 'Enregistrement...' : 'Envoyer mon avis',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (reviews.isEmpty)
          Text(
            widget.isOwner
                ? 'Vous n\'avez pas encore reçu d\'avis.'
                : 'Aucun avis pour le moment.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          )
        else
          ...reviews.map(_buildReviewTile),
      ],
    );
  }
}
