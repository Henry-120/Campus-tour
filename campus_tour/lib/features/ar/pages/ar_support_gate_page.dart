import 'package:campus_tour/features/ar/pages/ar_unavailable_page.dart';
import 'package:campus_tour/features/ar/services/ar_support_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArSupportGatePage extends StatefulWidget {
  const ArSupportGatePage({
    super.key,
    required this.service,
    required this.destinationBuilder,
  });

  final ArSupportService service;
  final WidgetBuilder destinationBuilder;

  @override
  State<ArSupportGatePage> createState() => _ArSupportGatePageState();
}

class _ArSupportGatePageState extends State<ArSupportGatePage>
    with WidgetsBindingObserver {
  ArSupportResult _result = const ArSupportResult(ArSupportStatus.checking);
  bool _checking = false;
  bool _openedDestination = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepare();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_openedDestination) {
      _prepare();
    }
  }

  Future<void> _prepare() async {
    if (_checking || _openedDestination) return;
    _checking = true;
    if (mounted) {
      setState(() {
        _result = const ArSupportResult(ArSupportStatus.checking);
      });
    }

    final result = await widget.service.prepare();
    _checking = false;
    if (!mounted) return;

    if (result.canStart) {
      _openedDestination = true;
      await Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(builder: widget.destinationBuilder),
      );
      return;
    }

    setState(() => _result = result);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_result.status == ArSupportStatus.checking) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'features.ar.pages.ar.support.gate.page.s001'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ArUnavailablePage(
      result: _result,
      onRetry: _result.canRetry ? _prepare : null,
    );
  }
}
