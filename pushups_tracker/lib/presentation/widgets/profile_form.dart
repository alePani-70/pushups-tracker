import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Registration data (spec §3.1 step 2). Also used to edit the profile.
class ProfileData {
  final String name;
  final int age;
  final double? weightKg;
  final String sex; // female | male | other | unspecified

  const ProfileData({required this.name, required this.age, this.weightKg, this.sex = 'unspecified'});

  static const sexOptions = <(String, String)>[
    ('female', 'Female'),
    ('male', 'Male'),
    ('other', 'Other'),
    ('unspecified', 'Prefer not to say'),
  ];

  static String sexLabel(String value) {
    for (final (v, label) in sexOptions) {
      if (v == value) return label;
    }
    return 'Prefer not to say';
  }
}

/// Name / age / weight / sex form with the validation rules from the spec:
/// name 1–40 chars, age 10–100, weight optional 20–300 kg.
class ProfileForm extends StatefulWidget {
  final ProfileData? initial;
  final String submitLabel;
  final bool busy;
  final ValueChanged<ProfileData> onSubmit;

  /// Optional widget rendered above the form (e.g. a title block).
  final Widget? header;

  const ProfileForm({
    super.key,
    this.initial,
    required this.onSubmit,
    this.submitLabel = 'CONTINUE',
    this.busy = false,
    this.header,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _weight;
  late String _sex;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _name = TextEditingController(text: i?.name ?? '');
    _age = TextEditingController(text: i?.age.toString() ?? '');
    _weight = TextEditingController(text: i?.weightKg == null ? '' : _trimZero(i!.weightKg!));
    _sex = i?.sex ?? 'unspecified';
  }

  static String _trimZero(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final weightText = _weight.text.trim().replaceAll(',', '.');
    widget.onSubmit(ProfileData(
      name: _name.text.trim(),
      age: int.parse(_age.text.trim()),
      weightKg: weightText.isEmpty ? null : double.parse(weightText),
      sex: _sex,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                if (widget.header != null) ...[widget.header!, const SizedBox(height: 16)],
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  maxLength: 40,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return 'Please enter your name';
                    if (s.length > 40) return 'Keep it under 40 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _age,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          helperText: 'Sets your rank band',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final n = int.tryParse(v?.trim() ?? '');
                          if (n == null) return 'Required';
                          if (n < 10 || n > 100) return '10–100';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _weight,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          helperText: 'Optional',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final s = v?.trim().replaceAll(',', '.') ?? '';
                          if (s.isEmpty) return null;
                          final w = double.tryParse(s);
                          if (w == null) return 'Number';
                          if (w < 20 || w > 300) return '20–300';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Sex', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final (value, label) in ProfileData.sexOptions)
                      ChoiceChip(
                        label: Text(label),
                        selected: _sex == value,
                        onSelected: (_) => setState(() => _sex = value),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Stored only on this device. Age picks the rank band shown after tests; weight and sex are kept for your own records and export.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: widget.busy ? null : _submit,
            child: widget.busy
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}
