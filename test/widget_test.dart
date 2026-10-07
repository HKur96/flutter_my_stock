import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catat_stok/main.dart';

void main() {
  testWidgets('App loads cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const StokSayaApp());
    expect(find.text('Stok Saya'), findsOneWidget);
  });
}
