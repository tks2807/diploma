import 'package:bookit/screens/booking_screen.dart';
import 'package:bookit/screens/done_services_screen.dart';
import 'package:bookit/screens/home_screen.dart';
import 'package:bookit/screens/staff_home_screen.dart';
import 'package:bookit/screens/user_history_screen.dart';
import 'package:bookit/state/state_management.dart';
import 'package:bookit/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auth_ui/flutter_auth_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //Firebase
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // Смена путей приложения
      onGenerateRoute: (settings){
        switch (settings.name){
          case '/home':
            return PageTransition(
                settings: settings,
                child: HomePage(),
                type: PageTransitionType.fade
            );
            break;
          case '/doneServices':
            return PageTransition(
                settings: settings,
                child: DoneService(),
                type: PageTransitionType.fade
            );
            break;
          case '/staffHome':
            return PageTransition(
                settings: settings,
                child: StaffHome(),
                type: PageTransitionType.fade
            );
            break;
          case '/history':
            return PageTransition(
                settings: settings,
                child: UserHistory(),
                type: PageTransitionType.fade
            );
            break;
          case '/booking':
            return PageTransition(
                settings: settings,
                child: BookingScreen(),
                type: PageTransitionType.fade
            );
            break;
          default:
            return null;
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();

  // Логин пользователя
  processLogin(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;

    // Если пользователь не зарегистрирован
    if (user == null) {
      FlutterAuthUi.startUi(
        items: [AuthUiProvider.phone],
        tosAndPrivacyPolicy: TosAndPrivacyPolicy(tosUrl: 'https://google.com', privacyPolicyUrl: 'https://google.com'),
        androidOption: AndroidOption(
            enableSmartLock: false,
            showLogo: true,
            overrideTheme: true
        ),
      ).then((value) async{
        context.read(userLogged).state = FirebaseAuth.instance.currentUser;
        await checkLoginState(context, true, scaffoldState);
      }).catchError((e){
        ScaffoldMessenger.of(scaffoldState.currentContext!).showSnackBar(
            SnackBar(content: Text('${e.toString()}')));
      });
      // Если пользователь зарегеистрирован
    } else {

    }
  }

  // Проверка состояние регистрации пользователя
  Future<LOGIN_STATE> checkLoginState(BuildContext context, bool fromLogin, GlobalKey<ScaffoldState> scaffoldState) async{
    if (!context.read(forceReload).state){
      await Future.delayed(Duration(seconds: fromLogin == true ? 0 : 3)).then((value) =>
      {
        FirebaseAuth.instance.currentUser!
            .getIdToken()
            .then((token) async {
          print('$token');
          context.read(userToken).state = token;

          // Проверка если пользователь есть в система
          CollectionReference userRef = FirebaseFirestore.instance.collection('User');
          DocumentSnapshot snapshotUser = await userRef.doc(FirebaseAuth.instance.currentUser!.phoneNumber).get();

          context.read(forceReload).state = true;
          if (snapshotUser.exists) {
            // Если пользователь в системе -> переход на главную
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            //Если пользователь не в системе
          } else {
            var nameController = TextEditingController();
            var emailController = TextEditingController();
            // Окно для заполнения личных данных
            Alert(
                context: context,
                title: 'Заполните информацию',
                content: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.account_circle),
                        labelText: 'Имя',
                      ),
                      controller: nameController,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.email),
                        labelText: 'Эл.Почта',
                      ),
                      controller: emailController,
                    ),
                  ],
                ),
                buttons: [
                  DialogButton(
                    child: Text('ОТМЕНА'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  DialogButton(
                      child: Text('ОБНОВИТЬ'),
                      onPressed: () {
                        userRef.doc(FirebaseAuth.instance.currentUser!.phoneNumber).set({
                          'name': nameController.text,
                          'email': emailController.text,
                        }).then((value) async {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(scaffoldState.currentContext!).showSnackBar(
                              SnackBar(
                                content: Text('Профиль обновлен успешно!'),
                              )
                          );
                          await Future.delayed(Duration(seconds: 1), (){
                            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                          });
                        }).catchError((e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(scaffoldState.currentContext!).showSnackBar(
                              SnackBar(
                                content: Text('{$e}'),
                              )
                          );
                        });
                      }
                  )
                ]
            ).show();
          }
        })
      });
    }
    return FirebaseAuth.instance.currentUser != null
        ? LOGIN_STATE.LOGGED
        : LOGIN_STATE.NOT_LOGIN;
  }


  @override
  Widget build(BuildContext context, watch) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldState,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bookit_bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                  padding: const EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width,
                  child: FutureBuilder(
                      future: checkLoginState(context, false, scaffoldState),
                      builder: (context, snapshot){
                        if (snapshot.connectionState == ConnectionState.waiting){
                          return Center(child: CircularProgressIndicator(),);
                        } else {
                          var userState = snapshot.data as LOGIN_STATE?;
                          if (userState == LOGIN_STATE.LOGGED){
                            return Container();
                          } else {
                            return ElevatedButton.icon(
                              onPressed: () => processLogin(context),
                              icon: Icon(Icons.phone),
                              label: Text('Зарегестрируйтесь через телефон'),
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                            );
                          }
                        }
                      }
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}
