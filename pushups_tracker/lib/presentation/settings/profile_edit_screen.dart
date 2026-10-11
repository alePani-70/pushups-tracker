import 'package:flutter/material.dart';
import '../../data/database.dart';
import '../widgets/profile_form.dart';

/// Spec §3.7: edit name / age / weight / sex. Pops with `true` after saving.
class ProfileEditScreen extends StatefulWidget {
  final AppDatabase db;
  final User user;

  const ProfileEditScreen({super.key, required this.db, required this.user});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  bool _saving = false;

  Future<void> _save(ProfileData data) async {
    setState(() => _saving = true);
    try {
      await widget.db.updateUser(UsersCompanion(
        id: Value(widget.user.id),
        name: Value(data.name),
        age: Value(data.age),
        weightKg: Value(data.weightKg),
        sex: Value(data.sex),
      ));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ProfileForm(
            initial: ProfileData(
              name: u.name,
              age: u.age ?? 30,
              weightKg: u.weightKg,
              sex: u.sex,
            ),
            submitLabel: 'SAVE',
            busy: _saving,
            onSubmit: _save,
          ),
        ),
      ),
    );
  }
}
