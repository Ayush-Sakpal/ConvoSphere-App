import 'dart:io';

import 'package:chat_app/consts.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:chat_app/widgets/custom_form_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget{
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterPageState();

}

class _RegisterPageState extends State<RegisterPage>{

  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _registerFormKey = GlobalKey();

  late MediaService _mediaService;
  late NavigationService _navigationService;
  late AuthService _authService;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  late AlertService _alertService;

  String? email, password, name;
  File? selectedImage;
  bool isLoading = false;

  @override
  void initState(){
    super.initState();

    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
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
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20
            ),
          child: Column(
            children: [
              _headerText(),
              if(!isLoading) _registerForm(),
              if(!isLoading) _loginAccountLink(),

              if(isLoading) const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
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
            "Let's, get going!",
            style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800
            ),
          ),

          Text(
            "Register an account using the form below",
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

  Widget _registerForm(){
    return Container(
      height:  MediaQuery.of(context).size.height * 0.60,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.05
      ),

      child: Form(
        key: _registerFormKey,
        child: Column(
          children: [
            _pfpSelectionField(),

            SizedBox(
              height: 20,
            ),
            
            CustomFormField(
                hintText: "Name",
                height: MediaQuery.of(context).size.height * 0.10,
                validationRegEx: NAME_VALIDATION_REGEX,
                onSaved: (value){
                  name = value;
                }
            ),

            CustomFormField(
                hintText: "Email",
                height: MediaQuery.of(context).size.height * 0.10,
                validationRegEx: EMAIL_VALIDATION_REGEX,
                onSaved: (value){
                  email = value;
                }
            ),

            CustomFormField(
                hintText: "Password",
                height: MediaQuery.of(context).size.height * 0.10,
                validationRegEx: PASSWORD_VALIDATION_REGEX,
                obscureText: true,
                onSaved: (value){
                  password = value;
                }
            ),

            _registerButton(),
          ],
        ),
      ),
    );
  }

  Widget _pfpSelectionField(){
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if(file != null){
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.15,
        backgroundImage: selectedImage != null ? FileImage(selectedImage!) : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }

  Widget _registerButton(){
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: MaterialButton(
        color: Theme.of(context).colorScheme.primary,
          onPressed: () async {
          setState(() {
            isLoading = true;
          });
            try{
              if((_registerFormKey.currentState?.validate() ?? false) && selectedImage != null){
                _registerFormKey.currentState?.save();
                bool result = await _authService.signup(email!, password!);

                if(result){
                  String? pfpURL = await _storageService.uploadUserPfp(
                      file: selectedImage!,
                      uid: _authService.user!.uid,
                  );
                  if(pfpURL != null){
                    await _databaseService.createUserProfile(
                        userProfile: UserProfile(
                            uid: _authService.user!.uid,
                            name: name,
                            pfpURL: pfpURL
                        )
                    );
                    setState(() {
                      _navigationService.goBack();
                      _navigationService.pushReplacementNamed("/home");
                    });
                    _alertService.showToast(
                        text: "User registered successfully!",
                        icon: Icons.done,
                        color: Colors.green
                    );
                  }
                  else{
                    throw Exception("Unable to upload user profile picture");
                  }
                }
                else{
                  throw Exception("Unable to register user");
                }
                print(result);
              }
            }
            catch(e){
              _alertService.showToast(
                  text: "Failed to register, please try again!",
                  icon: Icons.error,
                  color: Colors.red
              );
              print(e);
            }

            setState(() {
              isLoading = false;
            });
          },
        child: const Text(
            "Register",
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
    );
  }

  Widget _loginAccountLink(){
    return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
                "Already have an account?"
            ),
            const SizedBox(
              width: 3,
            ),
            GestureDetector(
              onTap: (){
                _navigationService.goBack();
              },
              child: const Text(
                "Log In",
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