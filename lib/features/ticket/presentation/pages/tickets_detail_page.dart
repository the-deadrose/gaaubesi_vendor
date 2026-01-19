import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/entity/pending_ticket_list_entity.dart';

@RoutePage()
class TicketDetailScreen extends StatefulWidget {
  final PendingTicketEntity ticket;
  final String? category;

  const TicketDetailScreen({super.key, required this.ticket, this.category});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _replyController.text = widget.ticket.reply ?? '';
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.confirmation_number, color: AppTheme.marianBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ticket #${widget.ticket.id}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.blackBean,
                  ),
                ),
              ),
              _buildStatusBadge(widget.ticket.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.ticket.subject,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.blackBean,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDateOnly(widget.ticket.createdOnFormatted),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                _formatTimeOnly(widget.ticket.createdOnFormatted),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = AppTheme.warningYellow.withValues(alpha: 0.2);
        textColor = AppTheme.warningYellow;
        label = 'Pending';
        icon = Icons.pending;
        break;
      case 'closed':
        backgroundColor = AppTheme.successGreen.withValues(alpha: 0.2);
        textColor = AppTheme.successGreen;
        label = 'Closed';
        icon = Icons.check_circle;
        break;
      case 'resolved':
        backgroundColor = AppTheme.infoBlue.withValues(alpha: 0.2);
        textColor = AppTheme.infoBlue;
        label = 'Resolved';
        icon = Icons.verified;
        break;
      default:
        backgroundColor = AppTheme.powerBlue.withValues(alpha: 0.2);
        textColor = AppTheme.powerBlue;
        label = status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: AppTheme.marianBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.blackBean,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.ticket.description,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppTheme.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateOnly(String formattedDateTime) {
    try {
      // Format: "2026-01-18 16:25"
      final parts = formattedDateTime.split(' ');
      if (parts.isNotEmpty) {
        final datePart = parts[0];
        final date = DateTime.parse(datePart);
        // Using basic formatting without importing intl
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      return formattedDateTime;
    } catch (e) {
      return formattedDateTime;
    }
  }

  String _formatTimeOnly(String formattedDateTime) {
    try {
      // Format: "2026-01-18 16:25"
      final parts = formattedDateTime.split(' ');
      if (parts.length >= 2) {
        return parts[1];
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
               backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text('Ticket Detail'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildHeader(), _buildDescriptionCard()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
