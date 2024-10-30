import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final String poemKey;
  final bool isLiked;
  final int likeCount;
  final VoidCallback onLikeToggle;

  const LikeButton({
    Key? key,
    required this.poemKey,
    required this.isLiked,
    required this.likeCount,
    required this.onLikeToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : Colors.grey,
      ),
      onPressed: onLikeToggle,
      tooltip: 'Beğeni: $likeCount',
    );
  }
}
