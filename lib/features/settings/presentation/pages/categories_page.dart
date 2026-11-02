import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/category_dao.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/icon_registry.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _dao = sl<CategoryDao>();
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final expenses = await _dao.getAllByType(0);
    final incomes = await _dao.getAllByType(1);
    if (mounted) {
      setState(() {
        _expenseCategories = expenses;
        _incomeCategories = incomes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Gastos'),
            Tab(text: 'Ingresos'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryForm(
          type: _tabController.index == 0
              ? TransactionType.expense
              : TransactionType.income,
        ),
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_expenseCategories, theme),
          _buildList(_incomeCategories, theme),
        ],
      ),
    );
  }

  Widget _buildList(List<Category> categories, ThemeData theme) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          'Sin categorias',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(Spacing.lg),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final color = Color(cat.color);
        return Card(
          margin: const EdgeInsets.only(bottom: Spacing.sm),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withAlpha(30),
              child: Icon(resolveIcon(cat.iconCodePoint), color: color, size: 20),
            ),
            title: Text(cat.name),
            subtitle: cat.isDefault
                ? Text('Predeterminada',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ))
                : null,
            trailing: cat.isDefault
                ? null
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(PhosphorIconsLight.pencilSimple, size: 20),
                        onPressed: () => _showCategoryForm(
                          type: TransactionType.fromValue(cat.type),
                          existing: cat,
                        ),
                      ),
                      IconButton(
                        icon: Icon(PhosphorIconsLight.trash, size: 20),
                        onPressed: () => _confirmDelete(cat),
                      ),
                    ],
                  ),
            onTap: cat.isDefault
                ? null
                : () => _showCategoryForm(
                      type: TransactionType.fromValue(cat.type),
                      existing: cat,
                    ),
          ),
        );
      },
    );
  }

  void _confirmDelete(Category cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar categoria'),
        content: Text(
          'Se eliminara "${cat.name}". Las transacciones existentes con esta categoria no se veran afectadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _dao.deleteCategory(cat.id);
              _loadCategories();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showCategoryForm({
    required TransactionType type,
    Category? existing,
  }) {
    final isEdit = existing != null;
    final nameController =
        TextEditingController(text: isEdit ? existing.name : '');
    int selectedIcon =
        isEdit ? existing.iconCodePoint : Icons.category_rounded.codePoint;
    int selectedColor = isEdit ? existing.color : Colors.blue.toARGB32();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: Spacing.xl,
                right: Spacing.xl,
                top: Spacing.xl,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + Spacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEdit ? 'Editar categoria' : 'Nueva categoria',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  Center(
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Color(selectedColor).withAlpha(30),
                      child: Icon(
                        resolveIcon(selectedIcon),
                        color: Color(selectedColor),
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      hintText: 'Ej: Mascotas, Gimnasio...',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: Spacing.lg),
                  Text('Icono',
                      style: Theme.of(ctx).textTheme.labelMedium),
                  const SizedBox(height: Spacing.sm),
                  Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.sm,
                    children: _availableIcons.map((icon) {
                      final isSelected = icon.codePoint == selectedIcon;
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => selectedIcon = icon.codePoint),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(selectedColor).withAlpha(30)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(
                                    color: Color(selectedColor), width: 2)
                                : Border.all(
                                    color: Theme.of(ctx)
                                        .colorScheme
                                        .outlineVariant),
                          ),
                          child: Icon(icon,
                              size: 22,
                              color: isSelected
                                  ? Color(selectedColor)
                                  : Theme.of(ctx)
                                      .colorScheme
                                      .onSurfaceVariant),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: Spacing.lg),
                  Text('Color',
                      style: Theme.of(ctx).textTheme.labelMedium),
                  const SizedBox(height: Spacing.sm),
                  Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.sm,
                    children: _availableColors.map((color) {
                      final isSelected = color.toARGB32() == selectedColor;
                      return GestureDetector(
                        onTap: () => setSheetState(
                            () => selectedColor = color.toARGB32()),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: Colors.white, width: 3)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: Spacing.xl),
                  FilledButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;
                      Navigator.pop(ctx);
                      if (isEdit) {
                        await _dao.updateCategory(CategoriesCompanion(
                          id: Value(existing.id),
                          name: Value(name),
                          iconCodePoint: Value(selectedIcon),
                          color: Value(selectedColor),
                          type: Value(existing.type),
                          isDefault: Value(existing.isDefault),
                        ));
                      } else {
                        await _dao.insertCategory(CategoriesCompanion.insert(
                          name: name,
                          iconCodePoint: selectedIcon,
                          color: selectedColor,
                          type: type.value,
                        ));
                      }
                      _loadCategories();
                    },
                    child: Text(isEdit ? 'Guardar' : 'Crear'),
                  ),
                  const SizedBox(height: Spacing.sm),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static const _availableIcons = <IconData>[
    Icons.home_rounded,
    Icons.restaurant_rounded,
    Icons.directions_car_rounded,
    Icons.local_hospital_rounded,
    Icons.school_rounded,
    Icons.movie_rounded,
    Icons.receipt_long_rounded,
    Icons.credit_card_rounded,
    Icons.payments_rounded,
    Icons.laptop_rounded,
    Icons.trending_up_rounded,
    Icons.category_rounded,
    Icons.shopping_cart_rounded,
    Icons.pets_rounded,
    Icons.fitness_center_rounded,
    Icons.wifi_rounded,
    Icons.phone_android_rounded,
    Icons.flight_rounded,
    Icons.local_cafe_rounded,
    Icons.child_care_rounded,
    Icons.brush_rounded,
    Icons.build_rounded,
    Icons.music_note_rounded,
    Icons.sports_esports_rounded,
  ];

  static const _availableColors = <Color>[
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
    Colors.deepOrange,
    Colors.lime,
    Colors.lightBlue,
    Colors.brown,
    Colors.deepPurple,
    Colors.grey,
  ];
}
