import 'package:flutter_test/flutter_test.dart';

void main() {
  test('send birthdate as string', () {
    var birthdateTimestamp = 1633046400000; // Example timestamp
    var birthdateString = DateTime.fromMillisecondsSinceEpoch(birthdateTimestamp).toIso8601String();
    
    expect(birthdateString, isA<String>());
  });
}