import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_provider.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _state = TextEditingController();
  final _course = TextEditingController();
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileProvider>();
    if (!p.isLoaded) {
      p.load().then((_) => _fillFromProvider());
    } else {
      _fillFromProvider();
    }
  }

  void _fillFromProvider() {
    final up = context.read<ProfileProvider>().profile;
    _name.text = up.name;
    _email.text = up.email;
    _phone.text = up.phone;
    _state.text = up.preferredState;
    _course.text = up.preferredCourse;
    _notifications = up.notifications;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _state.dispose();
    _course.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: pp.isLoaded
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _AvatarCard(nameController: _name),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Personal Info',
                    child: Column(
                      children: [
                        _field('Name', _name, TextInputType.name),
                        _field('Email', _email, TextInputType.emailAddress),
                        _field('Phone', _phone, TextInputType.phone),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Preferences',
                    child: Column(
                      children: [
                        _field('Preferred State', _state, TextInputType.text),
                        _field('Preferred Course', _course, TextInputType.text),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Notifications'),
                          value: _notifications,
                          onChanged: (v) => setState(() => _notifications = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: pp.isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save_rounded),
                          label: const Text('Save'),
                          onPressed: pp.isSaving
                              ? null
                              : () async {
                                  final next = UserProfile(
                                    name: _name.text.trim(),
                                    email: _email.text.trim(),
                                    phone: _phone.text.trim(),
                                    preferredState: _state.text.trim(),
                                    preferredCourse: _course.text.trim(),
                                    notifications: _notifications,
                                  );
                                  await pp.save(next);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Profile saved')),
                                  );
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign out'),
                    onPressed: () {
                      // Hook your auth sign-out here.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sign out tapped')),
                      );
                    },
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _field(String label, TextEditingController c, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  final TextEditingController nameController;
  const _AvatarCard({required this.nameController});

  @override
  Widget build(BuildContext context) {
    final name = nameController.text.trim();
    final initials = name.isEmpty
        ? 'CC'
        : (name.split(RegExp(r'\s+')).take(2).map((e) => e[0]).join())
            .toUpperCase();

    return Row(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  )),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
