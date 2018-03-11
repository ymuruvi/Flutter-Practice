
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:english_words/english_words.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;

GoogleSignIn _googleSignIn = new GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);


void main() {
  print("Running App");
  return runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (new MaterialApp(
      title: 'Startup Name Generator',
      home: new RandomWords(),
      theme: new ThemeData(
          primaryColor: Colors.redAccent
      ),

    )
    );
  }
}

class RandomWords extends StatefulWidget{
  @override
  createState() => new RandomWordsState();
}

class RandomWordsState extends State<RandomWords>{

  final _suggestions = <WordPair>[];
  final _saved = new Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(

        title: new Text('Random Name Generator', textAlign: TextAlign.center,),
        centerTitle: true,
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.list), onPressed: _pushSaved)
        ],
      ),
      body: _buildSuggestions(),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () {
          _handleSignIn();
        },
        child: new Icon(Icons.add),
      ),
    );
  }

  Widget _buildRow(WordPair pair){
    final alreadySaved = _saved.contains(pair);

    return new SizedBox(
      child: new Card(
          color: alreadySaved ? Colors.red : Colors.grey,
        child: new ListTile(
          title: new Text(
            pair.asPascalCase,
            style: _biggerFont,
          ),
          trailing: new Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,

          ),
          onTap: (){
            setState((){
              if(alreadySaved){
                _saved.remove(pair);
              } else {
                _saved.add(pair);
              }});},
        ))
    );
  }

  Widget _buildSuggestions(){
    return new ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i){
        if(i.isOdd) return new Divider(
          height: 0.0,
          color: Colors.white,
        );
        final index = i ~/2;
        if (index >= _suggestions.length){
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              final tiles = _saved.map(
                    (pair) {
                  return new GestureDetector(onTap:
                      () {},
                      child: new SizedBox(
                        height: 64.0,
                        child: new Card(
                          color: Colors.blueAccent,
                          child: new Center(
                            child: new ListTile(
                              trailing: new Icon(Icons.map),
                              onTap: () {},
                              title: new Text(
                                  pair.asPascalCase
                              ),
                            ),
                          ),
                        ),
                      )
                  );
                },
              );
              final divided = ListTile.divideTiles(
                  context: context,
                  tiles: tiles
              ).toList();
              return new Scaffold(
                appBar: new AppBar(
                  title: new Text('Saved Combinations'),
                  centerTitle: true,
                ),
                body: new ListView(children: divided,),
              );
            }
        )
    );
  }

}


class CardItem extends StatelessWidget {
  const CardItem({
    Key key,
    @required this.animation,
    this.onTap,
    @required this.item,
    this.selected: false
  })
      : assert(animation != null),
        assert(item != null && item >= 0),
        assert(selected != null),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback onTap;
  final int item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme
        .of(context)
        .textTheme
        .display1;
    if (selected) {
      textStyle = textStyle.copyWith(color: Colors.lightGreenAccent[400]);
    }
    return new Padding(
      padding: const EdgeInsets.all(2.0),
      child: new SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: new GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            print("Tapped");
          },
          child: new SizedBox(

            height: 128.0,
            child: new ListTile(
              trailing: new Icon(Icons.map),
            ),

          ),
        ),
      ),
    );
  }
}

Future<FirebaseUser> _handleSignIn() async {
  GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  FirebaseUser user = await _auth.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  print("signed in " + user.displayName);
  return user;
}