import 'package:auto_size_text/auto_size_text.dart';
import 'package:congratulations_app/models/loading_model.dart';
import 'package:congratulations_app/screens/chat.dart';
import 'package:congratulations_app/screens/new_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MyContacts extends StatefulWidget {
  const MyContacts({super.key});

  @override
  State<MyContacts> createState() => _MyContactsState();
}

class _MyContactsState extends State<MyContacts> {
  static RxBool isLoading = false.obs;
  static List<Contact> allContacts = [];

  Future getAllContacts() async {
    isLoading.value = true;

    allContacts = await FlutterContacts.getContacts(withProperties: true);

    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    getAllContacts();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Obx(
        () => isLoading.value
            ? loading()
            : Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  toolbarHeight: 67,
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  title: AutoSizeText(
                    'Мои контакты',
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
                  actions: [
                    Obx(
                      () => Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: IconButton(
                            onPressed: () async {
                              if (NewMessage.contacts.isNotEmpty) {
                                NewMessage.contacts.clear();
                              } else {
                                for (int i = 0; i < allContacts.length; i++) {
                                  for (int f = 0;
                                      f < allContacts[i].phones.length;
                                      f++) {
                                    NewMessage.contacts.addAll({
                                      allContacts[i]
                                              .phones[f]
                                              .normalizedNumber
                                              .replaceAll('(', '')
                                              .replaceAll(')', ''):
                                          allContacts[i].displayName
                                    });
                                  }
                                }
                              }
                            },
                            splashRadius: 25,
                            icon: Icon(
                              NewMessage.contacts.isEmpty
                                  ? Icons.select_all_rounded
                                  : Icons.cancel_rounded,
                              size: 28,
                              color: NewMessage.contacts.isEmpty
                                  ? Colors.blueAccent
                                  : Colors.redAccent,
                            )),
                      ),
                    ),
                  ],
                ),
                body: ListView.builder(
                  itemCount: allContacts.length,
                  itemBuilder: (context, index) {
                    String contact = allContacts[index]
                        .phones
                        .map((e) => e.normalizedNumber)
                        .toString()
                        .replaceAll('(', '')
                        .replaceAll(')', '');

                    return allContacts[index].phones.isEmpty
                        ? Container()
                        : Obx(
                            () => Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0, bottom: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: NewMessage.contacts.keys
                                              .contains(contact)
                                          ? Colors.blue
                                          : Colors.transparent,
                                      width: 2.5),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Material(
                                  clipBehavior: Clip.antiAlias,
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.grey.shade200,
                                  child: InkWell(
                                    onTap: () {
                                      if (contact.isNotEmpty) {
                                        if (NewMessage.contacts.keys
                                            .contains(contact)) {
                                          NewMessage.contacts.removeWhere(
                                              (key, value) => key == contact);
                                        } else {
                                          NewMessage.contacts.addAll({
                                            contact:
                                                allContacts[index].displayName
                                          });
                                        }
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              AutoSizeText(
                                                allContacts[index].displayName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.roboto(
                                                    color: Colors.black87,
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              const SizedBox(height: 5.0),
                                              AutoSizeText(
                                                allContacts[index]
                                                    .phones
                                                    .map((e) => e.number)
                                                    .toString()
                                                    .replaceAll('(', '')
                                                    .replaceAll(')', ''),
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.roboto(
                                                    color: Colors.black87
                                                        .withOpacity(0.7),
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                              onPressed: () => Get.to(() =>
                                                  Chat(
                                                      recieverName:
                                                          allContacts[index]
                                                              .displayName,
                                                      recieverPhone: contact)),
                                              splashRadius: 25,
                                              icon: const Icon(
                                                Icons.chat_outlined,
                                                size: 28,
                                                color: Colors.blueAccent,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                  },
                )),
      ),
    );
  }
}
