import 'package:flutter/material.dart';
import '../../core/constants/country_data.dart';
import '../../core/theme/app_theme.dart';

/// Shows a bottom sheet country picker matching modern mobile app standards.
Future<Country?> showCountryPickerSheet({
  required BuildContext context,
  String? selectedCountry,
}) {
  return showModalBottomSheet<Country>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _CountryPickerSheet(selectedCountry: selectedCountry),
  );
}

class _CountryPickerSheet extends StatefulWidget {
  final String? selectedCountry;
  const _CountryPickerSheet({this.selectedCountry});

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  late TextEditingController _searchController;
  List<Country> _filtered = kCountries;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = kCountries;
      } else {
        _filtered = kCountries.where((c) {
          return c.name.toLowerCase().contains(q) ||
              c.code.toLowerCase().contains(q) ||
              c.dialCode.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, -6),
          )
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('🌍', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Text(
                  'Select Country',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search country or code...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Divider
          Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),

          // Country list
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 10),
                        Text(
                          'No country found',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 64,
                      color: colorScheme.outline.withOpacity(0.12),
                    ),
                    itemBuilder: (context, index) {
                      final country = _filtered[index];
                      final isSelected = widget.selectedCountry != null &&
                          (widget.selectedCountry == country.name ||
                              widget.selectedCountry == country.displayName ||
                              widget.selectedCountry == country.code);

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        tileColor: isSelected
                            ? AppTheme.primaryMint.withOpacity(0.12)
                            : Colors.transparent,
                        leading: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            country.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        title: Text(
                          country.name,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          '${country.code} • ${country.dialCode}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppTheme.primaryMint,
                                size: 24,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, country),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
