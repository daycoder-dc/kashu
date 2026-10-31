import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Future<List<Category>> getAllByType(int type) {
    return (select(categories)..where((c) => c.type.equals(type))).get();
  }

  Future<List<Category>> getAll() => select(categories).get();

  Stream<List<Category>> watchAll() => select(categories).watch();

  Future<Category> getById(int id) {
    return (select(categories)..where((c) => c.id.equals(id))).getSingle();
  }

  Future<int> insertCategory(CategoriesCompanion entry) {
    return into(categories).insert(entry);
  }

  Future<bool> updateCategory(CategoriesCompanion entry) {
    return update(categories).replace(entry);
  }

  Future<int> deleteCategory(int id) {
    return (delete(categories)..where((c) => c.id.equals(id))).go();
  }

  Future<void> seedCategories(List<CategoriesCompanion> entries) async {
    await batch((b) => b.insertAll(categories, entries));
  }
}
