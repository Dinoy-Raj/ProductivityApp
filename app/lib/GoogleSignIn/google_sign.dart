import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;


  Future googleLogin() async {
    // try{
  final googleUser = await googleSignIn.signIn();

  if (googleUser == null)
    {
      Fluttertoast.showToast(msg:"Selecting An Account Is Required",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      googleLogin();
    }

  _user = googleUser;


  final googleAuth = await googleUser!.authentication;



  final credential = GoogleAuthProvider.credential(
  accessToken: googleAuth.accessToken,
  idToken: googleAuth.idToken,
  );

  await FirebaseAuth.instance.signInWithCredential(credential);

  await FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .set({'email': _user?.email, 'image': _user?.photoUrl, 'name': _user?.displayName});

  notifyListeners();

  }


  Future logOut() async {
    await googleSignIn.disconnect();
    await FirebaseAuth.instance.signOut();
  }
}
