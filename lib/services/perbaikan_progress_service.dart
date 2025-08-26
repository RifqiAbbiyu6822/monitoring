// lib/services/perbaikan_progress_service.dart - Progress Tracking Service
import 'dart:convert';
import '../widgets/photo_widgets.dart';

class PerbaikanProgressService {
  static const String _storageKey = 'perbaikan_progress';
  
  // Save progress update with photo
  static Future<void> saveProgressUpdate({
    required String perbaikanId,
    required double progress,
    required String description,
    required List<String> photos,
    String? notes,
  }) async {
    final progressItem = ProgressPhotoItem(
      photoPath: photos.isNotEmpty ? photos.first : '',
      progress: progress,
      description: description,
      timestamp: DateTime.now(),
      notes: notes,
    );
    
    // In a real app, this would save to database
    // For now, we'll use the existing local storage
    final existingProgress = await getProgressHistory(perbaikanId);
    existingProgress.add(progressItem);
    
    // Save to local storage (implementation would depend on your storage solution)
    await _saveToStorage(perbaikanId, existingProgress);
  }
  
  // Get progress history for a perbaikan
  static Future<List<ProgressPhotoItem>> getProgressHistory(String perbaikanId) async {
    // Implementation would retrieve from your database
    return [];
  }
  
  // Private helper to save to storage
  static Future<void> _saveToStorage(String perbaikanId, List<ProgressPhotoItem> progress) async {
    // Implementation depends on your storage solution
  }
  
  // Get latest progress percentage
  static Future<double> getLatestProgress(String perbaikanId) async {
    final history = await getProgressHistory(perbaikanId);
    if (history.isEmpty) return 0.0;
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return history.first.progress;
  }
  
  // Generate progress milestones
  static List<double> generateMilestones() {
    return [0, 10, 25, 50, 75, 90, 100];
  }
  
  // Get progress status text
  static String getProgressStatusText(double progress) {
    if (progress == 0) return 'Belum dimulai';
    if (progress <= 25) return 'Tahap awal';
    if (progress <= 50) return 'Setengah jalan';
    if (progress <= 75) return 'Hampir selesai';
    if (progress < 100) return 'Finalisasi';
    return 'Selesai';
  }
}

// Enhanced Progress Update Dialog
class ProgressUpdateDialog extends StatefulWidget {
  final String perbaikanId;
  final double currentProgress;
  final Function(double, String, List<String>, String?) onUpdate;

  const ProgressUpdateDialog({
    super.key,
    required this.perbaikanId,
    required this.currentProgress,
    required this.onUpdate,
  });

  @override
  State<ProgressUpdateDialog> createState() => _ProgressUpdateDialogState();
}

class _ProgressUpdateDialogState extends State<ProgressUpdateDialog>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  double _selectedProgress = 0;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  List<String> _photos = [];
  
  final List<double> _milestones = [0, 10, 25, 50, 75, 90, 100];
  
  @override
  void initState() {
    super.initState();
    _selectedProgress = widget.currentProgress;
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: widget.currentProgress / 100,
      end: _selectedProgress / 100,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _progressController.forward();
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _updateProgress(double newProgress) {
    setState(() {
      _selectedProgress = newProgress;
    });
    
    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: newProgress / 100,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _progressController.reset();
    _progressController.forward();
    
    // Auto-fill description based on progress
    if (newProgress == 0) {
      _descriptionController.text = 'Persiapan dimulai';
    } else if (newProgress <= 25) {
      _descriptionController.text = 'Tahap awal pekerjaan';
    } else if (newProgress <= 50) {
      _descriptionController.text = 'Progress setengah jalan';
    } else if (newProgress <= 75) {
      _descriptionController.text = 'Memasuki tahap akhir';
    } else if (newProgress < 100) {
      _descriptionController.text = 'Finalisasi pekerjaan';
    } else {
      _descriptionController.text = 'Pekerjaan selesai';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.timeline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Update Progress',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Perbarui kemajuan pekerjaan',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress visualization
                    _buildProgressVisualization(),
                    const SizedBox(height: 24),
                    
                    // Progress selector
                    _buildProgressSelector(),
                    const SizedBox(height: 24),
                    
                    // Description
                    _buildDescriptionField(),
                    const SizedBox(height: 20),
                    
                    // Photo section
                    _buildPhotoSection(),
                    const SizedBox(height: 20),
                    
                    // Notes
                    _buildNotesField(),
                  ],
                ),
              ),
            ),
            
            // Actions
            _buildActions(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressVisualization() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.05),
            AppTheme.primaryLight.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Progress circle
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _progressAnimation.value,
                      strokeWidth: 8,
                      backgroundColor: AppTheme.borderColor.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${(_selectedProgress).toInt()}%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        PerbaikanProgressService.getProgressStatusText(_selectedProgress),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          
          // Progress bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress Sebelumnya',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${widget.currentProgress.toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: AppTheme.borderColor.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Progress (%)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Milestone buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _milestones.map((milestone) {
            final isSelected = _selectedProgress == milestone;
            final isDisabled = milestone < widget.currentProgress;
            
            return GestureDetector(
              onTap: isDisabled ? null : () => _updateProgress(milestone),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : isDisabled
                          ? AppTheme.backgroundColor
                          : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : isDisabled
                            ? AppTheme.borderColor.withOpacity(0.3)
                            : AppTheme.primaryColor.withOpacity(0.3),
                    width: 1.5,