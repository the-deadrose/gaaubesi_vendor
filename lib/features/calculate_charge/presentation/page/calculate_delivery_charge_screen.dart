import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_event.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_state.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/domain/entity/calculate_deliver_charge_entity.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/presentation/bloc/calculate_delivery_charge_bloc.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/presentation/bloc/calculate_delivery_charge_event.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/presentation/bloc/calculate_delivery_charge_state.dart';

@RoutePage()
class CalculateDeliveryChargeScreen extends StatefulWidget {
  const CalculateDeliveryChargeScreen({super.key});

  @override
  State<CalculateDeliveryChargeScreen> createState() =>
      _CalculateDeliveryChargeScreenState();
}

class _CalculateDeliveryChargeScreenState
    extends State<CalculateDeliveryChargeScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedSourceBranchId;
  String? _selectedDestinationBranchId;
  CalculateDeliveryCharge? _calculatedCharge;
  final TextEditingController _weightController = TextEditingController(
    text: '1',
  );
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _fetchBranchList();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _fetchBranchList() {
    context.read<BranchListBloc>().add(const FetchBranchListEvent(''));
  }

  void _calculateDeliveryCharge() {
    if (_selectedSourceBranchId == null ||
        _selectedDestinationBranchId == null) {
      _showSnackBar('Select both branches');
      return;
    }

    if (_selectedSourceBranchId == _selectedDestinationBranchId) {
      _showSnackBar('Source and destination cannot be same');
      return;
    }

    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) {
      _showSnackBar('Enter valid weight');
      return;
    }

    setState(() {
      _calculatedCharge = null;
    });

    context.read<CalculateDeliveryChargeBloc>().add(
      CalculateDeliveryChargeRequested(
        sourceBranchId: _selectedSourceBranchId!,
        destinationBranchId: _selectedDestinationBranchId!,
        weight: _weightController.text,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _selectedSourceBranchId = null;
      _selectedDestinationBranchId = null;
      _calculatedCharge = null;
      _weightController.text = '1';
    });
  }

  bool get _isEverythingCleared {
    return _selectedSourceBranchId == null &&
        _selectedDestinationBranchId == null &&
        _calculatedCharge == null &&
        (_weightController.text == '1' || _weightController.text.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        title: const Text('Calculate Charge'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<
            CalculateDeliveryChargeBloc,
            CalculateDeliveryChargeState
          >(
            listener: (context, state) {
              if (state is CalculateDeliveryChargeLoaded) {
                setState(() {
                  _calculatedCharge = state.calculateDeliveryCharge;
                });
              } else if (state is CalculateDeliveryChargeError) {
                _showSnackBar(state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<BranchListBloc, BranchListState>(
          builder: (context, branchState) {
            if (branchState is BranchListLoading) {
              return _buildShimmerLoading();
            }

            if (branchState is BranchListError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, size: 48),
                    const SizedBox(height: 16),
                    Text(branchState.message),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _fetchBranchList,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (branchState is BranchListLoaded) {
              return _Content(
                branches: branchState.branchList,
                weightController: _weightController,
                selectedSourceId: _selectedSourceBranchId,
                selectedDestinationId: _selectedDestinationBranchId,
                calculatedCharge: _calculatedCharge,
                onSourceChanged: (value) => setState(() {
                  _selectedSourceBranchId = value;
                  _calculatedCharge = null;
                }),
                onDestinationChanged: (value) => setState(() {
                  _selectedDestinationBranchId = value;
                  _calculatedCharge = null;
                }),
                onCalculate: _calculateDeliveryCharge,
                onClear: _clearAll,
                isClearDisabled: _isEverythingCleared,
              );
            }

            return _buildShimmerLoading();
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerWidget(
              width: double.infinity,
              height: 70,
              controller: _shimmerController,
              animation: _shimmerAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _ShimmerWidget(
              width: double.infinity,
              height: 70,
              controller: _shimmerController,
              animation: _shimmerAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _ShimmerWidget(
              width: double.infinity,
              height: 70,
              controller: _shimmerController,
              animation: _shimmerAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _ShimmerWidget(
                    width: double.infinity,
                    height: 56,
                    controller: _shimmerController,
                    animation: _shimmerAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: _ShimmerWidget(
                    width: double.infinity,
                    height: 56,
                    controller: _shimmerController,
                    animation: _shimmerAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _ShimmerWidget(
              width: double.infinity,
              height: 150,
              controller: _shimmerController,
              animation: _shimmerAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final AnimationController controller;
  final Animation<double> animation;
  final Widget child;

  const _ShimmerWidget({
    required this.width,
    required this.height,
    required this.controller,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: _ShimmerPainter(
              animationValue: animation.value,
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double animationValue;
  final Color baseColor;
  final Color highlightColor;

  _ShimmerPainter({
    required this.animationValue,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      begin: Alignment(animationValue - 1, 0.0),
      end: Alignment(animationValue, 0.0),
      colors: [baseColor, highlightColor, baseColor],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTRB(0, 0, size.width, size.height),
      )
      ..blendMode = BlendMode.srcATop;

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CalculateChargeShimmerEffect extends StatelessWidget {
  const CalculateChargeShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weight Input Shimmer
            _buildShimmerSection(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // From Branch Shimmer
            _buildShimmerSection(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // To Branch Shimmer
            _buildShimmerSection(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Buttons Shimmer
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Results Section Shimmer
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerSection({required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 20,
          color: Colors.grey[200],
          margin: const EdgeInsets.only(bottom: 8),
        ),
        child,
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final List<OrderStatusEntity> branches;
  final TextEditingController weightController;
  final String? selectedSourceId;
  final String? selectedDestinationId;
  final CalculateDeliveryCharge? calculatedCharge;
  final ValueChanged<String?> onSourceChanged;
  final ValueChanged<String?> onDestinationChanged;
  final VoidCallback onCalculate;
  final VoidCallback onClear;
  final bool isClearDisabled;

  const _Content({
    required this.branches,
    required this.weightController,
    required this.selectedSourceId,
    required this.selectedDestinationId,
    required this.calculatedCharge,
    required this.onSourceChanged,
    required this.onDestinationChanged,
    required this.onCalculate,
    required this.onClear,
    required this.isClearDisabled,
  });

  @override
  Widget build(BuildContext context) {
    final canCalculate =
        selectedSourceId != null &&
        selectedDestinationId != null &&
        selectedSourceId != selectedDestinationId;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weight Input
            _buildInputSection(
              context,
              title: 'Weight (kg)',
              child: TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter weight',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // From Branch
            _buildInputSection(
              context,
              title: 'From',
              child: DropdownButtonFormField<String>(
                initialValue: selectedSourceId,
                isExpanded: true,
                hint: const Text('Select branch'),
                items: branches.map((branch) {
                  return DropdownMenuItem(
                    value: branch.value,
                    child: Text(branch.label, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: onSourceChanged,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // To Branch
            _buildInputSection(
              context,
              title: 'To',
              child: DropdownButtonFormField<String>(
                initialValue: selectedDestinationId,
                isExpanded: true,
                hint: const Text('Select branch'),
                items: branches.map((branch) {
                  return DropdownMenuItem(
                    value: branch.value,
                    child: Text(branch.label, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: onDestinationChanged,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Buttons Row
            Row(
              children: [
                // Calculate Button (Bigger)
                Expanded(
                  flex: 3, // Takes 3/4 of the space
                  child:
                      BlocBuilder<
                        CalculateDeliveryChargeBloc,
                        CalculateDeliveryChargeState
                      >(
                        builder: (context, state) {
                          final isLoading =
                              state is CalculateDeliveryChargeLoading;
                          return ElevatedButton(
                            onPressed: canCalculate && !isLoading
                                ? onCalculate
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'CALCULATE',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          );
                        },
                      ),
                ),
                const SizedBox(width: 12),

                // Clear Button (Smaller)
                Expanded(
                  flex: 1, // Takes 1/4 of the space
                  child: OutlinedButton(
                    onPressed: isClearDisabled ? null : onClear,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: BorderSide(
                        color: isClearDisabled
                            ? Theme.of(context).disabledColor
                            : Theme.of(context).colorScheme.outline,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: isClearDisabled
                          ? Theme.of(context).disabledColor
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Results
            if (calculatedCharge != null)
              _buildResults(context, calculatedCharge!),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildResults(BuildContext context, CalculateDeliveryCharge charge) {
    final theme = Theme.of(context);
    final isSuccess = charge.success == true;
    final hasDiscount = charge.hasDiscount ?? false;
    final finalCharge = hasDiscount
        ? charge.discountedCharge
        : charge.deliveryCharge;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSuccess
            ? theme.primaryColor.withValues(alpha:  0.05)
            : theme.colorScheme.error.withValues(alpha:  0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess
              ? theme.primaryColor.withValues(alpha:  0.1)
              : theme.colorScheme.error.withValues(alpha:  0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status
          Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? theme.primaryColor : theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                isSuccess ? 'Delivery Charge' : 'Error',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSuccess
                      ? theme.primaryColor
                      : theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price or Error
          if (isSuccess) ...[
            if (hasDiscount) ...[
              Text(
                'Original: ${charge.originalCharge}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.onSurface.withValues(alpha:  0.6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha:  0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Discount Applied',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              finalCharge.toString(),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.primaryColor,
              ),
            ),
          ] else ...[
            Text(
              charge.message ?? 'Unable to calculate charge',
              style: theme.textTheme.bodyMedium,
            ),
          ],

          // Message
          if (charge.message != null && charge.message!.isNotEmpty && isSuccess)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                charge.message!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha:  0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
