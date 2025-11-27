import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobilecrypto/main.dart';
import 'package:mobilecrypto/screens/auth/login_screen.dart';
import 'package:mobilecrypto/utils/supabase_config.dart';

void main() {
  // ✅ INITIALISATION AVANT CHAQUE TEST
  setUp(() async {
    // Initialiser Supabase pour chaque test
    await SupabaseConfig.init();
  });

  testWidgets('App startup test', (WidgetTester tester) async {
    // Construire l'app après l'initialisation
    await tester.pumpWidget(MyApp(initialPage: const SignUpScreen()));

    // Vérifications
    expect(find.byType(SignUpScreen), findsOneWidget);
    expect(find.text('Pour commencer, entrez votre numéro mobile'), findsOneWidget);
  });

  testWidgets('Home screen navigation test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(initialPage: const SignUpScreen()));
    
    // Vérifier les éléments de base de l'écran de connexion
    expect(find.byType(SignUpScreen), findsOneWidget);
    expect(find.text('+225'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}