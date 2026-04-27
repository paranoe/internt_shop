import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_controller.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_state.dart';

class AdminParametersScreen extends StatefulWidget {
  const AdminParametersScreen({super.key});

  @override
  State<AdminParametersScreen> createState() => _AdminParametersScreenState();
}

class _AdminParametersScreenState extends State<AdminParametersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadAll();
    });
  }

  Future<void> _showCreateMeasurementUnitDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final shortNameController = TextEditingController();

    final created =
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Создать единицу измерения',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Название',
                            prefixIcon: const Icon(Icons.straighten),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Введите название';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: shortNameController,
                          decoration: InputDecoration(
                            labelText: 'Краткое обозначение',
                            hintText: 'см, кг, ГБ',
                            prefixIcon: const Icon(Icons.short_text),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Введите краткое обозначение';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;

                              final ok = await context
                                  .read<AdminController>()
                                  .createMeasurementUnit(
                                    name: nameController.text.trim(),
                                    shortName: shortNameController.text.trim(),
                                  );

                              if (!mounted) return;
                              Navigator.of(sheetContext).pop(ok);
                            },
                            child: const Text('Создать единицу'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ) ??
        false;

    if (!mounted) return;

    if (created) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Единица измерения создана')),
      );
    } else {
      final error = context.read<AdminController>().state.errorMessage;
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  Future<void> _showCreateParameterDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    String selectedType = 'text';
    int? selectedUnitId;

    final created =
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                final units = context
                    .read<AdminController>()
                    .state
                    .measurementUnits;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    decoration: BoxDecoration(
                      color: Theme.of(sheetContext).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 42,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Создать параметр',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Название параметра',
                                prefixIcon: const Icon(Icons.tune_outlined),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Введите название параметра';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              value: selectedType,
                              decoration: InputDecoration(
                                labelText: 'Тип параметра',
                                prefixIcon: const Icon(Icons.data_object),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'text',
                                  child: Text('text'),
                                ),
                                DropdownMenuItem(
                                  value: 'number',
                                  child: Text('number'),
                                ),
                                DropdownMenuItem(
                                  value: 'boolean',
                                  child: Text('boolean'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setModalState(() {
                                  selectedType = value;
                                  if (selectedType != 'number') {
                                    selectedUnitId = null;
                                  }
                                });
                              },
                            ),
                            if (selectedType == 'number') ...[
                              const SizedBox(height: 14),
                              DropdownButtonFormField<int>(
                                value: selectedUnitId,
                                decoration: InputDecoration(
                                  labelText: 'Единица измерения',
                                  prefixIcon: const Icon(Icons.straighten),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: units.map((item) {
                                  final id =
                                      int.tryParse(
                                        item['unit_id'].toString(),
                                      ) ??
                                      0;
                                  final name = item['name']?.toString() ?? '';
                                  final shortName =
                                      item['short_name']?.toString() ?? '';
                                  return DropdownMenuItem<int>(
                                    value: id,
                                    child: Text('$name ($shortName)'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedUnitId = value;
                                  });
                                },
                              ),
                            ],
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () async {
                                  if (!formKey.currentState!.validate()) return;

                                  final ok = await context
                                      .read<AdminController>()
                                      .createParameter(
                                        name: nameController.text.trim(),
                                        dataType: selectedType,
                                        unitId: selectedType == 'number'
                                            ? selectedUnitId
                                            : null,
                                      );

                                  if (!mounted) return;
                                  Navigator.of(sheetContext).pop(ok);
                                },
                                child: const Text('Создать параметр'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ) ??
        false;

    if (!mounted) return;

    if (created) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Параметр создан')));
    } else {
      final error = context.read<AdminController>().state.errorMessage;
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  Future<void> _confirmDeleteParameter(
    int parameterId,
    String parameterName,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Удалить параметр'),
            content: Text('Удалить параметр "$parameterName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Удалить'),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !confirmed) return;

    final ok = await context.read<AdminController>().deleteParameter(
      parameterId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Параметр удалён' : 'Не удалось удалить параметр'),
      ),
    );
  }

  Future<void> _confirmDeleteMeasurementUnit(
    int unitId,
    String unitName,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Удалить единицу измерения'),
            content: Text('Удалить единицу "$unitName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Удалить'),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !confirmed) return;

    final ok = await context.read<AdminController>().deleteMeasurementUnit(
      unitId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Единица измерения удалена' : 'Не удалось удалить единицу',
        ),
      ),
    );
  }

  Future<void> _showCreateBindingDialog() async {
    final currentState = context.read<AdminController>().state;

    if (currentState.categories.isEmpty || currentState.parameters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала загрузите категории и параметры'),
        ),
      );
      return;
    }

    int? selectedCategoryId;
    int? selectedSubcategoryId;
    int? selectedParameterId;
    bool isRequired = false;

    final created =
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return BlocBuilder<AdminController, AdminState>(
                  builder: (context, state) {
                    final subcategories = state.subcategories;

                    return Container(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        24 + MediaQuery.of(sheetContext).viewInsets.bottom,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(sheetContext).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Container(
                                width: 42,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Привязать параметр',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              value: selectedCategoryId,
                              decoration: _inputDecoration(
                                'Категория',
                                Icons.category_outlined,
                              ),
                              items: state.categories.map((item) {
                                final id =
                                    int.tryParse(
                                      item['category_id'].toString(),
                                    ) ??
                                    0;
                                final name =
                                    item['category_name']?.toString() ??
                                    item['name']?.toString() ??
                                    'Категория';
                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Text(name),
                                );
                              }).toList(),
                              onChanged: (value) async {
                                if (value == null) return;

                                setModalState(() {
                                  selectedCategoryId = value;
                                  selectedSubcategoryId = null;
                                });

                                await context
                                    .read<AdminController>()
                                    .loadSubcategoriesByCategory(value);
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: selectedSubcategoryId,
                              decoration: _inputDecoration(
                                'Подкатегория',
                                Icons.grid_view_rounded,
                              ),
                              items: subcategories.map((item) {
                                final id =
                                    int.tryParse(
                                      (item['subcategory_id'] ??
                                              item['podcategories_id'])
                                          .toString(),
                                    ) ??
                                    0;
                                final name =
                                    item['subcategory_name']?.toString() ??
                                    item['name']?.toString() ??
                                    'Подкатегория';
                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Text(name),
                                );
                              }).toList(),
                              onChanged: subcategories.isEmpty
                                  ? null
                                  : (value) {
                                      setModalState(() {
                                        selectedSubcategoryId = value;
                                      });
                                    },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: selectedParameterId,
                              decoration: _inputDecoration(
                                'Параметр',
                                Icons.tune_outlined,
                              ),
                              items: state.parameters.map((item) {
                                final id =
                                    int.tryParse(
                                      item['parameter_id'].toString(),
                                    ) ??
                                    0;
                                final name =
                                    item['name']?.toString() ?? 'Параметр';
                                final type =
                                    item['data_type']?.toString() ?? 'text';
                                final unitShortName =
                                    item['unit_short_name']?.toString() ?? '';

                                final label = unitShortName.isEmpty
                                    ? '$name ($type)'
                                    : '$name ($type, $unitShortName)';

                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Text(label),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setModalState(() {
                                  selectedParameterId = value;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            SwitchListTile(
                              value: isRequired,
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Обязательный параметр'),
                              onChanged: (value) {
                                setModalState(() {
                                  isRequired = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () async {
                                  if (selectedSubcategoryId == null ||
                                      selectedParameterId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Выберите подкатегорию и параметр',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final ok = await context
                                      .read<AdminController>()
                                      .createBinding(
                                        subcategoryId: selectedSubcategoryId!,
                                        parameterId: selectedParameterId!,
                                        isRequired: isRequired,
                                      );

                                  if (!mounted) return;
                                  Navigator.of(sheetContext).pop(ok);
                                },
                                child: const Text('Сохранить привязку'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ) ??
        false;

    if (!mounted) return;

    if (created) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Привязка создана')));
    } else {
      final error = context.read<AdminController>().state.errorMessage;
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  Future<void> _confirmDeleteBinding(Map<String, dynamic> binding) async {
    final subcategoryId =
        int.tryParse(
          (binding['subcategory_id'] ?? binding['podcategory_id']).toString(),
        ) ??
        0;
    final parameterId = int.tryParse(binding['parameter_id'].toString()) ?? 0;
    final name =
        binding['parameter_name']?.toString() ??
        binding['name']?.toString() ??
        'параметр';

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Удалить привязку'),
            content: Text('Удалить привязку параметра "$name"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Удалить'),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !confirmed) return;

    final ok = await context.read<AdminController>().deleteBinding(
      subcategoryId: subcategoryId,
      parameterId: parameterId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Привязка удалена' : 'Не удалось удалить привязку'),
      ),
    );
  }

  static InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  String _parameterSubtitle(Map<String, dynamic> parameter) {
    final type = parameter['data_type']?.toString() ?? 'text';
    final unitShortName = parameter['unit_short_name']?.toString() ?? '';

    if (unitShortName.isEmpty) {
      return 'Тип: $type';
    }

    return 'Тип: $type • Ед.: $unitShortName';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Параметры'), centerTitle: true),
      body: BlocBuilder<AdminController, AdminState>(
        builder: (context, state) {
          final isLoading =
              state.status == AdminStatus.loading &&
              state.parameters.isEmpty &&
              state.bindings.isEmpty &&
              state.measurementUnits.isEmpty;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AdminStatus.error &&
              state.parameters.isEmpty &&
              state.bindings.isEmpty &&
              state.measurementUnits.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Не удалось загрузить параметры',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<AdminController>().loadAll(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _showCreateParameterDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Создать параметр'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showCreateMeasurementUnitDialog,
                        icon: const Icon(Icons.straighten),
                        label: const Text('Создать единицу измерения'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showCreateBindingDialog,
                        icon: const Icon(Icons.link),
                        label: const Text('Привязать к подкатегории'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Параметры',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (state.parameters.isEmpty)
                  const _AdminEmptyBlock(
                    icon: Icons.tune_outlined,
                    text: 'Параметров пока нет',
                  )
                else
                  ...state.parameters.map((parameter) {
                    final parameterId =
                        int.tryParse(parameter['parameter_id'].toString()) ?? 0;
                    final name = parameter['name']?.toString() ?? 'Параметр';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.10),
                            ),
                            child: const Icon(Icons.tune_outlined),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _parameterSubtitle(parameter),
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: parameterId == 0
                                ? null
                                : () => _confirmDeleteParameter(
                                    parameterId,
                                    name,
                                  ),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 20),
                const Text(
                  'Единицы измерения',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (state.measurementUnits.isEmpty)
                  const _AdminEmptyBlock(
                    icon: Icons.straighten,
                    text: 'Единиц измерения пока нет',
                  )
                else
                  ...state.measurementUnits.map((unit) {
                    final unitId =
                        int.tryParse(unit['unit_id'].toString()) ?? 0;
                    final name = unit['name']?.toString() ?? 'Единица';
                    final shortName = unit['short_name']?.toString() ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.teal.withValues(alpha: 0.10),
                            ),
                            child: const Icon(Icons.straighten),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  shortName,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: unitId == 0
                                ? null
                                : () => _confirmDeleteMeasurementUnit(
                                    unitId,
                                    name,
                                  ),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 20),
                const Text(
                  'Привязки параметров',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (state.bindings.isEmpty)
                  const _AdminEmptyBlock(
                    icon: Icons.link_off,
                    text: 'Привязок пока нет',
                  )
                else
                  ...state.bindings.map((binding) {
                    final parameterName =
                        binding['parameter_name']?.toString() ??
                        binding['name']?.toString() ??
                        'Параметр';
                    final subcategoryName =
                        binding['subcategory_name']?.toString() ??
                        binding['podcategory_name']?.toString() ??
                        'Подкатегория';
                    final isRequired = binding['is_required'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.orange.withValues(alpha: 0.10),
                            ),
                            child: const Icon(Icons.link),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  parameterName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subcategoryName,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isRequired
                                      ? 'Обязательный'
                                      : 'Необязательный',
                                  style: TextStyle(
                                    color: isRequired
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _confirmDeleteBinding(binding),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AdminEmptyBlock extends StatelessWidget {
  const _AdminEmptyBlock({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.grey),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
