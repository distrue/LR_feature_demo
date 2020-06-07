import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import './pages/tflite.dart';
import './pages/socketio.dart';
import './pages/restapi.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "LoyalRoader Demo",
      theme: ThemeData(
        primaryColor: Colors.greenAccent
      ),
      home: MyHome()
    );
  }
}

class MyHome extends StatefulWidget {
  MyHome({Key key, this.title}) : super(key: key);
  // This widget is the root of your application.

  final String title;

  @override
  MyTabsState createState() => MyTabsState();
}

class MyTabsState extends State<MyHome> with SingleTickerProviderStateMixin {
  static TabController controller;

  @override
  void initState() {
    super.initState();

    controller = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feature Demo')),
      body: TabBarView(
        controller: controller,
        children: <Widget>[TfliteExample(), SocketIO(), RestApi()],
      ),
      bottomNavigationBar: Container(
        child: TabBar(
          controller: controller,
          tabs: [
            Tab(icon: Icon(Icons.table_chart), text: 'TFLiteExample'),
            Tab(icon: Icon(Icons.donut_small), text: 'socketio',),
            Tab(icon: Icon(Icons.cloud), text: 'restApi'),
          ]
        ),
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

Widget textSection = Container(
  padding: const EdgeInsets.all(32),
  child: Text(
    'Lake Oeschinen lies at the foot of the Blüemlisalp in the Bernese '
        'Alps. Situated 1,578 meters above sea level, it is one of the '
        'larger Alpine Lakes. A gondola ride from Kandersteg, followed by a '
        'half-hour walk through pastures and pine forest, leads you to the '
        'lake, which warms to 20 degrees Celsius in the summer. Activities '
        'enjoyed here include rowing, and riding the summer toboggan run.',
    softWrap: true,
  ),
);
