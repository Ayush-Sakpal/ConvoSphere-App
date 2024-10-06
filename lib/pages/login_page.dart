import 'package:chat_app/consts.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/main.dart';
import 'package:get_it/get_it.dart';

import '../widgets/custom_form_field.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{

  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  String? email, password;

  final GlobalKey<FormState> _loginFormKey = GlobalKey();

  @override
  void initState(){
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI(){
    return SafeArea(
        child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20
            ),

          child: Column(
            children: [
              _headerText(),
              _loginForm(),
              _createAnAccountLink()
            ],
          ),
        )
    );
  }

  Widget _headerText(){
    return SizedBox(
      width: MediaQuery.of(context).size.width,

      child: const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            'Hi, Welcome Back!',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800
            ),
          ),

          Text(
            "Hello again, you've been missed",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              color: Colors.grey
            ),
          )
        ],
      ),
    );
  }

  Widget _loginForm(){
    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.05
      ),
      
      child: Form(
        key: _loginFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomFormField(
                hintText: "Email",
                height: MediaQuery.of(context).size.height * 0.1,
                validationRegEx: EMAIL_VALIDATION_REGEX,
                onSaved: (value){
                  setState(() {
                    email = value;
                  });
                },
              ),
              CustomFormField(
                hintText: "Password",
                  height: MediaQuery.of(context).size.height * 0.1,
                validationRegEx: PASSWORD_VALIDATION_REGEX,
                obscureText: true,
                onSaved: (value){
                  setState(() {
                    password = value;
                  });
                },
              ),
              _loginButton()
            ],
          )
      ),
    );
  }

  Widget _loginButton(){
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: MaterialButton(
          onPressed: () async{
            if(_loginFormKey.currentState?.validate() ?? false) {
              _loginFormKey.currentState?.save();
              bool result = await _authService.login(email!, password!);

              print(result);
              
              if(result){
                _navigationService.pushReplacementNamed("/home");
                _alertService.showToast(
                    text: "Successfully logged in!",
                    icon: Icons.done,
                    color: Colors.green
                );
              }
              else{
                _alertService.showToast(
                    text: "Failed to login, Please try again!",
                  icon: Icons.error,
                  color: Colors.red
                );
              }
            }
          },
        color: Theme.of(context).colorScheme.primary,
        child: const Text(
          "Login",
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),

    );
  }

  Widget _createAnAccountLink(){
    return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              "Don't have an account?"
            ),
            const SizedBox(
              width: 3,
            ),
            GestureDetector(
              onTap: (){
                _navigationService.pushNamed("/register");
              },
              child: const Text(
                  "Sign Up",
                style: TextStyle(
                  fontWeight: FontWeight.w800
                ),
              ),
            )
          ],
        )
    );
  }

}