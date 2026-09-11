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
  String _activeAiEngine = 'Qwen 2.5 (Local)'; // 'Qwen 2.5 (Local)' or 'Gemini (Cloud)'
  String _aiState = 'STANDBY'; // STANDBY, LISTENING, THINKING, SPEAKING
  bool _isBleConnected = true;
  bool _isWifiConnected = true;
  int _batteryLevel = 88;

  // Dynamic Quick Action Buttons
  List<Map<String, String>> _quickActions = [
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
            BottomNavigationBarItem(
              icon: Icon(Icons.terminal, size: 20),
              label: 'HUD CHAT',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology, size: 20),
              label: 'BRAIN & VOICE',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.developer_board, size: 20),
              label: 'HARDWARE',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.apps, size: 20),
              label: 'MODULES & LOGS',
            ),
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
      'text': 'Temperature: 28.4掳C. PIR Sensor: Idle. ESP32 Node connected via BLE.',
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
              // Arc Reactor Pulse Animation Simulator
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
                  crossAxisAlignment: CrossAlignment.start,
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
            mainAxisAlignment: MainAlignment.spaceBetween,
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
                    crossAxisAlignment: CrossAlignment.start,
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
                          const SizedBox(width: 6),
                          Text(
                            msg['time']!,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg['text']!,
                        style: const TextStyle(fontSize: 11, height: 1.3),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Chat Input Box
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFF0D1117),
            border: Border(top: BorderSide(color: Color(0xFF1F2937))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgController,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Enter command or ask N.O.R.A...',
                    hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    fillColor: const Color(0xFF131A24),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: Icon(Icons.send, color: widget.accentColor, size: 20),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// TAB 2: AI BRAIN & DUAL VOICE MANAGER
// ==========================================
class BrainVoiceTab extends StatefulWidget {
  final Color accentColor;
  final String activeAi;
  final ValueChanged<String> onAiChanged;
  final ValueChanged<Color> onAccentChanged;

  const BrainVoiceTab({
    super.key,
    required this.accentColor,
    required this.activeAi,
    required this.onAiChanged,
    required this.onAccentChanged,
  });

  @override
  State<BrainVoiceTab> createState() => _BrainVoiceTabState();
}

class _BrainVoiceTabState extends State<BrainVoiceTab> {
  double _temperature = 0.7;
  double _topP = 0.9;
  bool _autoLanguageSwitch = true;
  double _indoPitch = 1.0;
  double _indoSpeed = 1.0;
  double _englishPitch = 1.0;
  double _englishSpeed = 1.1;

  final TextEditingController _systemPromptCtrl = TextEditingController(
    text: 'You are N.O.R.A., a tactical AI assistant. Be concise, direct, and helpful.',
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          // Theme Accent Picker
          _buildSectionHeader('UI ACCENT COLOR SWITCHER'),
          Row(
            mainAxisAlignment: MainAlignment.spaceAround,
            children: [
              _buildColorDot(const Color(0xFF00F0FF), 'Cyan'),
              _buildColorDot(const Color(0xFF00FF66), 'Lime'),
              _buildColorDot(const Color(0xFFFFB000), 'Amber'),
              _buildColorDot(const Color(0xFFFF0055), 'Red'),
              _buildColorDot(const Color(0xFFA855F7), 'Purple'),
            ],
          ),
          const SizedBox(height: 16),

          // AI Engine Selector
          _buildSectionHeader('AI ENGINE DUAL-BRAIN MANAGER'),
          Row(
            children: [
              Expanded(
                child: _buildAiEngineCard(
                  title: 'Qwen 2.5 (1.5B)',
                  subtitle: 'LOCAL ENGINE (Offline)',
                  description: 'Zero Latency, High Privacy, Lightweight',
                  isSelected: widget.activeAi.contains('Local'),
                  onTap: () => widget.onAiChanged('Qwen 2.5 (Local)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAiEngineCard(
                  title: 'Gemini API',
                  subtitle: 'CLOUD ENGINE (Online)',
                  description: 'High Reasoning, Vision & Complex Tasks',
                  isSelected: widget.activeAi.contains('Gemini'),
                  onTap: () => widget.onAiChanged('Gemini (Cloud)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // System Prompt & AI Parameters
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Text('SYSTEM PROMPT (N.O.R.A. Personality)', style: TextStyle(color: widget.accentColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _systemPromptCtrl,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 11),
                    decoration: const InputDecoration(
                      fillColor: Color(0xFF0A0E14),
                      filled: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAlignment.start,
                          children: [
                            Text('Temperature: ${_temperature.toStringAsFixed(1)}', style: const TextStyle(fontSize: 10)),
                            Slider(
                              value: _temperature,
                              min: 0.1,
                              max: 1.5,
                              activeColor: widget.accentColor,
                              onChanged: (v) => setState(() => _temperature = v),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAlignment.start,
                          children: [
                            Text('Top-P: ${_topP.toStringAsFixed(1)}', style: const TextStyle(fontSize: 10)),
                            Slider(
                              value: _topP,
                              min: 0.1,
                              max: 1.0,
                              activeColor: widget.accentColor,
                              onChanged: (v) => setState(() => _topP = v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dual-Voice Engine (Sherpa-onnx)
          _buildSectionHeader('SHERPA-ONNX DUAL-VOICE ENGINE'),
          SwitchListTile(
            title: const Text('Auto-Language Voice Switching', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            subtitle: const Text('Switch accent automatically based on language detected', style: TextStyle(fontSize: 9)),
            value: _autoLanguageSwitch,
            activeColor: widget.accentColor,
            contentPadding: EdgeInsets.zero,
            onChanged: (v) => setState(() => _autoLanguageSwitch = v),
          ),
          
          // Voice 1: Indonesian Accent
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAlignment.spaceBetween,
                    children: [
                      Text('VOICE 1: BAHASA INDONESIA', style: TextStyle(color: widget.accentColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      const Text('Model: id_nora_v2.onnx', style: TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Pitch: ${_indoPitch.toStringAsFixed(1)}', style: const TextStyle(fontSize: 10)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Slider(
                          value: _indoPitch,
                          min: 0.5,
                          max: 1.5,
                          activeColor: widget.accentColor,
                          onChanged: (v) => setState(() => _indoPitch = v),
                        ),
                      ),
                      Expanded(
                        child: Text('Speed: ${_indoSpeed.toStringAsFixed(1)}', style: const TextStyle(fontSize: 10)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Slider(
                          value: _indoSpeed,
                          min: 0.5,
                          max: 2.0,
                          activeColor: widget.accentColor,
                          onChanged: (v) => setState(() => _indoSpeed = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Voice 2: English Accent
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAlignment.spaceBetween,
                    children: [
                      Text('VOICE 2: ENGLISH (US ACCENT)', style: TextStyle(color: widget.accentColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      const Text('Model: en_us_nora_v4.onnx', style: TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Pitch: ${_englishPitch.toStringAsFixed(1)}', style: const TextStyle(fontSize: 10)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Slider(
                          value: _englishPitch,
                          min: 0.5,
                          max: 1.5,
                          activeColor: widget.accentColor,
                          onChanged: (v) => setState(() => _englishPitch = v),
                        ),
                      ),
                      Expanded(
                        child: Text('Speed: ${_englishSpeed.toStringAsFixed(1)}', style: const TextStyle(fontSize: 10)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Slider(
                          value: _englishSpeed,
                          min: 0.5,
                          max: 2.0,
                          activeColor: widget.accentColor,
                          onChanged: (v) => setState(() => _englishSpeed = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        title,
        style: TextStyle(
          color: widget.accentColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color, String label) {
    return GestureDetector(
      onTap: () => widget.onAccentChanged(color),
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.accentColor == color ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  Widget _buildAiEngineCard({
    required String title,
    required String subtitle,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? widget.accentColor.withOpacity(0.15) : const Color(0xFF131A24),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? widget.accentColor : Colors.grey.shade800,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            Text(title, style: TextStyle(color: isSelected ? widget.accentColor : Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(description, style: TextStyle(fontSize: 8, color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// TAB 3: HARDWARE, SENSORS & DISPLAY CONFIG
// ==========================================
class HardwareSensorsTab extends StatefulWidget {
  final Color accentColor;
  final bool isBleConnected;
  final bool isWifiConnected;
  final int batteryLevel;
  final Function(String) onAddLog;

  const HardwareSensorsTab({
    super.key,
    required this.accentColor,
    required this.isBleConnected,
    required this.isWifiConnected,
    required this.batteryLevel,
    required this.onAddLog,
  });

  @override
  State<HardwareSensorsTab> createState() => _HardwareSensorsTabState();
}

class _HardwareSensorsTabState extends State<HardwareSensorsTab> {
  // ST7789 Zone Config State (Live updates hardware without reflashing!)
  double _zone1Height = 15;
  double _zone2Height = 55;
  double _zone3Height = 15;
  double _zone4Height = 15;

  String _zone2Content = 'Arc Reactor / Lyrics';
  String _zone4Content = 'Digital Clock (HH:MM:SS)';
  double _displayBrightness = 80;

  // Automation Rules
  final List<Map<String, String>> _rules = [
    {'trigger': 'PIR Motion (22:00-06:00)', 'action': 'Suara Warning + RGB Red Alert'},
    {'trigger': 'TTP223 Touch', 'action': 'Toggle Relay 0ms + Silent Telemetry'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          // ESP Bridge Config
          _buildSectionHeader('ESP32 HARDWARE BRIDGE'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.memory, color: widget.accentColor, size: 16),
                          const SizedBox(width: 6),
                          const Text('Node: ESP32 Super Mini (BLE/WiFi)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('CONNECTED', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(height: 12),
                  Row(
                    mainAxisAlignment: MainAlignment.spaceAround,
                    children: [
                      _buildMiniStatus('Protocol', 'BLE + MQTT'),
                      _buildMiniStatus('IP Address', '192.168.1.105'),
                      _buildMiniStatus('Signal', '-62 dBm'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // LIVE ST7789 DISPLAY CONFIGURATOR (NO APK UPDATE / REFLASH NEEDED!)
          _buildSectionHeader('LIVE ST7789 DISPLAY CONFIGURATOR'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAlignment.spaceBetween,
                    children: [
                      Text('ST7789 Zoned Screen Preview', style: TextStyle(color: widget.accentColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.accentColor,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          widget.onAddLog('Synced Display Layout Config to ESP32 over BLE');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Display Layout Synced to ESP32!'), duration: Duration(seconds: 1)),
                          );
                        },
                        child: const Text('SYNC TO ESP', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Simulated ST7789 Physical Screen Layout Preview
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: widget.accentColor, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        // Zone 1: Status Bar
                        Expanded(
                          flex: _zone1Height.round(),
                          child: Container(
                            color: Colors.blue.withOpacity(0.2),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              mainAxisAlignment: MainAlignment.spaceBetween,
                              children: [
                                Text('BAT:${widget.batteryLevel}% | BLE:OK', style: const TextStyle(fontSize: 7, color: Colors.white)),
                                Text('AI: ${widget.accentColor == const Color(0xFF00F0FF) ? "QWEN" : "GEMINI"}', style: TextStyle(fontSize: 7, color: widget.accentColor)),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Colors.cyan),
                        // Zone 2: Main Content / Arc Reactor
                        Expanded(
                          flex: _zone2Height.round(),
                          child: Container(
                            color: Colors.cyan.withOpacity(0.1),
                            child: Center(
                              child: Text(
                                _zone2Content,
                                style: TextStyle(color: widget.accentColor, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Colors.cyan),
                        // Zone 3: Branding & State
                        Expanded(
                          flex: _zone3Height.round(),
                          child: Container(
                            color: Colors.purple.withOpacity(0.2),
                            child: const Center(
                              child: Text('N.O.R.A. [ STANDBY ]', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Colors.cyan),
                        // Zone 4: Clock
                        Expanded(
                          flex: _zone4Height.round(),
                          child: Container(
                            color: Colors.amber.withOpacity(0.2),
                            child: Center(
                              child: Text(_zone4Content, style: const TextStyle(fontSize: 8, color: Colors.amber, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Zone Adjusters
                  Row(
                    children: [
                      Expanded(
                        child: Text('Zone 2 Ratio: ${_zone2Height.round()}%', style: const TextStyle(fontSize: 9)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Slider(
                          value: _zone2Height,
                          min: 30,
                          max: 70,
                          activeColor: widget.accentColor,
                          onChanged: (v) {
                            setState(() {
                              _zone2Height = v;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Brightness: ${_displayBrightness.round()}%', style: const TextStyle(fontSize: 9)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Slider(
                          value: _displayBrightness,
                          min: 10,
                          max: 100,
                          activeColor: widget.accentColor,
                          onChanged: (v) => setState(() => _displayBrightness = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // SENSOR AUTOMATION RULE ENGINE (IF-THEN)
          _buildSectionHeader('SENSOR TELEMETRY & AUTOMATION RULES'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAlignment.spaceBetween,
                    children: [
                      Text('Active Sensor Rules', style: TextStyle(color: widget.accentColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _rules.add({'trigger': 'DHT11 Temp > 32掳C', 'action': 'Trigger Fan + Voice Alert'});
                          });
                          widget.onAddLog('Added Automation Rule');
                        },
                        child: Text('+ ADD RULE', style: TextStyle(color: widget.accentColor, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _rules.length,
                    itemBuilder: (context, index) {
                      final r = _rules[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0E14),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAlignment.start,
                              children: [
                                Text('IF: ${r['trigger']}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber)),
                                Text('THEN: ${r['action']}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                              onPressed: () => setState(() => _rules.removeAt(index)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        title,
        style: TextStyle(
          color: widget.accentColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildMiniStatus(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ==========================================
// TAB 4: MODULES & DIAGNOSTIC SERIAL LOGS
// ==========================================
class ModulesLogsTab extends StatelessWidget {
  final Color accentColor;
  final List<String> logs;
  final VoidCallback onClearLogs;

  const ModulesLogsTab({
    super.key,
    required this.accentColor,
    required this.logs,
    required this.onClearLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          Text(
            'ACTIVE AUTOMATION MODULES',
            style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _buildModuleTile('Morning Briefing', '06:00-09:00 (1x/day)', Icons.wb_sunny, accentColor)),
              const SizedBox(width: 8),
              Expanded(child: _buildModuleTile('Music & Lyrics Sync', 'Spotify / YouTube', Icons.music_note, accentColor)),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAlignment.spaceBetween,
            children: [
              Text(
                'INTERNAL DIAGNOSTIC LOG & SERIAL MONITOR',
                style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              InkWell(
                onTap: onClearLogs,
                child: const Text('CLEAR LOGS', style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Terminal Log Screen
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withOpacity(0.4)),
              ),
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      logs[index],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        color: Color(0xFF00FF66),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleTile(String title, String desc, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF131A24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(fontSize: 8, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
