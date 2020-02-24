import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MessageScreen("superman"),
    );
  }
}
class MessageScreen extends StatefulWidget {
  final String UID;

  MessageScreen(this.UID);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final CometChat _cometChat = CometChat();
  final List<String> _messages = [];
  String _currentMessage = "dsfsdfsfsdf";
  final TextEditingController _textController = TextEditingController();
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _cometChat.initMethodChannel();
    _cometChat.initEventChannel();
    _cometChat.joinGroup().whenComplete(() {
      _cometChat.stream.receiveBroadcastStream().listen((value) {
        setState(() {
          _messages.add(value);
        });
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Timer(Duration(milliseconds: 500),
        () => _controller.jumpTo(_controller.position.maxScrollExtent));
    return Scaffold(
      backgroundColor: Colors.white,
     
      body: Container(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                 Padding(padding: EdgeInsets.only(top:20,left:10),child: Icon(Icons.arrow_back_ios),),
                  Padding(padding: EdgeInsets.only(top: 20,left: 20),
                  child:Text("data",style:  TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22,
                                                  fontFamily: "SukhumvitSet")),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(top:20)),
              messageList(),
              messageInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Expanded messageList() {
    return Expanded(
      flex: 2,
      child: ListView.builder(
          padding: EdgeInsets.all(8.0),
          controller: _controller,
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            return buildTile(_messages[index]);
          }),
    );
  }

  Padding messageInputArea() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20,left: 16.0,right: 16.0,top: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: TextField(
              
              controller: _textController,
              onChanged: (value) {
                _currentMessage = value;
              },
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                
                 border: new OutlineInputBorder(
                  
                   borderRadius: const BorderRadius.all(
          const Radius.circular(40.0),
          
        )
        ),
                  hintText: "  Enter Message",

                  hintStyle: TextStyle(color: Colors.red),
                  labelStyle: TextStyle(color: Colors.black),
                 
                  ),
            ),
          ),
    

          SizedBox(
            width: 10.0,
          ),
          // Expanded(
          //   flex: 1,
          //   child: RaisedButton(
          //     onPressed: () {
          //       _textController.clear();
          //       _cometChat.sendMessage(userMessage: _currentMessage);
          //       var data = {
          //         'Message': "sdfsdf",
          //         'SenderUID': widget.UID
          //       };
          //       String result = json.encode(data);
          //       setState(() {
          //         print("sdfsdfsdfsdfsdfsdf  $data");
          //         _messages.add(result);
          //       });
          //     },
          //     child: Icon(Icons.send),
          //   ),
          // )
           Expanded(
            flex: -2,
            child: Padding(
              padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
              child: IconButton(icon: Icon(Icons.send,size: 40,color:  Color(0xFFFF1744),)
              , onPressed: () {
                  _textController.clear();
                  _cometChat.sendMessage(userMessage: _currentMessage);
                  var data = {
                    'Message': _currentMessage,
                    'SenderUID': widget.UID
                  };
                  String result = json.encode(data);
                  setState(() {
                    print("sdfsdfsdfsdfsdfsdf  $data");
                    _messages.add(result);
                  });
                },
              
              ),
            )
          ),
      
          
    
        ],
      ),
    );
  }

  Widget buildTile(String data) {
    var result = json.decode(data);
    print("fgfdgdfgdfgd"+result['SenderUID']);
    print(result['Message']);
    if (result['SenderUID'] == widget.UID) {
      //Own message
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: Container(),
            ),
            Flexible(
              child: Card(
                elevation: 5.0,
                color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    result['Message'],
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontFamily: "SukhumvitSet"
                    ),
                  ),
                ),
              ),
            ),
            CircleAvatar(
              backgroundImage: AssetImage('images/${widget.UID}.png'),
              backgroundColor: Colors.white,
            ),
          ],
        ),
      );
    } else {
      //Other's message
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: AssetImage(
                  'images/${widget.UID == 'batman' ? 'superman' : 'batman'}.png'),
              backgroundColor: Colors.white,
            ),
            Flexible(
              child: Card(
                elevation: 5.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    result['Message'],
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Container(),
            ),
          ],
        ),
      );
    }
  }
}
class CometChat {
  MethodChannel _platform;
  EventChannel _stream;

  EventChannel get stream => _stream;

  void initMethodChannel(){
    _platform = const MethodChannel('com.sagar.gossip/initialize');
  }

  void initEventChannel(){
    _stream = const EventChannel('com.sagar.gossip/message');
  }

  //Method to initialize the CometChat SDK
  Future<String> init() async {
    String isInitialized = "Not Initialized";
    try {
      final bool result =
          await _platform.invokeMethod('isCometChatInitialized');
      isInitialized = "Comet was initialized successfully $result";
    } on PlatformException catch (e) {
      isInitialized = e.message;
    }
    return isInitialized;
  }

  //Login a user using API_KEY and UID of the user
  Future<String> login({@required String uid, @required String apiKey}) async {
    String status = "";
    try {
      final String result = await _platform
          .invokeMethod('loginUser', {"UID": uid, "API_KEY": apiKey});
      Map finalResult = json.decode(result);
      if (finalResult['RESULT']) {
        status = "Logged in successfully";
      } else {
        status = "Login failed";
      }
    } on PlatformException catch (e) {
      print("Exception");
      status = e.message;
    }
    return status;
  }

  Future<String> joinGroup() async{
    String status = "";
    try{
      final bool result = await _platform.invokeMethod('joinGroup', {'GUID': 'dc_superheroes'});
      if(result){
        status = "Success";
      }else{
        status = "Failed";
      }
    }on PlatformException catch (e){
      status = e.message;
    }
    return status;
  }

  //Send message to the user
  Future<String> sendMessage({@required String userMessage}) async {
    String status = "";
    try {
      final bool result = await _platform.invokeMethod('sendMessage',
          {"ROOM_ID": 'dc_superheroes', "MESSAGE": "$userMessage"});
      if (result) {
        status = "Message send successfully";
      } else {
        status = "Message was not sent";
      }
    } on PlatformException catch (e) {
      status = e.message;
    }
    print(status);
    return status;
  }
}


//class MyHomePage extends StatefulWidget {
//  final String title;
//
//  MyHomePage({Key key, this.title}) : super(key: key);
//
//  @override
//  _MyHomePageState createState() => _MyHomePageState();
//}

//class _MyHomePageState extends State<MyHomePage> {
//  static const platform = const MethodChannel('com.sagar.gossip/initialize');
//  static const stream = const EventChannel('com.sagar.gossip/message');
//
//  String _userMessage = "";
//
//  static const UID = "SUPERHERO1";
//  static const _receiverID = "SUPERHERO2";
//  static const API_KEY = "09598c4d81e1fd4eee40486d7cb17f69a69846eb";
//
//  @override
//  void initState() {
//    super.initState();
//    init().whenComplete(() {
//      login().whenComplete(() {
//        print("Logged in");
//      });
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//        appBar: AppBar(
//          title: Text(widget.title),
//        ),
//        body: Center(
//          child: Column(
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: <Widget>[
//              TextField(
//                decoration: InputDecoration(
//                  hintText: "Enter Message",
//                ),
//                onChanged: (value) {
//                  _userMessage = value;
//                },
//              ),
//              Container(margin: EdgeInsets.all(8.0)),
//              StreamBuilder(
//                  stream: stream.receiveBroadcastStream(),
//                  builder: (BuildContext context, AsyncSnapshot snapshot) {
//                    if (snapshot.hasError) {
//                      return Text('Error ${snapshot.error.toString()}');
//                    } else if (snapshot.hasData) {
//                      return Text(snapshot.data.toString());
//                    }
//                    return Text('Incoming Messages');
//                  })
//            ],
//          ),
//        ),
//        floatingActionButton: FloatingActionButton(
//          onPressed: sendMessage,
//          tooltip: 'Send Message',
//          child: Icon(Icons.send),
//        ) // This trailing comma makes auto-formatting nicer for build methods.
//        );
//  }
//
//  //Method to initialize the CometChat SDK
//  Future<String> init() async {
//    String isInitialized = "Not Initialized";
//    try {
//      final bool result = await platform.invokeMethod('isCometChatInitialized');
//      isInitialized = "Comet was initialized successfully $result";
//    } on PlatformException catch (e) {
//      isInitialized = e.message;
//    }
//    return isInitialized;
//  }
//
//  //Login a user using API_KEY and UID of the user
//  Future<String> login() async {
//    String status = "";
//    try {
//      final String result = await platform
//          .invokeMethod('loginUser', {"UID": UID, "API_KEY": API_KEY});
//      Map finalResult = json.decode(result);
//      if (finalResult['RESULT']) {
//        status = "Logged in successfully";
//      } else {
//        status = "Login failed";
//      }
//    } on PlatformException catch (e) {
//      print("Exception");
//      status = e.message;
//    }
//    return status;
//  }
//
//  //Send message to the user
//  Future<String> sendMessage() async {
//    String status = "";
//    try {
//      final bool result = await platform.invokeMethod('sendMessage',
//          {"RECEIVER_ID": '$_receiverID', "MESSAGE": "$_userMessage"});
//      if (result) {
//        status = "Message send successfully";
//      } else {
//        status = "Message was not sent";
//      }
//    } on PlatformException catch (e) {
//      status = e.message;
//    }
//    print(status);
//    return status;
//  }
//}
