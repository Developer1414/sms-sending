import 'package:auto_size_text/auto_size_text.dart';
import 'package:congratulations_app/models/loading_model.dart';
import 'package:congratulations_app/models/message_model.dart';
import 'package:congratulations_app/screens/show_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListMessages extends StatefulWidget {
  const ListMessages({super.key});

  static List<Message> messages = [];

  @override
  State<ListMessages> createState() => _ListMessagesState();
}

class _ListMessagesState extends State<ListMessages> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 67,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: AutoSizeText(
            'История сообщений',
            minFontSize: 10,
            style: GoogleFonts.roboto(
                color: Colors.black87,
                fontSize: 25,
                fontWeight: FontWeight.w700),
          ),
        ),
        body: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return loading();
            }

            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data!.containsKey('messages')) {
                ListMessages.messages =
                    Message.decode(snapshot.data!.getString('messages')!);
              }
            }

            return ListMessages.messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: AutoSizeText(
                        'Вы ещё не отправили ни одного сообщения',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                            color: Colors.black87.withOpacity(0.5),
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: ListMessages.messages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Material(
                          clipBehavior: Clip.antiAlias,
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.grey.shade200,
                          child: InkWell(
                            onTap: () => Get.to(() => ShowMessage(
                                message:
                                    ListMessages.messages[index].messages)),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AutoSizeText(
                                        ListMessages.messages[index].userName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.roboto(
                                            color: Colors.black87,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      AutoSizeText(
                                        ListMessages.messages[index].date,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.roboto(
                                            color: Colors.black87,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5.0),
                                  AutoSizeText(
                                    ListMessages.messages[index].messages,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.roboto(
                                        color: Colors.black87.withOpacity(0.7),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10.0));
          },
        ),
      ),
    );
  }
}
