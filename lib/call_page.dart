import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:zegocloud_tutorial_test/utils/zegocloud_token.dart';
import 'key_center.dart';

class CallPage extends StatefulWidget {
  final String localUserID;
  final String localUserName;
  final String roomID;
   CallPage({Key? key,required this.localUserName,required this.localUserID,required this.roomID}) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  Widget? localView;
  int? localViewID;
  Widget? remoteView;
  int? remoteViewID;
  @override
  void initState() {
    startListenEvent();
    loginRoom();
    super.initState();
  }

  @override
  void dispose() {
    stopListenEvent();

    logoutRoom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Call Page")),
      body: Stack(
        children: [
          localView ?? Container(),
          Positioned(
            top: MediaQuery.of(context).size.height / 20,
            right: MediaQuery.of(context).size.width / 20,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: AspectRatio(
                aspectRatio: 9.0 / 16.0,
                child: remoteView ?? Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height / 20,
            left: 0,
            right: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              height: MediaQuery.of(context).size.width / 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(shape: const CircleBorder(), backgroundColor: Colors.red),
                    onPressed: () => Navigator.pop(context),
                    child: const Center(child: Icon(Icons.call_end, size: 32)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void startListenEvent() {
    // Callback for updates on the status of other users in the room.
    // Users can only receive callbacks when the isUserStatusNotify property of ZegoRoomConfig is set to `true` when logging in to the room (loginRoom).
    ZegoExpressEngine.onRoomUserUpdate = (roomID, updateType, List<ZegoUser> userList) {
      debugPrint(
          'onRoomUserUpdate: roomID: $roomID, updateType: ${updateType.name}, userList: ${userList.map((e) => e.userID)}');
    };
    // Callback for updates on the status of the streams in the room.
    ZegoExpressEngine.onRoomStreamUpdate = (roomID, updateType, List<ZegoStream> streamList, extendedData) {
      debugPrint(
          'onRoomStreamUpdate: roomID: $roomID, updateType: $updateType, streamList: ${streamList.map((e) => e.streamID)}, extendedData: $extendedData');
      if (updateType == ZegoUpdateType.Add) {
        for (final stream in streamList) {
          startPlayStream(stream.streamID);
        }
      } else {
        for (final stream in streamList) {
          stopPlayStream(stream.streamID);
        }
      }
    };
    // Callback for updates on the current user's room connection status.
    ZegoExpressEngine.onRoomStateUpdate = (roomID, state, errorCode, extendedData) {
      debugPrint(
          'onRoomStateUpdate: roomID: $roomID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    };

    // Callback for updates on the current user's stream publishing changes.
    ZegoExpressEngine.onPublisherStateUpdate = (streamID, state, errorCode, extendedData) {
      debugPrint(
          'onPublisherStateUpdate: streamID: $streamID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    };
  }
  Future<void> startPublish() async{
    // After calling the `loginRoom` method, call this method to publish streams.
    // The StreamID must be unique in the room.
    String streamID = '${widget.roomID}_${widget.localUserID}_call';
    return ZegoExpressEngine.instance.startPublishingStream(streamID);
  }
  Future<void> startPlayStream(String streamID) async {
    // Start to play streams. Set the view for rendering the remote streams.
    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      remoteViewID = viewID;
      ZegoCanvas canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
    }).then((canvasViewWidget) {
      setState(() => remoteView = canvasViewWidget);
    });
  }

  Future<void> stopPlayStream(String streamID) async {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
    if (remoteViewID != null) {
      ZegoExpressEngine.instance.destroyCanvasView(remoteViewID!);
      setState(() {
        remoteViewID = null;
        remoteView = null;
      });
    }
  }
  Future<void> stopPublish() async {
    return ZegoExpressEngine.instance.stopPublishingStream();
  }
  void stopListenEvent() {
    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
  }

  Future<ZegoRoomLoginResult> loginRoom() async {
    // The value of `userID` is generated locally and must be globally unique.
    final user = ZegoUser(widget.localUserID, widget.localUserName);

    // The value of `roomID` is generated locally and must be globally unique.
    final roomID = widget.roomID;

    // onRoomUserUpdate callback can be received when "isUserStatusNotify" parameter value is "true".
    ZegoRoomConfig roomConfig = ZegoRoomConfig.defaultConfig()..isUserStatusNotify = true;



    if (kIsWeb) {
      // ! ** Warning: ZegoTokenUtils is only for use during testing. When your application goes live,
      // ! ** tokens must be generated by the server side. Please do not generate tokens on the client side!
      roomConfig.token = ZegoTokenUtils.generateToken(appID, serverSecret, widget.localUserID);
    }
    // log in to a room
    // Users must log in to the same room to call each other.
    return ZegoExpressEngine.instance.loginRoom(roomID, user, config: roomConfig).then((ZegoRoomLoginResult loginRoomResult) {
      debugPrint('loginRoom: errorCode:${loginRoomResult.errorCode}, extendedData:${loginRoomResult.extendedData}');
      if (loginRoomResult.errorCode == 0) {
        startPreview();
        startPublish();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('loginRoom failed: ${loginRoomResult.errorCode}')));
      }
      return loginRoomResult;
    });
  }

  Future<ZegoRoomLogoutResult> logoutRoom() async {
    stopPreview();
    stopPublish();
    return ZegoExpressEngine.instance.logoutRoom(widget.roomID);
  }


  Future<void> startPreview() async {
    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      localViewID = viewID;
      ZegoCanvas previewCanvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
    }).then((canvasViewWidget) {
      setState(() => localView = canvasViewWidget);
    });
  }

  Future<void> stopPreview() async {
    ZegoExpressEngine.instance.stopPreview();
    if (localViewID != null) {
      await ZegoExpressEngine.instance.destroyCanvasView(localViewID!);
      setState(() {
        localViewID = null;
        localView = null;
      });
    }
  }


}

