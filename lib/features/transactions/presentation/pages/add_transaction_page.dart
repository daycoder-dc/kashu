import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../cubit/transaction_form_cubit.dart';
import '../cubit/transaction_form_state.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionEntity? existing;

  const AddTransactionPage({super.key, this.existing});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  late final TransactionFormCubit _cubit;
  final _formKey = GlobalKey<FormState>();
  final _conceptController = TextEditingController();
  final _amountController = TextEditingController();

  late TransactionType _selectedType;
  CategoryEntity? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isPaid = false;
  String? _imagePath;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _cubit = TransactionFormCubit(
      repository: sl(),
      createTransaction: sl(),
      updateTransaction: sl(),
      deleteTransaction: sl(),
    );

    if (_isEditing) {
      final e = widget.existing!;
      _conceptController.text = e.concept;
      _amountController.text = e.amount.toStringAsFixed(0);
      _selectedType = e.type;
      _selectedDate = e.date;
      _isPaid = e.isPaid;
      _imagePath = e.imagePath;
    } else {
      _selectedType = TransactionType.expense;
    }

    _cubit.loadCategories(_selectedType);
  }

  @override
  void dispose() {
    _conceptController.dispose();
    _amountController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<TransactionFormCubit, TransactionFormState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is TransactionFormSuccess) {
          context.pop();
        }
        if (state is TransactionFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar transaccion' : 'Nueva transaccion'),
          actions: [
            if (_isEditing)
              IconButton(
                icon: Icon(PhosphorIconsLight.trash),
                onPressed: _confirmDelete,
              ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTypeToggle(theme),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _conceptController,
                  decoration: const InputDecoration(
                    labelText: 'Concepto',
                    hintText: 'Ej: Almuerzo, Arriendo...',
                    prefixIcon: Icon(PhosphorIconsLight.note),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    hintText: '0',
                    prefixIcon: Icon(PhosphorIconsLight.currencyDollar),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    final amount = double.tryParse(v);
                    if (amount == null || amount <= 0) return 'Monto invalido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildCategoryDropdown(theme),
                const SizedBox(height: 16),
                _buildDatePicker(theme),
                const SizedBox(height: 16),
                if (_selectedType == TransactionType.expense)
                  SwitchListTile(
                    title: const Text('Pagado'),
                    subtitle: const Text('Marca si ya realizaste este pago'),
                    value: _isPaid,
                    onChanged: (v) => setState(() => _isPaid = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                const SizedBox(height: 8),
                _buildImageSection(theme),
                const SizedBox(height: 24),
                BlocBuilder<TransactionFormCubit, TransactionFormState>(
                  bloc: _cubit,
                  builder: (context, state) {
                    final saving = state is TransactionFormSaving;
                    return FilledButton.icon(
                      onPressed: saving ? null : _save,
                      icon: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(PhosphorIconsBold.check),
                      label: Text(_isEditing ? 'Guardar cambios' : 'Guardar'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle(ThemeData theme) {
    return SegmentedButton<TransactionType>(
      segments: const [
        ButtonSegment(
          value: TransactionType.expense,
          label: Text('Gasto'),
          icon: Icon(PhosphorIconsRegular.arrowUp),
        ),
        ButtonSegment(
          value: TransactionType.income,
          label: Text('Ingreso'),
          icon: Icon(PhosphorIconsRegular.arrowDown),
        ),
      ],
      selected: {_selectedType},
      onSelectionChanged: (selected) {
        setState(() {
          _selectedType = selected.first;
          _selectedCategory = null;
          if (_selectedType == TransactionType.income) _isPaid = false;
        });
        _cubit.switchType(_selectedType);
      },
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return BlocBuilder<TransactionFormCubit, TransactionFormState>(
      bloc: _cubit,
      builder: (context, state) {
        final categories =
            state is TransactionFormReady ? state.categories : <CategoryEntity>[];

        if (_isEditing && _selectedCategory == null && categories.isNotEmpty) {
          final match = categories
              .where((c) => c.id == widget.existing!.categoryId)
              .toList();
          if (match.isNotEmpty) _selectedCategory = match.first;
        }

        return DropdownButtonFormField<CategoryEntity>(
          key: ValueKey('cat_${_selectedType.value}_${_selectedCategory?.id}'),
          initialValue: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Categoria',
            prefixIcon: Icon(PhosphorIconsLight.tag),
          ),
          items: categories
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Icon(c.iconData, color: c.displayColor, size: 20),
                        const SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedCategory = v),
          validator: (v) => v == null ? 'Selecciona una categoria' : null,
        );
      },
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030, 12, 31),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha',
          prefixIcon: Icon(PhosphorIconsLight.calendar),
        ),
        child: Text(
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
        ),
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Foto del recibo', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        if (_imagePath != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_imagePath!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.surface,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() => _imagePath = null),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          )
        else
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: Icon(PhosphorIconsLight.camera),
            label: const Text('Adjuntar foto'),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (xFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final destDir = Directory(p.join(appDir.path, 'receipts'));
    if (!await destDir.exists()) await destDir.create(recursive: true);

    final dest = p.join(destDir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
    await File(xFile.path).copy(dest);
    setState(() => _imagePath = dest);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final entity = TransactionEntity(
      id: widget.existing?.id ?? 0,
      concept: _conceptController.text.trim(),
      amount: double.parse(_amountController.text),
      type: _selectedType,
      isPaid: _selectedType == TransactionType.expense ? _isPaid : false,
      imagePath: _imagePath,
      date: _selectedDate,
      categoryId: _selectedCategory!.id,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _cubit.save(entity);
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar transaccion'),
        content: const Text('Esta accion no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true && widget.existing != null) {
      _cubit.delete(widget.existing!.id);
    }
  }
}
