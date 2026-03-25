// System
import 'dart:async'; // 非同步
import 'dart:math' as math; // 數學擴充

// UI
import 'package:flutter/material.dart'; // UI 元件
import 'package:flutter/services.dart'; // 手機底層系統處理
import 'package:google_fonts/google_fonts.dart'; // 字體

// Hardware
import 'package:geolocator/geolocator.dart'; // GPS
import 'package:flutter_compass/flutter_compass.dart'; // 電子羅盤
import 'package:image_picker/image_picker.dart'; // 相機

// Multimedia
import 'package:audioplayers/audioplayers.dart'; // 音效

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // 把上下界拿掉
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartScreen(), // app 進去後第一個看到的頁面
    );
  }
}

/////////////////////////////////////////////////////////

class StartScreen extends StatefulWidget { // 開始頁面
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class GpsScreen extends StatefulWidget { // GPS 頁面
  const GpsScreen({super.key});

  @override
  State<GpsScreen> createState() => _GpsScreenState();
}

// class CollectionScreen extends StatefulWidget {
//   const CollectionScreen({super.key});

//   @override
//   State<CollectionScreen> createState() => _CollectionScreenState();
// }

class _StartScreenState extends State<StartScreen> with WidgetsBindingObserver { // 監看 app 生命週期
  static final AudioPlayer _globalPlayer = AudioPlayer();
  static final AudioPlayer _bgmPlayer = AudioPlayer();

  double _buttonScale = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _globalPlayer.setSource(AssetSource('audio/startSFX.mp3'));  // 預載入
    _startBgm();
  }

  void _playStartSfx() {
    _globalPlayer.resume();
  }

  Future<void> _startBgm() async {
    await _bgmPlayer.setSource(AssetSource('audio/BGM.mp3'));
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.65);
    await _bgmPlayer.resume();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _bgmPlayer.pause();
      debugPrint("[Lifecycle] App 已進入背景，音樂暫停！");
    } else if (state == AppLifecycleState.resumed) {
      _bgmPlayer.resume();
      debugPrint("[Lifecycle] 歡迎回來！音樂繼續演奏～");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. 背景圖
          Image.asset(
            'assets/images/Arcana_Background.jpg', 
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          
          // 2. 加一層淡淡的黑色半透明遮罩，讓前面的白字和按鈕更清楚
          Container(
            color: Colors.black.withValues(alpha: 0.4),
          ),

          // 3. 畫面正中央的內容：標題 + 按鈕
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // 讓內容垂直置中
              children: [
                // App 大標題
                Text(
                  "Campus Tour", 
                  style: GoogleFonts.zcoolQingKeHuangYou(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0, // 讓字距稍微拉開，更有質感
                    shadows: const [
                      Shadow(color: Colors.pinkAccent, blurRadius: 10, offset: Offset(2, 2)),
                      Shadow(color: Colors.black54, blurRadius: 20, offset: Offset(4, 4)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60), // 標題和按鈕之間空出 60 的距離
                
                AnimatedScale(
                  scale: _buttonScale,
                  duration: const Duration(milliseconds: 150), // 放大時間
                  curve: Curves.easeInOut,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.pinkAccent.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5)
                      ]
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.withValues(alpha: 0.7), 
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        elevation: 10, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35), 
                          side: const BorderSide(color: Colors.white, width: 2), 
                        ),
                      ),
                      onPressed: () async {
                        _playStartSfx(); // 戴耳機會有明顯延遲
                        setState(() {
                          _buttonScale = 1.2; 
                        });
                        await Future.delayed(const Duration(milliseconds: 150));
                        setState(() {
                          _buttonScale = 1.0; 
                        });
                        await Future.delayed(const Duration(milliseconds: 350));
                        if (!context.mounted) return;
                        
                        Navigator.pushReplacement( // 跳轉
                          context,
                          MaterialPageRoute(builder: (context) => const GpsScreen()),
                        );
                      },
                      child: Text(
                        "START",
                        style: GoogleFonts.zcoolQingKeHuangYou(
                          fontSize: 26, 
                          color: Colors.white, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GpsScreenState extends State<GpsScreen> {
  String _locationMessage = "正在初始化定位系統...";
  StreamSubscription<Position>? _positionStreamSubscription;

  double? _heading = 0; 
  StreamSubscription<CompassEvent>? _compassSubscription;

  final AudioPlayer _welcomePlayer = AudioPlayer();

  final ImagePicker _picker = ImagePicker(); // 相機功能

  // 當頁面一建立，立刻執行初始化
  @override
  void initState() {
    super.initState();
    _startTrackingOnLoad();
    _startCompassStream();
    _playWelcomeGreeting();
  }

  // 自動執行的初始化邏輯
  Future<void> _startTrackingOnLoad() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. 檢查 GPS 硬體有沒有開
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() { _locationMessage = "請開啟手機 GPS 定位功能"; });
      return;
    }

    // 2. 檢查並請求權限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() { _locationMessage = "定位權限被拒絕"; });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() { _locationMessage = "定位權限被永久拒絕，請至設定開啟"; });
      return;
    }

    // 3. 權限通過後，自動開啟持續監聽
    _startLocationStream();
  }

  void _startLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // 高精確度（適用於 10 公尺內觸發）
      distanceFilter: 2, // 移動超過 2 公尺才更新畫面
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      setState(() {
        _locationMessage = 
          "📍 即時位置更新中\n"
          "緯度 : ${position.latitude.toStringAsFixed(6)}\n"
          "經度 : ${position.longitude.toStringAsFixed(5)}";
      });
    });
  }

  void _startCompassStream() {
    // 監聽羅盤事件（這行會回傳手機離「正北」的角度 0~360）
    _compassSubscription = FlutterCompass.events!.listen((event) {
      setState(() {
        // 更新朝向角度
        _heading = event.heading; 
      });
    });
  }

  Future<void> _playWelcomeGreeting() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _welcomePlayer.setVolume(0.8); 
    _welcomePlayer.play(AssetSource('audio/intro.mp3'));
  }

  Future<void> _takePhoto() async {
    try {
      // 這行會暫停我們的 App，並優雅地彈出手機內建的相機！
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      
      if (photo != null) {
        // 如果使用者真的拍了照（沒有按取消
        debugPrint("[Camera] 📸 拍照成功！照片存在這裡: ${photo.path}");
        // 之後我們甚至可以把這張照片顯示在畫面上，或是存進您之前提到的 SQLite 資料庫裡！
        // 跟 YOLO 有關吧
      }
    } catch (e) {
      debugPrint("[Camera] 打開相機失敗: $e");
    }
  }

  @override
  void dispose() {
    // 記得離開 App 時關閉監聽，保護電池
    // ? 如果前面的 object 有東西才執行後面的 method
    _positionStreamSubscription?.cancel();
    _compassSubscription?.cancel();
    _welcomePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "拉毗哭暈在廁所",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo.withValues(alpha: 0.5),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/Arcana.jpg', // 我老婆
            width: double.infinity, // 寬度撐滿螢幕
            height: double.infinity, // 高度撐滿螢幕
            fit: BoxFit.cover, // 關鍵：讓圖片縮放以填滿整個畫面，且不變形
            alignment: Alignment.center, // 放正中心
          ),
          Positioned(
            top: 100,
            right: 15,
            // 用 Transform.rotate 來旋轉圖片 ✨
            child: Transform.rotate(
              // 📐 旋轉角度計算 📐
              // 我們要把手機朝向的角度 (0~360) 轉換成弧度，並且取負值（-1）
              // 這樣手機順時針轉，圖片逆時針轉，箭頭就會永遠維持指向上方（正北）
              angle: ((_heading ?? 0) * (math.pi / 180) * -1),
              child: Image.asset(
                'assets/images/arrow.png',
                width: 75,
                height: 75,
                fit: BoxFit.contain,
              ),
            ), 
          ),
          Align(
            alignment: Alignment.topLeft,  // 放左上
            child: Container(
              margin: const EdgeInsets.only(top: 100, left: 15), // 外間距
              padding: const EdgeInsets.all(20), // 內間距
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10)
                ]
              ),
              child: Text(
                _locationMessage,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.black87
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePhoto, // 按下就執行拍照函數
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
      ),
    );
  }
}