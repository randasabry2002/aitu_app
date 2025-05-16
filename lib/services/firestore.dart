import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aitu_app/models/student.dart';

class FirebaseService {
  Future<Student?> getDataWithStudentId(String studentCode) async {
// Replace with the actual student code input
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('StudentsTable')
        .where('code', isEqualTo: studentCode)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return Student.fromJson(
          querySnapshot.docs[0].data() as Map<String, dynamic>);
    } else {
      throw Exception('Student not found');
    }
  }
}
