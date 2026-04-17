import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/orderdetail/domain/entities/order_detail_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/edit_order_request_entity.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/cards/order_card_actions.dart';
import 'package:gaaubesi_vendor/features/orderdetail/presentation/widgets/add_comment_dialog.dart';
import 'package:gaaubesi_vendor/features/orderdetail/presentation/widgets/edit_order_dialog.dart';

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
  bool _isStatusUpdatesExpanded = true;
  bool _isDeliveryAddressExpanded = false;
  bool _isDeliveryInstructionExpanded = false;
  final TextEditingController _newCommentController = TextEditingController();
  String _selectedCommentType = 'Information';

  @override
  void initState() {
    super.initState();
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
        title: Row(
          children: [
            BlocBuilder<OrderDetailBloc, OrderDetailState>(
              builder: (context, state) {
                if (state is OrderDetailLoaded) {
                  return Text('Order No.${state.order.orderId}');
                }
                return const Text('Order Details');
              },
            ),
            SizedBox(width: 6),
            BlocBuilder<OrderDetailBloc, OrderDetailState>(
              builder: (context, state) {
                if (state is OrderDetailLoaded &&
                    state.order.getIsEditable) {
                  return IconButton(
                    onPressed: () {
                      EditOrderDialog.show(
                        context,
                        order: state.order,
                        onUpdate: (data) {
                          debugPrint('Updated data: $data');
                          context.read<OrderDetailBloc>().add(
                            OrderEditRequested(
                              orderId: state.order.orderId,
                              request: OrderEditEntity(
                                branch: data['branch'] as int,
                                destinationBranch:
                                    data['destinationBranch'] as int,
                                weight: data['weight'] as double,
                                codCharge: data['codCharge'] as int,
                                packageAccess: data['packageAccess'] as String,
                                packageType: data['packageType'] as String,
                                remarks: data['remarks'] as String,
                                receiverName: data['receiverName'] as String,
                                receiverPhoneNumber:
                                    data['receiverPhoneNumber'] as String,
                                pickupType: data['pickupType'] as String,
                                altReceiverPhoneNumber:
                                    data['altReceiverPhoneNumber'] as String,
                                receiverFullAddress:
                                    data['receiverFullAddress'] as String,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.arrow_drop_down_sharp),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
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
            debugPrint(
              'Order Detail Loaded - is_editable: ${state.order.getIsEditable}',
            );
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
            _buildBasicInfoSection(context, order),
            _buildStatusUpdatesSection(context, order),
            _buildCommentsSection(context, order),
            _buildMessageSection(context, order),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context, OrderDetailEntity order) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  order.sourceBranch,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.swap_horiz_rounded,
                  size: 25,
                  color: theme.colorScheme.primary,
                ),
              ),
              Flexible(
                child: Text(
                  order.destinationBranch,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            'Basic Info',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 25
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildField('Receiver Name:', order.receiverName, theme),
                    _buildField(
                      'Receiver Number:',
                      order.receiverNumber,
                      theme,
                    ),
                    _buildField('COD Charge:', 'Rs. ${order.codCharge}', theme),
                    _buildField(
                      'Delivery Charge:',
                      'Rs. ${order.deliveryCharge}',
                      theme,
                    ),
                    _buildField(
                      'Delivery Address:',
                      order.receiverAddress,
                      theme,
                      allowExpand: true,
                      isExpanded: _isDeliveryAddressExpanded,
                      onToggleExpand: () {
                        setState(
                          () => _isDeliveryAddressExpanded =
                              !_isDeliveryAddressExpanded,
                        );
                      },
                    ),
                    _buildField('Created On:', order.createdOnFormatted, theme),
                    _buildField('Created By:', 'Demo Vendor', theme),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: ColoredBox(
                        color: Colors.white,
                        child: Image.memory(
                          base64Decode(order.qrCode),
                          width: 160,
                          height: 90,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(
                                width: 160,
                                height: 90,
                                child: Center(
                                  child: Icon(
                                    Icons.qr_code_2,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Additional Info',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (order.getIsEditable) ...[
                              const SizedBox(width: 6),
                              Text(
                                '|',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  EditOrderDialog.show(
                                    context,
                                    order: order,
                                    onUpdate: (data) {
                                      debugPrint('Updated data: $data');
                                      context.read<OrderDetailBloc>().add(
                                        OrderEditRequested(
                                          orderId: order.orderId,
                                          request: OrderEditEntity(
                                            branch: data['branch'] as int,
                                            destinationBranch:
                                                data['destinationBranch'] as int,
                                            weight: data['weight'] as double,
                                            codCharge: data['codCharge'] as int,
                                            packageAccess:
                                                data['packageAccess'] as String,
                                            packageType:
                                                data['packageType'] as String,
                                            remarks: data['remarks'] as String,
                                            receiverName:
                                                data['receiverName'] as String,
                                            receiverPhoneNumber:
                                                data['receiverPhoneNumber']
                                                    as String,
                                            pickupType:
                                                data['pickupType'] as String,
                                            altReceiverPhoneNumber:
                                                data['altReceiverPhoneNumber']
                                                    as String,
                                            receiverFullAddress:
                                                data['receiverFullAddress']
                                                    as String,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 15,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),

                        _buildSmallField(
                          'Tracking Code:',
                          order.orderId.toString(),
                          theme,
                        ),
                        _buildSmallField('Package Access:', 'none', theme),
                        _buildSmallField(
                          'Delivery Instruction:',
                          order.deliveryInstruction.isEmpty
                              ? '-'
                              : order.deliveryInstruction,
                          theme,
                          allowExpandToggle: true,
                          isExpanded: _isDeliveryInstructionExpanded,
                          onToggleExpand: () {
                            setState(
                              () => _isDeliveryInstructionExpanded =
                                  !_isDeliveryInstructionExpanded,
                            );
                          },
                        ),
                        _buildSmallField(
                          'Vendor Ref. ID:',
                          order.vendorReferenceId.isEmpty
                              ? 'None'
                              : order.vendorReferenceId,
                          theme,
                        ),
                        _buildSmallField(
                          'Description:',
                          order.orderDescription,
                          theme,
                        ),
                      ],
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

  Widget _buildField(
    String label,
    String value,
    ThemeData theme, {
    bool allowExpand = false,
    bool isExpanded = false,
    VoidCallback? onToggleExpand,
  }) {
    final valueStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          LayoutBuilder(
            builder: (context, constraints) {
              if (!allowExpand) {
                return Text(
                  value,
                  style: valueStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                );
              }

              final textPainter = TextPainter(
                text: TextSpan(text: value, style: valueStyle),
                textDirection: Directionality.of(context),
                maxLines: 2,
              )..layout(maxWidth: constraints.maxWidth);

              final hasOverflow = textPainter.didExceedMaxLines;

              if (onToggleExpand == null) {
                return Text(
                  value,
                  style: valueStyle,
                  maxLines: hasOverflow ? null : 2,
                  overflow: hasOverflow
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  softWrap: true,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: valueStyle,
                    maxLines: isExpanded ? null : 2,
                    overflow: isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  if (hasOverflow)
                    GestureDetector(
                      onTap: onToggleExpand,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          isExpanded ? 'Show less' : 'Show more',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSmallField(
    String label,
    String value,
    ThemeData theme, {
    bool allowExpandToggle = false,
    bool isExpanded = false,
    VoidCallback? onToggleExpand,
  }) {
    final valueStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          LayoutBuilder(
            builder: (context, constraints) {
              if (!allowExpandToggle) {
                return Text(
                  value,
                  style: valueStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                );
              }

              final textPainter = TextPainter(
                text: TextSpan(text: value, style: valueStyle),
                textDirection: Directionality.of(context),
                maxLines: 2,
              )..layout(maxWidth: constraints.maxWidth);

              final hasOverflow = textPainter.didExceedMaxLines;

              if (onToggleExpand == null) {
                return Text(
                  value,
                  style: valueStyle,
                  maxLines: hasOverflow ? null : 2,
                  overflow: hasOverflow
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  softWrap: true,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: valueStyle,
                    maxLines: isExpanded ? null : 2,
                    overflow: isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  if (hasOverflow)
                    GestureDetector(
                      onTap: onToggleExpand,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          isExpanded ? 'Show less' : 'Show more',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdatesSection(
    BuildContext context,
    OrderDetailEntity order,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _isStatusUpdatesExpanded = !_isStatusUpdatesExpanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Text(
                  'Status Updates',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isStatusUpdatesExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
          if (_isStatusUpdatesExpanded) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                      children: [
                        TextSpan(
                          text: order.lastDeliveryStatus,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' by you on ',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.55,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: order.createdOnFormatted,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.55,
                            ),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentsSection(BuildContext context, OrderDetailEntity order) {
    final theme = Theme.of(context);
    final comments = order.comments ?? [];

    debugPrint('Comments in order: ${comments.length}');
    for (var comment in comments) {
      debugPrint(
        'Comment: ${comment.comments}, Type: ${comment.commentType}, Added by: ${comment.addedByName}',
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext dialogContext) {
                      return AddCommentDialog(
                        orderId: widget.orderId,
                        commentController: _newCommentController,
                        selectedCommentType: _selectedCommentType,
                        onCommentTypeChanged: (type) =>
                            _selectedCommentType = type,
                      );
                    },
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'New',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Icon(Icons.add, size: 16, color: theme.colorScheme.primary),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(
                    () => _isCommentsExpanded = !_isCommentsExpanded,
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Text(
                        'Comments',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '|',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isCommentsExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurface,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (_isCommentsExpanded) ...[
            const SizedBox(height: 14),
            if (comments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No comments yet. Tap New + to add one.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 20, thickness: 0.5),
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildChip(
                            comment.commentTypeDisplay,
                            comment.isImportant
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                            theme,
                          ),
                          if (comment.isImportant) ...[
                            const SizedBox(width: 6),
                            _buildChipWithIcon(
                              'Important',
                              Icons.priority_high,
                              theme.colorScheme.error,
                              theme,
                            ),
                          ],
                          const Spacer(),
                          Text(
                            comment.createdOnFormatted,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        comment.comments,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Added by ${comment.addedByName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 11,
                        ),
                      ),
                      if (comment.canReply) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext dialogContext) {
                                  return AddCommentDialog(
                                    orderId: widget.orderId,
                                    commentToReply: comment,
                                    commentController: _newCommentController,
                                    selectedCommentType: _selectedCommentType,
                                    onCommentTypeChanged: (type) =>
                                        _selectedCommentType = type,
                                  );
                                },
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.reply,
                                  size: 15,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Reply',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageSection(BuildContext context, OrderDetailEntity order) {
    final theme = Theme.of(context);
    final messages = order.messages;

    debugPrint('Messages in order: ${messages?.length ?? 0}');
    if (messages != null) {
      for (var message in messages) {
        debugPrint(
          'Message: ${message.messageText}, Type: ${message.messageType}',
        );
      }
    }

    if (messages == null || messages.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _isMessagesExpanded = !_isMessagesExpanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Text(
                  'Messages',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isMessagesExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
          if (_isMessagesExpanded) ...[
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: messages.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 20, thickness: 0.5),
              itemBuilder: (context, index) {
                final message = messages[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildChip(
                          message.messageType,
                          theme.colorScheme.primary,
                          theme,
                        ),
                        const Spacer(),
                        Text(
                          message.sentOnFormatted,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message.messageText,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sent by ${message.sentByName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 11,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildChipWithIcon(
    String label,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
