import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  static void showSuccess(String message) {
    toastification.show(
      title: Text("Success"),
      description: Text(message),
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.bottomCenter,
    );
  }

  static void showError(String message) {
    toastification.show(
      title: Text("Error"),
      description: Text(message),
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 4),
      alignment: Alignment.bottomCenter,
    );
  }

  static void showInfo(String message) {
    toastification.show(
      title: Text("Info"),
      description: Text(message),
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.bottomCenter,
    );
  }
}
