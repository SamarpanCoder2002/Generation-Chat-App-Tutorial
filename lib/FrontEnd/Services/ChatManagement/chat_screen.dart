import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:animations/animations.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:circle_list/circle_list.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:generation/Global_Uses/native_calling.dart';
import 'package:generation/Global_Uses/show_toast_message.dart';
import 'package:generation/Global_Uses/enum_generation.dart';
import 'package:generation/FrontEnd/Preview/image_preview_screen.dart';

class ChatScreen extends StatefulWidget {
  final String userName;

  ChatScreen({Key? key, required this.userName}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isLoading = false;
  bool _writeTextPresent = false;
  bool _lastDirection = false;
  bool _showEmojiPicker = false;

  final FToast _fToast = FToast();

  List<Map<String, String>> _allConversationMessages = [
    {"Samarpan Dasgupta": "19:0"},
    {"Amitava Garai": "20:0"},
  ];
  List<bool> _conversationMessageHolder = [true, false];
  List<ChatMessageTypes> _chatMessageCategoryHolder = [
    ChatMessageTypes.Text,
    ChatMessageTypes.Text,
  ];

  final TextEditingController _typedText = TextEditingController();

  final NativeCallback _nativeCallback = NativeCallback();

  /// Audio Player and Dio Downloader Initialized
  final AudioPlayer _justAudioPlayer = AudioPlayer();

  final Record _record = Record();

  /// Some Integer Value Initialized
  late double _currAudioPlayingTime;
  int _lastAudioPlayingIndex = 0;

  double _audioPlayingSpeed = 1.0;

  /// Audio Playing Time Related
  String _totalDuration = '0:00';
  String _loadingTime = '0:00';

  double _chatBoxHeight = 0.0;

  String _hintText = "Type Here...";

  late Directory _audioDirectory;

  /// For Audio Player
  IconData _iconData = Icons.play_arrow_rounded;

  _takePermissionForStorage() async {
    var status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      {
        showToast("Thanks For Storage Permission", _fToast,
            toastColor: Colors.green, fontSize: 16.0);

        _makeDirectoryForRecordings();
      }
    } else {
      showToast("Some Problem May Be Arrive", _fToast,
          toastColor: Colors.green, fontSize: 16.0);
    }
  }

  _makeDirectoryForRecordings() async {
    final Directory? directory = await getExternalStorageDirectory();

    _audioDirectory = await Directory(directory!.path + '/Recordings/')
        .create(); // This directory will create Once in whole Application
  }

  @override
  void initState() {
    _fToast.init(context);

    _takePermissionForStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this._chatBoxHeight = MediaQuery.of(context).size.height - 160;

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          if (this._showEmojiPicker) {
            if (mounted) {
              setState(() {
                this._showEmojiPicker = false;
                this._chatBoxHeight += 300;
              });
            }
            return false;
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
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
              //margin: EdgeInsets.all(12.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    width: double.maxFinite,
                    height: this._chatBoxHeight,
                    padding: EdgeInsets.only(top: 20.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: this._allConversationMessages.length,
                      itemBuilder: (itemBuilderContext, index) {
                        if (this._chatMessageCategoryHolder[index] ==
                            ChatMessageTypes.Text)
                          return _textConversationManagement(
                              itemBuilderContext, index);
                        else if (this._chatMessageCategoryHolder[index] ==
                            ChatMessageTypes.Image)
                          return _mediaConversationManagement(
                              itemBuilderContext, index);
                        else if (this._chatMessageCategoryHolder[index] ==
                            ChatMessageTypes.Video)
                          return _mediaConversationManagement(
                              itemBuilderContext, index);
                        else if (this._chatMessageCategoryHolder[index] ==
                            ChatMessageTypes.Document)
                          return _documentConversationManagement(
                              itemBuilderContext, index);
                        else if (this._chatMessageCategoryHolder[index] ==
                            ChatMessageTypes.Location)
                          return _locationConversationManagement(
                              itemBuilderContext, index);
                        else if (this._chatMessageCategoryHolder[index] ==
                            ChatMessageTypes.Audio)
                          return _audioConversationManagement(
                              itemBuilderContext, index);
                        return Center();
                      },
                    ),
                  ),
                  _bottomInsertionPortion(context),
                  this._showEmojiPicker
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 300.0,
                          child: EmojiPicker(
                            onEmojiSelected: (category, emoji) {
                              if (mounted) {
                                setState(() {
                                  this._typedText.text += emoji.emoji;
                                  this._typedText.text.isEmpty
                                      ? this._writeTextPresent = false
                                      : this._writeTextPresent = true;
                                });
                              }
                            },
                            onBackspacePressed: () {
                              // Backspace-Button tapped logic
                              // Remove this line to also remove the button in the UI
                            },
                            config: Config(
                                columns: 7,
                                emojiSizeMax: 32.0,
                                verticalSpacing: 0,
                                horizontalSpacing: 0,
                                initCategory: Category.RECENT,
                                bgColor: Color(0xFFF2F2F2),
                                indicatorColor: Colors.blue,
                                iconColor: Colors.grey,
                                iconColorSelected: Colors.blue,
                                progressIndicatorColor: Colors.blue,
                                showRecentsTab: true,
                                recentsLimit: 28,
                                noRecentsText: "No Recents",
                                noRecentsStyle: const TextStyle(
                                    fontSize: 20, color: Colors.black26),
                                categoryIcons: const CategoryIcons(),
                                buttonMode: ButtonMode.MATERIAL),
                          ),
                        )
                      : SizedBox()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _differentChatOptions() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
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
                            final pickedImage = await ImagePicker().pickImage(
                                source: ImageSource.camera, imageQuality: 50);
                            if (pickedImage != null) {
                              _addSelectedMediaToChat(pickedImage.path);
                            }
                          },
                          onLongPress: () async {
                            final XFile? pickedImage = await ImagePicker()
                                .pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 50);
                            if (pickedImage != null) {
                              _addSelectedMediaToChat(pickedImage.path);
                            }
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
                            if (mounted) {
                              setState(() {
                                this._isLoading = true;
                              });
                            }

                            final pickedVideo = await ImagePicker().pickVideo(
                                source: ImageSource.camera,
                                maxDuration: Duration(seconds: 15));

                            if (pickedVideo != null) {
                              final String thumbnailPathTake =
                                  await _nativeCallback.getTheVideoThumbnail(
                                      videoPath: pickedVideo.path);

                              _addSelectedMediaToChat(pickedVideo.path,
                                  chatMessageTypeTake: ChatMessageTypes.Video,
                                  thumbnailPath: thumbnailPathTake);
                            }

                            if (mounted) {
                              setState(() {
                                this._isLoading = false;
                              });
                            }
                          },
                          onLongPress: () async {
                            if (mounted) {
                              setState(() {
                                this._isLoading = true;
                              });
                            }

                            final pickedVideo = await ImagePicker().pickVideo(
                                source: ImageSource.gallery,
                                maxDuration: Duration(seconds: 15));

                            if (pickedVideo != null) {
                              final String thumbnailPathTake =
                                  await _nativeCallback.getTheVideoThumbnail(
                                      videoPath: pickedVideo.path);

                              _addSelectedMediaToChat(pickedVideo.path,
                                  chatMessageTypeTake: ChatMessageTypes.Video,
                                  thumbnailPath: thumbnailPathTake);
                            }

                            if (mounted) {
                              setState(() {
                                this._isLoading = false;
                              });
                            }
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
                            await _pickFileFromStorage();
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
                            final PermissionStatus locationPermissionStatus =
                                await Permission.location.request();
                            if (locationPermissionStatus ==
                                PermissionStatus.granted) {
                              await _takeLocationInput();
                            } else {
                              showToast(
                                  "Location Permission Required", this._fToast);
                            }
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
                            final List<String> _allowedExtensions = const [
                              'mp3',
                              'm4a',
                              'wav',
                              'ogg',
                            ];

                            final FilePickerResult? _audioFilePickerResult =
                                await FilePicker.platform.pickFiles(
                              type: FileType.audio,
                            );

                            Navigator.pop(context);

                            if (_audioFilePickerResult != null) {
                              _audioFilePickerResult.files.forEach((element) {
                                print('Name: ${element.path}');
                                print('Extension: ${element.extension}');
                                if (_allowedExtensions
                                    .contains(element.extension)) {
                                  _voiceSend(element.path.toString(),
                                      audioExtension: '.${element.extension}');
                                } else {
                                  _voiceSend(element.path.toString());
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  Widget _timeReFormat(String _willReturnTime) {
    if (int.parse(_willReturnTime.split(':')[0]) < 10)
      _willReturnTime = _willReturnTime.replaceRange(
          0, _willReturnTime.indexOf(':'), '0${_willReturnTime.split(':')[0]}');

    if (int.parse(_willReturnTime.split(':')[1]) < 10)
      _willReturnTime = _willReturnTime.replaceRange(
          _willReturnTime.indexOf(':') + 1,
          _willReturnTime.length,
          '0${_willReturnTime.split(':')[1]}');

    return Text(
      _willReturnTime,
      style: const TextStyle(color: Colors.lightBlue),
    );
  }

  Widget _bottomInsertionPortion(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 80.0,
      decoration: BoxDecoration(
          color: const Color.fromRGBO(25, 39, 52, 1),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.emoji_emotions_outlined,
              color: Colors.amber,
            ),
            onPressed: () {
              print('Clicked Emoji');
              if (mounted) {
                setState(() {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  this._showEmojiPicker = true;
                  this._chatBoxHeight -= 300;
                });
              }
            },
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
                  hintText: _hintText,
                  hintStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
                  ),
                ),
                onTap: () {
                  if (mounted) {
                    setState(() {
                      this._chatBoxHeight += 300;
                      this._showEmojiPicker = false;
                    });
                  }
                },
                onChanged: (writeText) {
                  bool _isEmpty = false;
                  writeText.isEmpty ? _isEmpty = true : _isEmpty = false;

                  if (mounted) {
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
                      size: 30.0,
                    )
                  : Icon(
                      Icons.keyboard_voice_rounded,
                      color: Colors.green,
                      size: 30.0,
                    ),
              onTap: this._writeTextPresent ? _sendText : _voiceTake,
            ),
          ),
        ],
      ),
    );
  }

  Widget _textConversationManagement(
      BuildContext itemBuilderContext, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          margin: this._conversationMessageHolder[index]
              ? EdgeInsets.only(
                  right: MediaQuery.of(context).size.width / 3,
                  left: 5.0,
                )
              : EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 3,
                  right: 5.0,
                ),
          alignment: this._conversationMessageHolder[index]
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: this._conversationMessageHolder[index]
                  ? Color.fromRGBO(60, 80, 100, 1)
                  : Color.fromRGBO(102, 102, 255, 1),
              elevation: 0.0,
              padding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: this._conversationMessageHolder[index]
                      ? Radius.circular(0.0)
                      : Radius.circular(20.0),
                  topRight: this._conversationMessageHolder[index]
                      ? Radius.circular(20.0)
                      : Radius.circular(0.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
            ),
            child: Text(
              this._allConversationMessages[index].keys.first,
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
            onPressed: () {},
            onLongPress: () {},
          ),
        ),
        _conversationMessageTime(
            this._allConversationMessages[index].values.first, index),
      ],
    );
  }

  Widget _mediaConversationManagement(
      BuildContext itemBuilderContext, int index) {
    return Column(
      children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.3,
            margin: this._conversationMessageHolder[index]
                ? EdgeInsets.only(
                    right: MediaQuery.of(context).size.width / 3,
                    left: 5.0,
                    top: 30.0,
                  )
                : EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 3,
                    right: 5.0,
                    top: 15.0,
                  ),
            alignment: this._conversationMessageHolder[index]
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: OpenContainer(
              openColor: const Color.fromRGBO(60, 80, 100, 1),
              closedColor: this._conversationMessageHolder[index]
                  ? const Color.fromRGBO(60, 80, 100, 1)
                  : const Color.fromRGBO(102, 102, 255, 1),
              middleColor: Color.fromRGBO(60, 80, 100, 1),
              closedElevation: 0.0,
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              transitionDuration: Duration(
                milliseconds: 400,
              ),
              transitionType: ContainerTransitionType.fadeThrough,
              openBuilder: (context, openWidget) {
                return ImageViewScreen(
                  imagePath: this._chatMessageCategoryHolder[index] ==
                          ChatMessageTypes.Image
                      ? this._allConversationMessages[index].keys.first
                      : this
                          ._allConversationMessages[index]
                          .keys
                          .first
                          .split("+")[0],
                  imageProviderCategory: ImageProviderCategory.FileImage,
                );
              },
              closedBuilder: (context, closeWidget) => Stack(
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: PhotoView(
                      imageProvider: FileImage(File(
                          this._chatMessageCategoryHolder[index] ==
                                  ChatMessageTypes.Image
                              ? this._allConversationMessages[index].keys.first
                              : this
                                  ._allConversationMessages[index]
                                  .keys
                                  .first
                                  .split("+")[0])),
                      loadingBuilder: (context, event) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorBuilder: (context, obj, stackTrace) => Center(
                          child: Text(
                        'Image not Found',
                        style: TextStyle(
                          fontSize: 23.0,
                          color: Colors.red,
                          fontFamily: 'Lora',
                          letterSpacing: 1.0,
                        ),
                      )),
                      enableRotation: true,
                      minScale: PhotoViewComputedScale.covered,
                    ),
                  ),
                  if (this._chatMessageCategoryHolder[index] ==
                      ChatMessageTypes.Video)
                    Center(
                      child: IconButton(
                        iconSize: 100.0,
                        icon: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          print(
                              "Opening Path is: ${this._allConversationMessages[index].keys.first.split("+")[1]}");

                          final OpenResult openResult = await OpenFile.open(this
                              ._allConversationMessages[index]
                              .keys
                              .first
                              .split("+")[1]);

                          openFileResultStatus(openResult: openResult);
                        },
                      ),
                    ),
                ],
              ),
            )),
        _conversationMessageTime(
            this._allConversationMessages[index].values.first.split("+")[0],
            index),
      ],
    );
  }

  Widget _conversationMessageTime(String time, int index) {
    return Container(
      alignment: this._conversationMessageHolder[index]
          ? Alignment.centerLeft
          : Alignment.centerRight,
      margin: this._conversationMessageHolder[index]
          ? const EdgeInsets.only(
              left: 5.0,
              bottom: 5.0,
              top: 5.0,
            )
          : const EdgeInsets.only(
              right: 5.0,
              bottom: 5.0,
              top: 5.0,
            ),
      child: _timeReFormat(time),
    );
  }

  void _addSelectedMediaToChat(String path,
      {ChatMessageTypes chatMessageTypeTake = ChatMessageTypes.Image,
      String thumbnailPath = ''}) {
    Navigator.pop(context);

    print('Thumbnail Path: $thumbnailPath    ${File(path).path}');

    final String _messageTime =
        "${DateTime.now().hour}:${DateTime.now().minute}";

    if (mounted) {
      setState(() {
        this._allConversationMessages.add({
          chatMessageTypeTake == ChatMessageTypes.Image
              ? File(path).path
              : "$thumbnailPath+${File(path).path}": _messageTime,
        });

        this._chatMessageCategoryHolder.add(
            chatMessageTypeTake == ChatMessageTypes.Image
                ? ChatMessageTypes.Image
                : ChatMessageTypes.Video);

        this._conversationMessageHolder.add(this._lastDirection);
        this._lastDirection = !this._lastDirection;
      });
    }
  }

  void openFileResultStatus({required OpenResult openResult}) {
    if (openResult.type == ResultType.permissionDenied)
      showToast('Permission Denied to Open File', _fToast,
          toastColor: Colors.red, fontSize: 16.0);
    else if (openResult.type == ResultType.noAppToOpen)
      showToast('No App Found to Open', _fToast,
          toastColor: Colors.amber, fontSize: 16.0);
    else if (openResult.type == ResultType.error)
      showToast('Error in Opening File', _fToast,
          toastColor: Colors.red, fontSize: 16.0);
    else if (openResult.type == ResultType.fileNotFound)
      showToast('Sorry, File Not Found', _fToast,
          toastColor: Colors.red, fontSize: 16.0);
  }

  Widget _documentConversationManagement(
      BuildContext itemBuilderContext, int index) {
    return Column(
      children: [
        Container(
            height:
                this._allConversationMessages[index].keys.first.contains('.pdf')
                    ? MediaQuery.of(context).size.height * 0.3
                    : 70.0,
            margin: this._conversationMessageHolder[index]
                ? EdgeInsets.only(
                    right: MediaQuery.of(context).size.width / 3,
                    left: 5.0,
                    top: 30.0,
                  )
                : EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 3,
                    right: 5.0,
                    top: 15.0,
                  ),
            alignment: this._conversationMessageHolder[index]
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: this
                        ._allConversationMessages[index]
                        .keys
                        .first
                        .contains('.pdf')
                    ? Colors.white
                    : this._conversationMessageHolder[index]
                        ? const Color.fromRGBO(60, 80, 100, 1)
                        : const Color.fromRGBO(102, 102, 255, 1),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: this
                      ._allConversationMessages[index]
                      .keys
                      .first
                      .contains('.pdf')
                  ? Stack(
                      children: [
                        Center(
                            child: Text(
                          'Loading Error',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            color: Colors.red,
                            fontSize: 20.0,
                            letterSpacing: 1.0,
                          ),
                        )),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: PdfView(
                            path:
                                this._allConversationMessages[index].keys.first,
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            child: Icon(
                              Icons.open_in_new_rounded,
                              size: 40.0,
                              color: Colors.blue,
                            ),
                            onTap: () async {
                              final OpenResult openResult = await OpenFile.open(
                                  this
                                      ._allConversationMessages[index]
                                      .keys
                                      .first);

                              openFileResultStatus(openResult: openResult);
                            },
                          ),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () async {
                        final OpenResult openResult = await OpenFile.open(
                            this._allConversationMessages[index].keys.first);

                        openFileResultStatus(openResult: openResult);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 20.0,
                          ),
                          Icon(
                            Entypo.documents,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          Expanded(
                            child: Text(
                              this
                                  ._allConversationMessages[index]
                                  .keys
                                  .first
                                  .split("/")
                                  .last,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Lora',
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            )),
        _conversationMessageTime(
            this._allConversationMessages[index].values.first, index),
      ],
    );
  }

  Future<void> _pickFileFromStorage() async {
    List<String> _allowedExtensions = [
      'pdf',
      'doc',
      'docx',
      'ppt',
      'pptx',
      'c',
      'cpp',
      'py',
      'text'
    ];

    try {
      if (!await Permission.storage.isGranted) _takePermissionForStorage();

      final FilePickerResult? filePickerResult =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );

      if (filePickerResult != null && filePickerResult.files.length > 0) {
        Navigator.pop(context);

        filePickerResult.files.forEach((file) async {
          print(file.path);

          if (_allowedExtensions.contains(file.extension)) {
            final String _messageTime =
                "${DateTime.now().hour}:${DateTime.now().minute}";

            if (mounted) {
              setState(() {
                this._allConversationMessages.add({
                  File(file.path.toString()).path: _messageTime,
                });

                this._chatMessageCategoryHolder.add(ChatMessageTypes.Document);
                this._conversationMessageHolder.add(this._lastDirection);
                this._lastDirection = !this._lastDirection;
              });
            }
          } else {
            showToast(
              'Not Supporting Document Format',
              this._fToast,
              toastColor: Colors.red,
              fontSize: 16.0,
            );
          }
        });
      }
    } catch (e) {
      showToast(
        'Some Error Happened',
        this._fToast,
        toastColor: Colors.red,
        fontSize: 16.0,
      );
    }
  }

  Widget _locationConversationManagement(
      BuildContext itemBuilderContext, int index) {
    return Column(children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
        ),
        height: MediaQuery.of(context).size.height * 0.3,
        margin: this._conversationMessageHolder[index]
            ? EdgeInsets.only(
                right: MediaQuery.of(context).size.width / 3,
                left: 5.0,
                top: 30.0,
              )
            : EdgeInsets.only(
                left: MediaQuery.of(context).size.width / 3,
                right: 5.0,
                top: 15.0,
              ),
        alignment: this._conversationMessageHolder[index]
            ? Alignment.centerLeft
            : Alignment.centerRight,
        child: GoogleMap(
          mapType: MapType.hybrid,
          markers: Set.of([
            Marker(
                markerId: MarkerId('locate'),
                zIndex: 1.0,
                draggable: true,
                position: LatLng(
                    double.parse(this
                        ._allConversationMessages[index]
                        .keys
                        .first
                        .split('+')[0]),
                    double.parse(this
                        ._allConversationMessages[index]
                        .keys
                        .first
                        .split('+')[1])))
          ]),
          initialCameraPosition: CameraPosition(
            target: LatLng(
                double.parse(this
                    ._allConversationMessages[index]
                    .keys
                    .first
                    .split('+')[0]),
                double.parse(this
                    ._allConversationMessages[index]
                    .keys
                    .first
                    .split('+')[1])),
            zoom: 17.4746,
          ),
        ),
      ),
      _conversationMessageTime(
          this._allConversationMessages[index].values.first, index),
    ]);
  }

  Future<void> _takeLocationInput() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      final Marker marker = Marker(
          markerId: MarkerId('locate'),
          zIndex: 1.0,
          draggable: true,
          position: LatLng(position.latitude, position.longitude));

      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                backgroundColor: Colors.black26,
                actions: [
                  FloatingActionButton(
                    child: Icon(Icons.send),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);

                      final String _messageTime =
                          "${DateTime.now().hour}:${DateTime.now().minute}";

                      if (mounted) {
                        setState(() {
                          this._allConversationMessages.add({
                            "${position.latitude}+${position.longitude}":
                                _messageTime,
                          });

                          this
                              ._chatMessageCategoryHolder
                              .add(ChatMessageTypes.Location);
                          this._conversationMessageHolder.add(_lastDirection);
                          _lastDirection = !_lastDirection;
                        });
                      }
                    },
                  ),
                ],
                content: FittedBox(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                    ),
                    child: GoogleMap(
                      mapType: MapType.hybrid,
                      markers: Set.of([marker]),
                      initialCameraPosition: CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 18.4746,
                      ),
                    ),
                  ),
                ),
              ));
    } catch (e) {
      print('Map Show Error: ${e.toString()}');
      showToast('Map Show Error', this._fToast,
          toastColor: Colors.red, fontSize: 16.0);
    }
  }

  Widget _audioConversationManagement(
      BuildContext itemBuilderContext, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onLongPress: () async {},
          child: Container(
            margin: this._conversationMessageHolder[index]
                ? EdgeInsets.only(
                    right: MediaQuery.of(context).size.width / 3,
                    left: 5.0,
                    top: 5.0,
                  )
                : EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 3,
                    right: 5.0,
                    top: 5.0,
                  ),
            alignment: this._conversationMessageHolder[index]
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              height: 70.0,
              width: 250.0,
              decoration: BoxDecoration(
                color: this._conversationMessageHolder[index]
                    ? Color.fromRGBO(60, 80, 100, 1)
                    : Color.fromRGBO(102, 102, 255, 1),
                borderRadius: this._conversationMessageHolder[index]
                    ? BorderRadius.only(
                        topRight: Radius.circular(40.0),
                        bottomLeft: Radius.circular(40.0),
                        bottomRight: Radius.circular(40.0),
                      )
                    : BorderRadius.only(
                        topLeft: Radius.circular(40.0),
                        bottomLeft: Radius.circular(40.0),
                        bottomRight: Radius.circular(40.0),
                      ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20.0,
                  ),
                  GestureDetector(
                    onLongPress: () => _chatMicrophoneOnLongPressAction(),
                    onTap: () => chatMicrophoneOnTapAction(index),
                    child: Icon(
                      index == _lastAudioPlayingIndex
                          ? _iconData
                          : Icons.play_arrow_rounded,
                      color: Color.fromRGBO(10, 255, 30, 1),
                      size: 35.0,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              top: 26.0,
                            ),
                            child: LinearPercentIndicator(
                              percent: _justAudioPlayer.duration == null
                                  ? 0.0
                                  : _lastAudioPlayingIndex == index
                                      ? _currAudioPlayingTime /
                                                  _justAudioPlayer
                                                      .duration!.inMicroseconds
                                                      .ceilToDouble() <=
                                              1.0
                                          ? _currAudioPlayingTime /
                                              _justAudioPlayer
                                                  .duration!.inMicroseconds
                                                  .ceilToDouble()
                                          : 0.0
                                      : 0,
                              backgroundColor: Colors.black26,
                              progressColor:
                                  this._conversationMessageHolder[index]
                                      ? Colors.lightBlue
                                      : Colors.amber,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0, right: 7.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _lastAudioPlayingIndex == index
                                          ? _loadingTime
                                          : '0:00',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _lastAudioPlayingIndex == index
                                          ? _totalDuration
                                          : '',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: GestureDetector(
                      child: _lastAudioPlayingIndex != index
                          ? CircleAvatar(
                              radius: 23.0,
                              backgroundColor:
                                  this._conversationMessageHolder[index]
                                      ? Color.fromRGBO(60, 80, 100, 1)
                                      : Color.fromRGBO(102, 102, 255, 1),
                              backgroundImage: ExactAssetImage(
                                "assets/images/google.png",
                              ),
                            )
                          : Text(
                              '${this._audioPlayingSpeed.toString().contains('.0') ? this._audioPlayingSpeed.toString().split('.')[0] : this._audioPlayingSpeed}x',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18.0),
                            ),
                      onTap: () {
                        print('Audio Play Speed Tapped');
                        if (mounted) {
                          setState(() {
                            if (this._audioPlayingSpeed != 3.0)
                              this._audioPlayingSpeed += 0.5;
                            else
                              this._audioPlayingSpeed = 1.0;

                            _justAudioPlayer.setSpeed(this._audioPlayingSpeed);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _conversationMessageTime(
            this._allConversationMessages[index].values.first, index),
      ],
    );
  }

  void _voiceSend(String recordedFilePath,
      {String audioExtension = '.mp3'}) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    if (_justAudioPlayer.duration != null) {
      if (mounted) {
        setState(() {
          _justAudioPlayer.stop();
          _iconData = Icons.play_arrow_rounded;
        });
      }
    }

    await _justAudioPlayer.setFilePath(recordedFilePath);

    if (_justAudioPlayer.duration!.inMinutes > 20)
      showToast(
          "Audio File Duration Can't be greater than 20 minutes", _fToast);
    else {
      final String _messageTime =
          "${DateTime.now().hour}:${DateTime.now().minute}";

      if (mounted) {
        setState(() {
          this._allConversationMessages.add({
            recordedFilePath: _messageTime,
          });
          this._chatMessageCategoryHolder.add(ChatMessageTypes.Audio);
          this._conversationMessageHolder.add(this._lastDirection);
          this._lastDirection = !this._lastDirection;
        });
      }
    }
  }

  void chatMicrophoneOnTapAction(int index) async {
    try {
      _justAudioPlayer.positionStream.listen((event) {
        if (mounted) {
          setState(() {
            _currAudioPlayingTime = event.inMicroseconds.ceilToDouble();
            _loadingTime =
                '${event.inMinutes} : ${event.inSeconds > 59 ? event.inSeconds % 60 : event.inSeconds}';
          });
        }
      });

      _justAudioPlayer.playerStateStream.listen((event) {
        if (event.processingState == ProcessingState.completed) {
          _justAudioPlayer.stop();
          if (mounted) {
            setState(() {
              this._loadingTime = '0:00';
              this._iconData = Icons.play_arrow_rounded;
            });
          }
        }
      });

      if (_lastAudioPlayingIndex != index) {
        await _justAudioPlayer
            .setFilePath(this._allConversationMessages[index].keys.first);

        if (mounted) {
          setState(() {
            _lastAudioPlayingIndex = index;
            _totalDuration =
                '${_justAudioPlayer.duration!.inMinutes} : ${_justAudioPlayer.duration!.inSeconds > 59 ? _justAudioPlayer.duration!.inSeconds % 60 : _justAudioPlayer.duration!.inSeconds}';
            _iconData = Icons.pause;
            this._audioPlayingSpeed = 1.0;
            _justAudioPlayer.setSpeed(this._audioPlayingSpeed);
          });
        }

        await _justAudioPlayer.play();
      } else {
        print(_justAudioPlayer.processingState);
        if (_justAudioPlayer.processingState == ProcessingState.idle) {
          await _justAudioPlayer
              .setFilePath(this._allConversationMessages[index].keys.first);

          if (mounted) {
            setState(() {
              _lastAudioPlayingIndex = index;
              _totalDuration =
                  '${_justAudioPlayer.duration!.inMinutes} : ${_justAudioPlayer.duration!.inSeconds}';
              _iconData = Icons.pause;
            });
          }

          await _justAudioPlayer.play();
        } else if (_justAudioPlayer.playing) {
          if (mounted) {
            setState(() {
              _iconData = Icons.play_arrow_rounded;
            });
          }

          await _justAudioPlayer.pause();
        } else if (_justAudioPlayer.processingState == ProcessingState.ready) {
          if (mounted) {
            setState(() {
              _iconData = Icons.pause;
            });
          }

          await _justAudioPlayer.play();
        } else if (_justAudioPlayer.processingState ==
            ProcessingState.completed) {}
      }
    } catch (e) {
      print('Audio Playing Error');
      showToast('May be Audio File Not Found', _fToast);
    }
  }

  void _chatMicrophoneOnLongPressAction() async {
    if (_justAudioPlayer.playing) {
      await _justAudioPlayer.stop();

      if (mounted) {
        setState(() {
          print('Audio Play Completed');
          _justAudioPlayer.stop();
          if (mounted) {
            setState(() {
              _loadingTime = '0:00';
              _iconData = Icons.play_arrow_rounded;
              _lastAudioPlayingIndex = -1;
            });
          }
        });
      }
    }
  }

  void _sendText() {
    if (this._writeTextPresent) {
      final String _messageTime =
          "${DateTime.now().hour}:${DateTime.now().minute}";
      if (mounted) {
        setState(() {
          this._allConversationMessages.add({
            this._typedText.text: _messageTime,
          });
          this._chatMessageCategoryHolder.add(ChatMessageTypes.Text);
          this._conversationMessageHolder.add(this._lastDirection);
          this._lastDirection = !this._lastDirection;
          this._typedText.clear();
        });
      }
    }
  }

  void _voiceTake() async {
    if (!await Permission.microphone.status.isGranted) {
      final microphoneStatus = await Permission.microphone.request();
      if (microphoneStatus != PermissionStatus.granted)
        showToast(
            "Microphone Permission Required To Record Voice", this._fToast);
    } else {
      if (await this._record.isRecording()) {
        if (mounted) {
          setState(() {
            _hintText = 'Type Here...';
          });
        }
        final String? recordedFilePath = await this._record.stop();

        _voiceSend(recordedFilePath.toString());
      } else {
        if (mounted) {
          setState(() {
            _hintText = 'Recording....';
          });
        }

        await this
            ._record
            .start(
              path: '${_audioDirectory.path}${DateTime.now()}.aac',
            )
            .then((value) => print("Recording"));
      }
    }
  }
}
