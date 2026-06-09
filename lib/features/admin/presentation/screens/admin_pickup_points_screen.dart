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

  String _addressFromPoint(Map<String, dynamic> point) {
    final address = point['address']?.toString().trim() ?? '';

    if (address.isNotEmpty) {
      return address;
    }

    final streetName = point['street_name']?.toString().trim() ?? '';
    final houseNumber = point['house_number']?.toString().trim() ?? '';
    final cityName = point['city_name']?.toString().trim() ?? '';

    final parts = <String>[];

    if (streetName.isNotEmpty) {
      parts.add('ул. $streetName');
    }

    if (houseNumber.isNotEmpty) {
      parts.add('д. $houseNumber');
    }

    if (cityName.isNotEmpty) {
      parts.add(cityName);
    }

    if (parts.isEmpty) {
      return 'Адрес ПВЗ не указан';
    }

    return parts.join(', ');
  }

  Future<void> _reload() async {
    await context.read<AdminController>().loadCities();

    if (!mounted) return;

    await context.read<AdminController>().loadPickupPoints(
      cityId: _selectedCityIdFilter,
    );
  }

  Future<String?> _showTextInputDialog({
    required String title,
    required String label,
    required String hint,
    required IconData icon,
  }) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: Icon(icon),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isEmpty) {
                  return;
                }

                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop(value);
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );

    return result;
  }

  Future<Map<String, dynamic>?> _addStreet(int cityId) async {
    final streetName = await _showTextInputDialog(
      title: 'Добавить улицу',
      label: 'Название улицы',
      hint: 'Например: Ленина',
      icon: Icons.signpost_outlined,
    );

    if (streetName == null || streetName.trim().isEmpty) {
      return null;
    }

    final ok = await context.read<AdminController>().createStreet(
      cityId: cityId,
      streetName: streetName.trim(),
    );

    if (!ok || !mounted) {
      return null;
    }

    final streets = await context.read<AdminController>().getStreetsByCity(
      cityId,
    );

    for (final street in streets) {
      final name = street['street_name']?.toString().trim().toLowerCase() ?? '';

      if (name == streetName.trim().toLowerCase()) {
        return street;
      }
    }

    return streets.isNotEmpty ? streets.last : null;
  }

  Future<Map<String, dynamic>?> _addHouse(int streetId) async {
    final houseNumber = await _showTextInputDialog(
      title: 'Добавить дом',
      label: 'Номер дома',
      hint: 'Например: 10А',
      icon: Icons.home_outlined,
    );

    if (houseNumber == null || houseNumber.trim().isEmpty) {
      return null;
    }

    final ok = await context.read<AdminController>().createHouse(
      streetId: streetId,
      houseNumber: houseNumber.trim(),
    );

    if (!ok || !mounted) {
      return null;
    }

    final houses = await context.read<AdminController>().getHousesByStreet(
      streetId,
    );

    for (final house in houses) {
      final number =
          house['house_number']?.toString().trim().toLowerCase() ?? '';

      if (number == houseNumber.trim().toLowerCase()) {
        return house;
      }
    }

    return houses.isNotEmpty ? houses.last : null;
  }

  Future<void> _showCreateDialog() async {
    final cities = List<Map<String, dynamic>>.from(
      context.read<AdminController>().state.cities,
    );

    final created =
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) {
            return _PickupPointEditorSheet(
              title: 'Создать ПВЗ',
              cities: cities,
              actionText: 'Создать',
              initialCityId: null,
              initialStreetId: null,
              initialHouseId: null,
              onAddStreet: _addStreet,
              onAddHouse: _addHouse,
              onSubmit: (houseId) async {
                return context.read<AdminController>().createPickupPoint(
                  houseId: houseId,
                );
              },
            );
          },
        ) ??
        false;

    if (!mounted) return;

    if (created) {
      await _reload();

      if (!mounted) return;

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
    required int pickupPointId,
    required int currentCityId,
    required int currentStreetId,
    required int currentHouseId,
  }) async {
    final cities = List<Map<String, dynamic>>.from(
      context.read<AdminController>().state.cities,
    );

    final updated =
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) {
            return _PickupPointEditorSheet(
              title: 'Редактировать ПВЗ',
              cities: cities,
              actionText: 'Сохранить',
              initialCityId: currentCityId > 0 ? currentCityId : null,
              initialStreetId: currentStreetId > 0 ? currentStreetId : null,
              initialHouseId: currentHouseId > 0 ? currentHouseId : null,
              onAddStreet: _addStreet,
              onAddHouse: _addHouse,
              onSubmit: (houseId) async {
                return context.read<AdminController>().updatePickupPoint(
                  pickupPointId: pickupPointId,
                  houseId: houseId,
                );
              },
            );
          },
        ) ??
        false;

    if (!mounted) return;

    if (updated) {
      await _reload();

      if (!mounted) return;

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

  Future<void> _confirmDelete({
    required int pickupPointId,
    required String address,
  }) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Удалить ПВЗ'),
              content: Text('Удалить пункт выдачи по адресу:\n$address?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Удалить'),
                ),
              ],
            );
          },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Пункты выдачи заказов'),
        centerTitle: true,
      ),
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
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: state.cities.isEmpty ? null : _showCreateDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить ПВЗ'),
                  ),
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
                        int.tryParse(
                          point['pickup_point_id']?.toString() ?? '',
                        ) ??
                        0;

                    final houseId =
                        int.tryParse(point['house_id']?.toString() ?? '') ?? 0;

                    final streetId =
                        int.tryParse(point['street_id']?.toString() ?? '') ?? 0;

                    final cityId =
                        int.tryParse(point['city_id']?.toString() ?? '') ?? 0;

                    final streetName =
                        point['street_name']?.toString().trim() ?? '';
                    final houseNumber =
                        point['house_number']?.toString().trim() ?? '';
                    final cityName =
                        point['city_name']?.toString().trim() ?? '';
                    final address = _addressFromPoint(point);

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
                                  address,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  [
                                    if (streetName.isNotEmpty)
                                      'Улица: $streetName',
                                    if (houseNumber.isNotEmpty)
                                      'Дом: $houseNumber',
                                    if (cityName.isNotEmpty) 'Город: $cityName',
                                  ].join(' • '),
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID дома: $houseId',
                                  style: const TextStyle(
                                    color: Colors.black38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: pickupPointId == 0
                                ? null
                                : () => _showEditDialog(
                                    pickupPointId: pickupPointId,
                                    currentCityId: cityId,
                                    currentStreetId: streetId,
                                    currentHouseId: houseId,
                                  ),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            onPressed: pickupPointId == 0
                                ? null
                                : () => _confirmDelete(
                                    pickupPointId: pickupPointId,
                                    address: address,
                                  ),
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

class _PickupPointEditorSheet extends StatefulWidget {
  const _PickupPointEditorSheet({
    required this.title,
    required this.cities,
    required this.actionText,
    required this.initialCityId,
    required this.initialStreetId,
    required this.initialHouseId,
    required this.onSubmit,
    required this.onAddStreet,
    required this.onAddHouse,
  });

  final String title;
  final List<Map<String, dynamic>> cities;
  final String actionText;
  final int? initialCityId;
  final int? initialStreetId;
  final int? initialHouseId;
  final Future<bool> Function(int houseId) onSubmit;
  final Future<Map<String, dynamic>?> Function(int cityId) onAddStreet;
  final Future<Map<String, dynamic>?> Function(int streetId) onAddHouse;

  @override
  State<_PickupPointEditorSheet> createState() =>
      _PickupPointEditorSheetState();
}

class _PickupPointEditorSheetState extends State<_PickupPointEditorSheet> {
  int? _selectedCityId;
  int? _selectedStreetId;
  int? _selectedHouseId;

  List<Map<String, dynamic>> _streets = [];
  List<Map<String, dynamic>> _houses = [];

  bool _isLoadingStreets = false;
  bool _isLoadingHouses = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _selectedCityId = widget.initialCityId;
    _selectedStreetId = widget.initialStreetId;
    _selectedHouseId = widget.initialHouseId;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_selectedCityId != null) {
        await _loadStreets(_selectedCityId!, keepSelection: true);
      }

      if (_selectedStreetId != null) {
        await _loadHouses(_selectedStreetId!, keepSelection: true);
      }
    });
  }

  Future<void> _loadStreets(int cityId, {bool keepSelection = false}) async {
    setState(() {
      _isLoadingStreets = true;
      _streets = [];
      _houses = [];

      if (!keepSelection) {
        _selectedStreetId = null;
        _selectedHouseId = null;
      }
    });

    final items = await context.read<AdminController>().getStreetsByCity(
      cityId,
    );

    if (!mounted) return;

    final selectedStreetExists = items.any((item) {
      final id = int.tryParse(item['street_id']?.toString() ?? '') ?? 0;
      return id == _selectedStreetId;
    });

    setState(() {
      _streets = items;
      _isLoadingStreets = false;

      if (!selectedStreetExists) {
        _selectedStreetId = null;
        _selectedHouseId = null;
      }
    });
  }

  Future<void> _loadHouses(int streetId, {bool keepSelection = false}) async {
    setState(() {
      _isLoadingHouses = true;
      _houses = [];

      if (!keepSelection) {
        _selectedHouseId = null;
      }
    });

    final items = await context.read<AdminController>().getHousesByStreet(
      streetId,
    );

    if (!mounted) return;

    final selectedHouseExists = items.any((item) {
      final id = int.tryParse(item['house_id']?.toString() ?? '') ?? 0;
      return id == _selectedHouseId;
    });

    setState(() {
      _houses = items;
      _isLoadingHouses = false;

      if (!selectedHouseExists) {
        _selectedHouseId = null;
      }
    });
  }

  Future<void> _addStreet() async {
    final cityId = _selectedCityId;

    if (cityId == null || cityId <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Сначала выберите город')));
      return;
    }

    final street = await widget.onAddStreet(cityId);

    if (!mounted || street == null) return;

    final streetId = int.tryParse(street['street_id']?.toString() ?? '') ?? 0;

    final items = await context.read<AdminController>().getStreetsByCity(
      cityId,
    );

    if (!mounted) return;

    final exists = items.any((item) {
      final id = int.tryParse(item['street_id']?.toString() ?? '') ?? 0;
      return id == streetId;
    });

    setState(() {
      _streets = items;
      _houses = [];
      _selectedStreetId = exists && streetId > 0 ? streetId : null;
      _selectedHouseId = null;
    });

    if (exists && streetId > 0) {
      await _loadHouses(streetId);
    }
  }

  Future<void> _addHouse() async {
    final streetId = _selectedStreetId;

    if (streetId == null || streetId <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Сначала выберите улицу')));
      return;
    }

    final house = await widget.onAddHouse(streetId);

    if (!mounted || house == null) return;

    final houseId = int.tryParse(house['house_id']?.toString() ?? '') ?? 0;

    final items = await context.read<AdminController>().getHousesByStreet(
      streetId,
    );

    if (!mounted) return;

    final exists = items.any((item) {
      final id = int.tryParse(item['house_id']?.toString() ?? '') ?? 0;
      return id == houseId;
    });

    setState(() {
      _houses = items;
      _selectedHouseId = exists && houseId > 0 ? houseId : null;
    });
  }

  Future<void> _submit() async {
    final houseId = _selectedHouseId;

    if (houseId == null || houseId <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите дом')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final ok = await widget.onSubmit(houseId);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    Navigator.of(context).pop(ok);
  }

  String _cityName(Map<String, dynamic> city) {
    return city['city_name']?.toString() ?? 'Город';
  }

  String _streetName(Map<String, dynamic> street) {
    return street['street_name']?.toString() ?? 'Улица';
  }

  String _houseNumber(Map<String, dynamic> house) {
    return house['house_number']?.toString() ?? 'Дом';
  }

  int? _safeDropdownValue({
    required int? value,
    required List<Map<String, dynamic>> items,
    required String idKey,
  }) {
    if (value == null) return null;

    final exists = items.any((item) {
      final id = int.tryParse(item[idKey]?.toString() ?? '') ?? 0;
      return id == value;
    });

    return exists ? value : null;
  }

  @override
  Widget build(BuildContext context) {
    final safeCityValue = _safeDropdownValue(
      value: _selectedCityId,
      items: widget.cities,
      idKey: 'city_id',
    );

    final safeStreetValue = _safeDropdownValue(
      value: _selectedStreetId,
      items: _streets,
      idKey: 'street_id',
    );

    final safeHouseValue = _safeDropdownValue(
      value: _selectedHouseId,
      items: _houses,
      idKey: 'house_id',
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: safeCityValue,
                  decoration: _inputDecoration(
                    label: 'Город',
                    icon: Icons.location_city_outlined,
                  ),
                  items: widget.cities.map((city) {
                    final cityId =
                        int.tryParse(city['city_id']?.toString() ?? '') ?? 0;

                    return DropdownMenuItem<int>(
                      value: cityId,
                      child: Text(_cityName(city)),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    if (value == null || value <= 0) return;

                    setState(() {
                      _selectedCityId = value;
                      _selectedStreetId = null;
                      _selectedHouseId = null;
                      _streets = [];
                      _houses = [];
                    });

                    await _loadStreets(value);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: safeStreetValue,
                        decoration: _inputDecoration(
                          label: 'Улица',
                          icon: Icons.signpost_outlined,
                        ),
                        items: _streets.map((street) {
                          final streetId =
                              int.tryParse(
                                street['street_id']?.toString() ?? '',
                              ) ??
                              0;

                          return DropdownMenuItem<int>(
                            value: streetId,
                            child: Text(_streetName(street)),
                          );
                        }).toList(),
                        onChanged: _isLoadingStreets
                            ? null
                            : (value) async {
                                if (value == null || value <= 0) return;

                                setState(() {
                                  _selectedStreetId = value;
                                  _selectedHouseId = null;
                                  _houses = [];
                                });

                                await _loadHouses(value);
                              },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: _selectedCityId == null ? null : _addStreet,
                      icon: const Icon(Icons.add),
                      tooltip: 'Добавить улицу',
                    ),
                  ],
                ),
                if (_isLoadingStreets) ...[
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: safeHouseValue,
                        decoration: _inputDecoration(
                          label: 'Дом',
                          icon: Icons.home_outlined,
                        ),
                        items: _houses.map((house) {
                          final houseId =
                              int.tryParse(
                                house['house_id']?.toString() ?? '',
                              ) ??
                              0;

                          return DropdownMenuItem<int>(
                            value: houseId,
                            child: Text(_houseNumber(house)),
                          );
                        }).toList(),
                        onChanged: _isLoadingHouses
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedHouseId = value;
                                });
                              },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: _selectedStreetId == null ? null : _addHouse,
                      icon: const Icon(Icons.add),
                      tooltip: 'Добавить дом',
                    ),
                  ],
                ),
                if (_isLoadingHouses) ...[
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(widget.actionText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
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
