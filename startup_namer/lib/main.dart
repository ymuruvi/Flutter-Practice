
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:english_words/english_words.dart';

void main() {
  return runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Startup Name Generator',
      home: new RandomWords(),
      theme: new ThemeData(
          primaryColor: Colors.white
      ),
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

          title: new Text('Startup Name Generator',textAlign: TextAlign.center,),
          centerTitle: true,
          actions: <Widget>[
            new IconButton(icon: new Icon(Icons.list), onPressed: _pushSaved)
          ],
        ),
        body: _buildSuggestions()
    );
  }

  Widget _buildRow(WordPair pair){
    final alreadySaved = _saved.contains(pair);

    return new ListTile(
      title: new Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : Colors.grey,
      ),
      onTap: (){
        setState((){
          if(alreadySaved){
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  Widget _buildSuggestions(){
    return new ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i){
        if(i.isOdd) return new Divider();
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
                  return new SizedBox(
                    height: 64.0,
                    child: new Card(
                      color: Colors.blueAccent,
                      child: new Center(
                        child: new Text(
                            pair.asPascalCase,
                            style: new TextStyle(
                                color: Colors.black,
                                fontStyle: FontStyle.italic
                            )
                        ),
                      ),
                    ),
                  );
                },
              );
              final divided = ListTile.divideTiles(
                  context: context,
                  tiles: tiles
              ).toList();
              return new Scaffold(
                appBar: new AppBar(
                  title: new Text('Saved Suggestions'),
                  centerTitle: true,
                ),
                body: new ListView(children: divided,),
              );
            }
        )
    );
  }
}

/// Displays its integer item as 'item N' on a Card whose color is based on
/// the item's value. The text is displayed in bright green if selected is true.
/// This widget's height is based on the animation parameter, it varies
/// from 0 to 128 as the animation varies from 0.0 to 1.0.
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
    if (selected)
      textStyle = textStyle.copyWith(color: Colors.lightGreenAccent[400]);
    return new Padding(
      padding: const EdgeInsets.all(2.0),
      child: new SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: new GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: new SizedBox(
            height: 128.0,
            child: new Card(
              color: Colors.primaries[item % Colors.primaries.length],
              child: new Center(
                child: new Text('Item $item', style: textStyle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

