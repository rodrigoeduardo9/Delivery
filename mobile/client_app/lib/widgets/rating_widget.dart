import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../config/theme.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final ValueChanged<double>? onRatingChanged;
  final double itemSize;
  final bool interactive;

  const RatingWidget({
    super.key,
    this.rating = 0,
    this.onRatingChanged,
    this.itemSize = 32,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: itemSize,
      ignoreGestures: !interactive,
      itemBuilder: (context, index) {
        return const Icon(
          Icons.star,
          color: AppTheme.ratingStar,
        );
      },
      onRatingUpdate: (value) {
        onRatingChanged?.call(value);
      },
    );
  }
}

class RatingInputWidget extends StatefulWidget {
  final ValueChanged<double>? onSubmitted;
  final ValueChanged<String>? onCommentChanged;

  const RatingInputWidget({
    super.key,
    this.onSubmitted,
    this.onCommentChanged,
  });

  @override
  State<RatingInputWidget> createState() => _RatingInputWidgetState();
}

class _RatingInputWidgetState extends State<RatingInputWidget> {
  double _rating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Rate your experience',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        RatingBar.builder(
          initialRating: 0,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 40,
          itemBuilder: (context, index) {
            return const Icon(Icons.star, color: AppTheme.ratingStar);
          },
          onRatingUpdate: (value) {
            setState(() => _rating = value);
            widget.onSubmitted?.call(value);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _commentController,
          decoration: const InputDecoration(
            hintText: 'Write a comment (optional)',
            filled: true,
          ),
          maxLines: 3,
          onChanged: (v) => widget.onCommentChanged?.call(v),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _rating > 0
                ? () => widget.onSubmitted?.call(_rating)
                : null,
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }
}
