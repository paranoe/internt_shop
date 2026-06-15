import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:diplomeprojectmobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:diplomeprojectmobile/features/profile/presentation/controllers/profile_state.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:diplomeprojectmobile/shared/widgets/auth_required.dart';

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
      final isAuth =
          context.read<AuthController>().state.status ==
          AuthStatus.authenticated;

      if (!isAuth) return;

      context.read<ProfileController>().loadProfile();
    });
  }

  String _valueOrDash(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? '—' : v;
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  String _formatBelarusPhone(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return '—';
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('375')) digits = digits.substring(3);
    if (digits.startsWith('80')) digits = digits.substring(2);
    if (digits.length < 9) return raw;
    digits = digits.substring(0, 9);
    return '+375 (${digits.substring(0, 2)}) ${digits.substring(2, 5)}-${digits.substring(5, 7)}-${digits.substring(7, 9)}';
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
            content: const Text('Удалить сохранённый пункт выдачи из профиля?'),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'ПВЗ удалён' : 'Не удалось удалить ПВЗ')),
    );
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
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Введите номер карты. Пробелы поставятся автоматически.',
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
                          if (digits.isEmpty) return 'Введите номер карты';
                          if (digits.length < _minCardDigits)
                            return 'Номер карты слишком короткий';
                          if (digits.length > _maxCardDigits)
                            return 'Слишком много цифр';
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
    }
  }

  Future<void> _showAddPickupPointDialog() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Выбор ПВЗ оставлен как в исходной версии проекта'),
      ),
    );
  }

  Widget _buildCardItem(Map card) {
    final cardId = int.tryParse(card['card_id'].toString()) ?? 0;
    final cardNumber = card['card_number']?.toString() ?? '—';

    return _SectionCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.credit_card, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardNumber,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Карта #$cardId',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: cardId == 0 ? null : () => _confirmDeleteCard(cardId),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupPointItem(Map point) {
    final userPickupId =
        int.tryParse(
          point['user_pickup_id']?.toString() ?? point['id']?.toString() ?? '',
        ) ??
        0;
    final address =
        point['address']?.toString().trim() ??
        point['display_name']?.toString().trim() ??
        'Сохранённый пункт выдачи';

    return _SectionCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              address,
              style: const TextStyle(fontWeight: FontWeight.w700),
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

  @override
  Widget build(BuildContext context) {
    final isAuth =
        context.watch<AuthController>().state.status ==
        AuthStatus.authenticated;

    if (!isAuth) {
      return const AuthRequired(
        title: 'Профиль недоступен',
        subtitle: 'Авторизуйтесь для доступа к профилю',
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
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
          if (profile == null)
            return const Center(child: Text('Нет данных профиля'));

          final firstLetter = profile.email.isNotEmpty
              ? profile.email[0].toUpperCase()
              : 'U';

          return RefreshIndicator(
            onRefresh: () => context.read<ProfileController>().loadProfile(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _SectionCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          firstLetter,
                          style: const TextStyle(
                            fontSize: 24,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Роль: ${profile.role}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _MenuItem(
                  icon: Icons.favorite_border_rounded,
                  title: 'Избранные товары',
                  subtitle: 'Список сохранённых товаров',
                  onTap: () => context.push(AppRoutes.buyerFavorites),
                ),
                const SizedBox(height: 16),
                const _SectionTitle(title: 'Личные данные'),
                const SizedBox(height: 8),
                _SectionCard(
                  child: Column(
                    children: [
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
                        value: _formatBelarusPhone(profile.phone),
                      ),
                      _ProfileRow(
                        label: 'Пол',
                        value: _valueOrDash(profile.gender),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.editProfile),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Редактировать'),
                  ),
                ),
                const SizedBox(height: 20),
                _SectionHeader(title: 'Мои карты', onAdd: _showAddCardDialog),
                const SizedBox(height: 8),
                if (state.cards.isEmpty)
                  const _EmptyBlock(
                    icon: Icons.credit_card_off_outlined,
                    text: 'Сохранённых карт пока нет',
                  )
                else
                  ...state.cards.map(_buildCardItem),
                const SizedBox(height: 20),
                _SectionHeader(
                  title: 'Мои ПВЗ',
                  onAdd: _showAddPickupPointDialog,
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
                    context.go(AppRoutes.buyerHome);
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
  const _SectionCard({required this.child, this.margin});

  final Widget child;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onAdd});
  final String title;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SectionTitle(title: title)),
        IconButton.filledTonal(onPressed: onAdd, icon: const Icon(Icons.add)),
      ],
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
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          SizedBox(
            width: 94,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
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
    return _SectionCard(
      child: Column(
        children: [
          Icon(icon, size: 30, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: AppColors.textMuted)),
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
    if (digits.length > maxDigits) digits = digits.substring(0, maxDigits);

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final isGroupEnd = (i + 1) % 4 == 0;
      final isNotLast = i + 1 != digits.length;
      if (isGroupEnd && isNotLast) buffer.write(' ');
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
