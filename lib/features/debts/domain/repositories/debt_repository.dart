import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/debt_entity.dart';
import '../entities/debt_payment_entity.dart';
import '../entities/debts_summary.dart';

abstract class DebtRepository {
  Future<Either<Failure, DebtsSummary>> getSummary();

  Future<Either<Failure, DebtEntity>> getDebtById(int id);

  Future<Either<Failure, List<DebtPaymentEntity>>> getPayments(int debtId);

  Future<Either<Failure, int>> createDebt({
    required String name,
    required double totalAmount,
    required double interestRate,
    required int totalInstallments,
    required double monthlyPayment,
    required DateTime startDate,
    required int categoryId,
  });

  Future<Either<Failure, void>> deleteDebt(int id);

  Future<Either<Failure, void>> togglePayment({
    required int paymentId,
    required bool isPaid,
  });
}
