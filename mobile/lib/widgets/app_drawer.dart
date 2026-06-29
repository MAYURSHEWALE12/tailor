import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final loc = AppLocalizations.of(context);

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primary),
            accountName: Text(
              user?.name ?? 'User',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(user?.phone ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user != null && user.name.isNotEmpty
                    ? user.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _DrawerItem(
            icon: Icons.dashboard_outlined,
            label: loc?.translate('dashboard') ?? 'Dashboard',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
          _DrawerItem(
            icon: Icons.bar_chart_outlined,
            label: loc?.translate('reports') ?? 'Reports',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/reports');
            },
          ),
          _DrawerItem(
            icon: Icons.people_outlined,
            label: loc?.translate('customers') ?? 'Customers',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/customers');
            },
          ),
          _DrawerItem(
            icon: Icons.person_add_outlined,
            label: loc?.translate('add_customer') ?? 'Add Customer',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/add-customer');
            },
          ),
          _DrawerItem(
            icon: Icons.settings_outlined,
            label: loc?.translate('settings') ?? 'Settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: Icon(Icons.palette_outlined, color: Theme.of(context).colorScheme.onSurface),
            title: Text(
              loc?.translate('theme') ?? 'Theme',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: DropdownButton<ThemeMode>(
              value: Provider.of<ThemeProvider>(context).themeMode,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(loc?.translate('light') ?? 'Light'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(loc?.translate('dark') ?? 'Dark'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(loc?.translate('system') ?? 'System'),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  Provider.of<ThemeProvider>(context, listen: false).changeTheme(mode);
                }
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.language, color: Theme.of(context).colorScheme.onSurface),
            title: Text(
              loc?.translate('select_language') ?? 'Language',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: DropdownButton<String>(
              value: Provider.of<LanguageProvider>(context).locale.languageCode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'hi', child: Text('हिंदी')),
                DropdownMenuItem(value: 'mr', child: Text('मराठी')),
              ],
              onChanged: (langCode) {
                if (langCode != null) {
                  Provider.of<LanguageProvider>(context, listen: false)
                      .changeLanguage(langCode);
                }
              },
            ),
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.logout,
            label: loc?.translate('logout') ?? 'Logout',
            textColor: AppTheme.danger,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(loc?.translate('logout_confirm_title') ?? 'Logout'),
                  content: Text(loc?.translate('logout_confirm_msg') ?? 'Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(loc?.translate('cancel') ?? 'Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(
                        loc?.translate('logout') ?? 'Logout',
                        style: const TextStyle(color: AppTheme.danger),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: textColor ?? onSurface),
      title: Text(
        label,
        style: TextStyle(
          color: textColor ?? onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
