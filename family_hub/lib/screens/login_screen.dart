import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/family_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      Provider.of<FamilyProvider>(context, listen: false).signInAsEmail(email);
    } else {
      Provider.of<FamilyProvider>(context, listen: false).signIn();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign in placeholder (not wired).')),
    );
    if (!mounted) return;
    context.go('/');
  }

  void _handleCreateAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create account placeholder (not wired).')),
    );
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset placeholder (not wired).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Welcome to FamilyHub',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to coordinate plans, chores, and safety alerts.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'you@example.com',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _handleForgotPassword,
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _handleSignIn,
                  child: const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _handleCreateAccount,
                  child: const Text('Create Account'),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or'),
                  ),
                  Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Continue with Google placeholder.')),
                    );
                  },
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Continue with Google'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Continue with Apple placeholder.')),
                    );
                  },
                  icon: const Icon(Icons.apple),
                  label: const Text('Continue with Apple'),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Text(
                'Demo Accounts:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _DemoAccountTile(
                label: 'Dad (Mike)',
                email: 'mike@example.com',
                onUse: () {
                  _emailController.text = 'mike@example.com';
                  _passwordController.text = 'demo';
                  _handleSignIn();
                },
              ),
              _DemoAccountTile(
                label: 'Mom (Mary)',
                email: 'mary@example.com',
                onUse: () {
                  _emailController.text = 'mary@example.com';
                  _passwordController.text = 'demo';
                  _handleSignIn();
                },
              ),
              _DemoAccountTile(
                label: 'Alex (Emma)',
                email: 'emma@example.com',
                onUse: () {
                  _emailController.text = 'emma@example.com';
                  _passwordController.text = 'demo';
                  _handleSignIn();
                },
              ),
              _DemoAccountTile(
                label: 'Sarah (Friend)',
                email: 'sarah@example.com',
                onUse: () {
                  _emailController.text = 'sarah@example.com';
                  _passwordController.text = 'demo';
                  _handleSignIn();
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Any password works for demo accounts',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                'SOS test note: alerts go to close family only (Dad, Mom, Alex). Sarah is non-close family.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Provider.of<FamilyProvider>(context, listen: false).signInAsEmail('mike@example.com');
                    context.go('/');
                  },
                  child: const Text('Skip login (dev)'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'By continuing, you agree to the FamilyHub privacy and safety guidelines.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoAccountTile extends StatelessWidget {
  final String label;
  final String email;
  final VoidCallback onUse;

  const _DemoAccountTile({
    required this.label,
    required this.email,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(email, style: const TextStyle(fontSize: 12)),
        trailing: OutlinedButton(
          onPressed: onUse,
          child: const Text('Use'),
        ),
      ),
    );
  }
}
