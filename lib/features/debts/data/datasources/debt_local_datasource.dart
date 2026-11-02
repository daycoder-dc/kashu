import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/debt_dao.dart';

class DebtLocalDatasource {
  final DebtDao _debtDao;

  DebtLocalDatasource({required DebtDao debtDao}) : _debtDao = debtDao;

  Future<List<DebtWithCategory>> getActiveDebts() {
    return _debtDao.getActiveDebts();
  }

  Future<Debt?> getDebtById(int id) {
    return _debtDao.getDebtById(id);
  }

  Future<List<DebtPayment>> getPaymentsForDebt(int debtId) {
    return _debtDao.getPaymentsForDebt(debtId);
  }

  Future<int> insertDebt({
    required String name,
    required double totalAmount,
    required double interestRate,
    required int totalInstallments,
    required double monthlyPayment,
    required DateTime startDate,
    required int categoryId,
  }) {
    return _debtDao.insertDebt(
      DebtsCompanion.insert(
        name: name,
        totalAmount: totalAmount,
        interestRate: interestRate,
        totalInstallments: totalInstallments,
        monthlyPayment: monthlyPayment,
        startDate: startDate,
        categoryId: categoryId,
      ),
    );
  }

  Future<void> updateDebt({
    required int id,
    required String name,
    required int categoryId,
  }) {
    return _debtDao.updateDebtFields(id, name, categoryId);
  }

  Future<void> deleteDebt(int id) {
    return _debtDao.deleteDebt(id);
  }

  Future<void> togglePayment(int paymentId, bool isPaid) {
    return _debtDao.togglePayment(paymentId, isPaid);
  }

  Future<double> totalActiveDebt() {
    return _debtDao.totalActiveDebt();
  }

  Future<double> totalMonthlyPayments() {
    return _debtDao.totalMonthlyPayments();
  }

  Future<double> totalPaidAmount() {
    return _debtDao.totalPaidAmount();
  }
}
