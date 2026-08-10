import 'package:campus_tour/styles/setting_page_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UserProtocolPage extends StatefulWidget {
  const UserProtocolPage({super.key});

  @override
  State<UserProtocolPage> createState() => _UserProtocolPageState();
}

class _UserProtocolPageState extends State<UserProtocolPage> {
  static final Uri _documentUri = Uri.parse(
    'https://docs.google.com/document/d/e/'
    '2PACX-1vSBgzOKiCsxdOe5BK7ULYseQyDZa90fKM0CaD0OnM8Cc-dCBT69btKADHXW0HxxDG8-P58HiCakcJ9o/pub',
  );

  late final WebViewController _controller;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => _setLoadingProgress(0),
          onProgress: _setLoadingProgress,
          onPageFinished: (_) => _setLoadingProgress(100),
        ),
      )
      ..loadRequest(_documentUri);
  }

  void _setLoadingProgress(int progress) {
    if (!mounted || _loadingProgress == progress) {
      return;
    }

    setState(() {
      _loadingProgress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: SettingPageStyles.pageBackgroundDecoration,
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: SettingPageStyles.pageContentConstraints,
              child: Padding(
                padding: SettingPageStyles.pagePadding,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration:
                              SettingPageStyles.navigationButtonDecoration,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: SettingPageStyles.mutedIconColor,
                            tooltip: 'view.camera.view.s010'.tr,
                          ),
                        ),
                        SizedBox(width: SettingPageStyles.gapMd),
                        Expanded(
                          child: Text(
                            'view.lhf.setting.page.s048'.tr,
                            style: SettingPageStyles.pageTitleStyle,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SettingPageStyles.sectionSpacing),
                    Expanded(
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: SettingPageStyles.settingCardDecoration,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: WebViewWidget(controller: _controller),
                            ),
                            if (_loadingProgress < 100)
                              Align(
                                alignment: Alignment.topCenter,
                                child: LinearProgressIndicator(
                                  value: _loadingProgress / 100,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
