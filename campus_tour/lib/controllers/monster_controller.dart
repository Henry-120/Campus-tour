import 'package:get/get.dart';                // 提供 GetxController、Rxn、Obx 等
import '../services/firestore_service.dart';
import '../models/monster_model.dart';        // MonsterModel
import '../models/architecture_model.dart';   // ArchitectureModel
import '../models/qa_model.dart';             // QAModel


//此controller 還要重新改
class MonsterController extends GetxController {
  final FirestoreService _service = FirestoreService();

  var monster = Rxn<MonsterModel>();
  var architecture = Rxn<ArchitectureModel>();
  var qa = Rxn<QAModel>();

  Future<void> loadMonsterWithRelations(String id) async {
    final result = await _service.getMonsterWithRelations(id);
    if (result != null) {
      monster.value = result["monster"] as MonsterModel;
      architecture.value = result["architecture"] as ArchitectureModel?;
      qa.value = result["qa"] as QAModel?;
    }
  }

}
