import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lelang_fb/app/utils/custom_text_field.dart';
import 'package:lelang_fb/core/constants/color.dart';
import 'dart:math';

class PhoneVerificationController extends GetxController {
  Map<String, dynamic>? pendingUpdates;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isVerifying = false.obs;
  var verificationCode = ''.obs;
  var pendingPhoneNumber = ''.obs;
  final verificationCodeController = TextEditingController();
  var verificationError = ''.obs;

  Future<bool> sendVerificationCode(String phoneNumber) async {
    try {
      isVerifying.value = true;
      final User? user = _auth.currentUser;

      if (user != null) {
        String code = _generateVerificationCode();
        verificationCode.value = code;
        pendingPhoneNumber.value = phoneNumber;

        Get.dialog(
          createVerificationDialog(),
          barrierDismissible: false,
        );

        Get.snackbar(
          'Verification Code',
          'Your verification code is: $code',
          duration: Duration(seconds: 30),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return true;
      }
      return false;
    } catch (e) {
      print('Error sending verification code: $e');
      Get.snackbar(
        'Error',
        'Failed to send verification code',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isVerifying.value = false;
    }
  }

  String _generateVerificationCode() {
    Random random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  Widget createVerificationDialog() {
    verificationError.value = '';
    verificationCodeController.clear();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Verify Phone Number',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Please check the verification code shown in the notification.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: verificationCodeController,
                  labelText: 'Verification Code',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
                Obx(() => verificationError.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          verificationError.value,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : SizedBox.shrink()),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    if (Get.isDialogOpen ?? false) {
                      Get.back();
                    }
                    pendingUpdates = null;
                  },
                  child: Text('Cancel'),
                ),
                Obx(() => ElevatedButton(
                      onPressed: isVerifying.value
                          ? null
                          : () => verifyCode(verificationCodeController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.hijauTua,
                      ),
                      child: isVerifying.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ))
                          : Text('Verify',
                              style: TextStyle(color: Colors.white)),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> verifyCode(String enteredCode) async {
    try {
      if (enteredCode == verificationCode.value) {
        final User? user = _auth.currentUser;
        if (user != null && pendingUpdates != null) {
          isVerifying.value = true;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update(pendingUpdates!);

          pendingUpdates = null;

          Get.closeAllSnackbars();

          Get.until((route) => !Get.isDialogOpen!);

          notifyVerificationSuccess();
          Get.snackbar(
            'Success',
            'Phone number verified and profile updated successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      } else {
        verificationError.value =
            'Invalid verification code. Please try again.';
      }
    } catch (e) {
      print('Error verifying code: $e');
      verificationError.value = 'Failed to verify code: ${e.toString()}';
    } finally {
      isVerifying.value = false;
    }
  }

  final _onVerificationSuccessCallback = Rxn<Function>();

  set verificationSuccessCallback(Function callback) =>
      _onVerificationSuccessCallback.value = callback;

  void notifyVerificationSuccess() =>
      _onVerificationSuccessCallback.value?.call();

}
