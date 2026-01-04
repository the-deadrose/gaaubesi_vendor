import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';

class CommentCard extends StatelessWidget {
  final CommentEntity comment;

  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    comment.addedByName[0],
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.addedByName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        comment.addedByRole,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (comment.isImportant)
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Comment Text
            Text(
              comment.comments,
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 8),

            // Metadata
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(comment.commentTypeDisplay),
                  backgroundColor: Colors.blue[50],
                  labelStyle: const TextStyle(fontSize: 12),
                ),
                Chip(
                  label: Text(comment.branchName),
                  backgroundColor: Colors.green[50],
                  labelStyle: const TextStyle(fontSize: 12),
                ),
                if (comment.statusDisplay != null)
                  Chip(
                    label: Text(comment.statusDisplay!),
                    backgroundColor: Colors.orange[50],
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  comment.createdOnFormatted,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (comment.canReply)
                  TextButton(
                    onPressed: () {
                      // Handle reply
                    },
                    child: const Text('Reply'),
                  ),
              ],
            ),

            // Child Comments
            if (comment.hasChildComments && (comment.childComments?.isNotEmpty ?? false))
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const Text(
                      'Replies:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    ...(comment.childComments ?? []).map((child) => Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    child.addedByName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    child.addedByRole,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                child.comments,
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                child.createdOnFormatted,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}