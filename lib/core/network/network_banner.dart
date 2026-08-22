import 'dart:async';

import 'package:flutter/material.dart';

import 'network_status.dart';

class NetworkBanner extends StatefulWidget {
  const NetworkBanner({required this.child, required this.networkStatus, super.key});

  final Widget child;
  final NetworkStatus networkStatus;

  @override
  State<NetworkBanner> createState() => _NetworkBannerState();
}

class _NetworkBannerState extends State<NetworkBanner> {
  StreamSubscription<bool>? _subscription;
  bool _online = true;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    _online = await widget.networkStatus.isOnline;
    if (mounted) setState(() {});
    await widget.networkStatus.start();
    _subscription = widget.networkStatus.changes.listen((online) {
      if (mounted && online != _online) setState(() => _online = online);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      widget.child,
      if (!_online)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Material(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(children: [
                  const Icon(Icons.cloud_off_outlined, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Нет подключения к интернету. Показываются доступные данные.', style: Theme.of(context).textTheme.bodySmall)),
                ]),
              ),
            ),
          ),
        ),
    ]);
  }
}
