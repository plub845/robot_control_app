// main.dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:flutter/services.dart'; // Import for device orientation
import 'package:app_settings/app_settings.dart'; // For opening app settings
import 'package:permission_handler/permission_handler.dart'; // For checking Bluetooth permissions

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set preferred orientations to landscape only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const RobotControlApp());
  });
}

class RobotControlApp extends StatefulWidget {
  const RobotControlApp({super.key});

  @override
  State<RobotControlApp> createState() => _RobotControlAppState();
}

class _RobotControlAppState extends State<RobotControlApp> {
  Locale _locale = const Locale('en');
  ThemeData _currentTheme = AppThemes.lightTheme; // Default theme

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _setTheme(ThemeData theme) {
    setState(() {
      _currentTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robot Controller',
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('th'),
        Locale('zh'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: _currentTheme,
      home: ControlPage(
        onLocaleChange: _setLocale,
        currentLocale: _locale,
        onThemeChange: _setTheme,
        currentTheme: _currentTheme,
      ),
    );
  }
}

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Robot Controller',
      'speed': 'Speed',
      'settings': 'Settings',
      'camera': 'View Camera',
      'followLine': 'Follow Line',
      'ownerMessage': 'This app is created by [join845].', // Simplified ownership
      'left': 'Left',
      'right': 'Right',
      'forward': 'Forward',
      'backward': 'Backward',
      'stop': 'STOP',
      'changeLanguage': 'Change Language',
      'useWiFi': 'Use WiFi instead of Bluetooth',
      'showSpeed': 'Show Speed Slider',
      'showLineFollow': 'Show Line Follow Button',
      'showCamera': 'Show Camera Button',
      'wifiIp': 'WiFi IP (e.g. 192.168.4.1)',
      'save': 'Save',
      'imageSettings': 'Image Settings',
      'imageWidth': 'Image Width',
      'imageHeight': 'Image Height',
      'brightness': 'Brightness',
      'rotation': 'Rotation',
      'zoom': 'Zoom',
      'streamType': 'Stream Type',
      'jpegSingle': 'JPEG (Single Frame)',
      'mjpegStream': 'MJPEG (Stream)',
      'selectTheme': 'Select Theme',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'themeBlue': 'Blue',
      'themeGreen': 'Green',
      'howToUse': 'How to Use',
      'usageInstructions': '1. Connect to your robot via Bluetooth or WiFi.\n2. Use the arrow buttons to control movement.\n3. Adjust speed with the slider.\n4. Use "Follow Line" for autonomous movement.\n5. Use "View Camera" to see the robot\'s perspective.\n6. Adjust settings for connection, display, and camera in the settings menu.',
      'connectionErrorTitle': 'Connection Error',
      'bluetoothNotConnected': 'Bluetooth is not connected. Please connect or enable Bluetooth in settings.',
      'wifiConnectionError': 'WiFi connection error. Please check your IP or WiFi settings.',
      'bluetoothOff': 'Bluetooth is off. Please turn on Bluetooth in settings.',
      'openSettings': 'Open Settings',
      'dismiss': 'Dismiss',
    },
    'th': {
      'title': 'ควบคุมหุ่นยนต์',
      'speed': 'ความเร็ว',
      'settings': 'ตั้งค่า',
      'camera': 'ดูกล้อง',
      'followLine': 'เดินตามเส้น',
      'ownerMessage': 'แอปนี้สร้างโดย [join845].', // Simplified ownership
      'left': 'ซ้าย',
      'right': 'ขวา',
      'forward': 'ไปข้างหน้า',
      'backward': 'ถอยหลัง',
      'stop': 'หยุด',
      'changeLanguage': 'เปลี่ยนภาษา',
      'useWiFi': 'ใช้ WiFi แทน Bluetooth',
      'showSpeed': 'แสดงแถบความเร็ว',
      'showLineFollow': 'แสดงปุ่มเดินตามเส้น',
      'showCamera': 'แสดงปุ่มกล้อง',
      'wifiIp': 'WiFi IP (เช่น 192.168.4.1)',
      'save': 'บันทึก',
      'imageSettings': 'การตั้งค่ารูปภาพ',
      'imageWidth': 'ความกว้างรูปภาพ',
      'imageHeight': 'ความสูงรูปภาพ',
      'brightness': 'ความสว่าง',
      'rotation': 'การหมุน',
      'zoom': 'การซูม',
      'streamType': 'ประเภทสตรีม',
      'jpegSingle': 'JPEG (ภาพเดี่ยว)',
      'mjpegStream': 'MJPEG (สตรีม)',
      'selectTheme': 'เลือกธีม',
      'themeLight': 'สว่าง',
      'themeDark': 'มืด',
      'themeBlue': 'สีน้ำเงิน',
      'themeGreen': 'สีเขียว',
      'howToUse': 'วิธีใช้',
      'usageInstructions': '1. เชื่อมต่อหุ่นยนต์ของคุณผ่านบลูทูธหรือ WiFi.\n2. ใช้ปุ่มลูกศรเพื่อควบคุมการเคลื่อนที่.\n3. ปรับความเร็วด้วยแถบเลื่อน.\n4. ใช้ "เดินตามเส้น" สำหรับการเคลื่อนที่อัตโนมัติ.\n5. ใช้ "ดูกล้อง" เพื่อดูมุมมองของหุ่นยนต์.\n6. ปรับการตั้งค่าการเชื่อมต่อ, การแสดงผล และกล้องในเมนูตั้งค่า.',
      'connectionErrorTitle': 'ข้อผิดพลาดการเชื่อมต่อ',
      'bluetoothNotConnected': 'บลูทูธไม่ได้เชื่อมต่อ โปรดเชื่อมต่อหรือเปิดใช้งานบลูทูธในการตั้งค่า.',
      'wifiConnectionError': 'ข้อผิดพลาดการเชื่อมต่อ WiFi โปรดตรวจสอบ IP หรือการตั้งค่า WiFi ของคุณ.',
      'bluetoothOff': 'บลูทูธปิดอยู่ โปรดเปิดบลูทูธในการตั้งค่า.',
      'openSettings': 'เปิดการตั้งค่า',
      'dismiss': 'ปิด',
    },
    'zh': {
      'title': '机器人控制',
      'speed': '速度',
      'settings': '设置',
      'camera': '查看摄像头',
      'followLine': '循迹',
      'ownerMessage': '本应用由[join845]创建。', // Simplified ownership
      'left': '左',
      'right': '右',
      'forward': '前进',
      'backward': '后退',
      'stop': '停止',
      'changeLanguage': '切换语言',
      'useWiFi': '使用WiFi代替蓝牙',
      'showSpeed': '显示速度滑块',
      'showLineFollow': '显示循迹按钮',
      'showCamera': '显示摄像头按钮',
      'wifiIp': 'WiFi IP（例如192.168.4.1）',
      'save': '保存',
      'imageSettings': '图像设置',
      'imageWidth': '图像宽度',
      'imageHeight': '图像高度',
      'brightness': '亮度',
      'rotation': '旋转',
      'zoom': '缩放',
      'streamType': '流类型',
      'jpegSingle': 'JPEG（单帧）',
      'mjpegStream': 'MJPEG（流）',
      'selectTheme': '选择主题',
      'themeLight': '亮',
      'themeDark': '暗',
      'themeBlue': '蓝色',
      'themeGreen': '绿色',
      'howToUse': '使用说明',
      'usageInstructions': '1. 通过蓝牙或WiFi连接到您的机器人。\n2. 使用箭头按钮控制移动。\n3. 使用滑块调整速度。\n4. 使用“循迹”进行自主移动。\n5. 使用“查看摄像头”查看机器人的视角。\n6. 在设置菜单中调整连接、显示和摄像头设置。',
      'connectionErrorTitle': '连接错误',
      'bluetoothNotConnected': '蓝牙未连接。请在设置中连接或启用蓝牙。',
      'wifiConnectionError': 'WiFi连接错误。请检查您的IP或WiFi设置。',
      'bluetoothOff': '蓝牙已关闭。请在设置中打开蓝牙。',
      'openSettings': '打开设置',
      'dismiss': '关闭',
    }
  };

  String text(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }
}

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: Brightness.dark),
    useMaterial3: true,
  );

  static final ThemeData blueTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.light),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.indigo),
    useMaterial3: true,
  );

  static final ThemeData greenTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.light),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.teal),
    useMaterial3: true,
  );
}

class ControlPage extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  final Locale currentLocale;
  final Function(ThemeData) onThemeChange;
  final ThemeData currentTheme;

  const ControlPage({
    super.key,
    required this.onLocaleChange,
    required this.currentLocale,
    required this.onThemeChange,
    required this.currentTheme,
  });

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  late AppLocalizations loc;
  int speed = 100;
  String mode = "manual";
  bool showSpeed = true;
  bool showLineFollow = true;
  bool showCamera = true;
  bool useWiFi = true;
  String ip = "192.168.4.1";

  // Camera settings
  int imageWidth = 640;
  int imageHeight = 480;
  double brightness = 0.5;
  double rotation = 0.0; // in degrees
  double zoom = 1.0;
  String streamType = 'mjpeg'; // 'jpeg' or 'mjpeg'

  BluetoothConnection? connection;
  String? _errorNotification; // To hold the error message for the bell icon

  @override
  void initState() {
    super.initState();
    loc = AppLocalizations(widget.currentLocale);
    _loadSettings();
    _checkBluetoothState(); // Check Bluetooth state on init
  }

  @override
  void didUpdateWidget(covariant ControlPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLocale != oldWidget.currentLocale) {
      setState(() {
        loc = AppLocalizations(widget.currentLocale);
      });
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showSpeed = prefs.getBool('showSpeed') ?? true;
      showLineFollow = prefs.getBool('showLineFollow') ?? true;
      showCamera = prefs.getBool('showCamera') ?? true;
      useWiFi = prefs.getBool('useWiFi') ?? true;
      ip = prefs.getString('ip') ?? '192.168.4.1';
      imageWidth = prefs.getInt('imageWidth') ?? 640;
      imageHeight = prefs.getInt('imageHeight') ?? 480;
      brightness = prefs.getDouble('brightness') ?? 0.5;
      rotation = prefs.getDouble('rotation') ?? 0.0;
      zoom = prefs.getDouble('zoom') ?? 1.0;
      streamType = prefs.getString('streamType') ?? 'mjpeg';
    });
  }

  Future<void> _checkBluetoothState() async {
    // Request Bluetooth permissions if not granted
    if (!(await Permission.bluetooth.request().isGranted) ||
        !(await Permission.bluetoothScan.request().isGranted) ||
        !(await Permission.bluetoothConnect.request().isGranted)) {
      _showError("Bluetooth permissions not granted.");
      return;
    }

    if (!useWiFi) {
      BluetoothState bluetoothState = await FlutterBluetoothSerial.instance.state;
      if (bluetoothState == BluetoothState.STATE_OFF) {
        _showError(loc.text('bluetoothOff'), openSettings: () => AppSettings.openAppSettings(type: AppSettingsType.bluetooth));
      }
    }
  }

  Future<void> _sendCommand(String action) async {
    final message = {
      "action": action,
      "speed": speed,
      "mode": mode,
      "camera_settings": {
        "width": imageWidth,
        "height": imageHeight,
        "brightness": brightness,
        "rotation": rotation,
        "zoom": zoom,
        "stream_type": streamType,
      }
    };
    final msg = message.toString();

    if (useWiFi) {
      try {
        await http.post(
          Uri.parse('http://$ip/control'),
          headers: {"Content-Type": "application/json"},
          body: msg,
        );
        _clearError();
      } catch (e) {
        _showError(loc.text('wifiConnectionError'), openSettings: () => AppSettings.openAppSettings(type: AppSettingsType.wifi));
      }
    } else {
      // Check Bluetooth permissions before proceeding
      if (!(await Permission.bluetooth.request().isGranted) ||
          !(await Permission.bluetoothScan.request().isGranted) ||
          !(await Permission.bluetoothConnect.request().isGranted)) {
        _showError("Bluetooth permissions not granted. Please grant them in app settings.");
        return;
      }

      try {
        BluetoothState bluetoothState = await FlutterBluetoothSerial.instance.state;
        if (bluetoothState == BluetoothState.STATE_OFF) {
          _showError(loc.text('bluetoothOff'), openSettings: () => AppSettings.openAppSettings(type: AppSettingsType.bluetooth));
          return;
        }

        if (connection != null && connection!.isConnected) {
          connection!.output.add(Uint8List.fromList(msg.codeUnits));
          await connection!.output.allSent;
          _clearError();
        } else {
          _showError(loc.text('bluetoothNotConnected'), openSettings: () => AppSettings.openAppSettings(type: AppSettingsType.bluetooth));
        }
      } catch (e) {
        _showError("Bluetooth Error: $e", openSettings: () => AppSettings.openAppSettings(type: AppSettingsType.bluetooth));
      }
    }
  }

  void _showError(String msg, {Function? openSettings}) {
    setState(() {
      _errorNotification = msg;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.text('connectionErrorTitle')),
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              child: Text(loc.text('dismiss')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            if (openSettings != null)
              TextButton(
                child: Text(loc.text('openSettings')),
                onPressed: () {
                  openSettings();
                  Navigator.of(context).pop();
                },
              ),
          ],
        );
      },
    );
  }

  void _clearError() {
    setState(() {
      _errorNotification = null;
    });
  }

  void _showHowToUse() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.text('howToUse')),
        content: SingleChildScrollView(
          child: Text(loc.text('usageInstructions')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.text('dismiss')),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          loc: loc,
          showSpeed: showSpeed,
          showLineFollow: showLineFollow,
          showCamera: showCamera,
          useWiFi: useWiFi,
          ip: ip,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
          brightness: brightness,
          rotation: rotation,
          zoom: zoom,
          streamType: streamType,
          onSave: (s, l, c, wifi, ipNew, width, height, bright, rot, zm, st) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('showSpeed', s);
            await prefs.setBool('showLineFollow', l);
            await prefs.setBool('showCamera', c);
            await prefs.setBool('useWiFi', wifi);
            await prefs.setString('ip', ipNew);
            await prefs.setInt('imageWidth', width);
            await prefs.setInt('imageHeight', height);
            await prefs.setDouble('brightness', bright);
            await prefs.setDouble('rotation', rot);
            await prefs.setDouble('zoom', zm);
            await prefs.setString('streamType', st);

            setState(() {
              showSpeed = s;
              showLineFollow = l;
              showCamera = c;
              useWiFi = wifi;
              ip = ipNew;
              imageWidth = width;
              imageHeight = height;
              brightness = bright;
              rotation = rot;
              zoom = zm;
              streamType = st;
            });
          },
        ),
      ),
    );
  }

  void _changeLanguage() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.text('changeLanguage')),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  widget.onLocaleChange(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('ภาษาไทย'),
                onTap: () {
                  widget.onLocaleChange(const Locale('th'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('中文'),
                onTap: () {
                  widget.onLocaleChange(const Locale('zh'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTheme() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.text('selectTheme')),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(loc.text('themeLight')),
                onTap: () {
                  widget.onThemeChange(AppThemes.lightTheme);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(loc.text('themeDark')),
                onTap: () {
                  widget.onThemeChange(AppThemes.darkTheme);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(loc.text('themeBlue')),
                onTap: () {
                  widget.onThemeChange(AppThemes.blueTheme);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(loc.text('themeGreen')),
                onTap: () {
                  widget.onThemeChange(AppThemes.greenTheme);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArrowButton(String imagePath, String action, {double size = 70.0}) {
    return InkWell(
      onTap: () => _sendCommand(action),
      borderRadius: BorderRadius.circular(size / 2),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          imagePath,
          width: size,
          height: size,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, String action) {
    return ElevatedButton(
      onPressed: () => _sendCommand(action),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.text('title')),
        actions: [
          if (_errorNotification != null)
            IconButton(
              icon: const Icon(Icons.notifications_active, color: Colors.red),
              tooltip: _errorNotification,
              onPressed: () => _showError(_errorNotification!, openSettings: useWiFi ? () => AppSettings.openAppSettings(type: AppSettingsType.wifi) : () => AppSettings.openAppSettings(type: AppSettingsType.bluetooth)),
            ),
          IconButton(
            icon: const Icon(Icons.palette),
            tooltip: loc.text('selectTheme'),
            onPressed: _selectTheme,
          ),
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: loc.text('changeLanguage'),
            onPressed: _changeLanguage,
          ),
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
            tooltip: loc.text('settings'),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: loc.text('howToUse'),
            onPressed: _showHowToUse,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left control pad (Arrows)
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildArrowButton('assets/images/arrow_up.png', "forward"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildArrowButton('assets/images/arrow_left.png', "left"),
                        const SizedBox(width: 10),
                        _buildActionButton(loc.text('stop'), "stop"),
                        const SizedBox(width: 10),
                        _buildArrowButton('assets/images/arrow_right.png', "right"),
                      ],
                    ),
                    _buildArrowButton('assets/images/arrow_down.png', "backward"),
                  ],
                ),
              ),
              const VerticalDivider(width: 32.0),
              // Right control panel (Speed, Line Follow, Camera)
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showSpeed)
                      Column(
                        children: [
                          Text('${loc.text('speed')}: $speed', style: Theme.of(context).textTheme.titleLarge),
                          Slider(
                            min: 0,
                            max: 255,
                            value: speed.toDouble(),
                            onChanged: (v) => setState(() => speed = v.toInt()),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    if (showLineFollow)
                      _buildActionButton(loc.text('followLine'), "line"),
                    const SizedBox(height: 20),
                    if (showCamera)
                      _buildActionButton(loc.text('camera'), "camera"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ----------------------------------------------------
// !!! IMPORTANT: SettingsPage AND _SettingsPageState MUST BE DECLARED HERE,
//                 OUTSIDE of any other class.
// ----------------------------------------------------

class SettingsPage extends StatefulWidget {
  final AppLocalizations loc;
  final bool showSpeed, showLineFollow, showCamera, useWiFi;
  final String ip;
  final int imageWidth, imageHeight;
  final double brightness, rotation, zoom;
  final String streamType;
  final Function(bool, bool, bool, bool, String, int, int, double, double, double, String) onSave;

  const SettingsPage({
    super.key,
    required this.loc,
    required this.showSpeed,
    required this.showLineFollow,
    required this.showCamera,
    required this.useWiFi,
    required this.ip,
    required this.imageWidth,
    required this.imageHeight,
    required this.brightness,
    required this.rotation,
    required this.zoom,
    required this.streamType,
    required this.onSave,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool showSpeed, showLineFollow, showCamera, useWiFi;
  late TextEditingController ipController;
  late TextEditingController imageWidthController;
  late TextEditingController imageHeightController;
  late double brightness;
  late double rotation;
  late double zoom;
  late String streamType;

  @override
  void initState() {
    super.initState();
    showSpeed = widget.showSpeed;
    showLineFollow = widget.showLineFollow;
    showCamera = widget.showCamera;
    useWiFi = widget.useWiFi;
    ipController = TextEditingController(text: widget.ip);
    imageWidthController = TextEditingController(text: widget.imageWidth.toString());
    imageHeightController = TextEditingController(text: widget.imageHeight.toString());
    brightness = widget.brightness;
    rotation = widget.rotation;
    zoom = widget.zoom;
    streamType = widget.streamType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.loc.text('settings'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              value: showSpeed,
              onChanged: (v) => setState(() => showSpeed = v),
              title: Text(widget.loc.text('showSpeed')),
            ),
            SwitchListTile(
              value: showLineFollow,
              onChanged: (v) => setState(() => showLineFollow = v),
              title: Text(widget.loc.text('showLineFollow')),
            ),
            SwitchListTile(
              value: showCamera,
              onChanged: (v) => setState(() => showCamera = v),
              title: Text(widget.loc.text('showCamera')),
            ),
            SwitchListTile(
              value: useWiFi,
              onChanged: (v) => setState(() => useWiFi = v),
              title: Text(widget.loc.text('useWiFi')),
            ),
            TextField(
              controller: ipController,
              decoration: InputDecoration(labelText: widget.loc.text('wifiIp')),
              keyboardType: TextInputType.url,
            ),
            const Divider(),
            Text(widget.loc.text('imageSettings'), style: Theme.of(context).textTheme.headlineSmall),
            TextField(
              controller: imageWidthController,
              decoration: InputDecoration(labelText: widget.loc.text('imageWidth')),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: imageHeightController,
              decoration: InputDecoration(labelText: widget.loc.text('imageHeight')),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                Expanded(child: Text(widget.loc.text('brightness'))),
                Expanded(
                  flex: 5,
                  child: Slider(
                    min: 0.0,
                    max: 1.0,
                    value: brightness,
                    onChanged: (v) => setState(() => brightness = v),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text(widget.loc.text('rotation'))),
                Expanded(
                  flex: 5,
                  child: Slider(
                    min: 0.0,
                    max: 360.0,
                    value: rotation,
                    onChanged: (v) => setState(() => rotation = v),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text(widget.loc.text('zoom'))),
                Expanded(
                  flex: 5,
                  child: Slider(
                    min: 0.1,
                    max: 5.0,
                    value: zoom,
                    onChanged: (v) => setState(() => zoom = v),
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              value: streamType,
              decoration: InputDecoration(labelText: widget.loc.text('streamType')),
              items: [
                DropdownMenuItem(
                  value: 'jpeg',
                  child: Text(widget.loc.text('jpegSingle')),
                ),
                DropdownMenuItem(
                  value: 'mjpeg',
                  child: Text(widget.loc.text('mjpegStream')),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  streamType = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onSave(
                  showSpeed,
                  showLineFollow,
                  showCamera,
                  useWiFi,
                  ipController.text,
                  int.tryParse(imageWidthController.text) ?? 640,
                  int.tryParse(imageHeightController.text) ?? 480,
                  brightness,
                  rotation,
                  zoom,
                  streamType,
                );
                Navigator.pop(context);
              },
              child: Text(widget.loc.text('save')),
            )
          ],
        ),
      ),
    );
  }
}