/// Mock database helper for tests
/// Uses mocktail to create mock AppDatabase
import 'package:mocktail/mocktail.dart';
import 'package:re_link/core/database/app_database.dart';

class MockAppDatabase extends Mock implements AppDatabase {}
