import 'package:flutter/material.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_state.dart';

class FiltersSheetContent extends StatefulWidget {
  const FiltersSheetContent({super.key, required this.state});

  final CatalogState state;

  @override
  State<FiltersSheetContent> createState() => _FiltersSheetContentState();
}

class _FiltersSheetContentState extends State<FiltersSheetContent> {
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  late double? _selectedRating;
  late Map<int, String> _selectedValues;

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(text: widget.state.minPrice);
    _maxPriceController = TextEditingController(text: widget.state.maxPrice);
    _selectedRating = widget.state.minRating;
    _selectedValues = Map<int, String>.from(widget.state.parameterFilters);
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Фильтры',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              const Text('Цена', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'От'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'До'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Рейтинг',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('4+'),
                    selected: _selectedRating == 4.0,
                    onSelected: (_) {
                      setState(() {
                        _selectedRating = _selectedRating == 4.0 ? null : 4.0;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('4.5+'),
                    selected: _selectedRating == 4.5,
                    onSelected: (_) {
                      setState(() {
                        _selectedRating = _selectedRating == 4.5 ? null : 4.5;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('5'),
                    selected: _selectedRating == 5.0,
                    onSelected: (_) {
                      setState(() {
                        _selectedRating = _selectedRating == 5.0 ? null : 5.0;
                      });
                    },
                  ),
                ],
              ),
              if (state.availableParameters.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Параметры товара',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...state.availableParameters.map((parameter) {
                  final parameterId =
                      int.tryParse(
                        (parameter['parameter_id'] ?? '').toString(),
                      ) ??
                      0;
                  final name = (parameter['name'] ?? 'Параметр').toString();
                  final values =
                      (parameter['values'] as List<dynamic>? ?? const [])
                          .map((e) => e.toString())
                          .toList();

                  if (values.isEmpty) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: values.map((value) {
                            final selected =
                                _selectedValues[parameterId] == value;

                            return ChoiceChip(
                              label: Text(value),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  if (selected) {
                                    _selectedValues.remove(parameterId);
                                  } else {
                                    _selectedValues[parameterId] = value;
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(const FilterResult.clear());
                      },
                      child: const Text('Сбросить'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(
FilterResult.apply(
                            minPrice: _minPriceController.text.trim(),
                            maxPrice: _maxPriceController.text.trim(),
                            minRating: _selectedRating,
                            parameterFilters: _selectedValues,
                          ),
                        );
                      },
                      child: const Text('Применить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterResult {
  const FilterResult.apply({
    required this.minPrice,
    required this.maxPrice,
    required this.minRating,
    required this.parameterFilters,
  }) : clear = false;

  const FilterResult.clear()
    : minPrice = '',
      maxPrice = '',
      minRating = null,
      parameterFilters = const {},
      clear = true;

  final String minPrice;
  final String maxPrice;
  final double? minRating;
  final Map<int, String> parameterFilters;
  final bool clear;
}