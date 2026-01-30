import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project_bfsi/auth/state/auth_cubit.dart';
import 'package:flutter_project_bfsi/auth/state/auth_state.dart';
import 'package:flutter_project_bfsi/common/colors.dart';
import 'package:flutter_project_bfsi/common/common_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _errorText = null);

    context.read<AuthCubit>().login(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            switch (state) {
              case AuthAuthenticated():
                Navigator.of(context).pushReplacementNamed('/transactions');
              case AuthError(message: final message):
                setState(() => _errorText = message);
              default:
                // No-op
                break;
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CustomText(
                        'Secure Transaction Dashboard',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        textAlign: TextAlign.center,
                      ),
                      Space.vertical(48),
                      CommonTextFormField(
                        controller: _usernameController,
                        labelText: 'Username',
                        prefixIcon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      Space.vertical(16),
                      CommonTextFormField(
                        controller: _passwordController,
                        labelText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        showObscureToggle: true,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onLoginPressed(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      if (_errorText != null) ...[
                        Space.vertical(16),
                        CustomText(
                          _errorText!,
                          color: Theme.of(context).colorScheme.error,
                          textAlign: TextAlign.center,
                        ),
                      ],
                      Space.vertical(32),
                      CustomButton(
                        text: isLoading ? 'Logging in...' : 'Login',
                        borderRadius: 32,
                        height: 50,
                        padding: const EdgeInsets.all(6.0),
                        backgroundColor: isLoading ? lightPurple : deepPurple,
                        onPressed: isLoading ? () {} : _onLoginPressed,
                      ),
                      if (isLoading) ...[
                        Space.vertical(16),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
