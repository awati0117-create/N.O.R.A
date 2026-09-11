import 'package:flutter/material.dart';

void main() {
  runApp(const NoraApp());
}

class NoraApp extends StatefulWidget {
  const NoraApp({super.key});

  @override
  State<NoraApp> createState() => _NoraAppState();
}

class _NoraAppState extends State<NoraApp> {
  // Global Theme Accent State
  Color _accentColor = const Color(0xFF00F0FF); // Cyber Cyan

  void _changeAccent(Color newColor) {
    setState(() {
      _accentColor = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'N.O.R.A. System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E14),
        colorScheme: ColorScheme.dark(
          primary: _accentColor,
          secondary: _accentColor.withOpacity(0.8),
          surface: const Color(0xFF131A24),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF131A24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _accentColor.withOpacity(0.2), width: 1),
          ),
        ),
        useMaterial3: true,
      ),
      home: MainScreen(
        accentColor: _accentColor,
        onAccentChanged: _changeAccent,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final Color accentColor;
  final ValueChanged<Color> onAccentChanged;

  const MainScreen({
    super.key,
    required this.accentColor,
    required this.onAccentChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // System States
  String _activeAiEngine = 'Qwen 2.5 (Local)'; 
  String _aiState = 'STANDBY'; 
  bool _isBleConnected = true;
  bool _isWifiConnected = true;
  int _batteryLevel = 88;

  // Dynamic Quick Action Buttons
  final List<Map<String, String>> _quickActions = [
    {'name': 'LOCK ROOM', 'command': 'ESP_RELAY_LOCK', 'color': 'red'},
    {'name': 'PARTY RGB', 'command': 'ESP_RGB_PARTY', 'color': 'purple'},
    {'name': 'NIGHT MODE', 'command': 'SYS_NIGHT_MODE', 'color': 'amber'},
    {'name': 'BRIEFING', 'command': 'TRIGGER_MORNING_BRIEF', 'color': 'cyan'},
  ];

  // Logs System
  final List<String> _logs = [
    '[19:42:01] [BLE] Connected to ESP32_POCKET_NODE',
    '[19:42:02] [SENSOR] PIR Motion detected on Port D2',
    '[19:42:02] [RULE] Triggered: Warning LED + Silent Telemetry',
    '[19:42:05] [AI_LOCAL] Qwen 2.5 1.5B loaded into RAM (1.2GB)',
    '[19:42:10] [TTS] Dual-Engine Ready: ID-v2 (Indo) & EN-v4 (US)',
  ];

  void _addLog(String log) {
    setState(() {
      _logs.insert(0, '[${DateTime.now().toString().substring(11, 19)}] $log');
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HudChatTab(
        accentColor: widget.accentColor,
        aiState: _aiState,
        activeAi: _activeAiEngine,
        quickActions: _quickActions,
        onStateChange: (newState) => setState(() => _aiState = newState),
        onAddQuickAction: (name, cmd) {
          setState(() {
            _quickActions.add({'name': name, 'command': cmd, 'color': 'cyan'});
          });
          _addLog('Added Quick Action: $name ($cmd)');
        },
        onDeleteQuickAction: (index) {
          setState(() {
            _quickActions.removeAt(index);
          });
        },
        onExecuteCommand: (cmd) => _addLog('Executed Command: $cmd'),
      ),
      BrainVoiceTab(
        accentColor: widget.accentColor,
        activeAi: _activeAiEngine,
        onAiChanged: (newAi) {
          setState(() => _activeAiEngine = newAi);
          _addLog('Switched AI Brain to $newAi');
        },
        onAccentChanged: widget.onAccentChanged,
      ),
      HardwareSensorsTab(
        accentColor: widget.accentColor,
        isBleConnected: _isBleConnected,
        isWifiConnected: _isWifiConnected,
        batteryLevel: _batteryLevel,
        onAddLog: _addLog,
      ),
      ModulesLogsTab(
        accentColor: widget.accentColor,
        logs: _logs,
        onClearLogs: () => setState(() => _logs.clear()),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: widget.accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withOpacity(0.8),
                    blurRadius: 6,
                  )
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'N.O.R.A.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: widget.accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: widget.accentColor.withOpacity(0.4), width: 0.8),
              ),
              child: Text(
                _activeAiEngine.contains('Local') ? 'QWEN-LOCAL' : 'GEMINI-CLOUD',
                style: TextStyle(
                  color: widget.accentColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBleConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              color: _isBleConnected ? widget.accentColor : Colors.grey,
              size: 20,
            ),
            onPressed: () => setState(() => _isBleConnected = !_isBleConnected),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Row(
                children: [
                  Icon(Icons.battery_4_bar, color: widget.accentColor, size: 16),
                  Text(
                    '$_batteryLevel%',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1117),
          border: Border(top: BorderSide(color: widget.accentColor.withOpacity(0.2))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: widget.accentColor,
          unselectedItemColor: Colors.grey.shade600,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.terminal, size: 20), label: 'HUD CHAT'),
            BottomNavigationBarItem(icon: Icon(Icons.psychology, size: 20), label: 'BRAIN & VOICE'),
            BottomNavigationBarItem(icon: Icon(Icons.developer_board, size: 20), label: 'HARDWARE'),
            BottomNavigationBarItem(icon: Icon(Icons.apps, size: 20), label: 'MODULES & LOGS'),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// TAB 1: HUD CHAT & QUICK ACTIONS
// ==========================================
class HudChatTab extends StatefulWidget {
  final Color accentColor;
  final String aiState;
  final String activeAi;
  final List<Map<String, String>> quickActions;
  final ValueChanged<String> onStateChange;
  final Function(String, String) onAddQuickAction;
  final Function(int) onDeleteQuickAction;
  final Function(String) onExecuteCommand;

  const HudChatTab({
    super.key,
    required this.accentColor,
    required this.aiState,
    required this.activeAi,
    required this.quickActions,
    required this.onStateChange,
    required this.onAddQuickAction,
    required this.onDeleteQuickAction,
    required this.onExecuteCommand,
  });

  @override
  State<HudChatTab> createState() => _HudChatTabState();
}

class _HudChatTabState extends State<HudChatTab> {
  final List<Map<String, String>> _messages = [
    {
      'sender': 'N.O.R.A.',
      'text': 'System Online. Both Indonesian & English Voice engines initialized. How can I assist you?',
      'time': '19:40'
    },
    {
      'sender': 'User',
      'text': 'Check room telemetry status.',
      'time': '19:41'
    },
    {
      'sender': 'N.O.R.A.',
      'text': 'Temperature: 28.4°C. PIR Sensor: Idle. ESP32 Node connected via BLE.',
      'time': '19:41'
    },
  ];

  final TextEditingController _msgController = TextEditingController();

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'sender': 'User',
        'text': _msgController.text,
        'time': DateTime.now().toString().substring(11, 16),
      });
    });
    String query = _msgController.text;
    _msgController.clear();
    widget.onStateChange('THINKING');

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onStateChange('SPEAKING');
        setState(() {
          _messages.add({
            'sender': 'N.O.R.A.',
            'text': 'Processed query via ${widget.activeAi}: "$query". Executing requested routine.',
            'time': DateTime.now().toString().substring(11, 16),
          });
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) widget.onStateChange('STANDBY');
        });
      }
    });
  }

  void _showAddActionDialog() {
    final nameCtrl = TextEditingController();
    final cmdCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131A24),
        title: Text('Add Custom Quick Button', style: TextStyle(color: widget.accentColor, fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                labelText: 'Button Label (e.g. LOCK ROOM)',
                labelStyle: TextStyle(fontSize: 11),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: cmdCtrl,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                labelText: 'ESP Command Tag (e.g. ESP_RELAY_OFF)',
                labelStyle: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(fontSize: 11)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: widget.accentColor),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && cmdCtrl.text.isNotEmpty) {
                widget.onAddQuickAction(nameCtrl.text, cmdCtrl.text);
                Navigator.pop(context);
              }
            },
            child: const Text('ADD', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AI Dynamic Visualizer Card
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF131A24),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.accentColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accentColor.withOpacity(
                    widget.aiState == 'SPEAKING' ? 0.4 : (widget.aiState == 'THINKING' ? 0.25 : 0.1),
                  ),
                  border: Border.all(
                    color: widget.accentColor,
                    width: widget.aiState == 'SPEAKING' ? 3 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.5),
                      blurRadius: widget.aiState == 'SPEAKING' ? 12 : 4,
                    )
                  ],
                ),
                child: Center(
                  child: Icon(
                    widget.aiState == 'LISTENING'
                        ? Icons.mic
                        : (widget.aiState == 'THINKING'
                            ? Icons.auto_awesome
                            : (widget.aiState == 'SPEAKING' ? Icons.graphic_eq : Icons.power_settings_new)),
                    color: widget.accentColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  // PERBAIKAN: Mengganti CrossAlignment menjadi CrossAxisAlignment
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI STATE: ${widget.aiState}',
                      style: TextStyle(
                        color: widget.accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Active Engine: ${widget.activeAi} | Voice: Dual Sherpa',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  widget.aiState == 'LISTENING' ? Icons.stop_circle : Icons.mic_none,
                  color: widget.accentColor,
                ),
                onPressed: () {
                  if (widget.aiState == 'LISTENING') {
                    widget.onStateChange('STANDBY');
                  } else {
                    widget.onStateChange('LISTENING');
                  }
                },
              ),
            ],
          ),
        ),

        // Custom Dynamic Quick Action Buttons Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            // PERBAIKAN: Mengganti MainAlignment menjadi MainAxisAlignment
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DYNAMIC QUICK ACTIONS',
                style: TextStyle(
                  color: widget.accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              InkWell(
                onTap: _showAddActionDialog,
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: widget.accentColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'ADD BUTTON',
                      style: TextStyle(color: widget.accentColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 34,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: widget.quickActions.length,
            itemBuilder: (context, index) {
              final act = widget.quickActions[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onLongPress: () => widget.onDeleteQuickAction(index),
                  onTap: () => widget.onExecuteCommand(act['command']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: widget.accentColor.withOpacity(0.4), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flash_on, color: widget.accentColor, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          act['name']!,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Terminal Chat Messages List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isNora = msg['sender'] == 'N.O.R.A.';
              return Align(
                alignment: isNora ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                  decoration: BoxDecoration(
                    color: isNora ? const Color(0xFF131A24) : widget.accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isNora ? widget.accentColor.withOpacity(0.3) : widget.accentColor.withOpacity(0.6),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            msg['sender']!,
                            style: TextStyle(
                              color: isNora ? widget.accentColor : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          // PERBAIKAN: Menambahkan kurung penutup yang hilang dan melanjutkan kode yang terpotong
                    
