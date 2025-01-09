import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/color.dart';
import 'dart:async';

class UpcomingAuctionCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final double price;
  final String location;
  final String rarity;
  final DateTime date;
  final String startTime;
  final VoidCallback onTap;
  final String category;
  final String id;
  final Function(String)? onStatusChange;

  const UpcomingAuctionCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.location,
    required this.rarity,
    required this.date,
    required this.startTime,
    required this.onTap,
    this.category = 'Others',
    required this.id,
    this.onStatusChange,
  }) : super(key: key);

  @override
  State<UpcomingAuctionCard> createState() => _UpcomingAuctionCardState();
}

class _UpcomingAuctionCardState extends State<UpcomingAuctionCard> {
  StreamSubscription? _auctionStatusSubscription;
  StreamController<bool>? _statusController;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _statusController = StreamController<bool>();
    _setupAuctionStatusStream();
  }

  @override
  void dispose() {
    _auctionStatusSubscription?.cancel();
    _statusController?.close();
    super.dispose();
  }

  void _setupAuctionStatusStream() {
    _auctionStatusSubscription = Stream.periodic(
      const Duration(seconds: 1),
      (_) => _checkAuctionStatus(),
    ).listen((hasStarted) {
      if (mounted && hasStarted) {
        widget.onStatusChange?.call(widget.id);
        _auctionStatusSubscription?.cancel();
      }
    });
  }

  bool _checkAuctionStatus() {
    final now = DateTime.now();
    final startTime = _getStartDateTime();
    final hasStarted = now.isAfter(startTime);

    if (hasStarted != _hasStarted) {
      setState(() {
        _hasStarted = hasStarted;
      });
    }

    return hasStarted;
  }

  DateTime _getStartDateTime() {
    final parts = widget.startTime.split(':');
    return DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('d MMM y', 'id_ID').format(date);
    } catch (e) {
      return DateFormat('d MMM y').format(date);
    }
  }

  String _formatPrice(double amount) {
    try {
      return NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(amount);
    } catch (e) {
      return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }

  String _extractCityOnly(String fullLocation) {
    final parts = fullLocation.split(',');
    return parts.length > 1 ? parts[1].trim() : parts[0].trim();
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
            // Start Time Label & Image section
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
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 10, color: Colors.black),
                        SizedBox(width: 4),
                        Text(
                          _hasStarted ? 'Started' : widget.startTime,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Category badge remains at bottom-right
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: _buildBadge(widget.category, Colors.white,
                      isCategory: true),
                ),
              ],
            ),

            // Content section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status and Rarity badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBadge('UPCOMING', AppColors.hijauTua),
                        _buildBadge(
                            widget.rarity, _getRarityColor(widget.rarity)),
                      ],
                    ),
                    SizedBox(height: 4),

                    // Name
                    Text(
                      widget.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),

                    // Price
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
                        // Location
                        Expanded(
                          flex: 1,
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
                        // Date
                        Expanded(
                          flex: 1,
                          child: Text(
                            _formatDate(widget.date),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
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

  Widget _buildBadge(String text, Color color, {bool isCategory = false}) {
    if (isCategory) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
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
