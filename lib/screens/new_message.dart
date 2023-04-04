import 'package:auto_size_text/auto_size_text.dart';
import 'package:congratulations_app/models/button_model.dart';
import 'package:congratulations_app/models/dialog.dart';
import 'package:congratulations_app/models/loading_model.dart';
import 'package:congratulations_app/models/message_model.dart';
import 'package:congratulations_app/screens/list_messages.dart';
import 'package:congratulations_app/screens/my_contacts.dart';
import 'package:congratulations_app/services/ad_service.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_advanced/sms_advanced.dart';

Future saveMessage({String userName = '', String messages = ''}) async {
  Message message = Message(
      userName: userName,
      messages: messages,
      date: DateFormat.MMMd('ru_RU').add_jm().format(
            DateTime.parse(DateTime.now().toString()),
          ));

  SharedPreferences prefs = await SharedPreferences.getInstance();

  ListMessages.messages.add(message);

  String json = Message.encode(ListMessages.messages);

  await prefs.setString('messages', json).whenComplete(() {
    ListMessages.messages = Message.decode(prefs.getString('messages')!);
  });
}

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  static RxMap contacts = {}.obs;
  static RxBool isLoading = false.obs;
  static String selectedItem = '';
  static List<String> items = [
    'Отправить вышеуказанное сообщение всем выбранным контактам',
    'Отправить каждому выбранному контакту личное сообщение, которое Вы для него написали'
  ];
  static TextEditingController textController = TextEditingController();

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  @override
  void initState() {
    super.initState();
    NewMessage.selectedItem = NewMessage.items.first;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Obx(
          () => NewMessage.isLoading.value
              ? loading()
              : Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    elevation: 0,
                    toolbarHeight: 67,
                    backgroundColor: Colors.transparent,
                    centerTitle: true,
                    title: AutoSizeText(
                      'Новое сообщение',
                      minFontSize: 10,
                      style: GoogleFonts.roboto(
                          color: Colors.black87,
                          fontSize: 25,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 60.0,
                            child: DropdownSearch<String>(
                              popupProps: const PopupProps.menu(
                                showSelectedItems: true,
                              ),
                              items: NewMessage.items,
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                baseStyle: GoogleFonts.roboto(
                                    color: Colors.black87.withOpacity(0.7),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700),
                                dropdownSearchDecoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15.0)),
                                      borderSide: BorderSide(
                                          width: 2.0,
                                          color: const Color.fromARGB(
                                                  255, 99, 99, 99)
                                              .withOpacity(0.4))),
                                  focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0)),
                                      borderSide: BorderSide(
                                          width: 2.0,
                                          color:
                                              Color.fromARGB(255, 99, 99, 99))),
                                  labelText: "Кому отправить",
                                ),
                              ),
                              onChanged: (text) {
                                NewMessage.selectedItem = text!;

                                setState(() {});
                              },
                              selectedItem: NewMessage.selectedItem,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: customButton(
                              onTap: () async {
                                if (await Permission.sms.request().isGranted) {
                                  AdService().showNonSkippableAd(() async {
                                    SmsSender sender = SmsSender();

                                    if (NewMessage.selectedItem ==
                                        NewMessage.items.first) {
                                      if (NewMessage.contacts.isEmpty ||
                                          NewMessage
                                              .textController.text.isEmpty) {
                                        return;
                                      }

                                      NewMessage.isLoading.value = true;

                                      NewMessage.contacts
                                          .forEach((key, value) async {
                                        await sender
                                            .sendSms(SmsMessage(
                                                key,
                                                NewMessage.textController.text
                                                    .replaceAll(
                                                        '{name}', value)))
                                            .whenComplete(() async {
                                          await saveMessage(
                                              userName: value,
                                              messages: NewMessage
                                                  .textController.text
                                                  .replaceAll('{name}', value));
                                        });
                                      });
                                    } else {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();

                                      List<String> canceledUsers = [];

                                      NewMessage.contacts
                                          .forEach((key, value) async {
                                        if (!prefs.containsKey(key)) {
                                          canceledUsers.add(value);
                                        }
                                      });

                                      if (canceledUsers.isEmpty) {
                                        NewMessage.contacts
                                            .forEach((key, value) async {
                                          await sender
                                              .sendSms(SmsMessage(
                                                  key, prefs.getString(key)!))
                                              .whenComplete(() async {
                                            await saveMessage(
                                                userName: value,
                                                messages:
                                                    prefs.getString(key)!);
                                          });
                                        });

                                        dialog(
                                            title: 'Успех!',
                                            content: NewMessage
                                                        .contacts.length ==
                                                    1
                                                ? 'Сообщение успешно отправлено!'
                                                : 'Сообщения успешно отправлены!');
                                      } else {
                                        dialog(
                                            title: 'Ошибка',
                                            content: canceledUsers.length == 1
                                                ? 'Контакту $canceledUsers не было отправлено сообщение, т.к. оно для него не написано.'
                                                : 'Контактам $canceledUsers не были отправлены сообщения, т.к. они для них не написаны.',
                                            isError: true);
                                      }
                                    }

                                    NewMessage.isLoading.value = false;
                                  });
                                }
                              },
                              color: Colors.green,
                              borderRadius: 15.0,
                              textSize: 20,
                              maxLines: 2,
                              text: 'Отправить'),
                        ),
                      ],
                    ),
                  ),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        NewMessage.selectedItem != NewMessage.items.first
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Stack(
                            clipBehavior: Clip.none,
                            alignment: AlignmentDirectional.topEnd,
                            children: [
                              Material(
                                borderRadius: BorderRadius.circular(15.0),
                                color: NewMessage.contacts.isEmpty
                                    ? Colors.blueAccent
                                    : Colors.grey.shade200,
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () async {
                                    if (await Permission.contacts
                                        .request()
                                        .isGranted) {
                                      Get.to(() => const MyContacts());
                                    }
                                  },
                                  child: SizedBox(
                                    height: 60.0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Obx(() => NewMessage
                                              .contacts.isEmpty
                                          ? Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.contacts_rounded,
                                                    color: Colors.white,
                                                    size: 25.0,
                                                  ),
                                                  const SizedBox(width: 10.0),
                                                  AutoSizeText(
                                                    'Выберите получателей',
                                                    minFontSize: 10,
                                                    style: GoogleFonts.roboto(
                                                        color: Colors.white,
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : ListView.separated(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  NewMessage.contacts.length,
                                              itemBuilder: (context, index) {
                                                return Chip(
                                                    label: AutoSizeText(
                                                  '${NewMessage.contacts.values.toList()[index] ?? 'Null'} (${NewMessage.contacts.keys.toList()[index] ?? 'Null'})',
                                                  minFontSize: 10,
                                                  style: GoogleFonts.roboto(
                                                      color: Colors.black87,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ));
                                              },
                                              separatorBuilder: (context,
                                                      index) =>
                                                  const SizedBox(width: 5.0))),
                                    ),
                                  ),
                                ),
                              ),
                              NewMessage.contacts.isEmpty
                                  ? Container()
                                  : Positioned(
                                      bottom: 45.0,
                                      right: -10.0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            borderRadius:
                                                BorderRadius.circular(25.0)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: AutoSizeText(
                                            'x${NewMessage.contacts.length}',
                                            minFontSize: 10,
                                            style: GoogleFonts.roboto(
                                                color: Colors.white,
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                    ),
                            ]),
                      ),
                      NewMessage.selectedItem != NewMessage.items.first
                          ? Container()
                          : Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 15.0, right: 15.0),
                                child: TextField(
                                  textAlignVertical: TextAlignVertical.top,
                                  controller: NewMessage.textController,
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  expands: true,
                                  maxLines: null,
                                  minLines: null,
                                  decoration: InputDecoration(
                                      hintText: 'Сообщение...',
                                      hintStyle: GoogleFonts.roboto(
                                          color:
                                              Colors.black87.withOpacity(0.5),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(15.0)),
                                          borderSide: BorderSide(
                                              width: 2.5,
                                              color: Colors.black87
                                                  .withOpacity(0.3))),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(15.0)),
                                          borderSide: BorderSide(
                                              width: 2.5,
                                              color: Colors.black87
                                                  .withOpacity(0.5)))),
                                  style: GoogleFonts.roboto(
                                      color: Colors.black87.withOpacity(0.7),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                      NewMessage.selectedItem != NewMessage.items.first
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0, top: 15.0),
                              child: AutoSizeText(
                                'Вы можете использовать команду "{name}", чтобы отправить всем сообщение с их именем. Пример: "Привет, {name}!"',
                                minFontSize: 10,
                                style: GoogleFonts.roboto(
                                    color: Colors.black87.withOpacity(0.5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
