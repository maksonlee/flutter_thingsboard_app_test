import 'package:flutter/material.dart';
import 'package:thingsboard_app/screens/my_tab_controller.dart';
import 'package:provider/provider.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../models/thingsboard_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, dimensions) {
        final width = dimensions.maxWidth / 1.5;
        final height = dimensions.maxHeight / 3;

        return Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Login to you account",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: height,
                    maxWidth: width,
                  ),
                  child: const LoginForm(),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _key = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwdController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
                icon: Icon(Icons.mail), hintText: "Email"),
          ),
          TextFormField(
            controller: passwdController,
            decoration: const InputDecoration(
                icon: Icon(Icons.vpn_key), hintText: "Password"),
            obscureText: true,
          ),
          ElevatedButton(
            child: const Text("Login"),
            onPressed: _login,
          ),
        ],
      ),
    );
  }

  void _login() async {
    if (_key.currentState?.validate() ?? false) {
      final email = emailController.text;
      final passwd = passwdController.text;

      final provider = Provider.of<ThingsBoardProvider>(context, listen: false);
      var tbClient = provider.tbClient;

      try {
        await tbClient.login(LoginRequest(email, passwd));
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const MyTabController();
        }));
      } catch (e) {
        const snackBar = SnackBar(
          backgroundColor: Color(0xFF800000),
          content: Text('Invalid username or password'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
