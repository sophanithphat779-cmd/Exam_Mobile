import 'package:flutter_test/flutter_test.dart';
import 'package:exam_mobile/main.dart';
import 'package:exam_mobile/routes/app_pages.dart';
import 'package:exam_mobile/controllers/auth_controller.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    Get.testMode = true;
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController());
    }

    await tester.pumpWidget(const MyApp(initialRoute: AppRoutes.LOGIN));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
