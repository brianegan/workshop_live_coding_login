import 'package:flutter/material.dart';
import 'package:login_demo_live_code/auth_model.dart';
import 'package:login_demo_live_code/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final model = AuthModel(
    AuthRepository(
      LocalStorage(prefs),
      WebClient(),
    ),
  );

  await model.init();

  runApp(MyApp(
    authModel: model,
  ));
}

class MyApp extends StatefulWidget {
  final AuthModel authModel;

  const MyApp({Key key, this.authModel}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loggedIn;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    _loggedIn = widget.authModel.loggedIn;
    widget.authModel.addListener(_navigateOnLoginChange);
    super.initState();
  }

  void _navigateOnLoginChange() {
    if (!_loggedIn && widget.authModel.loggedIn) {
      _navigatorKey.currentState.pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) =>
                DashboardScreen(title: "Hey, I'm logged in!")),
        (_) => false,
      );
    } else if (_loggedIn && !widget.authModel.loggedIn) {
      _navigatorKey.currentState.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (_) => false,
      );
    }

    _loggedIn = widget.authModel.loggedIn;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.authModel,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: widget.authModel.loggedIn
            ? DashboardScreen(title: 'Flutter Demo Home Page')
            : LoginScreen(),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              Provider.of<AuthModel>(context, listen: false).logout();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AuthModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(hintText: 'Email'),
              validator: (email) =>
                  model.validateEmail(email) ? null : 'Email must be valid',
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(hintText: 'Password'),
              validator: (password) => model.validatePassword(password)
                  ? null
                  : 'Password must be longer than 5 characters',
            ),
            SizedBox(height: 16),
            RaisedButton(
              child: Text('Log in'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  model.login(
                    _emailController.text,
                    _passwordController.text,
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
