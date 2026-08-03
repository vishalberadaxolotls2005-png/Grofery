import 'package:flutter/material.dart';
import 'package:grofery_user/utils/widgets/custom_toast.dart';

class NotifyButton extends StatefulWidget {
  final Widget Function(bool isNotified, VoidCallback onTap) builder;
  
  const NotifyButton({Key? key, required this.builder}) : super(key: key);

  @override
  State<NotifyButton> createState() => _NotifyButtonState();
}

class _NotifyButtonState extends State<NotifyButton> {
  bool isNotified = false;

  void handleTap() {
    if (!isNotified) {
      setState(() {
        isNotified = true;
      });
      ToastManager.show(
        context: context,
        message: 'You will be notified when product is available',
        type: ToastType.authGuard,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(isNotified, handleTap);
  }
}
