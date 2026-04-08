import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_controller.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_state.dart';

class AdminPickupPointsScreen extends StatefulWidget {
  const AdminPickupPointsScreen({super.key});

  @override
  State<AdminPickupPointsScreen> createState() =>
      _AdminPickupPointsScreenState();
}

class _AdminPickupPointsScreenState extends State<AdminPickupPointsScreen> {
  int? _selectedCityIdFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AdminController>().loadCities();
      if (!mounted) return;
      await context.read<AdminController>().loadPickupPoints();
    });
  }

  Future<void> _showCreateDialog(AdminState state) async {
    if (state.cities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала создайте хотя бы один город')),
      );
      return;
    }

    int? selectedCityId;

    final created =
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) {
            return StatefulBuilder(
              builder: (context, setModalState) {
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
                          'Создать ПВЗ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: selectedCityId,
                        decoration: InputDecoration(
                          labelText: 'Город',
                          prefixIcon: const Icon(Icons.location_city),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: state.cities.map((city) {
                          final cityId =
                              int.tryParse(city['city_id'].toString()) ?? 0;
                          final cityName =
                              city['city_name']?.toString() ?? 'Город';
                          return DropdownMenuItem<int>(
                            value: cityId,
                            child: Text(cityName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedCityId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            if (selectedCityId == null ||
                                selectedCityId! <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Выберите город')),
                              );
                              return;
                            }

                            final ok = await context
                                .read<AdminController>()
                                .createPickupPoint(cityId: selectedCityId!);

                            if (!mounted) return;
                            Navigator.of(sheetContext).pop(ok);
                          },
                          child: const Text('Создать'),
                        ),
                      ),
                    ],
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
      ).showSnackBar(const SnackBar(content: Text('ПВЗ создан')));
    } else {
      final error = context.read<AdminController>().state.errorMessage;
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  Future<void> _showEditDialog({
    required AdminState state,
    required int pickupPointId,
    required int currentCityId,
  }) async {
    if (state.cities.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Список городов пуст')));
      return;
    }

    int? selectedCityId = currentCityId;

    final updated =
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) {
            return StatefulBuilder(
              builder: (context, setModalState) {
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
                          'Редактировать ПВЗ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: selectedCityId,
                        decoration: InputDecoration(
                          labelText: 'Город',
                          prefixIcon: const Icon(Icons.location_city),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: state.cities.map((city) {
                          final cityId =
                              int.tryParse(city['city_id'].toString()) ?? 0;
                          final cityName =
                              city['city_name']?.toString() ?? 'Город';
                          return DropdownMenuItem<int>(
                            value: cityId,
                            child: Text(cityName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedCityId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            if (selectedCityId == null ||
                                selectedCityId! <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Выберите город')),
                              );
                              return;
                            }

                            final ok = await context
                                .read<AdminController>()
                                .updatePickupPoint(
                                  pickupPointId: pickupPointId,
                                  cityId: selectedCityId!,
                                );

                            if (!mounted) return;
                            Navigator.of(sheetContext).pop(ok);
                          },
                          child: const Text('Сохранить'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ) ??
        false;

    if (!mounted) return;

    if (updated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ПВЗ обновлён')));
    } else {
      final error = context.read<AdminController>().state.errorMessage;
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  Future<void> _confirmDelete(int pickupPointId) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Удалить ПВЗ'),
            content: Text('Удалить ПВЗ #$pickupPointId?'),
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

    final ok = await context.read<AdminController>().deletePickupPoint(
      pickupPointId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'ПВЗ удалён' : 'Не удалось удалить ПВЗ')),
    );
  }

  Future<void> _reload() async {
    await context.read<AdminController>().loadCities();
    if (!mounted) return;
    await context.read<AdminController>().loadPickupPoints(
      cityId: _selectedCityIdFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('ПВЗ'), centerTitle: true),
      body: BlocBuilder<AdminController, AdminState>(
        builder: (context, state) {
          final isLoading =
              state.status == AdminStatus.loading && state.pickupPoints.isEmpty;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AdminStatus.error && state.pickupPoints.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Не удалось загрузить ПВЗ',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<int?>(
                  value: _selectedCityIdFilter,
                  decoration: InputDecoration(
                    labelText: 'Фильтр по городу',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Все города'),
                    ),
                    ...state.cities.map((city) {
                      final cityId =
                          int.tryParse(city['city_id'].toString()) ?? 0;
                      final cityName = city['city_name']?.toString() ?? 'Город';
                      return DropdownMenuItem<int?>(
                        value: cityId,
                        child: Text(cityName),
                      );
                    }),
                  ],
                  onChanged: (value) async {
                    setState(() {
                      _selectedCityIdFilter = value;
                    });
                    await context.read<AdminController>().loadPickupPoints(
                      cityId: value,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _showCreateDialog(state),
                        icon: const Icon(Icons.add),
                        label: const Text('Добавить ПВЗ'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (state.pickupPoints.isEmpty)
                  const _AdminPickupEmptyBlock(
                    icon: Icons.location_on_outlined,
                    text: 'ПВЗ пока нет',
                  )
                else
                  ...state.pickupPoints.map((point) {
                    final pickupPointId =
                        int.tryParse(point['pickup_point_id'].toString()) ?? 0;
                    final cityId =
                        int.tryParse(point['city_id'].toString()) ?? 0;
                    final cityName = point['city_name']?.toString() ?? 'Город';

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
                            child: const Icon(Icons.location_on_outlined),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ПВЗ #$pickupPointId',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cityName,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: pickupPointId == 0
                                ? null
                                : () => _showEditDialog(
                                    state: state,
                                    pickupPointId: pickupPointId,
                                    currentCityId: cityId,
                                  ),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            onPressed: pickupPointId == 0
                                ? null
                                : () => _confirmDelete(pickupPointId),
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

class _AdminPickupEmptyBlock extends StatelessWidget {
  const _AdminPickupEmptyBlock({required this.icon, required this.text});

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
