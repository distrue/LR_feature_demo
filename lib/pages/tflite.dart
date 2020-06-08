import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

class TfliteExample extends StatefulWidget {
  TfliteExample({this.cameras});

  final List<CameraDescription> cameras;

  @override
  _CameraWMState createState() {
    return _CameraWMState();
  }
}

class _CameraWMState extends State<TfliteExample> {
  List<dynamic> _recognitions;
  CameraController controller;
  var tmp;
  double previewH;
  double previewW;
  double screenH;
  double screenW;

  @override
  void initState() {
    super.initState();
    loadModel();
    if (widget.cameras == null || widget.cameras.length < 1) {
      debugPrint('No Camera Available');
    } else {
      _initCameraController(widget.cameras[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    var tmp = MediaQuery.of(context).size;
    screenH = math.max(tmp.height, tmp.width);
    screenW = math.min(tmp.height, tmp.width);

    return Scaffold(
      body: Container(
        child: SafeArea(child: _cameraPreviewWidget()),
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    if (!(_recognitions == null)) {
      if (_recognitions.isNotEmpty) {
        return Stack(
            children: <Widget>[_cameraInitCheckWidget()] + _renderKeypoints());
      }
    }
    return _cameraInitCheckWidget();
  }

  Widget _cameraInitCheckWidget() {
    if (controller == null || widget.cameras.length < 1) {
      return Container();
    } else {
      return CameraPreview(controller);
    }
  }

  List<Widget> _renderKeypoints() {
    var lists = <Widget>[];
    _recognitions.forEach((re) {
      var list = re['keypoints'].values.map<Widget>((k) {
        var _x = k['x'];
        var _y = k['y'];
        var scaleW, scaleH, x, y;

        if (screenH / screenW > previewH / previewW) {
          scaleW = screenH / previewH * previewW;
          scaleH = screenH;
          var difW = (scaleW - screenW) / scaleW;
          x = (_x - difW / 2) * scaleW + 100;
          y = _y * scaleH;
        } else {
          scaleH = screenW / previewW * previewH;
          scaleW = screenW;
          var difH = (scaleH - screenH) / scaleH;
          x = _x * scaleW + 100;
          y = (_y - difH / 2) * scaleH;
        }

        return Positioned(
          left: x - 6,
          top: y - 6,
          width: 100,
          height: 12,
          child: Container(
            child: Text("●",
                style: TextStyle(
                    color: Color.fromRGBO(37, 213, 253, 1), fontSize: 5)),
          ),
        );
      }).toList();
      lists.addAll(list);
    });
    return lists;
  }

  Future<Null> loadModel() async {
    try {
      final String result = await Tflite.loadModel(
          model:
              "assets/posenet_mobilenet_v1_100_257x257_multi_kpt_stripped.tflite");
    } on PlatformException catch (e) {
      print("Error: ${e.code}\nError Message: ${e.message}");
    }
  }

  void _initCameraController(CameraDescription cameraDescription) {
    controller = CameraController(cameraDescription, ResolutionPreset.low);
    controller.initialize().then((_) {
      previewH = math.max(controller.value.previewSize.height,
          controller.value.previewSize.width);
      previewW = math.min(controller.value.previewSize.height,
          controller.value.previewSize.width);
      if (!mounted) {
        return;
      }
      setState(() {});
      controller.startImageStream(onAvailable);
    });
  }

  dynamic onAvailable(CameraImage img) async {
    Tflite.runPoseNetOnFrame(
            bytesList: img.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            imageHeight: img.height,
            imageWidth: img.width,
            numResults: 1)
        .then((recognitions) {
      setState(() {
        _recognitions = recognitions;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
