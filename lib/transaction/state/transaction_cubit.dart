import 'package:bloc/bloc.dart';
import 'package:flutter_project_bfsi/transaction/data/transaction_repository.dart';
import 'package:flutter_project_bfsi/transaction/model/transaction_model.dart';
import 'package:flutter_project_bfsi/transaction/state/transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit({
    required TransactionRepository repository,
    this.pageSize = 20,
  })  : _repository = repository,
        super(const TransactionInitial());

  final TransactionRepository _repository;
  final int pageSize;

  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final List<TransactionModel> _transactions = <TransactionModel>[];

  Future<void> loadInitialTransactions() async {
    emit(const TransactionLoading());
    _page = 1;
    _hasMore = true;
    _transactions.clear();

    try {
      final results = await _repository.fetchTransactions(
        page: _page,
        limit: pageSize,
      );

      if (results.isEmpty) {
        emit(const TransactionEmpty());
        return;
      }

      _transactions.addAll(results);
      _hasMore = results.length == pageSize;
      emit(TransactionLoaded(transactions: List.unmodifiable(_transactions), hasMore: _hasMore));
    } on TransactionRepositoryException catch (e) {
      emit(TransactionError(message: e.message));
    } catch (_) {
      emit(const TransactionError(message: 'Unable to load transactions.'));
    }
  }

  Future<void> loadMoreTransactions() async {
    final current = state;
    if (current is! TransactionLoaded) return;
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    emit(TransactionLoaded(
      transactions: List.unmodifiable(_transactions),
      hasMore: _hasMore,
      isLoadingMore: true,
    ));
    try {
      final nextPage = _page + 1;
      final results = await _repository.fetchTransactions(
        page: nextPage,
        limit: pageSize,
      );

      if (results.isEmpty) {
        _hasMore = false;
        emit(TransactionLoaded(
          transactions: List.unmodifiable(_transactions),
          hasMore: _hasMore,
          isLoadingMore: false,
        ));
        return;
      }

      _page = nextPage;
      _transactions.addAll(results);
      _hasMore = results.length == pageSize;
      emit(TransactionLoaded(
        transactions: List.unmodifiable(_transactions),
        hasMore: _hasMore,
        isLoadingMore: false,
      ));
    } on TransactionRepositoryException catch (e) {
      emit(TransactionError(message: e.message));
      emit(TransactionLoaded(
        transactions: List.unmodifiable(_transactions),
        hasMore: _hasMore,
        isLoadingMore: false,
      ));
    } catch (_) {
      emit(const TransactionError(message: 'Unable to load more transactions.'));
      emit(TransactionLoaded(
        transactions: List.unmodifiable(_transactions),
        hasMore: _hasMore,
        isLoadingMore: false,
      ));
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refreshTransactions() async {
    await loadInitialTransactions();
  }
}

