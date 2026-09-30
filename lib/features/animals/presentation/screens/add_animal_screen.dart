import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../application/animal_core_service.dart';
import '../../application/animal_master_providers.dart';
import '../../application/animal_providers.dart';
import '../../domain/enums/animal_enums.dart';

class AddAnimalScreen extends ConsumerStatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  ConsumerState<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends ConsumerState<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tagController = TextEditingController();
  final _rfidController = TextEditingController();
  final _nameController = TextEditingController();
  final _animalNumberController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _weightController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _notesController = TextEditingController();

  AnimalSpecies _species = AnimalSpecies.cow;
  AnimalSex _sex = AnimalSex.female;
  AnimalHornStatus _hornStatus = AnimalHornStatus.unknown;
  AnimalSource _source = AnimalSource.birth;
  DateTime _dob = DateTime.now();
  DateTime? _purchaseDate;
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [
      _tagController,
      _rfidController,
      _nameController,
      _animalNumberController,
      _breedController,
      _colorController,
      _weightController,
      _purchasePriceController,
      _notesController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 850;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Animal'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            compact ? AppSpacing.lg : 32,
            24,
            compact ? AppSpacing.lg : 32,
            40,
          ),
          children: [
            const _FormHeader(),
            const SizedBox(height: 20),
            _section(
              context,
              title: 'Identity',
              subtitle: 'Core identification stays stable across the animal lifecycle.',
              child: _identityFields(compact),
            ),
            const SizedBox(height: 16),
            _section(
              context,
              title: 'Classification',
              subtitle: 'Record the animal using the current farm master vocabulary.',
              child: _classificationFields(compact),
            ),
            const SizedBox(height: 16),
            _section(
              context,
              title: 'Source & Purchase',
              subtitle: 'Purchase fields become relevant when the animal was acquired.',
              child: _sourceFields(compact),
            ),
            const SizedBox(height: 16),
            _section(
              context,
              title: 'Additional details',
              subtitle: 'Optional operational information can be completed later.',
              child: _additionalFields(compact),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _saving ? null : () => context.pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: const Text('Save Animal'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _identityFields(bool compact) {
    return _grid(
      compact,
      [
        _textField(
          controller: _tagController,
          label: 'Official Ear Tag *',
          hint: 'e.g. SD-001',
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Tag number is required';
            return null;
          },
        ),
        _textField(controller: _rfidController, label: 'RFID Tag', hint: 'Optional'),
        _textField(controller: _animalNumberController, label: 'Animal Number', hint: 'Optional'),
        _textField(controller: _nameController, label: 'Name', hint: 'e.g. Ganga'),
      ],
    );
  }

  Widget _classificationFields(bool compact) {
    return _grid(
      compact,
      [
        DropdownButtonFormField<AnimalSpecies>(
          initialValue: _species,
          decoration: const InputDecoration(labelText: 'Species *'),
          items: AnimalSpecies.values
              .map((item) => DropdownMenuItem(value: item, child: Text(item.label)))
              .toList(),
          onChanged: (value) => setState(() => _species = value ?? _species),
        ),
        DropdownButtonFormField<AnimalSex>(
          initialValue: _sex,
          decoration: const InputDecoration(labelText: 'Sex *'),
          items: AnimalSex.values
              .map((item) => DropdownMenuItem(value: item, child: Text(item.label)))
              .toList(),
          onChanged: (value) => setState(() => _sex = value ?? _sex),
        ),
        _dateField(
          label: 'Date of Birth *',
          date: _dob,
          onPick: (date) => setState(() => _dob = date),
        ),
        DropdownButtonFormField<AnimalHornStatus>(
          initialValue: _hornStatus,
          decoration: const InputDecoration(labelText: 'Horn Status'),
          items: AnimalHornStatus.values
              .map((item) => DropdownMenuItem(value: item, child: Text(item.label)))
              .toList(),
          onChanged: (value) => setState(() => _hornStatus = value ?? _hornStatus),
        ),
        _textField(controller: _breedController, label: 'Breed', hint: 'Breed master will be linked later'),
        _textField(controller: _colorController, label: 'Color', hint: 'Optional'),
        _textField(
          controller: _weightController,
          label: 'Current Weight (kg)',
          hint: 'Optional',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            final parsed = double.tryParse(value.trim());
            if (parsed == null || parsed <= 0) return 'Enter a valid weight';
            return null;
          },
        ),
      ],
    );
  }

  Widget _sourceFields(bool compact) {
    return _grid(
      compact,
      [
        DropdownButtonFormField<AnimalSource>(
          initialValue: _source,
          decoration: const InputDecoration(labelText: 'Source *'),
          items: AnimalSource.values
              .map((item) => DropdownMenuItem(value: item, child: Text(item.label)))
              .toList(),
          onChanged: (value) => setState(() => _source = value ?? _source),
        ),
        _dateField(
          label: 'Purchase Date',
          date: _purchaseDate,
          onPick: (date) => setState(() => _purchaseDate = date),
          clearable: true,
        ),
        _textField(
          controller: _purchasePriceController,
          label: 'Purchase Price',
          hint: 'Optional',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            final parsed = double.tryParse(value.trim());
            if (parsed == null || parsed < 0) return 'Enter a valid amount';
            return null;
          },
        ),
      ],
    );
  }

  Widget _additionalFields(bool compact) {
    return _grid(
      compact,
      [
        _textField(controller: _notesController, label: 'Notes', hint: 'Optional', maxLines: 4),
      ],
    );
  }

  Widget _grid(bool compact, List<Widget> children) {
    if (compact) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100 ? 3 : 2;
        const gap = 12.0;
        final itemWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onPick,
    bool clearable = false,
  }) {
    final display = date == null ? 'Not set' : _formatDate(date);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: clearable && date != null
            ? IconButton(
                tooltip: 'Clear',
                onPressed: () => setState(() => _purchaseDate = null),
                icon: const Icon(Icons.clear_rounded),
              )
            : null,
      ),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) onPick(picked);
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(display)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final farmId = ref.read(currentFarmIdProvider);
    final service = ref.read(animalCoreServiceProvider);

    setState(() => _saving = true);
    try {
      final weight = double.tryParse(_weightController.text.trim());
      final purchasePrice = double.tryParse(_purchasePriceController.text.trim());

      final animal = buildAnimal(
        farmId: farmId,
        tagNumber: _tagController.text,
        rfid: _rfidController.text,
        qrCode: null,
        animalNumber: _animalNumberController.text,
        name: _nameController.text,
        species: _species,
        sex: _sex,
        dateOfBirth: _dob,
        source: _source,
        breedName: _breedController.text,
        color: _colorController.text,
        hornStatus: _hornStatus,
        weightKg: weight,
        purchaseDate: _purchaseDate,
        purchasePrice: purchasePrice,
        notes: _notesController.text,
      );

      await service.createAnimal(animal);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal saved successfully.')),
      );
      context.pop();
    } on AnimalBusinessException catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.accentSoft,
            child: Icon(Icons.pets_rounded, color: AppColors.primary, size: 26),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create an animal master record',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  'Identity first. Operational history will be connected to this record later.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
