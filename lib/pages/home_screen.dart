import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:tinder_app_v2/pages/profile_screen.dart';
import 'package:tinder_app_v2/pages/messages_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<SwipeItem> _swipeItems;
  late MatchEngine _matchEngine;

  @override
  void initState() {
    super.initState();
    _swipeItems = [];
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      final snapshot = await _firestore.collection('users').get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _swipeItems = [];
          _matchEngine = MatchEngine(swipeItems: _swipeItems);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No hay perfiles disponibles."),
          duration: Duration(seconds: 2),
        ));
        return;
      }

      List<SwipeItem> loadedItems = snapshot.docs.map((doc) {
        final userData = doc.data() as Map<String, dynamic>;

        String name = userData['name']?.toString() ?? 'Usuario desconocido';
        String photoUrl = (userData.containsKey('photos') &&
                userData['photos'] != null &&
                (userData['photos'] as List).isNotEmpty)
            ? userData['photos'][0]?.toString() ??
                'https://example.com/default.jpg'
            : 'https://example.com/default.jpg';

        return SwipeItem(
          content: Content(name: name, photoUrl: photoUrl),
          likeAction: () => _showActionSnackBar("Liked $name"),
          nopeAction: () => _showActionSnackBar("Nope $name"),
          superlikeAction: () => _showActionSnackBar("Superliked $name"),
        );
      }).toList();

      setState(() {
        _swipeItems = loadedItems;
        _matchEngine = MatchEngine(swipeItems: _swipeItems);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error al cargar perfiles: ${e.toString()}"),
        duration: Duration(seconds: 2),
      ));
    }
  }

  void _showActionSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 500),
    ));
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
        title: Icon(FontAwesomeIcons.fire, color: Colors.pink, size: 30),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.comments, color: Colors.grey),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessagesScreen()),
              );
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
                      final content = _swipeItems[index].content as Content;
                      return Stack(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: NetworkImage(content.photoUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 30,
                            left: 20,
                            child: Text(
                              content.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    onStackFinished: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("No más perfiles disponibles"),
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
                      _buildActionButton(FontAwesomeIcons.xmark, Colors.red,
                          () {
                        _matchEngine.currentItem?.nope();
                      }),
                      _buildActionButton(FontAwesomeIcons.star, Colors.blue,
                          () {
                        _matchEngine.currentItem?.superLike();
                      }),
                      _buildActionButton(FontAwesomeIcons.heart, Colors.green,
                          () {
                        _matchEngine.currentItem?.like();
                      }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
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
  final String photoUrl;

  Content({required this.name, required this.photoUrl});
}
