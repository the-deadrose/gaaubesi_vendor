import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:gaaubesi_vendor/core/widgets/primary_button.dart';

@RoutePage()
class BulkUploadOrdersPage extends StatefulWidget {
  const BulkUploadOrdersPage({super.key});

  @override
  State<BulkUploadOrdersPage> createState() => _BulkUploadOrdersPageState();
}

class _BulkUploadOrdersPageState extends State<BulkUploadOrdersPage> {
  String? _selectedFileName;
  bool _isLoading = false;
  bool _showPreview = false;
  int _totalOrders = 0;
  int _validOrders = 0;
  int _invalidOrders = 0;

  void _pickFile() async {
    // TODO: Implement file picker
    // For now, simulate file selection
    setState(() {
      _selectedFileName = 'orders_sample.csv';
      _showPreview = true;
      _totalOrders = 150;
      _validOrders = 145;
      _invalidOrders = 5;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'File picker will be implemented with file_picker package',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _downloadTemplate() {
    // TODO: Implement template download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template download will be implemented'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleUpload() {
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file first'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate upload
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_validOrders orders uploaded successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.router.maybePop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(
          'Bulk Upload Orders',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(isDark, theme),
          const SizedBox(height: 24),
          _buildUploadCard(isDark, theme),
          if (_showPreview) ...[
            const SizedBox(height: 24),
            _buildPreviewCard(isDark, theme),
          ],
          const SizedBox(height: 24),
          _buildInstructionsCard(isDark, theme),
          const SizedBox(height: 32),
          if (_selectedFileName != null)
            PrimaryButton(
              text: 'Upload Orders',
              onPressed: _handleUpload,
              isLoading: _isLoading,
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.blue.shade800 : Colors.blue.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.primaryColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bulk Upload Requirements',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload CSV or Excel files with order details',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _selectedFileName != null
                  ? Icons.check_circle
                  : Icons.cloud_upload_outlined,
              size: 40,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFileName ?? 'No file selected',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFileName != null
                ? 'File ready for upload'
                : 'Click below to select a file',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Select File'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _downloadTemplate,
                  icon: const Icon(Icons.download),
                  label: const Text('Template'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildPreviewCard(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'File Preview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Total Orders',
            _totalOrders.toString(),
            Colors.blue,
            Icons.receipt_long,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'Valid Orders',
            _validOrders.toString(),
            Colors.green,
            Icons.check_circle,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'Invalid Orders',
            _invalidOrders.toString(),
            Colors.red,
            Icons.error,
          ),
          if (_invalidOrders > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_invalidOrders rows have validation errors',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsCard(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'File Format Instructions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            'Required columns: Receiver Name, Phone, Address, Source, Destination',
          ),
          _buildInstructionItem(
            'Optional: Alternative Phone, Package Description, Delivery Charge, COD Charge',
          ),
          _buildInstructionItem('Download the template for correct format'),
          _buildInstructionItem('Maximum 1000 orders per upload'),
          _buildInstructionItem('Supported formats: CSV, XLSX'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.fiber_manual_record, size: 8),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
