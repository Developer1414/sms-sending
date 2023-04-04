import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  const Chat(
      {super.key, required this.recieverName, required this.recieverPhone});

  final String recieverName;
  final String recieverPhone;

  static TextEditingController textController = TextEditingController();

  Future getMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(recieverPhone)) {
      textController.text = prefs.getString(recieverPhone)!;
    } else {
      textController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    getMessage();
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 67,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: AutoSizeText(
              recieverName,
              minFontSize: 10,
              style: GoogleFonts.roboto(
                  color: Colors.black87,
                  fontSize: 25,
                  fontWeight: FontWeight.w700),
            ),
            leading: IconButton(
                onPressed: () => Get.back(),
                splashRadius: 25,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 28,
                  color: Colors.black87,
                )),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.top,
                    controller: textController,
                    keyboardType: TextInputType.multiline,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    onChanged: (value) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString(recieverPhone, value);

                      if (value.isEmpty) {
                        prefs.remove(recieverPhone);
                      }
                    },
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        hintText: 'Сообщение...',
                        hintStyle: GoogleFonts.roboto(
                            color: Colors.black87.withOpacity(0.5),
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15.0)),
                            borderSide: BorderSide(
                                width: 2.5,
                                color: Colors.black87.withOpacity(0.3))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15.0)),
                            borderSide: BorderSide(
                                width: 2.5,
                                color: Colors.black87.withOpacity(0.5)))),
                    style: GoogleFonts.roboto(
                        color: Colors.black87.withOpacity(0.7),
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Center(
                  child: AutoSizeText(
                    'Введенное сообщение будет автоматически сохранено.',
                    minFontSize: 10,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        color: Colors.black87.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
