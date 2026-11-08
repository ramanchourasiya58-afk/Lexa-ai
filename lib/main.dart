
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_page.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseUrl =
      const String.fromEnvironment('SUPABASE_URL');
  final supabaseKey =
      const String.fromEnvironment('SUPABASE_ANON_KEY');

  bool connected = false;
  String? errorMessage;

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    errorMessage = 'Supabase keys are missing. Check GitHub Secrets.';
  } else {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );
      connected = true;
    } catch (e) {
      errorMessage = 'Supabase connection failed: $e';
    }
  }

  runApp(
    LexaApp(
      supabaseConnected: connected,
      errorMessage: errorMessage,
    ),
  );
}

class LexaApp extends StatelessWidget {
  final bool supabaseConnected;
  final String? errorMessage;

  const LexaApp({
    super.key,
    required this.supabaseConnected,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LEXA AI',
      theme: ThemeData.dark(),
     home: AuthGate(
  supabaseConnected: supabaseConnected,
  errorMessage: errorMessage,
), 
    );
  }
}

class HomePage extends StatefulWidget {
  final bool supabaseConnected;
  final String? errorMessage;

  const HomePage({
    super.key,
    required this.supabaseConnected,
    this.errorMessage,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = TextEditingController();
  final messages = <String>[];

  void sendMessage() {
    final message = controller.text.trim();

    if (message.isEmpty) return;

    setState(() {
      messages.add(message);
      controller.clear();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LEXA AI'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          const Icon(
            Icons.auto_awesome,
            size: 55,
            color: Colors.blueAccent,
          ),

          const Text(
            'Welcome to LEXA AI',
            style: TextStyle(fontSize: 24),
          ),

          const SizedBox(height: 10),

          Text(
            widget.supabaseConnected
                ? 'Supabase Connected'
                : 'Supabase Not Connected',
            style: TextStyle(
              color: widget.supabaseConnected
                  ? Colors.greenAccent
                  : Colors.orangeAccent,
            ),
          ),

          if (widget.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                widget.errorMessage!,
                style: const TextStyle(
                  color: Colors.orangeAccent,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          const Divider(),

          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text('Start chatting with LEXA AI'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(messages[index]),
                        ),
                      );
                    },
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask LEXA anything...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
