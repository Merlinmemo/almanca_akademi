import 'progress_service.dart';

class AppBootstrap {
  final ProgressService _p = ProgressService();

  Future<void> init() async {
    // Kilit sistemi tek noktadan yönetilsin:
    // İlk açılışta sadece CourseCatalog.firstModuleCode açık olacak.
    await _p.ensureCourseBoot();
  }
}
