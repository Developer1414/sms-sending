import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowMessage extends StatelessWidget {
  const ShowMessage({super.key, required this.message});

  final String message;

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
            'Просмотр сообщения',
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
        body: ListView(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.grey.shade200,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: AutoSizeText(
                    message,
                    minFontSize: 10,
                    style: GoogleFonts.roboto(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
