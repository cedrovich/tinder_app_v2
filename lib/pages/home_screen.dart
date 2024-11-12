import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipe_cards/swipe_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<SwipeItem> _swipeItems = <SwipeItem>[];
  late MatchEngine _matchEngine;
  List<String> _names = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      final snapshot = await _firestore.collection('users').get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _swipeItems = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No hay perfiles disponibles."),
          duration: Duration(seconds: 2),
        ));
        return;
      }

      _names = snapshot.docs.map((doc) => doc['name'] as String).toList();

      _swipeItems = List<SwipeItem>.generate(
        _names.length,
        (index) => SwipeItem(
          content: Content(name: _names[index]),
          likeAction: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Liked ${_names[index]}"),
              duration: Duration(milliseconds: 500),
            ));
          },
          nopeAction: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Nope ${_names[index]}"),
              duration: Duration(milliseconds: 500),
            ));
          },
          superlikeAction: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Superliked ${_names[index]}"),
              duration: Duration(milliseconds: 500),
            ));
          },
        ),
      );

      setState(() {
        _matchEngine = MatchEngine(swipeItems: _swipeItems);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error al cargar perfiles: ${e.toString()}"),
        duration: Duration(seconds: 2),
      ));
      setState(() {
        _swipeItems = [];
      });
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.user, color: Colors.grey),
          onPressed: () {
            // TODO: Implement profile view
          },
        ),
        title: Icon(FontAwesomeIcons.fire, color: Colors.pink, size: 30),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.comments, color: Colors.grey),
            onPressed: () {
              // TODO: Implement chat view
            },
          ),
        ],
      ),
      body: _swipeItems.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SwipeCards(
                    matchEngine: _matchEngine,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Aqui se pondran las viejas",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                    onStackFinished: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Stack Finished"),
                        duration: Duration(milliseconds: 500),
                      ));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(FontAwesomeIcons.xmark, Colors.red, () {
                        _matchEngine.currentItem?.nope();
                      }),
                      _buildActionButton(FontAwesomeIcons.star, Colors.blue, () {
                        _matchEngine.currentItem?.superLike();
                      }),
                      _buildActionButton(FontAwesomeIcons.heart, Colors.green, () {
                        _matchEngine.currentItem?.like();
                      }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Icon(icon, color: Colors.white),
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
        backgroundColor: color,
      ),
    );
  }
}

class Content {
  final String name;

  Content({required this.name});
}
