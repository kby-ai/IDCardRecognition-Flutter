// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:idsdk_plugin/idsdk_plugin.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';
import 'dart:io' show Platform;
import 'about.dart';
import 'settings.dart';
import 'idcarddetectionview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ID Card Recognition',
        theme: ThemeData(
          // Define the default brightness and colors.
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        home: MyHomePage(title: 'ID Card Recognition'));
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({super.key, required this.title});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String _warningState = "";
  bool _visibleWarning = false;
  var _documentJson;

  final _IDsdkPlugin = IDsdkPlugin();

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    int facepluginState = -1;
    String warningState = "";
    bool visibleWarning = false;

    try {
      if (Platform.isAndroid) {
        await _IDsdkPlugin.setActivation(
                "UBfM4usfgtUNW5IL5ETwdO7nkTHhFrS8ti67jjFgbLoFtsVoYstUSBDU7LYrwQT0Vp1gprTfb3Ci" 
                "+tmRTWnTyBvxM1FghoC6Bq9fsOcCje0DBe3YNeTfrN9V00ubS4xj6JuoRCehNz0qw/WbUCIWiEgJ"
                "uGPX/GU6PFmbng+Ek9cIbCkRuXfozc7NVjkQSfjHGgzzLhF0RLk+hp6fH3JZE15gniVkAsC7HE1W"
                "Rk8jfwie5IORoy0TSm/gDrrG2AknQiC32prF4SqTZgJGHwYm73AtOdy5KHYbV79jDcx17cjYn7yb"
                "q98sQsb6kIrKlayGdDzWeB0WsMpcVeiVUz+atA==")
            .then((value) => facepluginState = value ?? -1);
      } else {
        await _IDsdkPlugin.setActivation(
                "nWsdDhTp12Ay5yAm4cHGqx2rfEv0U+Wyq/tDPopH2yz6RqyKmRU+eovPeDcAp3T3IJJYm2LbPSEz"
                "+e+YlQ4hz+1n8BNlh2gHo+UTVll40OEWkZ0VyxkhszsKN+3UIdNXGaQ6QL0lQunTwfamWuDNx7Ss"
                "efK/3IojqJAF0Bv7spdll3sfhE1IO/m7OyDcrbl5hkT9pFhFA/iCGARcCuCLk4A6r3mLkK57be4r"
                "T52DKtyutnu0PDTzPeaOVZRJdF0eifYXNvhE41CLGiAWwfjqOQOHfKdunXMDqF17s+LFLWwkeNAD"
                "PKMT+F/kRCjnTcC8WPX3bgNzyUBGsFw9fcneKA==")
            .then((value) => facepluginState = value ?? -1);
      }

      if (facepluginState == 0) {
        await _IDsdkPlugin.init()
            .then((value) => facepluginState = value ?? -1);
      }
    } catch (e) {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (facepluginState == -1) {
      warningState = "Invalid license!";
      visibleWarning = true;
    } else if (facepluginState == -2) {
      warningState = "License expired!";
      visibleWarning = true;
    } else if (facepluginState == -3) {
      warningState = "Invalid license!";
      visibleWarning = true;
    } else if (facepluginState == -4) {
      warningState = "No activated!";
      visibleWarning = true;
    } else if (facepluginState == -5) {
      warningState = "Init error!";
      visibleWarning = true;
    }

    setState(() {
      _warningState = warningState;
      _visibleWarning = visibleWarning;
    });
  }

  Future idcardRecognitionFromFile() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      var rotatedImage =
          await FlutterExifRotation.rotateImage(path: image.path);
      final results = await _IDsdkPlugin.idcardRecognition(rotatedImage.path);
      if (results != null) {
        setState(() {
          _documentJson = jsonDecode(results['results'].toString());
        });
      }

      // final faces = await _IDsdkPlugin.extractFaces(rotatedImage.path);
      // for (var face in faces) {
      //   num randomNumber =
      //       10000 + Random().nextInt(10000); // from 0 upto 99 included
      //   Person person = Person(
      //       name: 'Person' + randomNumber.toString(),
      //       faceJpg: face['faceJpg'],
      //       templates: face['templates']);
      //   insertPerson(person);
      // }

      // if (faces.length == 0) {
      //   Fluttertoast.showToast(
      //       msg: "No face detected!",
      //       toastLength: Toast.LENGTH_SHORT,
      //       gravity: ToastGravity.BOTTOM,
      //       timeInSecForIosWeb: 1,
      //       backgroundColor: Colors.red,
      //       textColor: Colors.white,
      //       fontSize: 16.0);
      // } else {
      //   Fluttertoast.showToast(
      //       msg: "Person enrolled!",
      //       toastLength: Toast.LENGTH_SHORT,
      //       gravity: ToastGravity.BOTTOM,
      //       timeInSecForIosWeb: 1,
      //       backgroundColor: Colors.red,
      //       textColor: Colors.white,
      //       fontSize: 16.0);
      // }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('ID Card Recognition'),
          toolbarHeight: 70,
          centerTitle: true,
        ),
        body: ListView(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: const Card(
                  color: Color.fromARGB(255, 0x49, 0x45, 0x4F),
                  child: ListTile(
                    leading: Icon(Icons.tips_and_updates),
                    subtitle: Text(
                      'KBY-AI offers SDKs for face recognition, liveness detection, and id document recognition.',
                      style: TextStyle(fontSize: 13),
                    ),
                  )),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                        label: const Text('Gallery'),
                        icon: const Icon(
                          Icons.person_add,
                          // color: Colors.white70,
                        ),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            // foregroundColor: Colors.white70,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            )),
                        onPressed: idcardRecognitionFromFile),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                        label: const Text('Camera'),
                        icon: const Icon(
                          Icons.person_search,
                        ),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            )),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => IDCardRecognitionView()),
                          );
                        }),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            if (_documentJson != null) JsonViewer(_documentJson)
          ],
        ));
  }
}
