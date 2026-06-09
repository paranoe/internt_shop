import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:diplomeprojectmobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:diplomeprojectmobile/features/profile/presentation/controllers/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const int _minCardDigits = 12;
  static const int _maxCardDigits = 19;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().loadProfile();
    });
  }

  String _valueOrDash(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? '—' : v;
  }

  String _formatBelarusPhone(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return '—';

    var digits = raw.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('375')) {
      digits = digits.substring(3);
    }

    if (digits.startsWith('80')) {
      digits = digits.substring(2);
    }

    if (digits.length < 9) {
      return raw;
    }

    digits = digits.substring(0, 9);

    return '+375 (${digits.substring(0, 2)}) '
        '${digits.substring(2, 5)}-'
        '${digits.substring(5, 7)}-'
        '${digits.substring(7, 9)}';
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  Future<void> _confirmDeleteCard(int cardId) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Удалить карту'),
            content: const Text('Вы действительно хотите удалить карту?'),
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

    await context.read<ProfileController>().deleteCard(cardId);
  }

  Future<void> _confirmDeletePickupPoint(int userPickupId) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Удалить ПВЗ'),
            content: const Text('Удалить сохранённый ПВЗ из профиля?'),
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

    final ok = await context.read<ProfileController>().deletePickupPoint(
      userPickupId,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ПВЗ удалён')));
    } else {
      final error = context.read<ProfileController>().state.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error?.isNotEmpty == true ? error! : 'Не удалось удалить ПВЗ',
          ),
        ),
      );
    }
  }

  Future<void> _showAddCardDialog() async {
    final formKey = GlobalKey<FormState>();
    final cardController = TextEditingController();

    final saved =
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
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Form(
                  key: formKey,
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
                        'Добавить карту',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Введите номер карты. Пробелы поставятся автоматически.',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: cardController,
                        keyboardType: TextInputType.number,
                        autofillHints: const [AutofillHints.creditCardNumber],
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CardNumberInputFormatter(maxDigits: _maxCardDigits),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Номер карты',
                          hintText: '1234 5678 9012 3456',
                          prefixIcon: const Icon(Icons.credit_card),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          helperText:
                              'Допустимо от $_minCardDigits до $_maxCardDigits цифр',
                        ),
                        validator: (value) {
                          final digits = _digitsOnly(value ?? '');

                          if (digits.isEmpty) {
                            return 'Введите номер карты';
                          }

                          if (digits.length < _minCardDigits) {
                            return 'Номер карты слишком короткий';
                          }

                          if (digits.length > _maxCardDigits) {
                            return 'Слишком много цифр';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            final raw = _digitsOnly(cardController.text);
                            final ok = await context
                                .read<ProfileController>()
                                .addCard(raw);

                            if (!mounted) return;
                            Navigator.of(sheetContext).pop(ok);
                          },
                          icon: const Icon(Icons.add_card),
                          label: const Text('Сохранить карту'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ) ??
        false;

    cardController.dispose();

    if (!mounted) return;

    if (saved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Карта добавлена')));
    } else {
      final error = context.read<ProfileController>().state.errorMessage;
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  Future<void> _showAddPickupPointDialog() async {
    final profileController = context.read<ProfileController>();
    final cities = await profileController.getCities();

    if (!mounted) return;

    if (cities.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Список городов пуст')));
      return;
    }

    int? selectedCityId;
    int? selectedStreetId;
    int? selectedHouseId;
    int? selectedPickupPointId;

    List<Map<String, dynamic>> allCityPickupPoints = [];
    List<Map<String, dynamic>> streets = [];
    List<Map<String, dynamic>> houses = [];
    List<Map<String, dynamic>> pickupPoints = [];

    bool isLoading = false;

    String addressFromPoint(Map<String, dynamic> point) {
      final address =
          point['address']?.toString().trim() ??
          point['display_name']?.toString().trim() ??
          '';

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

      return parts.isEmpty ? 'ПВЗ' : parts.join(', ');
    }

    List<Map<String, dynamic>> uniqueById({
      required List<Map<String, dynamic>> items,
      required String idKey,
    }) {
      final ids = <int>{};
      final result = <Map<String, dynamic>>[];

      for (final item in items) {
        final id = int.tryParse(item[idKey]?.toString() ?? '') ?? 0;

        if (id <= 0 || ids.contains(id)) {
          continue;
        }

        ids.add(id);
        result.add(item);
      }

      return result;
    }

    int? safeDropdownValue({
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

    final saved =
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                Future<void> loadCityData(int cityId) async {
                  setModalState(() {
                    isLoading = true;
                    selectedStreetId = null;
                    selectedHouseId = null;
                    selectedPickupPointId = null;
                    allCityPickupPoints = [];
                    streets = [];
                    houses = [];
                    pickupPoints = [];
                  });

                  final loaded = await profileController.getPickupPointsByCity(
                    cityId,
                  );

                  if (!mounted) return;

                  final loadedStreets = uniqueById(
                    items: loaded,
                    idKey: 'street_id',
                  );

                  setModalState(() {
                    allCityPickupPoints = loaded;
                    streets = loadedStreets;
                    isLoading = false;
                  });
                }

                void loadHousesByStreet(int streetId) {
                  final loadedHouses = allCityPickupPoints.where((point) {
                    final id =
                        int.tryParse(point['street_id']?.toString() ?? '') ?? 0;
                    return id == streetId;
                  }).toList();

                  setModalState(() {
                    selectedHouseId = null;
                    selectedPickupPointId = null;
                    houses = uniqueById(items: loadedHouses, idKey: 'house_id');
                    pickupPoints = [];
                  });
                }

                void loadPickupPointsByHouse(int houseId) {
                  final loadedPickupPoints = allCityPickupPoints.where((point) {
                    final id =
                        int.tryParse(point['house_id']?.toString() ?? '') ?? 0;
                    return id == houseId;
                  }).toList();

                  setModalState(() {
                    selectedPickupPointId = null;
                    pickupPoints = loadedPickupPoints;
                  });
                }

                final safeCityId = safeDropdownValue(
                  value: selectedCityId,
                  items: cities,
                  idKey: 'city_id',
                );

                final safeStreetId = safeDropdownValue(
                  value: selectedStreetId,
                  items: streets,
                  idKey: 'street_id',
                );

                final safeHouseId = safeDropdownValue(
                  value: selectedHouseId,
                  items: houses,
                  idKey: 'house_id',
                );

                final safePickupPointId = safeDropdownValue(
                  value: selectedPickupPointId,
                  items: pickupPoints,
                  idKey: 'pickup_point_id',
                );

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(sheetContext).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    24 + MediaQuery.of(sheetContext).viewInsets.bottom,
                  ),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Выбрать ПВЗ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: safeCityId,
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
                            items: cities.map((city) {
                              final cityId =
                                  int.tryParse(city['city_id'].toString()) ?? 0;
                              final cityName =
                                  city['city_name']?.toString() ?? '—';

                              return DropdownMenuItem<int>(
                                value: cityId,
                                child: Text(cityName),
                              );
                            }).toList(),
                            onChanged: (value) async {
                              if (value == null || value <= 0) return;

                              selectedCityId = value;
                              await loadCityData(value);
                            },
                          ),
                          const SizedBox(height: 16),
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: CircularProgressIndicator(),
                            )
                          else ...[
                            DropdownButtonFormField<int>(
                              value: safeStreetId,
                              decoration: InputDecoration(
                                labelText: 'Улица',
                                prefixIcon: const Icon(Icons.signpost_outlined),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: streets.map((point) {
                                final streetId =
                                    int.tryParse(
                                      point['street_id']?.toString() ?? '',
                                    ) ??
                                    0;

                                final streetName =
                                    point['street_name']?.toString() ?? '—';

                                return DropdownMenuItem<int>(
                                  value: streetId,
                                  child: Text(streetName),
                                );
                              }).toList(),
                              onChanged: streets.isEmpty
                                  ? null
                                  : (value) {
                                      if (value == null || value <= 0) return;

                                      selectedStreetId = value;
                                      loadHousesByStreet(value);
                                    },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              value: safeHouseId,
                              decoration: InputDecoration(
                                labelText: 'Дом',
                                prefixIcon: const Icon(Icons.home_outlined),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: houses.map((point) {
                                final houseId =
                                    int.tryParse(
                                      point['house_id']?.toString() ?? '',
                                    ) ??
                                    0;

                                final houseNumber =
                                    point['house_number']?.toString() ?? '—';

                                return DropdownMenuItem<int>(
                                  value: houseId,
                                  child: Text(houseNumber),
                                );
                              }).toList(),
                              onChanged: houses.isEmpty
                                  ? null
                                  : (value) {
                                      if (value == null || value <= 0) return;

                                      selectedHouseId = value;
                                      loadPickupPointsByHouse(value);
                                    },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              value: safePickupPointId,
                              decoration: InputDecoration(
                                labelText: 'ПВЗ',
                                prefixIcon: const Icon(
                                  Icons.location_on_outlined,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: pickupPoints.map((point) {
                                final pickupPointId =
                                    int.tryParse(
                                      point['pickup_point_id']?.toString() ??
                                          '',
                                    ) ??
                                    0;

                                return DropdownMenuItem<int>(
                                  value: pickupPointId,
                                  child: Text(addressFromPoint(point)),
                                );
                              }).toList(),
                              onChanged: pickupPoints.isEmpty
                                  ? null
                                  : (value) {
                                      setModalState(() {
                                        selectedPickupPointId = value;
                                      });
                                    },
                            ),
                          ],
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () async {
                                if (selectedPickupPointId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Выберите ПВЗ'),
                                    ),
                                  );
                                  return;
                                }

                                final ok = await profileController
                                    .addPickupPoint(selectedPickupPointId!);

                                if (!mounted) return;
                                Navigator.of(sheetContext).pop(ok);
                              },
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Сохранить ПВЗ'),
                            ),
                          ),
                        ],
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

    if (saved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ПВЗ сохранён')));
    } else {
      final error = context.read<ProfileController>().state.errorMessage;
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  Widget _buildCardItem(Map<String, dynamic> card) {
    final cardId = int.tryParse(card['card_id'].toString()) ?? 0;
    final cardNumber = card['card_number']?.toString() ?? '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.blue.shade500, Colors.indigo.shade500],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Карта #$cardId',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: cardId == 0 ? null : () => _confirmDeleteCard(cardId),
            icon: const Icon(Icons.delete_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupPointItem(Map<String, dynamic> point) {
    print('PROFILE PICKUP ITEM: $point');
    final userPickupId =
        int.tryParse(
          point['user_pickup_id']?.toString() ?? point['id']?.toString() ?? '',
        ) ??
        0;

    final pickupPointId =
        int.tryParse(point['pickup_point_id']?.toString() ?? '') ?? 0;

    final address =
        point['address']?.toString().trim() ??
        point['display_name']?.toString().trim() ??
        '';

    final streetName = point['street_name']?.toString().trim() ?? '';
    final houseNumber = point['house_number']?.toString().trim() ?? '';
    final cityName = point['city_name']?.toString().trim() ?? '';

    final fallbackAddress = [
      if (streetName.isNotEmpty) 'ул. $streetName',
      if (houseNumber.isNotEmpty) 'д. $houseNumber',
      if (cityName.isNotEmpty) cityName,
    ].join(', ');

    final displayAddress = address.isNotEmpty
        ? address
        : fallbackAddress.isNotEmpty
        ? fallbackAddress
        : 'ПВЗ #$pickupPointId';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
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
              color: Colors.deepPurple.withValues(alpha: 0.10),
            ),
            child: const Icon(Icons.location_on_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayAddress,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Сохранённый пункт выдачи',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: userPickupId <= 0
                ? null
                : () => _confirmDeletePickupPoint(userPickupId),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesEntry() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            context.push(AppRoutes.buyerFavorites);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Избранные товары',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Список сохранённых товаров',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7FB),
      ),
      body: BlocBuilder<ProfileController, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading && state.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ProfileStatus.error && state.profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Не удалось загрузить профиль',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final profile = state.profile;
          if (profile == null) {
            return const Center(child: Text('Нет данных профиля'));
          }

          final firstLetter = profile.email.isNotEmpty
              ? profile.email[0].toUpperCase()
              : 'U';

          return RefreshIndicator(
            onRefresh: () => context.read<ProfileController>().loadProfile(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.20,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withValues(alpha: 0.20),
                        child: Text(
                          firstLetter,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.email,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Роль: ${profile.role}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildFavoritesEntry(),
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle(title: 'Личные данные'),
                      const SizedBox(height: 12),
                      _ProfileRow(
                        label: 'Имя',
                        value: _valueOrDash(profile.firstName),
                      ),
                      _ProfileRow(
                        label: 'Фамилия',
                        value: _valueOrDash(profile.lastName),
                      ),
                      _ProfileRow(
                        label: 'Отчество',
                        value: _valueOrDash(profile.patronymic),
                      ),
                      _ProfileRow(
                        label: 'Телефон',
                        value: _valueOrDash(_formatBelarusPhone(profile.phone)),
                      ),
                      _ProfileRow(
                        label: 'Пол',
                        value: _valueOrDash(profile.gender),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          context.push(AppRoutes.editProfile);
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Редактировать'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: _SectionTitle(title: 'Мои карты')),
                    IconButton.filledTonal(
                      onPressed: _showAddCardDialog,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.cards.isEmpty)
                  const _EmptyBlock(
                    icon: Icons.credit_card_off_outlined,
                    text: 'Сохранённых карт пока нет',
                  )
                else
                  ...state.cards.map(_buildCardItem),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: _SectionTitle(title: 'Мои ПВЗ')),
                    IconButton.filledTonal(
                      onPressed: _showAddPickupPointDialog,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.pickupPoints.isEmpty)
                  const _EmptyBlock(
                    icon: Icons.location_off_outlined,
                    text: 'Сохранённых ПВЗ пока нет',
                  )
                else
                  ...state.pickupPoints.map(_buildPickupPointItem),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthController>().logout();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Выйти'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({required this.icon, required this.text});

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

class _CardNumberInputFormatter extends TextInputFormatter {
  _CardNumberInputFormatter({required this.maxDigits});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final isGroupEnd = (i + 1) % 4 == 0;
      final isNotLast = i + 1 != digits.length;
      if (isGroupEnd && isNotLast) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
