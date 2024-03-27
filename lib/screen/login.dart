import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //
  final TextEditingController _smsCodeController = TextEditingController();
  final TextEditingController _phoneController =
      TextEditingController(text: '+8210');
  late String _verificationId;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              loginForm(context),
              SizedBox(
                height: 30,
              ),
              smsCodeInput(),
              SizedBox(
                height: 15,
              ),
              button(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget loginForm(BuildContext context) {
    return TextFormField(
      controller: _phoneController,
      autofocus: true,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: 'Enter your phone number',
        prefixIcon: Icon(Icons.phone),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your phone number';
        }
        // Add any additional validation here if needed
        return null;
      },
    );
  }

  TextFormField smsCodeInput() {
    return TextFormField(
      controller: _smsCodeController,
      autofocus: true,
      validator: (val) {
        if (val!.isEmpty) {
          return 'The input is empty.';
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Input your sms code.',
        labelText: 'SMS Code',
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget button() {
    return ElevatedButton(
      onPressed: () async {
        await signInPhone(); // signInPhone 함수 호출
      },
      child: Text('Sign In'),
    );
  }

  Future<void> signInPhone() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        print('verificationCompleted');
        await auth
            .signInWithCredential(credential)
            .then((_) => Navigator.pushNamed(context, "/"));
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid phone number') {
          print('The provided phone number is not valid.');
        }
        print('verificationFailed $e');
      },
      codeSent: (String verificationId, int? resendToken) async {
        String smsCode = _smsCodeController.text;

        setState(() {
          // _codeSent = true;

          _verificationId = verificationId;
        });
        // String smsCode = '000000';
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: _verificationId, smsCode: _smsCodeController.text);
        // print('codeSent');
        await auth
            .signInWithCredential(credential)
            .then((_) => Navigator.pushNamed(context, "/"));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        timeout:
        Duration(seconds: 10);
        print('codeAutoRetrievalTimeout');
      },
    );
  }
}
