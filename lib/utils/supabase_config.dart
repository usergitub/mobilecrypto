import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://gasygxkrftqigaqjktis.supabase.co'; // remplace par ton URL Supabase
  static const String supabaseAnonKey = 'sb_publishable_tMDc7wz2fL8yLzPAjLgMtg_SibpTErF'; // remplace par ta clé anonyme

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
