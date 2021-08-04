import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:circle_list/circle_list.dart';

class GeneralMessagingSection extends StatefulWidget {
  const GeneralMessagingSection({Key? key}) : super(key: key);

  @override
  _GeneralMessagingSectionState createState() => _GeneralMessagingSectionState();
}

class _GeneralMessagingSectionState extends State<GeneralMessagingSection> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: CircleList(
              initialAngle: 55,
              outerRadius: MediaQuery.of(context).size.width / 2.2,
              innerRadius: MediaQuery.of(context).size.width / 4,
              showInitialAnimation: true,
              innerCircleColor: Color.fromRGBO(34, 48, 60, 1),
              outerCircleColor: Color.fromRGBO(0, 0, 0, 0.1),
              origin: Offset(0, 0),
              rotateMode: RotateMode.allRotate,
              centerWidget: Center(
                child: Text(
                  "G",
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: 65.0,
                  ),
                ),
              ),
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.blue,
                        width: 3,
                      )),
                  child: GestureDetector(
                    onTap: () async {
                      //_imageOrVideoSend(imageSource: ImageSource.camera);
                    },
                    onLongPress: () async {
                      //_imageOrVideoSend(imageSource: ImageSource.gallery);
                    },
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.lightGreen,
                      size: 30.0,
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.blue,
                        width: 3,
                      )),
                  child: GestureDetector(
                    onTap: () async {
                      // _imageOrVideoSend(
                      //     imageSource: ImageSource.camera, type: 'video');
                    },
                    onLongPress: () async {
                      // _imageOrVideoSend(
                      //     imageSource: ImageSource.gallery, type: 'video');
                    },
                    child: Icon(
                      Icons.video_collection,
                      color: Colors.lightGreen,
                      size: 30.0,
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.blue,
                        width: 3,
                      )),
                  child: GestureDetector(
                    onTap: () async {
                      //_extraTextManagement(MediaTypes.Text);
                    },
                    child: Icon(
                      Icons.text_fields_rounded,
                      color: Colors.lightGreen,
                      size: 30.0,
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.blue,
                        width: 3,
                      )),
                  child: GestureDetector(
                    onTap: () async {
                      //await _documentSend();
                    },
                    child: Icon(
                      Icons.document_scanner_outlined,
                      color: Colors.lightGreen,
                      size: 30.0,
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.blue,
                        width: 3,
                      )),
                  child: GestureDetector(
                    onTap: () async {
                      // if (!await NativeCallback().callToCheckNetworkConnectivity())
                      //   _showDiaLog(titleText: 'No Internet Connection');
                      // else {
                      //   _showDiaLog(titleText: 'Wait for map');
                      //   await _locationSend();
                      // }
                    },
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Colors.lightGreen,
                      size: 30.0,
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.blue,
                        width: 3,
                      )),
                  child: GestureDetector(
                    child: Icon(
                      Icons.music_note_rounded,
                      color: Colors.lightGreen,
                      size: 30.0,
                    ),
                    onTap: () async {
                      //await _voiceSend();
                    },
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
