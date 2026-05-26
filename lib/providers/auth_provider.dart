import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthStep { credentials, otp }
enum LoginMethod { email, mobile }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  User? _user;
  Map<String, dynamic>? _adminData;
  bool _isInitialized = false;
  AuthStep _step = AuthStep.credentials;
  LoginMethod _method = LoginMethod.email;
  bool _isLoading = false;
  String? _verificationId;

  AuthProvider() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        try {
          final doc = await _db.collection('admin_id').doc(user.uid).get();
          _adminData = doc.data();
        } catch (e) {
          debugPrint("Error fetching admin data: $e");
        }
      } else {
        _adminData = null;
      }
      _user = user;
      _isInitialized = true;
      notifyListeners();
    });
  }

  bool get isLoggedIn => _user != null;
  bool get isInitialized => _isInitialized;
  User? get user => _user;
  Map<String, dynamic>? get adminData => _adminData;
  AuthStep get step => _step;
  LoginMethod get method => _method;
  bool get isLoading => _isLoading;

  void setMethod(LoginMethod m) {
    _method = m;
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint("Login error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      if (credential.user != null) {
        // Explicitly store admin data in 'admin_id' collection
        await _db.collection('admin_id').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'phone': phone,
          'role': 'admin',
          'uid': credential.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Refresh local admin data
        final doc = await _db.collection('admin_id').doc(credential.user!.uid).get();
        _adminData = doc.data();
      }
    } catch (e) {
      debugPrint("Registration error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendOtp(String identifier) async {
    _isLoading = true;
    notifyListeners();

    if (_method == LoginMethod.email) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: identifier,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("Phone verification failed: ${e.message}");
          _isLoading = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _step = AuthStep.otp;
          _isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_verificationId != null) {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otp,
        );
        await _auth.signInWithCredential(credential);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("OTP Verification failed: $e");
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  void goBack() {
    _step = AuthStep.credentials;
    notifyListeners();
  }

  void logout() async {
    await _auth.signOut();
    _step = AuthStep.credentials;
    _adminData = null;
    notifyListeners();
  }
}
