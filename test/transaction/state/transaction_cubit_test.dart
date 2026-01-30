import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_project_bfsi/transaction/data/transaction_repository.dart';
import 'package:flutter_project_bfsi/transaction/model/transaction_model.dart';
import 'package:flutter_project_bfsi/transaction/state/transaction_cubit.dart';
import 'package:flutter_project_bfsi/transaction/state/transaction_state.dart';
import '../../mocks/mock_repositories.dart';

void main() {
  late TransactionCubit transactionCubit;
  late MockTransactionRepository mockRepository;

  // Sample test data
  final testTransactions = List.generate(
    10,
    (index) => TransactionModel(
      id: 'txn_$index',
      date: DateTime(2024, 1, index + 1),
      amount: (index + 1) * 100.0,
      status: TransactionStatus.success,
      merchant: 'Merchant $index',
      description: 'Transaction $index',
    ),
  );

  final moreTransactions = List.generate(
    5,
    (index) => TransactionModel(
      id: 'txn_${index + 10}',
      date: DateTime(2024, 2, index + 1),
      amount: (index + 11) * 100.0,
      status: TransactionStatus.pending,
      merchant: 'Merchant ${index + 10}',
      description: 'Transaction ${index + 10}',
    ),
  );

  setUp(() {
    mockRepository = MockTransactionRepository();
    transactionCubit = TransactionCubit(
      repository: mockRepository,
      pageSize: 10,
    );
  });

  tearDown(() {
    transactionCubit.close();
  });

  group('TransactionCubit', () {
    test('initial state should be TransactionInitial', () {
      expect(transactionCubit.state, isA<TransactionInitial>());
    });

    group('loadInitialTransactions', () {
      blocTest<TransactionCubit, TransactionState>(
        'should emit [TransactionLoading, TransactionLoaded] when data is fetched successfully',
        setUp: () {
          when(() => mockRepository.fetchTransactions(
                page: 1,
                limit: 10,
              )).thenAnswer((_) async => testTransactions);
        },
        build: () => TransactionCubit(
          repository: mockRepository,
          pageSize: 10,
        ),
        act: (cubit) => cubit.loadInitialTransactions(),
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionLoaded>()
              .having(
                (state) => state.transactions.length,
                'transactions count',
                10,
              )
              .having(
                (state) => state.hasMore,
                'hasMore',
                true,
              ),
        ],
        verify: (_) {
          verify(() => mockRepository.fetchTransactions(
                page: 1,
                limit: 10,
              )).called(1);
        },
      );

      blocTest<TransactionCubit, TransactionState>(
        'should emit [TransactionLoading, TransactionEmpty] when no transactions exist',
        setUp: () {
          when(() => mockRepository.fetchTransactions(
                page: 1,
                limit: 10,
              )).thenAnswer((_) async => <TransactionModel>[]);
        },
        build: () => TransactionCubit(
          repository: mockRepository,
          pageSize: 10,
        ),
        act: (cubit) => cubit.loadInitialTransactions(),
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionEmpty>(),
        ],
      );

      blocTest<TransactionCubit, TransactionState>(
        'should emit [TransactionLoading, TransactionError] when repository throws exception',
        setUp: () {
          when(() => mockRepository.fetchTransactions(
                page: 1,
                limit: 10,
              )).thenThrow(
            TransactionRepositoryException('Failed to fetch transactions'),
          );
        },
        build: () => TransactionCubit(
          repository: mockRepository,
          pageSize: 10,
        ),
        act: (cubit) => cubit.loadInitialTransactions(),
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionError>().having(
            (state) => state.message,
            'message',
            'Failed to fetch transactions',
          ),
        ],
      );

      blocTest<TransactionCubit, TransactionState>(
        'should emit [TransactionLoading, TransactionError] with generic message on unknown error',
        setUp: () {
          when(() => mockRepository.fetchTransactions(
                page: 1,
                limit: 10,
              )).thenThrow(Exception('Unknown error'));
        },
        build: () => TransactionCubit(
          repository: mockRepository,
          pageSize: 10,
        ),
        act: (cubit) => cubit.loadInitialTransactions(),
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionError>().having(
            (state) => state.message,
            'message',
            'Unable to load transactions.',
          ),
        ],
      );

      blocTest<TransactionCubit, TransactionState>(
        'should set hasMore to false when returned items are less than pageSize',
        setUp: () {
          when(() => mockRepository.fetchTransactions(
                page: 1,
                limit: 10,
              )).thenAnswer((_) async => testTransactions.take(5).toList());
        },
        build: () => TransactionCubit(
          repository: mockRepository,
          pageSize: 10,
        ),
        act: (cubit) => cubit.loadInitialTransactions(),
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionLoaded>()
              .having(
                (state) => state.transactions.length,
                'transactions count',
                5,
              )
              .having(
                (state) => state.hasMore,
                'hasMore',
                false,
              ),
        ],
      );
    });

    group('loadMoreTransactions', () {
      blocTest<TransactionCubit, TransactionState>(
        'should load more transactions and append to existing list',
        seed: () => TransactionLoaded(
          transactions: testTransactions,
          hasMore: true,
        ),
        setUp: () {
          when(() => mockRepository.fetchTransactions(
                page: 2,
                limit: 10,
              )).thenAnswer((_) async => moreTransactions);
        },
        build: () {
          final cubit = TransactionCubit(
            repository: mockRepository,
            pageSize: 10,
          );
          // Simulate that page 1 was already loaded
          return cubit;
        },
        act: (cubit) async {
          // First load initial to set up internal state
          when(() => mockRepository.fetchTransactions(
                page: 1,
                limit: 10,
              )).thenAnswer((_) async => testTransactions);
          await cubit.loadInitialTransactions();
          // Then load more
          await cubit.loadMoreTransactions();
        },
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionLoaded>(),
          isA<TransactionLoaded>().having(
            (state) => state.isLoadingMore,
            'isLoadingMore',
            true,
          ),
          isA<TransactionLoaded>()
              .having(
                (state) => state.transactions.length,
                'transactions count',
                15,
              )
              .having(
                (state) => state.isLoadingMore,
                'isLoadingMore',
                false,
              ),
        ],
      );

      blocTest<TransactionCubit, TransactionState>(
        'should not load more when hasMore is false',
        setUp: () {
          // First load returns less than pageSize items, setting hasMore to false
          when(() => mockRepository.fetchTransactions(
                page: 1,
                limit: 10,
              )).thenAnswer((_) async => testTransactions.take(5).toList());
        },
        build: () => TransactionCubit(
          repository: mockRepository,
          pageSize: 10,
        ),
        act: (cubit) async {
          // First load initial transactions with less than pageSize
          await cubit.loadInitialTransactions();
          // Clear mock invocations to check loadMoreTransactions doesn't call repository
          clearInteractions(mockRepository);
          // Try to load more - should not call repository since hasMore is false
          await cubit.loadMoreTransactions();
        },
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionLoaded>().having(
            (state) => state.hasMore,
            'hasMore',
            false,
          ),
        ],
        verify: (_) {
          // After clearInteractions, loadMoreTransactions should not call fetchTransactions
          verifyNever(() => mockRepository.fetchTransactions(
                page: 2,
                limit: 10,
              ));
        },
      );

      blocTest<TransactionCubit, TransactionState>(
        'should not load more when state is not TransactionLoaded',
        build: () => TransactionCubit(
          repository: mockRepository,
          pageSize: 10,
        ),
        act: (cubit) async {
          // Don't load initial transactions, state remains TransactionInitial
          await cubit.loadMoreTransactions();
        },
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockRepository.fetchTransactions(
                page: any(named: 'page'),
                limit: any(named: 'limit'),
              ));
        },
      );

      blocTest<TransactionCubit, TransactionState>(
        'should set hasMore to false when loadMore returns empty list',
        setUp: () {
          when(() => mockRepository.fetchTransactions(
                page: 1,
                limit: 10,
              )).thenAnswer((_) async => testTransactions);
          when(() => mockRepository.fetchTransactions(
                page: 2,
                limit: 10,
              )).thenAnswer((_) async => <TransactionModel>[]);
        },
        build: () => TransactionCubit(
          repository: mockRepository,
          pageSize: 10,
        ),
        act: (cubit) async {
          await cubit.loadInitialTransactions();
          await cubit.loadMoreTransactions();
        },
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionLoaded>().having(
            (state) => state.hasMore,
            'hasMore',
            true,
          ),
          isA<TransactionLoaded>().having(
            (state) => state.isLoadingMore,
            'isLoadingMore',
            true,
          ),
          isA<TransactionLoaded>()
              .having(
                (state) => state.hasMore,
                'hasMore',
                false,
              )
              .having(
                (state) => state.isLoadingMore,
                'isLoadingMore',
                false,
              ),
        ],
      );
    });

    group('refreshTransactions', () {
      blocTest<TransactionCubit, TransactionState>(
        'should reload transactions from page 1 on refresh',
        setUp: () {
          when(() => mockRepository.fetchTransactions(
                page: 1,
                limit: 10,
              )).thenAnswer((_) async => testTransactions);
        },
        build: () => TransactionCubit(
          repository: mockRepository,
          pageSize: 10,
        ),
        act: (cubit) async {
          // First load initial transactions
          await cubit.loadInitialTransactions();
          // Clear to track refresh calls
          clearInteractions(mockRepository);
          // Setup mock again for refresh
          when(() => mockRepository.fetchTransactions(
                page: 1,
                limit: 10,
              )).thenAnswer((_) async => testTransactions);
          // Now refresh
          await cubit.refreshTransactions();
        },
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionLoaded>(),
          isA<TransactionLoading>(),
          isA<TransactionLoaded>(),
        ],
        verify: (_) {
          verify(() => mockRepository.fetchTransactions(
                page: 1,
                limit: 10,
              )).called(1);
        },
      );
    });
  });
}
