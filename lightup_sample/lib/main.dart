/*
  For Readability I've stripped out the boilerplate comments
  that would normall be in the template code
*/
import 'package:flutter/material.dart';

//Surface Duo: Get Platform support for simulating android mode for test
import 'dart:io';

// Surface Duo: Add for Platform Channel support
import 'package:flutter/services.dart';

// Surface Duo: Define the Method Channel name
const platform = const MethodChannel('duosdk.microsoft.dev');

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Platform.isAndroid?AndroidHomePage(title: 'Flutter Demo Home Page'):MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isDualScreenDevice = false;
  bool _isAppSpanned = false;
  double _hingeAngle = 180.0;
  int _hingeSize = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    platform.invokeMethod('isDualScreenDevice').then((value) {
      _isDualScreenDevice = value;
    });
  }

  // Surface Duo: We'll use this simple function to query the APIs and report their values
  Future<void> _updateDualScreenInfo() async {
    print("_updateDualScreenInfo() - Start");
    _isAppSpanned = await platform.invokeMethod('isAppSpanned');
    _hingeAngle = await platform.invokeMethod('getHingeAngle');
    _hingeSize = await platform.invokeMethod('getHingeSize');
    print("_updateDualScreenInfo() - End");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<void>(
        future: _updateDualScreenInfo(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          return _createPage();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _createPage() {
    print("CreatePage()");

    if (!_isDualScreenDevice || (_isDualScreenDevice && !_isAppSpanned)) {
      // We are not on a dual-screen device or
      // we are but we are not spanned
      return _buildBody();
    } else {
      // We are on a dual-screen device and we are spanned
      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        // Portrait is what we get when we have rotated the device
        // and have two "landscape" screens on top of each other,
        // so together they are "portrait"
        return Column(
          children: [
            Flexible(
              flex: 1,
              child: Center(child: FlutterLogo(size: 200.0)),
            ),
            SizedBox(height: _hingeSize.toDouble()),
            Flexible(
              flex: 1,
              child: _buildBody(),
            ),
          ],
        );
      } else {
        return Row(
          children: [
            Flexible(
              flex: 1,
              child: Center(child: FlutterLogo(size: 200.0)),
            ),
            SizedBox(width: _hingeSize.toDouble()),
            Flexible(
              flex: 1,
              child: _buildBody(),
            ),
          ],
        );
      }
    }
  }

  Widget _buildBody() {
    print("CreatePage()");
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'You have pushed the button this many times:',
          ),
          Text(
            '$_counter',
            style: Theme.of(context).textTheme.headline4,
          ),
        ],
      ),
    );
  }
}

/// Android native counter app, for checking in Surface emulator.

class AndroidHomePage extends StatefulWidget {
  AndroidHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _AndroidHomePageState createState() => new _AndroidHomePageState();
}

class _AndroidHomePageState extends State<AndroidHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'You have pushed the button this many times:',
            ),
            new Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
