import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:tinder_app_v2/pages/profile_screen.dart';
import 'package:tinder_app_v2/pages/messages_screen.dart';
import 'package:tinder_app_v2/pages/info_profile.dart'; // Add this import

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
  String? _actionMessage;

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
        _showTemporaryMessage("No hay perfiles disponibles.");
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
        String? bio = userData['bio']?.toString();
        int? age = userData['age'] as int?;

        return SwipeItem(
          content: Content(name: name, photoUrl: photoUrl, bio: bio, age: age),
          likeAction: () => _showTemporaryMessage("Liked $name"),
          nopeAction: () => _showTemporaryMessage("Nope $name"),
          superlikeAction: () => _showTemporaryMessage("Superliked $name"),
        );
      }).toList();

      setState(() {
        _swipeItems = loadedItems;
        _matchEngine = MatchEngine(swipeItems: _swipeItems);
      });
    } catch (e) {
      _showTemporaryMessage("Error al cargar perfiles: ${e.toString()}");
    }
  }

  void _showTemporaryMessage(String message) {
    setState(() {
      _actionMessage = message;
    });

    Timer(Duration(seconds: 1), () {
      setState(() {
        _actionMessage = null;
      });
    });
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
          : Stack(
              children: [
                SwipeCards(
                  matchEngine: _matchEngine,
                  itemBuilder: (BuildContext context, int index) {
                    final content = _swipeItems[index].content as Content;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InfoProfile(profile: content),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                              image: DecorationImage(
                                image: NetworkImage(content.photoUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 100,
                            left: 50,
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
                      ),
                    );
                  },
                  onStackFinished: () {
                    _showTemporaryMessage("No más perfiles disponibles");
                  },
                ),
                if (_actionMessage != null)
                  Positioned(
                    top: 250,
                    left: 20,
                    right: 20,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromARGB(0, 255, 255, 255).withOpacity(0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Text(
                          _actionMessage!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20,
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
  final String? bio;
  final int? age;

  Content({required this.name, required this.photoUrl, this.bio, this.age});
}