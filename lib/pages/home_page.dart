import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/widgets/chat_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  @override
  void initState(){
    super.initState();

    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
            "Messages",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async{
                bool result = await _authService.logout();

                if(result){
                  _navigationService.pushReplacementNamed("/login");
                  _alertService.showToast(
                      text: "Successfully logged out!",
                      icon: Icons.done,
                    color: Colors.green
                  );
                }
                else{
                  _alertService.showToast(
                      text: "Failed to logout, Please try again!",
                      icon: Icons.error,
                    color: Colors.red
                  );
                }
              },
              color: Colors.white,
              icon: const Icon(
                Icons.logout
              )
          )
        ],
      ),

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
        child: _chatList(),
      ),
    );
  }

  Widget _chatList(){
    return StreamBuilder(
        stream: _databaseService.getUserProfiles(),
        builder: (context, snapshot){
          if(snapshot.hasError){
            return const Center(
              child: Text("Unable to load data."),
            );
          }
          if(snapshot.hasData && snapshot.data != null){
            final users = snapshot.data!.docs;
            return ListView.builder(
              itemCount: users.length,
                itemBuilder: (context, index){
                UserProfile user = users[index].data();
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10
                  ),
                  child: ChatTile(
                      userProfile: user,
                      onTap: () async{
                        final chatExists = await _databaseService.checkChatExists(
                            _authService.user!.uid,
                            user.uid!
                        );
                        if(!chatExists){
                          await _databaseService.createNewChat(_authService.user!.uid, user.uid!);
                        }
                        _navigationService.push(
                            MaterialPageRoute(builder: (context){
                                return ChatPage(chatUser: user);
                            })
                        );
                      }
                  ),
                );
                }
            );
          }
          return Center(
              child: CircularProgressIndicator()
          );
        }
    );
  }

}