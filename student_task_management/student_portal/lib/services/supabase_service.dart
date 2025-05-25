import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://tzfficfqbnfmdyrxkjxo.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR6ZmZpY2ZxYm5mbWR5cnhranhvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2MzQ1OTQsImV4cCI6MjA2MzIxMDU5NH0.vN2QPztwJwl8osfG6j6-ljboogMpJNmxrb1C3YnYzyA',
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }
}