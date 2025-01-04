import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lelang_fb/app/utils/custom_text_field.dart';
import 'package:lelang_fb/core/constants/color.dart';
import 'dart:math';

class PhoneVerificationController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isVerifying = false.obs;
  var verificationCode = ''.obs;
  final verificationCodeController = TextEditingController();
  var verificationError = ''.obs;

  Future<void> sendVerificationCode(String phoneNumber) async {
    try {
      isVerifying.value = true;
      final User? user = _auth.currentUser;

      if (user != null && user.email != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final currentPhone = userDoc.data()?['phoneNumber'];

        if (currentPhone == phoneNumber) {
          Get.snackbar(
            'Info',
            'This phone number is already verified',
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
          return;
        }

        String code = _generateVerificationCode();
        verificationCode.value = code;

        await _firestore.collection('phone_verifications').doc(user.uid).set({
          'code': code,
          'phoneNumber': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'isVerified': false
        });

        _showVerificationDialog();

        Get.snackbar(
          'Verification Code',
          'Your verification code is: $code\nPlease enter this code to verify your phone number.',
          duration: Duration(seconds: 30),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'You must be logged in with an email to verify your phone number',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error sending verification code: $e');
      Get.snackbar(
        'Error',
        'Failed to send verification code',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isVerifying.value = false;
    }
  }

  String _generateVerificationCode() {
    Random random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  void _showVerificationDialog() {
    verificationError.value = '';
    verificationCodeController.clear();

    Get.dialog(
      Dialog(
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
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        verifyCode(verificationCodeController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.hijauTua,
                    ),
                    child:
                        Text('Verify', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> verifyCode(String enteredCode) async {
    try {
      if (enteredCode == verificationCode.value) {
        final User? user = _auth.currentUser;
        if (user != null) {
          final verificationDoc = await _firestore
              .collection('phone_verifications')
              .doc(user.uid)
              .get();

          if (verificationDoc.exists) {
            final phoneNumber = verificationDoc.data()?['phoneNumber'];

            Get.back(closeOverlays: true);

            await _firestore.collection('users').doc(user.uid).update({
              'phoneNumber': phoneNumber,
              'updatedAt': FieldValue.serverTimestamp(),
            });

            await _firestore
                .collection('phone_verifications')
                .doc(user.uid)
                .delete();

            Get.snackbar(
              'Success',
              'Phone number verified and updated successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );

            notifyVerificationSuccess();
          }
        }
      } else {
        verificationError.value =
            'Invalid verification code. Please try again.';
      }
    } catch (e) {
      print('Error verifying code: $e');
      verificationError.value = 'Failed to verify code. Please try again.';
    }
  }

  final _onVerificationSuccessCallback = Rxn<Function>();

  set verificationSuccessCallback(Function callback) =>
      _onVerificationSuccessCallback.value = callback;

  void notifyVerificationSuccess() =>
      _onVerificationSuccessCallback.value?.call();
}
