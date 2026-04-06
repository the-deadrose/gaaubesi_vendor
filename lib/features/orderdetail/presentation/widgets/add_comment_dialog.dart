import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/configure/theme/theme.dart';
import 'package:gaaubesi_vendor/features/orderdetail/domain/entities/order_detail_entity.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_bloc.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_event.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/bloc/comments_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_bloc.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_event.dart';

class AddCommentDialog extends StatefulWidget {
  final int orderId;
  final CommentsEntity? commentToReply;
  final TextEditingController commentController;
  final String selectedCommentType;
  final Function(String) onCommentTypeChanged;

  const AddCommentDialog({
    super.key,
    required this.orderId,
    this.commentToReply,
    required this.commentController,
    required this.selectedCommentType,
    required this.onCommentTypeChanged,
  });

  @override
  State<AddCommentDialog> createState() => _AddCommentDialogState();
}

class _AddCommentDialogState extends State<AddCommentDialog> {
  late String _selectedCommentType;

  @override
  void initState() {
    super.initState();
    _selectedCommentType = widget.selectedCommentType;
    widget.commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isReply = widget.commentToReply != null;
    final parentContext = context;

    return BlocListener<CommentsBloc, CommentsState>(
      listener: (listenerContext, state) {
        debugPrint(
          '[DIALOG] CommentsBloc state changed: ${state.runtimeType}',
        );
        if (state is CreateCommentOrderdetailSuccess) {
          debugPrint(
            '[DIALOG] Success state commentId: ${state.commentId}, orderId: ${widget.orderId}',
          );
          if (state.commentId == widget.orderId.toString()) {
            debugPrint('[DIALOG] IDs match, adding comment to UI...');
            final newComment = CommentsEntity(
              id: DateTime.now().millisecondsSinceEpoch, 
              comments: widget.commentController.text,
              commentType: _selectedCommentType,
              commentTypeDisplay: _selectedCommentType,
              status: null,
              statusDisplay: null,
              addedByName:
                  'You', 
              createdOn: DateTime.now().toIso8601String(),
              createdOnFormatted: 'Just now',
              isImportant: false,
              canReply: false,
            );

            parentContext.read<OrderDetailBloc>().add(
              OrderDetailCommentAdded(comment: newComment),
            );

            widget.commentController.clear();

            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }

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
          if (widget.commentToReply != null &&
              state.commentId == widget.commentToReply!.id.toString()) {
            // Clear the text field
            widget.commentController.clear();

            // Safely close dialog
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
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
          if (widget.commentToReply != null &&
              state.commentId == widget.commentToReply!.id.toString()) {
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
                                  Navigator.of(context).pop(),
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
                              controller: widget.commentController,
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
                                  widget.onCommentTypeChanged(newValue);
                                }
                              },
                            ),

                            const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
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
                                                    widget.commentToReply!.id
                                                        .toString()
                                          : state
                                                is CreateCommentOrderdetailLoading)
                                      ? null
                                      : () {
                                          if (widget.commentController
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
                                            context.read<CommentsBloc>().add(
                                              ReplyCommentOrderDetailEvent(
                                                commentId: widget.commentToReply!.id
                                                    .toString(),
                                                comment: widget.commentToReply!
                                                    .comments,
                                                reply: widget.commentController
                                                    .text,
                                                commentType:
                                                    _selectedCommentType,
                                              ),
                                            );
                                          } else {
                                            context.read<CommentsBloc>().add(
                                              CreateCommentOrderdetailEvent(
                                                commentId: widget.orderId
                                                    .toString(),
                                                comment:
                                                    widget.commentController
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
                                                    widget.commentToReply!.id
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
  }
}
