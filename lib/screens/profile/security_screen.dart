import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _tfaEnabled = false;
  bool _biometricEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _tfaEnabled = prefs.getBool('security_tfa') ?? false;
        _biometricEnabled = prefs.getBool('security_biometric') ?? false;
        _loading = false;
      });
    }
  }

  Future<void> _toggleTfa(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('security_tfa', value);
    setState(() => _tfaEnabled = value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Two-Factor Authentication enabled!' : 'Two-Factor Authentication disabled!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('security_biometric', value);
    setState(() => _biometricEnabled = value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Biometric Authentication enabled!' : 'Biometric Authentication disabled!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Security & Privacy',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Protection Options',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Toggle lists
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          _switchRow(
                            context,
                            Icons.phonelink_lock_rounded,
                            'Two-Factor Auth (2FA)',
                            'Secure your login sessions',
                            _tfaEnabled,
                            _toggleTfa,
                          ),
                          const Divider(height: 20, thickness: 0.5),
                          _switchRow(
                            context,
                            Icons.fingerprint_rounded,
                            'Biometric Verification',
                            'Unlock with FaceID / TouchID',
                            _biometricEnabled,
                            _toggleBiometric,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Active Logins',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Session card list
                    _sessionItem(
                      context,
                      Icons.phone_android_rounded,
                      'Pixel 7 Pro (This Device)',
                      'Manila, Philippines • Active now',
                      isCurrent: true,
                    ),
                    const SizedBox(height: 12),
                    _sessionItem(
                      context,
                      Icons.laptop_chromebook_rounded,
                      'MacBook Pro 16"',
                      'Quezon City, Philippines • 2 hours ago',
                    ),
                    const SizedBox(height: 12),
                    _sessionItem(
                      context,
                      Icons.devices_other_rounded,
                      'TalkToss Desktop Client',
                      'Pasig, Philippines • May 22, 2026',
                    ),
                    const SizedBox(height: 32),

                    // Change password mock option
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Change Password'),
                            content: const Text(
                              'Since you are logged in via Google, password management is handled directly through your Google Account.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.password_rounded, color: cs.primary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Update Password',
                                    style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Linked via Google Auth provider',
                                    style: TextStyle(
                                      color: cs.onSurface.withValues(alpha: 0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.open_in_new_rounded, size: 18, color: cs.outline),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _switchRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.primary.withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: cs.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: cs.onSurface, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 12),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _sessionItem(
    BuildContext context,
    IconData icon,
    String device,
    String location, {
    bool isCurrent = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? cs.primary.withValues(alpha: 0.3) : cs.outlineVariant.withValues(alpha: 0.2),
          width: isCurrent ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: isCurrent ? cs.primary : cs.outline),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!isCurrent)
            IconButton(
              icon: Icon(Icons.logout_rounded, color: cs.error.withValues(alpha: 0.7), size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Session revoked successfully.')),
                );
              },
            ),
        ],
      ),
    );
  }
}
