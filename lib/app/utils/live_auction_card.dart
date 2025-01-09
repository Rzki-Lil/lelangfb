import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/color.dart';

class LiveAuctionCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final double price;
  final String location;
  final String rarity;
  final String id;
  final DateTime endTime;
  final int bidCount;
  final VoidCallback onTap;
  final bool showLiveBadge;
  final Function(String)? onStatusChange; // Add this

  const LiveAuctionCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.location,
    required this.rarity,
    required this.id,
    required this.endTime,
    required this.bidCount,
    required this.onTap,
    this.showLiveBadge = true,
    this.onStatusChange,
  }) : super(key: key);

  @override
  State<LiveAuctionCard> createState() => _LiveAuctionCardState();
}

class _LiveAuctionCardState extends State<LiveAuctionCard> {
  Timer? _timer;
  String _timeRemaining = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeRemaining = _calculateTimeRemaining();
        });

        // Only call onStatusChange when needed
        final now = DateTime.now();
        if (now.isAfter(widget.endTime) && _timeRemaining == 'Ended') {
          widget.onStatusChange?.call(widget.id);
          _timer?.cancel();
          // Remove the dialog trigger
        }
      }
    });
  }

  String _calculateTimeRemaining() {
    final now = DateTime.now();
    final difference = widget.endTime.difference(now);

    if (difference.isNegative) {
      _timer?.cancel();
      return 'Ended'; 
    }

    final minutes = difference.inMinutes;
    final seconds = difference.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Label
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    image: DecorationImage(
                      image: NetworkImage(widget.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          color: Colors.white,
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          _timeRemaining,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.showLiveBadge)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildBadge(
                          widget.rarity, _getRarityColor(widget.rarity)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.name,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _formatPrice(widget.price),
                      style: TextStyle(
                        color: AppColors.hijauTua,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Location section
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 12, color: Colors.grey[600]),
                              SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  _extractCityOnly(widget.location),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Bid count section
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.gavel,
                                size: 12, color: Colors.grey[600]),
                            SizedBox(width: 2),
                            Text(
                              '${widget.bidCount} bids',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double amount) {
    try {
      return NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(amount);
    } catch (e) {
      print('Error formatting price: $e');
      return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }

  String _extractCityOnly(String fullLocation) {
    final parts = fullLocation.split(',');
    return parts.length > 1 ? parts[1].trim() : parts[0].trim();
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey;
      case 'uncommon':
        return Colors.green;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      case 'mythic':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
