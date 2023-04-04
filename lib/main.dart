import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:congratulations_app/screens/list_messages.dart';
import 'package:congratulations_app/screens/new_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Appodeal.setAppKeys(
      androidAppKey: 'd015e0d1db2e1ce1e5a9c995693aa7505b333b899c8a5742');

  await Appodeal.initialize(
    hasConsent: true,
    adTypes: [AdType.nonSkippable],
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) {
    initializeDateFormatting('ru_RU', null)
        .then((value) => runApp(const MyApp()));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static RxInt currentIndex = 0.obs;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    var screens = const [NewMessage(), ListMessages()];

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          return snapshot.data?.containsKey('firstEntrance') ?? true
              ? Scaffold(
                  bottomNavigationBar: BottomNavigationBar(
                      unselectedItemColor: Colors.black87.withOpacity(0.5),
                      selectedItemColor: Colors.blueAccent,
                      type: BottomNavigationBarType.fixed,
                      showUnselectedLabels: true,
                      showSelectedLabels: true,
                      iconSize: 30,
                      onTap: (value) {
                        MyApp.currentIndex.value = value;
                        setState(() {});
                      },
                      currentIndex: MyApp.currentIndex.value,
                      items: const [
                        BottomNavigationBarItem(
                            label: 'Новое сообщение',
                            icon: Icon(
                              Icons.send_rounded,
                            )),
                        BottomNavigationBarItem(
                            label: 'История сообщений',
                            icon: Icon(
                              Icons.message_rounded,
                            )),
                      ]),
                  body: screens[MyApp.currentIndex.value],
                )
              : IntroductionScreen(
                  onDone: () async {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    pref.setBool('firstEntrance', true);
                    setState(() {});
                  },
                  onSkip: () async {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    pref.setBool('firstEntrance', true);
                    setState(() {});
                  },
                  showSkipButton: true,
                  skipOrBackFlex: 0,
                  nextFlex: 0,
                  showBackButton: false,
                  back: const Icon(Icons.arrow_back),
                  skip: AutoSizeText(
                    'Пропустить',
                    minFontSize: 10,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        color: Colors.black87.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                  next: const Icon(Icons.arrow_forward),
                  done: AutoSizeText(
                    'Закончить',
                    minFontSize: 10,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        color: Colors.black87.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                  curve: Curves.fastLinearToSlowEaseIn,
                  controlsMargin: const EdgeInsets.all(16),
                  controlsPadding:
                      const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                  dotsDecorator: const DotsDecorator(
                    size: Size(10.0, 10.0),
                    color: Color(0xFFBDBDBD),
                    activeSize: Size(22.0, 10.0),
                    activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                  ),
                  dotsContainerDecorator: ShapeDecoration(
                    color: Colors.black87.withOpacity(0.1),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                  ),
                  pages: [
                    pageViewModel(
                        screenId: 1,
                        bodyText:
                            'Начальный экран, где Вы можете написать сообщение и отправить его всем выбранным контактам. Перед отправкой Вашего сообщения, будет показана короткая реклама, что позволит нам предоставить Вам этот сервис бесплатно. После просмотра рекламы, Ваше сообщение будет отправлено на выбранные контакты.'),
                    pageViewModel(
                        screenId: 2,
                        bodyText:
                            'Но для отправки сообщения, Вам для начала нужно выбрать кому его отправить.'),
                    pageViewModel(
                        screenId: 3,
                        bodyText:
                            'На экране "История сообщений" Вы можете увидеть что, когда и кому Вы отправляли.'),
                    pageViewModel(
                        screenId: 4,
                        bodyText:
                            'Если нажать на сообщение, то увидете его полное содержание.'),
                    pageViewModel(
                        screenId: 5,
                        bodyText:
                            'Также, у Вас есть возможность отправить личное сообщение каждому выбранному контакту.'),
                    pageViewModel(
                        screenId: 6,
                        bodyText:
                            'Но для этого, каждому контакту Вам нужно написать личное сообщение. На этот экран можно попасть нажав на синюю иконку чата на экране "Мои контакты".'),
                  ],
                );
        },
      ),
    );
  }

  PageViewModel pageViewModel({int screenId = 0, String bodyText = ''}) {
    return PageViewModel(
      bodyWidget: AutoSizeText(
        bodyText,
        maxLines: 50,
        minFontSize: 10,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: GoogleFonts.roboto(
            color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      titleWidget: Center(
          child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Colors.blueAccent, width: 5.0)),
        child: Image.asset(
          'lib/assets/screen_$screenId.png',
          scale: 1.8,
        ),
      )),
    );
  }
}
