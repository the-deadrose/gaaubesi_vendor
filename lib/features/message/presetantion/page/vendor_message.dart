import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/message/presetantion/bloc/vendor_message_bloc.dart';
import 'package:gaaubesi_vendor/features/message/presetantion/bloc/vendor_message_event.dart';
import 'package:gaaubesi_vendor/features/message/presetantion/bloc/vendor_message_state.dart';
import 'package:gaaubesi_vendor/features/message/domain/entity/vendor_message_list_entity.dart';
import 'package:intl/intl.dart';

@RoutePage()
class VendorMessagesScreen extends StatefulWidget {
  const VendorMessagesScreen({super.key});

  @override
  VendorMessagesScreenState createState() => VendorMessagesScreenState();
}

class VendorMessagesScreenState extends State<VendorMessagesScreen> {
  final ScrollController _scrollController = ScrollController();
  late VendorMessageBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<VendorMessageBloc>();

    _bloc.add(FetchVendorMessageListEvent(page: "1"));

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_bloc.hasMore) {
        final nextPage = (_bloc.currentPage + 1).toString();
        _bloc.add(FetchVendorMessageListPaginationEvent(page: nextPage));
      }
    }
  }

  void _refreshMessages() {
    _bloc.add(FetchVendorMessageListEvent(page: "1"));
  }

  void _showMessageDialog(VendorMessageEntity message) {
    showDialog(
      context: context,
      builder: (context) => _buildMessageDialog(message),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  Widget _buildMessageDialog(VendorMessageEntity message) {
    Theme.of(context);

    return BlocListener<VendorMessageBloc, VendorMessageState>(
      listener: (context, state) {
        if (state is VendorMessageMarkAsReadSuccess &&
            state.messageId == message.id.toString()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Message marked as read',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppTheme.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
        if (state is VendorMessageMarkAsReadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppTheme.rojo,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.marianBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: AppTheme.marianBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.createdByName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(message.createdOn),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!message.isRead) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.rojo,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'UNREAD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message',
                        style: TextStyle(
                          color: AppTheme.blackBean,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        message.message,
                        style: TextStyle(
                          color: AppTheme.blackBean,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),

                      // Divider
                      const SizedBox(height: 24),
                      Divider(color: AppTheme.powerBlue, height: 1),
                      const SizedBox(height: 16),

                      // Additional info
                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        label: 'Date Sent',
                        value: DateFormat(
                          'MMM dd, yyyy - hh:mm a',
                        ).format(message.createdOn),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.person,
                        label: 'Sender',
                        value: message.createdByName,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.email,
                        label: 'Status',
                        value: message.isRead ? 'Read' : 'Unread',
                        valueColor: message.isRead
                            ? AppTheme.successGreen
                            : AppTheme.rojo,
                      ),
                    ],
                  ),
                ),
              ),

            // Footer buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppTheme.powerBlue, width: 1),
                ),
              ),
              child: BlocBuilder<VendorMessageBloc, VendorMessageState>(
                builder: (context, state) {
                  final isLoading = state is VendorMessageMarkAsReadLoading;
                  
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.blackBean,
                            side: BorderSide(color: AppTheme.powerBlue),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (!message.isRead) {
                                    context.read<VendorMessageBloc>().add(
                                          MarkMessageAsReadEvent(
                                            messageId: message.id.toString(),
                                          ),
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.marianBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            disabledBackgroundColor: AppTheme.marianBlue.withValues(alpha: 0.5),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                )
                              : Text(
                                  message.isRead ? 'Reply' : 'Mark as Read',
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    )
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.marianBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: AppTheme.darkGray, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? AppTheme.blackBean,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppTheme.powerBlue.withValues(alpha: 0.3),
            height: 1,
          ),
        ),
      ),
      body: Container(
        color: AppTheme.whiteSmoke,
        child: BlocConsumer<VendorMessageBloc, VendorMessageState>(
          listener: (context, state) {
            if (state is VendorMessageError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: AppTheme.rojo,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is VendorMessageLoading) {
              return _buildLoadingState();
            }

            if (state is VendorMessageEmpty) {
              return _buildEmptyState();
            }

            if (state is VendorMessageLoaded ||
                state is VendorMessagePaginated ||
                state is VendorMessagePaginating) {
              final vendorMessageList = state is VendorMessageLoaded
                  ? state.vendorMessageList
                  : state is VendorMessagePaginated
                  ? state.vendorMessageList
                  : null;

              if (vendorMessageList == null) {
                return _buildLoadingState();
              }

              return _buildMessageList(vendorMessageList, state);
            }

            if (state is VendorMessageError) {
              return _buildErrorState(state.message);
            }

            return _buildLoadingState();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.powerBlue.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: CircleAvatar(
              backgroundColor: AppTheme.lightGray,
              child: Icon(Icons.person, color: AppTheme.darkGray),
            ),
            title: Container(
              height: 16,
              width: 120,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            subtitle: Container(
              height: 14,
              width: 200,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.marianBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.message_outlined,
                size: 64,
                color: AppTheme.marianBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Messages Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.blackBean,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any messages yet.\nMessages from customers will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _refreshMessages,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.marianBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                elevation: 2,
              ),
              child: const Text('Refresh Messages'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.rojo.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 48, color: AppTheme.rojo),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Load Messages',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.blackBean,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.maybePop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.blackBean,
                    side: const BorderSide(color: AppTheme.powerBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _refreshMessages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.marianBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    elevation: 2,
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(
    VendorMessageListEntity vendorMessageList,
    VendorMessageState state,
  ) {
    final messages = vendorMessageList.results;

    return RefreshIndicator(
      onRefresh: () async {
        _refreshMessages();
        return Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppTheme.marianBlue,
      backgroundColor: Colors.white,
      displacement: 40,
      strokeWidth: 3,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: messages.length + (state is VendorMessagePaginating ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          // Show loading indicator at the bottom when paginating
          if (state is VendorMessagePaginating && index == messages.length) {
            return _buildPaginationLoader();
          }

          final message = messages[index];
          return _buildMessageCard(message, index);
        },
      ),
    );
  }

  Widget _buildPaginationLoader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.marianBlue),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard(VendorMessageEntity message, int index) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 200 + (index * 50)),
      opacity: 1,
      child: Transform.translate(
        offset: Offset(0, index * 0.5),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: message.isRead ? 0 : 2,
          shadowColor: AppTheme.marianBlue.withValues(alpha: 0.1),
          child: InkWell(
            onTap: () => _showMessageDialog(message),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: message.isRead
                      ? Colors.transparent
                      : AppTheme.marianBlue.withValues(alpha: 0.3),
                  width: message.isRead ? 0 : 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
                color: message.isRead
                    ? Colors.white
                    : AppTheme.marianBlue.withValues(alpha: 0.05),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: message.isRead
                          ? AppTheme.lightGray
                          : AppTheme.marianBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: message.isRead
                          ? AppTheme.darkGray
                          : AppTheme.marianBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Message Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sender and time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.createdByName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: message.isRead
                                          ? AppTheme.blackBean
                                          : AppTheme.marianBlue,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDateTime(message.createdOn),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.darkGray,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!message.isRead) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.rojo.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.rojo.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  'New',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.rojo,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Message preview
                        Text(
                          message.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.blackBean,
                            fontWeight: message.isRead
                                ? FontWeight.normal
                                : FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // Read status and chevron
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (!message.isRead) ...[
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppTheme.rojo,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Unread',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.rojo,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: AppTheme.successGreen,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Read',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.successGreen,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            Icon(
                              Icons.chevron_right,
                              color: AppTheme.powerBlue,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Today at ${DateFormat('h:mm a').format(dateTime)}';
    } else if (messageDate == yesterday) {
      return 'Yesterday at ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('MMM d, yyyy - h:mm a').format(dateTime);
    }
  }
}
