import 'package:flutter/material.dart';
import '../../model/perbaikan.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';

class PerbaikanFormScreen extends StatefulWidget {
  final Perbaikan? perbaikan;

  const PerbaikanFormScreen({super.key, this.perbaikan});

  @override
  State<PerbaikanFormScreen> createState() => _PerbaikanFormScreenState();
}

class _PerbaikanFormScreenState extends State<PerbaikanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kmPointController = TextEditingController();
  final _workDescriptionController = TextEditingController();
  final _contractorController = TextEditingController();
  final _assignedToController = TextEditingController();
  final _notesController = TextEditingController();
  final _costController = TextEditingController();

  String _selectedCategory = 'jalan';
  String _selectedSubcategory = 'lubang';
  String _selectedSection = 'A';
  String _selectedLane = 'Lajur 1';
  String _selectedStatus = 'pending';
  DateTime? _startDate;
  DateTime? _endDate;
  double _progress = 0.0;

  final List<String> _categories = ['jalan', 'jembatan', 'marka', 'rambu', 'drainase', 'penerangan'];
  final List<String> _subcategories = ['lubang', 'kerusakan', 'pengecatan', 'pemeliharaan'];
  final List<String> _sections = ['A', 'B', 'C', 'D'];
  final List<String> _lanes = ['Lajur 1', 'Lajur 2', 'Lajur 3', 'Bahaya'];
  final List<String> _statuses = ['pending', 'in_progress', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    if (widget.perbaikan != null) {
      _loadPerbaikanData();
    }
  }

  void _loadPerbaikanData() {
    final perbaikan = widget.perbaikan!;
    _kmPointController.text = perbaikan.kmPoint;
    _workDescriptionController.text = perbaikan.workDescription;
    _contractorController.text = perbaikan.contractor;
    _assignedToController.text = perbaikan.assignedTo;
    _notesController.text = perbaikan.notes ?? '';
    _costController.text = perbaikan.cost?.toString() ?? '';
    
    _selectedCategory = perbaikan.category;
    _selectedSubcategory = perbaikan.subcategory;
    _selectedSection = perbaikan.section;
    _selectedLane = perbaikan.lane;
    _selectedStatus = perbaikan.status;
    _startDate = perbaikan.startDate;
    _endDate = perbaikan.endDate;
    _progress = perbaikan.progress ?? 0.0;
  }

  @override
  void dispose() {
    _kmPointController.dispose();
    _workDescriptionController.dispose();
    _contractorController.dispose();
    _assignedToController.dispose();
    _notesController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.perbaikan == null ? 'Tambah Perbaikan' : 'Edit Perbaikan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildKmPointField(),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            _buildSubcategoryDropdown(),
            const SizedBox(height: 16),
            _buildSectionDropdown(),
            const SizedBox(height: 16),
            _buildLaneDropdown(),
            const SizedBox(height: 16),
            _buildWorkDescriptionField(),
            const SizedBox(height: 16),
            _buildContractorField(),
            const SizedBox(height: 16),
            _buildAssignedToField(),
            const SizedBox(height: 16),
            _buildStatusDropdown(),
            const SizedBox(height: 16),
            _buildDateFields(),
            const SizedBox(height: 16),
            _buildProgressSlider(),
            const SizedBox(height: 16),
            _buildCostField(),
            const SizedBox(height: 16),
            _buildNotesField(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildKmPointField() {
    return TextFormField(
      controller: _kmPointController,
      decoration: const InputDecoration(
        labelText: 'KM Point',
        hintText: 'Contoh: 12+300',
        prefixIcon: Icon(Icons.location_on),
      ),
      validator: Validators.validateKmPoint,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Kategori',
        prefixIcon: Icon(Icons.category),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  Widget _buildSubcategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSubcategory,
      decoration: const InputDecoration(
        labelText: 'Sub Kategori',
        prefixIcon: Icon(Icons.subdirectory_arrow_right),
      ),
      items: _subcategories.map((subcategory) {
        return DropdownMenuItem(
          value: subcategory,
          child: Text(subcategory.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSubcategory = value!;
        });
      },
    );
  }

  Widget _buildSectionDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSection,
      decoration: const InputDecoration(
        labelText: 'Seksi',
        prefixIcon: Icon(Icons.map),
      ),
      items: _sections.map((section) {
        return DropdownMenuItem(
          value: section,
          child: Text(section),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSection = value!;
        });
      },
    );
  }

  Widget _buildLaneDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedLane,
      decoration: const InputDecoration(
        labelText: 'Lajur',
        prefixIcon: Icon(Icons.directions_car),
      ),
      items: _lanes.map((lane) {
        return DropdownMenuItem(
          value: lane,
          child: Text(lane),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedLane = value!;
        });
      },
    );
  }

  Widget _buildWorkDescriptionField() {
    return TextFormField(
      controller: _workDescriptionController,
      decoration: const InputDecoration(
        labelText: 'Deskripsi Pekerjaan',
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
      validator: (value) => Validators.validateRequired(value, 'Deskripsi pekerjaan'),
    );
  }

  Widget _buildContractorField() {
    return TextFormField(
      controller: _contractorController,
      decoration: const InputDecoration(
        labelText: 'Kontraktor',
        prefixIcon: Icon(Icons.business),
      ),
      validator: (value) => Validators.validateRequired(value, 'Kontraktor'),
    );
  }

  Widget _buildAssignedToField() {
    return TextFormField(
      controller: _assignedToController,
      decoration: const InputDecoration(
        labelText: 'Ditugaskan Kepada',
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) => Validators.validateRequired(value, 'Ditugaskan kepada'),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        labelText: 'Status',
        prefixIcon: Icon(Icons.info),
      ),
      items: _statuses.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(Helpers.getStatusText(status)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedStatus = value!;
        });
      },
    );
  }

  Widget _buildDateFields() {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: const Text('Tanggal Mulai'),
            subtitle: Text(_startDate == null 
              ? 'Pilih tanggal' 
              : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
            leading: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(true),
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('Tanggal Selesai'),
            subtitle: Text(_endDate == null 
              ? 'Pilih tanggal' 
              : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
            leading: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(false),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progress: ${_progress.toStringAsFixed(0)}%'),
        Slider(
          value: _progress,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${_progress.toStringAsFixed(0)}%',
          onChanged: (value) {
            setState(() {
              _progress = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCostField() {
    return TextFormField(
      controller: _costController,
      decoration: const InputDecoration(
        labelText: 'Biaya (Rp)',
        prefixIcon: Icon(Icons.attach_money),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Catatan',
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 3,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      child: Text(widget.perbaikan == null ? 'Simpan' : 'Update'),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Here you would typically save to API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.perbaikan == null 
            ? 'Perbaikan berhasil ditambahkan' 
            : 'Perbaikan berhasil diupdate'),
        ),
      );
      Navigator.pop(context);
    }
  }
} 