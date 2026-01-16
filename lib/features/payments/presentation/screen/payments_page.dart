import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/payments/domain/entity/payment_request_list_entity.dart';
import 'package:gaaubesi_vendor/features/payments/presentation/bloc/payment_request_bloc.dart';
import 'package:gaaubesi_vendor/features/payments/presentation/bloc/payment_request_event.dart';
import 'package:gaaubesi_vendor/features/payments/presentation/bloc/payment_request_state.dart';

@RoutePage()
class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  @override
  void initState() {
    super.initState();
    // Load payment request list when the page initializes
    context.read<PaymentRequestBloc>().add(const LoadPaymentRequestList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PaymentRequestBloc>().add(
                const RefreshPaymentRequestList(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<PaymentRequestBloc, PaymentRequestState>(
        builder: (context, state) {
          return _buildContent(state);
        },
      ),
    );
  }

  Widget _buildContent(PaymentRequestState state) {
    if (state is PaymentRequestListLoading) {
      return _buildLoading();
    } else if (state is PaymentRequestListError) {
      return _buildError(state.failure);
    } else if (state is PaymentRequestListEmpty) {
      return _buildEmpty();
    } else if (state is PaymentRequestListLoaded) {
      return _buildLoaded(state.paymentRequestList);
    } else {
      // Initial state
      return const Center(child: Text('Tap refresh to load payment methods'));
    }
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(Failure failure) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _getErrorMessage(failure),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<PaymentRequestBloc>().add(
                const RefreshPaymentRequestList(),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _getErrorMessage(Failure failure) {
    // You can customize this based on your failure types
    return failure is ServerFailure
        ? 'Server error occurred. Please try again.'
        : 'An error occurred. Please try again.';
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.payment, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No payment methods available',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add payment methods to get started',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<PaymentRequestBloc>().add(
                const RefreshPaymentRequestList(),
              );
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoaded(PaymentRequestList paymentRequestList) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<PaymentRequestBloc>().add(
          const RefreshPaymentRequestList(),
        );
        // Wait a bit to show the refresh indicator
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        slivers: [
          // Payment Methods Section
          if (paymentRequestList.paymentMethods.isNotEmpty)
            _buildSectionHeader('Payment Methods'),
          if (paymentRequestList.paymentMethods.isNotEmpty)
            _buildPaymentMethods(paymentRequestList.paymentMethods),

          // Frequently Used Methods Section
          if (paymentRequestList.frequentlyUsedMethods.isNotEmpty)
            _buildSectionHeader('Frequently Used'),
          if (paymentRequestList.frequentlyUsedMethods.isNotEmpty)
            _buildFrequentlyUsedMethods(
              paymentRequestList.frequentlyUsedMethods,
            ),

          // Bank Names Section
          if (paymentRequestList.bankNames.isNotEmpty)
            _buildSectionHeader('Available Banks'),
          if (paymentRequestList.bankNames.isNotEmpty)
            _buildBankNames(paymentRequestList.bankNames),

          // Add some bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  SliverList _buildPaymentMethods(List<PaymentMethodEntity> paymentMethods) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final method = paymentMethods[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.1),
              child: Icon(
                _getPaymentMethodIcon(method.name),
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(method.name),
            subtitle: Text('ID: ${method.id}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Handle payment method selection
              _onPaymentMethodSelected(method);
            },
          ),
        );
      }, childCount: paymentMethods.length),
    );
  }

  IconData _getPaymentMethodIcon(String methodName) {
    if (methodName.toLowerCase().contains('bank')) {
      return Icons.account_balance;
    } else if (methodName.toLowerCase().contains('card')) {
      return Icons.credit_card;
    } else if (methodName.toLowerCase().contains('mobile')) {
      return Icons.phone;
    } else if (methodName.toLowerCase().contains('cash')) {
      return Icons.money;
    }
    return Icons.payment;
  }

  SliverList _buildFrequentlyUsedMethods(
    List<FrequentlyUsedMethodEntity> frequentlyUsedMethods,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final method = frequentlyUsedMethods[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              child: Icon(Icons.star, color: Colors.green),
            ),
            title: Text(method.paymentMethod.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (method.paymentBankName != null)
                  Text('Bank: ${method.paymentBankName}'),
                if (method.paymentAccountNumber != null)
                  Text('Account: ${method.paymentAccountNumber}'),
                if (method.paymentPhoneNumber != null)
                  Text('Phone: ${method.paymentPhoneNumber}'),
                Text(method.renderPaymentDetails),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _onFrequentlyUsedMethodSelected(method);
            },
          ),
        );
      }, childCount: frequentlyUsedMethods.length),
    );
  }

  SliverGrid _buildBankNames(List<BankNameEntity> bankNames) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.5,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final bank = bankNames[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              child: Icon(Icons.account_balance, color: Colors.blue),
            ),
            title: Text(
              bank.name,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              _onBankSelected(bank);
            },
          ),
        );
      }, childCount: bankNames.length),
    );
  }

  void _onPaymentMethodSelected(PaymentMethodEntity method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Selected: ${method.name}'),
        content: Text('ID: ${method.id}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onFrequentlyUsedMethodSelected(FrequentlyUsedMethodEntity method) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              method.paymentMethod.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (method.paymentBankName != null)
              _buildDetailRow('Bank', method.paymentBankName!),
            if (method.paymentAccountName != null)
              _buildDetailRow('Account Name', method.paymentAccountName!),
            if (method.paymentAccountNumber != null)
              _buildDetailRow('Account Number', method.paymentAccountNumber!),
            if (method.paymentPhoneNumber != null)
              _buildDetailRow('Phone', method.paymentPhoneNumber!),
            if (method.paymentPersonName != null)
              _buildDetailRow('Person Name', method.paymentPersonName!),
            if (method.paymentPersonPhone != null)
              _buildDetailRow('Person Phone', method.paymentPersonPhone!),
            const SizedBox(height: 16),
            Text(
              'Details: ${method.renderPaymentDetails}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _onBankSelected(BankNameEntity bank) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected bank: ${bank.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
