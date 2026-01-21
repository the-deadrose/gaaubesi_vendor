import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/entity/frequently_used_and_payment_method_entity.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/frequently_used_methods/frequently_used_payment_method_bloc.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/frequently_used_methods/frequently_used_payment_method_event.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/frequently_used_methods/frequently_used_payment_method_state.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/payment_request/payment_request_bloc.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/payment_request/payment_request_event.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/payment_request/payment_request_state.dart';

@RoutePage()
class PaymentRequestScreen extends StatefulWidget {
  const PaymentRequestScreen({super.key});

  @override
  State<PaymentRequestScreen> createState() => _PaymentRequestScreenState();
}

class _PaymentRequestScreenState extends State<PaymentRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _bankNameController = TextEditingController();

  String? _selectedPaymentMethodId;
  PaymentMethod? _selectedPaymentMethod;
  bool _showBankNameDropdown = true;

  @override
  void initState() {
    super.initState();
    context.read<FrequentlyUsedPaymentMethodBloc>().add(
      FetchFrequentlyUsedPaymentMethodEvent(),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _phoneNumberController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _descriptionController.clear();
    _accountNameController.clear();
    _accountNumberController.clear();
    _phoneNumberController.clear();
    _bankNameController.clear();
    setState(() {
      _selectedPaymentMethod = null;
      _selectedPaymentMethodId = null;
      _showBankNameDropdown = true;
    });
  }

  void _onPaymentMethodSelected(PaymentMethod? method) {
    setState(() {
      _selectedPaymentMethod = method;
      _selectedPaymentMethodId = method?.id;
      _clearFields();
      _showBankNameDropdown = true;
    });
  }

  void _onFrequentlyUsedMethodSelected(FrequentlyUsedMethod method) {
    setState(() {
      _selectedPaymentMethod = method.paymentMethod;
      _selectedPaymentMethodId = method.paymentMethod.id;

      if (_selectedPaymentMethodId == 'bank_transfer' ||
          _selectedPaymentMethodId == 'bank' ||
          _selectedPaymentMethod?.name.toLowerCase().contains('bank') == true) {
        _accountNameController.text = method.paymentAccountName ?? '';
        _accountNumberController.text = method.paymentAccountNumber ?? '';
        if (method.paymentBankName != null &&
            method.paymentBankName!.isNotEmpty) {
          final bankName = _getBankNameFromId(method.paymentBankName!);
          _bankNameController.text = bankName;
          _showBankNameDropdown = true;
        }
      } else if (_selectedPaymentMethodId == 'esewa' ||
          _selectedPaymentMethod?.name.toLowerCase().contains('esewa') ==
              true) {
        _accountNameController.text = method.paymentAccountName ?? '';
        _phoneNumberController.text = method.paymentPhoneNumber ?? '';
      }

      if (method.renderPaymentDetails.isNotEmpty) {
        _descriptionController.text = method.renderPaymentDetails;
      }
    });
  }

  void _submitPaymentRequest() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPaymentMethod == null) {
        _showSnackBar('Please select a payment method', isError: true);
        return;
      }

      final isBankTransfer =
          _selectedPaymentMethodId == 'bank_transfer' ||
          _selectedPaymentMethodId == 'bank' ||
          _selectedPaymentMethod?.name.toLowerCase().contains('bank') == true;

      final isEsewa =
          _selectedPaymentMethodId == 'esewa' ||
          _selectedPaymentMethod?.name.toLowerCase().contains('esewa') == true;

      if (isBankTransfer) {
        if (_bankNameController.text.isEmpty ||
            _accountNameController.text.isEmpty ||
            _accountNumberController.text.isEmpty) {
          _showSnackBar('Please fill all bank transfer details', isError: true);
          return;
        }
      } else if (isEsewa) {
        if (_accountNameController.text.isEmpty ||
            _phoneNumberController.text.isEmpty) {
          _showSnackBar('Please fill all eSewa details', isError: true);
          return;
        }
      }

      if (_descriptionController.text.isEmpty) {
        _showSnackBar('Please enter a description', isError: true);
        return;
      }

      context.read<PaymentRequestBloc>().add(
        CreatePaymentRequestEvent(
          paymentMethod: _selectedPaymentMethod!.id,
          description: _descriptionController.text,
          bankName: isBankTransfer ? _bankNameController.text : '',
          accountNumber: isBankTransfer ? _accountNumberController.text : '',
          accountName: isBankTransfer || isEsewa
              ? _accountNameController.text
              : '',
          phoneNumber: isEsewa ? _phoneNumberController.text : '',
        ),
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).extra.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Custom Shimmer Widget
  Widget _buildShimmerWidget({
    double? width,
    double? height,
    double radius = 8,
  }) {
    return _ShimmerWidget(width: width, height: height, radius: radius);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        title: const Text('Payment Request'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<PaymentRequestBloc, PaymentRequestState>(
            listener: (context, state) {
              if (state is CreatePaymentRequestSuccess) {
                _showSnackBar(state.message);
                Navigator.pop(context);
              } else if (state is CreatePaymentRequestFailure) {
                _showSnackBar(state.error, isError: true);
              }
            },
          ),
        ],
        child:
            BlocBuilder<
              FrequentlyUsedPaymentMethodBloc,
              FrequentlyUsedPaymentMethodState
            >(
              builder: (context, state) {
                if (state is FrequentlyUsedPaymentMethodLoading) {
                  return _buildLoadingState();
                }

                if (state is FrequentlyUsedPaymentMethodError) {
                  return _buildErrorState(state.message);
                }

                if (state is FrequentlyUsedPaymentMethodEmpty) {
                  return _buildEmptyState();
                }

                if (state is FrequentlyUsedPaymentMethodLoaded) {
                  final data = state.frequentlyUsedAndPaymentMethodList;
                  return _buildContent(data);
                }

                return const SizedBox();
              },
            ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment method dropdown shimmer
          _buildShimmerWidget(height: 60, radius: 12),
          const SizedBox(height: 24),

          // Description field shimmer
          _buildShimmerWidget(height: 120, radius: 12),
          const SizedBox(height: 24),

          // Frequently used header shimmer
          _buildShimmerWidget(height: 40, radius: 8),
          const SizedBox(height: 16),

          // Frequently used grid shimmer
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: 4,
            itemBuilder: (context, index) => _buildShimmerWidget(radius: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 20),
            Text(
              'Oops!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).extra.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<FrequentlyUsedPaymentMethodBloc>().add(
                  FetchFrequentlyUsedPaymentMethodEvent(),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
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
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Payment Methods',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Contact support to set up payment methods',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).extra.darkGray,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(FrequentlyUsedAndPaymentMethodList data) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentMethodDropdown(data.paymentMethods),
            const SizedBox(height: 24),

            _buildDescriptionSection(),
            const SizedBox(height: 32),

            if (_selectedPaymentMethod != null) _buildPaymentDetailsSection(),

            if (data.frequentlyUsedMethods.isNotEmpty)
              _buildFrequentlyUsedGrid(data.frequentlyUsedMethods),

            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodDropdown(List<PaymentMethod> paymentMethods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<PaymentMethod>(
              initialValue: _selectedPaymentMethod,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: InputBorder.none,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              icon: Icon(
                Icons.expand_more_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              dropdownColor: Theme.of(context).colorScheme.surface,
              style: Theme.of(context).textTheme.bodyLarge,
              items: [
                DropdownMenuItem<PaymentMethod>(
                  value: null,
                  child: Text(
                    'Choose payment method',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).extra.darkGray,
                    ),
                  ),
                ),
                ...paymentMethods.map((method) {
                  return DropdownMenuItem<PaymentMethod>(
                    value: method,
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _getMethodColor(method),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: _buildMethodIcon(method, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            method.name,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: _onPaymentMethodSelected,
              validator: (value) {
                if (value == null) return 'Please select a payment method';
                return null;
              },
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: 'What is this payment request for?',
            hintStyle: TextStyle(
              color: Theme.of(context).extra.darkGray.withValues(alpha: 0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          maxLines: 4,
          minLines: 3,
          style: Theme.of(context).textTheme.bodyLarge,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPaymentDetailsSection() {
    final isBankTransfer =
        _selectedPaymentMethodId == 'bank_transfer' ||
        _selectedPaymentMethodId == 'bank' ||
        _selectedPaymentMethod?.name.toLowerCase().contains('bank') == true;

    final isEsewa =
        _selectedPaymentMethodId == 'esewa' ||
        _selectedPaymentMethod?.name.toLowerCase().contains('esewa') == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Payment Details',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getMethodColor(_selectedPaymentMethod!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildMethodIcon(_selectedPaymentMethod!, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedPaymentMethod!.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (isBankTransfer) ...[
                _buildBankNameField(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _accountNumberController,
                  decoration: InputDecoration(
                    labelText: 'Account Number',
                    prefixIcon: Icon(
                      Icons.numbers_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.bodyLarge,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter account number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _accountNameController,
                  decoration: InputDecoration(
                    labelText: 'Account Holder Name',
                    prefixIcon: Icon(
                      Icons.person_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter account name';
                    }
                    return null;
                  },
                ),
              ] else if (isEsewa) ...[
                TextFormField(
                  controller: _accountNameController,
                  decoration: InputDecoration(
                    labelText: 'eSewa Account Name',
                    prefixIcon: Icon(
                      Icons.person_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter eSewa account name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Registered Phone Number',
                    prefixIcon: Icon(
                      Icons.phone_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  keyboardType: TextInputType.phone,
                  style: Theme.of(context).textTheme.bodyLarge,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (value.length != 10) {
                      return 'Please enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankNameField() {
    final availableBankNames = _getAvailableBankNames();

    if (_showBankNameDropdown && availableBankNames.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                initialValue: _bankNameController.text.isEmpty
                    ? null
                    : (availableBankNames.contains(_bankNameController.text)
                          ? _bankNameController.text
                          : null),
                decoration: InputDecoration(
                  labelText: 'Bank Name',
                  prefixIcon: Icon(
                    Icons.account_balance_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                icon: Icon(
                  Icons.expand_more_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                dropdownColor: Theme.of(context).colorScheme.surface,
                style: Theme.of(context).textTheme.bodyLarge,
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      'Select Bank',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).extra.darkGray,
                      ),
                    ),
                  ),
                  ...availableBankNames.map((bank) {
                    return DropdownMenuItem<String>(
                      value: bank,
                      child: Text(bank),
                    );
                  }),
                  DropdownMenuItem<String>(
                    value: 'other',
                    child: Text(
                      'Other Bank',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == 'other') {
                    setState(() {
                      _showBankNameDropdown = false;
                      _bankNameController.clear();
                    });
                  } else if (value != null) {
                    setState(() {
                      _bankNameController.text = value;
                    });
                  }
                },
                validator: (value) {
                  if (_bankNameController.text.isEmpty) {
                    return 'Please select or enter bank name';
                  }
                  return null;
                },
                isExpanded: true,
              ),
            ),
          ),
        ],
      );
    } else {
      return TextFormField(
        controller: _bankNameController,
        decoration: InputDecoration(
          labelText: 'Bank Name',
          prefixIcon: Icon(
            Icons.account_balance_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          suffixIcon: availableBankNames.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.list_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _showBankNameDropdown = true;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        style: Theme.of(context).textTheme.bodyLarge,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter bank name';
          }
          return null;
        },
      );
    }
  }

  Widget _buildFrequentlyUsedGrid(List<FrequentlyUsedMethod> methods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Frequently Used',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 1,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
          ),
          itemCount: methods.length,
          itemBuilder: (context, index) {
            final method = methods[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onFrequentlyUsedMethodSelected(method),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _getMethodColor(method.paymentMethod),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _buildMethodIcon(
                              method.paymentMethod,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              method.paymentMethod.name,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method.renderPaymentDetails,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (method.paymentBankName != null &&
                              method.paymentBankName!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                method.paymentBankName!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _clearFields,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).extra.darkGray,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: Theme.of(context).extra.darkGray,
                ),
                const SizedBox(width: 8),
                Text(
                  'Clear',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: BlocBuilder<PaymentRequestBloc, PaymentRequestState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state is CreatePaymentRequestLoading
                    ? null
                    : _submitPaymentRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: state is CreatePaymentRequestLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Submit Request',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getMethodColor(PaymentMethod method) {
    if (method.id == 'esewa' || method.name.toLowerCase().contains('esewa')) {
      return Colors.green;
    } else if (method.id == 'bank_transfer' ||
        method.id == 'bank' ||
        method.name.toLowerCase().contains('bank')) {
      return Colors.red;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getMethodIcon(PaymentMethod method) {
    if (method.id == 'esewa' || method.name.toLowerCase().contains('esewa')) {
      return Icons.account_balance_wallet_rounded;
    } else if (method.id == 'bank_transfer' ||
        method.id == 'bank' ||
        method.name.toLowerCase().contains('bank')) {
      return Icons.account_balance_rounded;
    } else {
      return Icons.payment_rounded;
    }
  }

  Widget _buildMethodIcon(PaymentMethod method, {double size = 24}) {
    if (method.id == 'esewa' || method.name.toLowerCase().contains('esewa')) {
      return Image.asset(
        'assets/esewa.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    } else {
      return Icon(_getMethodIcon(method), size: size, color: Colors.white);
    }
  }

  List<String> _getAvailableBankNames() {
    final state = context.read<FrequentlyUsedPaymentMethodBloc>().state;
    if (state is FrequentlyUsedPaymentMethodLoaded) {
      final names = state.frequentlyUsedAndPaymentMethodList.bankNames
          .map((bank) => bank.name)
          .toList();
      // Remove duplicates while preserving order
      final seen = <String>{};
      return names.where((name) => seen.add(name)).toList();
    }
    return [];
  }

  String _getBankNameFromId(String bankId) {
    try {
      final state = context.read<FrequentlyUsedPaymentMethodBloc>().state;
      if (state is FrequentlyUsedPaymentMethodLoaded) {
        final index = int.tryParse(bankId);
        if (index != null &&
            index >= 0 &&
            index < state.frequentlyUsedAndPaymentMethodList.bankNames.length) {
          return state.frequentlyUsedAndPaymentMethodList.bankNames[index].name;
        }
      }
    } catch (e) {
      // If parsing fails, return the bankId as is
    }
    return bankId;
  }
}

// Custom Shimmer Widget
class _ShimmerWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;

  const _ShimmerWidget({this.width, this.height, this.radius = 8});

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            color: Theme.of(
              context,
            ).extra.darkGray.withValues(alpha: _animation.value * 0.15),
          ),
        );
      },
    );
  }
}
