import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/orderdetail/domain/entities/order_detail_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/cards/order_card_actions.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_bloc.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_event.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_state.dart';

@RoutePage()
class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage>
    with OrderCardActionsMixin {
  bool _isMessagesExpanded = true;
  bool _isCommentsExpanded = true;
  final TextEditingController _newCommentController = TextEditingController();
  String _selectedCommentType = 'Information';

  @override
  void initState() {
    super.initState();
    // Load order details when the page is first created
    context.read<OrderDetailBloc>().add(
      OrderDetailRequested(orderId: widget.orderId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: const Text('Order Details'),
        centerTitle: false,
        elevation: 0,
      ),
      body: BlocBuilder<OrderDetailBloc, OrderDetailState>(
        builder: (context, state) {
          if (state is OrderDetailLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          if (state is OrderDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load order',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<OrderDetailBloc>().add(
                        OrderDetailRequested(
                          orderId: int.parse(
                            context.router.current.params.getString(
                              'orderId',
                              '0',
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is OrderDetailLoaded) {
            return _buildContent(context, state.order);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, OrderDetailEntity order) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderDetailBloc>().add(
          OrderDetailRefreshRequested(orderId: order.orderId),
        );
      },
      color: theme.colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(context, order),
            _buildCombinedInfoSection(context, order),
            const SizedBox(height: 16),
            _buildStatusUpdatesSection(context, order),
            const SizedBox(height: 16),
            _buildCommentsSection(context, order),
            const SizedBox(height: 16),
            _buildMessageSection(context, order),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context, OrderDetailEntity order) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '#SN.${order.orderId}',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.colorScheme.onPrimary,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedInfoSection(
    BuildContext context,
    OrderDetailEntity order,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info Section
          Text(
            'Order Information',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Flexible(
                child: Text(
                  '${order.sourceBranch} ',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.marianBlue,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Icon(
                Icons.arrow_forward,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              Flexible(
                child: Text(
                  ' ${order.destinationBranch}',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 13,
                    color: AppTheme.marianBlue,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Receiver Name:', order.receiverName, theme),
          const SizedBox(height: 8),
          _buildInfoRow('Receiver Number:', order.receiverNumber, theme),
          const SizedBox(height: 8),
          _buildInfoRow('COD Charge:', 'Rs. ${order.codCharge}', theme),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Delivery Charge:',
            'Rs. ${order.deliveryCharge}',
            theme,
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Delivery Address:', order.receiverAddress, theme),
          const SizedBox(height: 8),
          _buildInfoRow('Created On:', order.createdOnFormatted, theme),
          const SizedBox(height: 8),
          _buildInfoRow('Created By:', 'Demo Vendor', theme),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () => _EditAdditionalInfoDialog.show(
                    context,
                    initialPriority: 'Normal',
                    initialDescription: order.orderDescription,
                    initialVendorReferenceId: order.vendorReferenceId.isEmpty
                        ? null
                        : order.vendorReferenceId,
                    initialDeliveryInstruction:
                        order.deliveryInstruction.isEmpty
                        ? null
                        : order.deliveryInstruction,
                    onUpdate: (data) {
                      
                    },
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Additional Info',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildCompactInfoRow(
                        'Tracking Code:',
                        order.orderId.toString(),
                        theme,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactInfoRow(
                        'Package Access:',
                        'Can\'t Open',
                        theme,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactInfoRow(
                        'Delivery Instruction:',
                        order.deliveryInstruction.isEmpty
                            ? '-'
                            : order.deliveryInstruction,
                        theme,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactInfoRow(
                        'Vendor Reference ID:',
                        order.vendorReferenceId.isEmpty
                            ? 'None'
                            : order.vendorReferenceId,
                        theme,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactInfoRow(
                        'Description:',
                        order.orderDescription,
                        theme,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // QR Code Section
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Center(
                    child: Image.memory(
                      base64Decode(order.qrCode),
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.qr_code_2,
                          size: 80,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoRow(String label, String value, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusUpdatesSection(
    BuildContext context,
    OrderDetailEntity order,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Status Updates',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 24,
                color: theme.colorScheme.onSurface,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.lastDeliveryStatus,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created by you on ${order.createdOnFormatted}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageSection(BuildContext context, OrderDetailEntity order) {
    final theme = Theme.of(context);
    final messages = order.messages;

    // Debug print to check if messages are being received
    debugPrint('Messages in order: ${messages?.length ?? 0}');
    if (messages != null) {
      for (var message in messages) {
        debugPrint('Message: ${message.messageText}, Type: ${message.messageType}');
      }
    }

    if (messages == null || messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isMessagesExpanded = !_isMessagesExpanded;
              });
            },
            child: Row(
              children: [
                Text(
                  'Messages',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.message_outlined,
                  size: 24,
                  color: theme.colorScheme.onSurface,
                ),
                const Spacer(),
                Icon(
                  _isMessagesExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 24,
                  color: theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
          if (_isMessagesExpanded) ...[
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: messages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final message = messages[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              message.messageType,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            message.sentOnFormatted,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message.messageText,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sent by ${message.sentByName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentsSection(BuildContext context, OrderDetailEntity order) {
    final theme = Theme.of(context);
    final comments = order.comments ?? [];

    // Debug print to check if comments are being received
    debugPrint('Comments in order: ${comments.length}');
    for (var comment in comments) {
      debugPrint(
        'Comment: ${comment.comments}, Type: ${comment.commentType}, Added by: ${comment.addedByName}',
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isCommentsExpanded = !_isCommentsExpanded;
              });
            },
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.comment_outlined,
                  size: 24,
                  color: theme.colorScheme.onSurface,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    _showAddCommentDialog(context, theme);
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.marianBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Add New Comment',
                ),
                const SizedBox(width: 8),
                Icon(
                  _isCommentsExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 24,
                  color: theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
          if (_isCommentsExpanded) ...[
            const SizedBox(height: 16),
            if (comments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No comments yet. Click + to add one.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: comment.isImportant
                                    ? theme.colorScheme.error.withValues(
                                        alpha: 0.1,
                                      )
                                    : theme.colorScheme.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                comment.commentTypeDisplay,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: comment.isImportant
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            if (comment.isImportant)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.priority_high,
                                      size: 14,
                                      color: theme.colorScheme.error,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Important',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            const Spacer(),
                            Text(
                              comment.createdOnFormatted,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          comment.comments,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Added by ${comment.addedByName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        if (comment.canReply) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                _showAddCommentDialog(
                                  context,
                                  theme,
                                  commentToReply: comment,
                                );
                              },
                              icon: const Icon(Icons.reply, size: 16),
                              label: const Text('Reply'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddCommentDialog(
    BuildContext context,
    ThemeData theme, {
    CommentsEntity? commentToReply,
  }) {
    _newCommentController.clear();
    _selectedCommentType = 'Information';

    final parentContext = context;
    final isReply = commentToReply != null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocListener<CommentsBloc, CommentsState>(
          listener: (listenerContext, state) {
            debugPrint(
              '[DIALOG] CommentsBloc state changed: ${state.runtimeType}',
            );
            if (state is CreateCommentOrderdetailSuccess) {
              debugPrint(
                '[DIALOG] Success state commentId: ${state.commentId}, widget.orderId: ${widget.orderId}',
              );
              // Only handle if this is for the current order
              if (state.commentId == widget.orderId.toString()) {
                debugPrint('[DIALOG] IDs match, adding comment to UI...');
                // Add comment optimistically to the UI without full refresh
                final newComment = CommentsEntity(
                  id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
                  comments: _newCommentController.text,
                  commentType: _selectedCommentType,
                  commentTypeDisplay: _selectedCommentType,
                  status: null,
                  statusDisplay: null,
                  addedByName:
                      'You', // Placeholder, will be updated on next fetch
                  createdOn: DateTime.now().toIso8601String(),
                  createdOnFormatted: 'Just now',
                  isImportant: false,
                  canReply: false,
                );

                // Use parent context to access OrderDetailBloc
                parentContext.read<OrderDetailBloc>().add(
                  OrderDetailCommentAdded(comment: newComment),
                );

                // Clear the text field
                _newCommentController.clear();

                // Safely close dialog
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }

                // Show success message
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('Comment added successfully'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } else if (state is ReplyCommentOrderDetailSuccess) {
              // Handle reply success
              if (commentToReply != null &&
                  state.commentId == commentToReply.id.toString()) {
                // Clear the text field
                _newCommentController.clear();

                // Safely close dialog
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }

                // Show success message
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('Reply added successfully'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );

                // Refresh order details to show the new reply
                parentContext.read<OrderDetailBloc>().add(
                  OrderDetailRefreshRequested(orderId: widget.orderId),
                );
              }
            } else if (state is CreateCommentOrderdetailError) {
              // Only show error if this is for the current order
              if (state.commentId == widget.orderId.toString()) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    duration: const Duration(seconds: 3),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else if (state is ReplyCommentOrderDetailError) {
              // Handle reply error
              if (commentToReply != null &&
                  state.commentId == commentToReply.id.toString()) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    duration: const Duration(seconds: 3),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              return BlocBuilder<CommentsBloc, CommentsState>(
                builder: (context, state) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              border: Border(
                                bottom: BorderSide(
                                  color: AppTheme.lightGray,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  isReply
                                      ? 'Reply to Comment'
                                      : 'Add New Comment',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.blackBean,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  icon: const Icon(Icons.close),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  iconSize: 24,
                                  color: AppTheme.darkGray,
                                ),
                              ],
                            ),
                          ),

                          // Content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Comments field
                                Text(
                                  isReply ? 'Reply*' : 'Comments*',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.blackBean,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _newCommentController,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    hintText: isReply
                                        ? 'Enter your reply here...'
                                        : 'Enter your comment here...',
                                    hintStyle: TextStyle(
                                      color: AppTheme.darkGray.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppTheme.lightGray,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppTheme.lightGray,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppTheme.marianBlue,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.all(12),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Comment Type dropdown (for both new comments and replies)
                                Text(
                                  'Comment Type*',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.blackBean,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedCommentType,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppTheme.lightGray,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppTheme.lightGray,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppTheme.marianBlue,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  items: ['Information', 'Actionable'].map((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedCommentType = newValue;
                                      });
                                    }
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.darkGray,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      onPressed:
                                          (isReply
                                              ? state
                                                        is ReplyCommentOrderDetailLoading &&
                                                    state.commentId ==
                                                        commentToReply.id
                                                            .toString()
                                              : state
                                                    is CreateCommentOrderdetailLoading)
                                          ? null
                                          : () {
                                              if (_newCommentController
                                                  .text
                                                  .isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      isReply
                                                          ? 'Please enter a reply'
                                                          : 'Please enter a comment',
                                                    ),
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              if (isReply) {
                                                // Use the CommentsBloc to reply to a comment
                                                context.read<CommentsBloc>().add(
                                                  ReplyCommentOrderDetailEvent(
                                                    commentId: commentToReply.id
                                                        .toString(),
                                                    comment: commentToReply
                                                        .comments, // Include original comment text
                                                    reply: _newCommentController
                                                        .text,
                                                    commentType:
                                                        _selectedCommentType, // Use selected comment type
                                                  ),
                                                );
                                              } else {
                                                // Use the CommentsBloc to create a comment
                                                context.read<CommentsBloc>().add(
                                                  CreateCommentOrderdetailEvent(
                                                    commentId: widget.orderId
                                                        .toString(),
                                                    comment:
                                                        _newCommentController
                                                            .text,
                                                    commentType:
                                                        _selectedCommentType,
                                                  ),
                                                );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.marianBlue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child:
                                          (isReply
                                              ? state
                                                        is ReplyCommentOrderDetailLoading &&
                                                    state.commentId ==
                                                        commentToReply.id
                                                            .toString()
                                              : state
                                                    is CreateCommentOrderdetailLoading)
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              isReply
                                                  ? 'Send Reply'
                                                  : 'Add Comment',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _EditAdditionalInfoDialog extends StatefulWidget {
  final String? initialPriority;
  final String? initialDescription;
  final String? initialVendorReferenceId;
  final String? initialDeliveryInstruction;
  final Function(Map<String, String>) onUpdate;

  const _EditAdditionalInfoDialog({
    this.initialPriority,
    this.initialDescription,
    this.initialVendorReferenceId,
    this.initialDeliveryInstruction,
    required this.onUpdate,
  });

  @override
  State<_EditAdditionalInfoDialog> createState() =>
      __EditAdditionalInfoDialogState();

  static Future<void> show(
    BuildContext context, {
    String? initialPriority,
    String? initialDescription,
    String? initialVendorReferenceId,
    String? initialDeliveryInstruction,
    required Function(Map<String, String>) onUpdate,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EditAdditionalInfoDialog(
        initialPriority: initialPriority,
        initialDescription: initialDescription,
        initialVendorReferenceId: initialVendorReferenceId,
        initialDeliveryInstruction: initialDeliveryInstruction,
        onUpdate: onUpdate,
      ),
    );
  }
}

class __EditAdditionalInfoDialogState extends State<_EditAdditionalInfoDialog> {
  late TextEditingController _descriptionController;
  late TextEditingController _vendorRefController;
  late TextEditingController _deliveryInstructionController;
  late String _selectedPriority;

  final List<String> _priorities = ['Normal', 'High', 'Urgent', 'Low'];

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.initialPriority ?? 'Normal';
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
    _vendorRefController = TextEditingController(
      text: widget.initialVendorReferenceId ?? '',
    );
    _deliveryInstructionController = TextEditingController(
      text: widget.initialDeliveryInstruction ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _vendorRefController.dispose();
    _deliveryInstructionController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    final data = {
      'priority': _selectedPriority,
      'description': _descriptionController.text,
      'vendorReferenceId': _vendorRefController.text,
      'deliveryInstruction': _deliveryInstructionController.text,
    };
    widget.onUpdate(data);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPriorityField(theme),
                    const SizedBox(height: 20),
                    _buildDescriptionField(theme),
                    const SizedBox(height: 20),
                    _buildVendorRefField(theme),
                    const SizedBox(height: 20),
                    _buildDeliveryInstructionField(theme),
                  ],
                ),
              ),
            ),
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Update Description',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Priority',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPriority,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              style: theme.textTheme.bodyLarge,
              items: _priorities.map((priority) {
                return DropdownMenuItem<String>(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPriority = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Enter description',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorRefField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vendor reference id',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _vendorRefController,
          decoration: InputDecoration(
            hintText: 'Enter vendor reference id',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInstructionField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery instruction',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _deliveryInstructionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Enter delivery instruction',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _handleUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Update',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.5,
                ),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Cancel',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
