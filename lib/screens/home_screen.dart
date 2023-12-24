import 'package:chat_app/model/user.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void signOut() {
    AuthService().signOut();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C81AD),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: signOut,
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ))
        ],
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("error");
          }
          if ((snapshot.data?.docs ?? []).isEmpty || snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }
          //success
          final maplist = snapshot.data!.docs
              .map((e) => e.data() as Map<String, dynamic>)
              .toList();

          final item =
              maplist.firstWhere((i) => i['email'] == _auth.currentUser?.email);
          maplist.remove(item);

          final classList = maplist.map((e) => UserClass.fromMap(e));
          
          return ListView(
            children:classList
                .map<Widget>((doc) => _buildUserListItem(doc))
                .toList(),
          );
        });
  }

  Widget _buildUserListItem(UserClass user) {
    return ListTile(
      title: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(left: 10, right: 10, top: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF7C81AD)),
        child: Center(
            child: Text(
          user.email,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        )),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
                receiverUserEmail: user.email, receiverUserId: user.uid),
          ),
        );
      },
    );
  }
}
