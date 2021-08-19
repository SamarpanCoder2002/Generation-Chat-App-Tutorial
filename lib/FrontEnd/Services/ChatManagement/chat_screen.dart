import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:loading_overlay/loading_overlay.dart';
import 'package:animations/animations.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:circle_list/circle_list.dart';

class ChatScreen extends StatefulWidget {
  final String userName;

  ChatScreen({Key? key, required this.userName}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isLoading = false;
  bool _writeTextPresent = false;

  final TextEditingController _typedText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
        bottomSheet: _bottomSheet(),
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: const Color.fromRGBO(25, 39, 52, 1),
          elevation: 0.0,
          title: Text(widget.userName),
          leading: Row(
            children: <Widget>[
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: OpenContainer(
                  closedColor: const Color.fromRGBO(25, 39, 52, 1),
                  middleColor: const Color.fromRGBO(25, 39, 52, 1),
                  openColor: const Color.fromRGBO(25, 39, 52, 1),
                  closedShape: CircleBorder(),
                  closedElevation: 0.0,
                  transitionType: ContainerTransitionType.fadeThrough,
                  transitionDuration: Duration(milliseconds: 500),
                  openBuilder: (_, __) {
                    return Center();
                  },
                  closedBuilder: (_, __) {
                    return CircleAvatar(
                      radius: 23.0,
                      backgroundColor: const Color.fromRGBO(25, 39, 52, 1),
                      backgroundImage: ExactAssetImage(
                        "assets/images/google.png",
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.call,
                color: Colors.green,
              ),
            ),
          ],
        ),
        body: LoadingOverlay(
          isLoading: this._isLoading,
          color: Colors.black54,
          child: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            margin: EdgeInsets.all(12.0),
          ),
        ),
      ),
    );
  }

  Widget _bottomSheet() {
    return BottomSheet(
      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
      builder: (BuildContext context) {
        return Container(
          width: double.maxFinite,
          height: 80.0,
          decoration: BoxDecoration(
              color: const Color.fromRGBO(25, 39, 52, 1),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0))),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.emoji_emotions_outlined,
                  color: Colors.amber,
                ),
                onPressed: () {},
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                child: GestureDetector(
                  child: Icon(
                    Entypo.link,
                    color: Colors.lightBlue,
                  ),
                  onTap: _differentChatOptions,
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: double.maxFinite,
                  height: 60.0,
                  child: TextField(
                    controller: this._typedText,
                    style: TextStyle(color: Colors.white),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Type Here...',
                      hintStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.lightBlue, width: 2.0),
                      ),
                    ),
                    onChanged: (writeText) {
                      bool _isEmpty = false;
                      writeText.isEmpty ? _isEmpty = true : _isEmpty = false;

                      if(mounted){
                        setState(() {
                          this._writeTextPresent = !_isEmpty;
                        });
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: GestureDetector(
                  child: this._writeTextPresent
                      ? Icon(
                          Icons.send,
                          color: Colors.green,
                        )
                      : Icon(
                          Icons.keyboard_voice_rounded,
                          color: Colors.green,
                        ),
                  onTap: () {},
                ),
              ),
            ],
          ),
        );
      },
      onClosing: () {},
    );
  }

  void _differentChatOptions() {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      elevation: 0.3,
      backgroundColor: Color.fromRGBO(34, 48, 60, 0.5),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2.7,
        child: Center(
          child: CircleList(
            initialAngle: 55,
            outerRadius: MediaQuery.of(context).size.width / 3.2,
            innerRadius: MediaQuery.of(context).size.width / 10,
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
                  fontSize: 45.0,
                ),
              ),
            ),
            children: [
              Container(
                width: 38,
                height: 38,
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

                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
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

                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
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

                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
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

                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
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

                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
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
    ));
  }
}
