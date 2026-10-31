import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/transaction_type.dart';
import '../../../../core/error/either_typedefs.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDatasource _datasource;

  TransactionRepositoryImpl({required TransactionLocalDatasource datasource})
      : _datasource = datasource;

  @override
  Stream<List<TransactionEntity>> watchByMonth(int month, int year) {
    return _datasource.watchByMonth(month, year).map(
          (rows) => rows.map(TransactionModel.fromDrift).toList(),
        );
  }

  @override
  FutureEither<int> create(TransactionEntity entity) async {
    try {
      final id = await _datasource.create(entity);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<void> update(TransactionEntity entity) async {
    try {
      await _datasource.update(entity);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<void> delete(int id) async {
    try {
      await _datasource.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<void> togglePaid(int id, bool isPaid) async {
    try {
      await _datasource.togglePaid(id, isPaid);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<List<CategoryEntity>> getCategories(int type) async {
    try {
      final rows = await _datasource.getCategoriesByType(type);
      final entities = rows
          .map((c) => CategoryEntity(
                id: c.id,
                name: c.name,
                iconCodePoint: c.iconCodePoint,
                iconFontFamily: c.iconFontFamily,
                color: c.color,
                type: TransactionType.fromValue(c.type),
                isDefault: c.isDefault,
              ))
          .toList();
      return Right(entities);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
