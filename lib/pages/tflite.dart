import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

class TfliteExample extends StatelessWidget {
    final List<CameraDescription> cameras;

    TfliteExample(this.cameras);

    @override
    Widget build(BuildContext context){
        return MaterialApp(
          home: CameraApp(this.cameras),
        );
    }
}

class CameraApp extends StatefulWidget {
  final List<CameraDescription> cameras;
  
  CameraApp(this.cameras);

  @override
  _CameraAppState createState() => new _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;
  List<dynamic> _recognitions;
  double previewH;
  double previewW;
  double screenH;
  double screenW;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    loadModel();
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      previewH = math.max(controller.value.previewSize.height, controller.value.previewSize.width);
      previewW = math.min(controller.value.previewSize.height, controller.value.previewSize.width);
      controller.startImageStream(onAvailable);
    });
  }

  dynamic onAvailable(CameraImage img) async {
    try {
        Tflite.runPoseNetOnFrame(
        bytesList: img.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: img.height,
        imageWidth: img.width,
        numResults: 1).then((recognitions) {
          setState(() {
            _recognitions = recognitions;
          });
        });
    }
    on PlatformException catch (e) {
      print("Error: ${e.code}\nError Message: ${e.message}");
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tmp = MediaQuery.of(context).size;
    screenH = math.max(tmp.height, tmp.width);
    screenW = math.min(tmp.height, tmp.width);

    if (!controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      body: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: _cameraPreviewWidget(),
      ));
  }

  Future<Null> loadModel() async {
    try {
      final String result = await Tflite.loadModel(
        model: "assets/posenet_mv1_075_float_from_checkpoints.tflite");
    }
    on PlatformException catch (e) {
      print("Error: ${e.code}\nError Message: ${e.message}");
    }
  }
  
  Widget _cameraPreviewWidget() {
    if (!(_recognitions == null)) {
      return Stack(
        children: <Widget>[CameraPreview(controller)] + _renderKeypoints());
    }
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: CameraPreview(controller),
    );
  }


  List<Widget> _renderKeypoints() {
    if (_recognitions == null) return [];
    
    var lists = <Widget>[];
    _recognitions.forEach((re) {
      var list = re["keypoints"].values.map<Widget>((k) {
        var _x = k["x"];
        var _y = k["y"];
        var scaleW, scaleH, x, y;

        if (screenH / screenW > previewH / previewW) {
          scaleW = screenH / previewH * previewW;
          scaleH = screenH;
          var difW = (scaleW - screenW) / scaleW;
          x = (_x - difW / 2) * scaleW;
          y = _y * scaleH;
        } else {
          scaleH = screenW / previewW * previewH;
          scaleW = screenW;
          var difH = (scaleH - screenH) / scaleH;
          x = _x * scaleW;
          y = (_y - difH / 2) * scaleH;
        }

        return Positioned(
          left: x-6,
          top: y-6,
          width: 100,
          height: 12,
          child: Container(
            child: Text(
              "● ${k['part']}",
              style: TextStyle(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                fontSize: 12.0,
              ),
            ),
          ),
        );
       }).toList();
      lists..addAll(list);
    });
    return lists;
  }
}

