import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project_bfsi/auth/data/auth_repository.dart';
import 'package:flutter_project_bfsi/auth/security/secure_storage_service.dart';
import 'package:flutter_project_bfsi/auth/state/auth_cubit.dart';
import 'package:flutter_project_bfsi/common/colors.dart';
import 'package:flutter_project_bfsi/transaction/data/transaction_repository.dart';
import 'package:flutter_project_bfsi/transaction/presentation/transaction_list_screen.dart';
import 'package:flutter_project_bfsi/transaction/state/transaction_cubit.dart';

import 'auth/presentation/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => const AuthRepository(),
        ),
        RepositoryProvider<SecureStorageService>(
          create: (_) => SecureStorageService(),
        ),
        RepositoryProvider<TransactionRepository>(
          create: (_) => const TransactionRepository(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(
              authRepository: context.read<AuthRepository>(),
              secureStorageService: context.read<SecureStorageService>(),
            )..checkSession(),
            child: MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: deepPurple),
                useMaterial3: true,
              ),
              routes: {
                '/': (_) => const LoginPage(),
                '/transactions': (context) => BlocProvider<TransactionCubit>(
                      create: (_) => TransactionCubit(
                        repository: context.read<TransactionRepository>(),
                        pageSize: 10,
                      ),
                      child: const TransactionListScreen(),
                    ),
              },
              initialRoute: '/',
            ),
          );
        },
      ),
    );
  }
}
