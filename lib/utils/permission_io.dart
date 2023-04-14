import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermission()async{

  try{

    PermissionStatus microphoneStatus = await Permission.microphone.request();
    if (microphoneStatus != PermissionStatus.granted)
    {
      debugPrint('Error: Microphone permission not granted!!!');
      return false;
    }
  }on Exception catch(error)
  {
      debugPrint("Error in MicroPhone request Permission $error");
  }


  try{

    PermissionStatus cameraStatus = await Permission.camera.request();
    if (cameraStatus != PermissionStatus.granted)
    {
      debugPrint('Error: Camera permission not granted!!!');
      return false;
    }
  }on Exception catch(error)
  {
    debugPrint("Error in Camera request Permission $error");
  }

  return true;
}