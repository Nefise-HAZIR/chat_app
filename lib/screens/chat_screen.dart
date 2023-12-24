import 'package:chat_app/model/message.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/widgets/my_text_field.dart';
import 'package:chat_app/widgets/chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserId;
  const ChatScreen(
      {super.key,
      required this.receiverUserEmail,
      required this.receiverUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List messages=[];

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserId, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        backgroundColor: const Color(0xFF7C81AD),
        title: Text(widget.receiverUserEmail,style: const TextStyle(color: Colors.white),),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessage(
            widget.receiverUserId, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Error${snapshot.error}");
          }
          if ((snapshot.data?.docs ?? []).isEmpty || snapshot.connectionState == ConnectionState.waiting ) {
            return const Center(child: CircularProgressIndicator(),);
          }
         
          //success
          for (var i = 0; i < snapshot.data!.docs.length; i++) {
            var myQueryData = snapshot.data!.docs[i];
            var myMapData = myQueryData.data() as Map<String, dynamic>;

            // MessageClass myMessage = MessageClass(
            //   senderId: myMapData['senderId'],
            //   senderEmail: myMapData['senderEmail'],
            //   receiverId: myMapData['receiverId'],
            //   message: myMapData['message'],
            //   timestamp: myMapData['timestamp'],
            // );

            MessageClass myMessage = MessageClass.fromMap(myMapData);

           //MessageClass myMessage2 = MessageClass.fromMap3(myMapData);

            messages.add(myMessage);
          }

          return ListView(children: [
            for (var i = 0; i < messages.length; i++)
              _buildMessageItem2(messages[i])
          ]);
        });
  }

  Widget _buildMessageItem2(MessageClass messageClass) {
    var alignment = (messageClass.senderId == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              (messageClass.senderId == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [
            Text(
              messageClass.senderEmail,
              style: const TextStyle(color: Color(0xFF435585)),
            ),
            const SizedBox(
              height: 5,
            ),
            ChatBubble(message: messageClass.message),
          ],
        ),
      ),
    );
  }

  // Widget _buildMessageItem(DocumentSnapshot document) {
  //   Map<String, dynamic> data = document.data() as Map<String, dynamic>;

  //   var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
  //       ? Alignment.centerRight
  //       : Alignment.centerLeft;
  //   return Container(
  //     alignment: alignment,
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Column(
  //         crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
  //             ? CrossAxisAlignment.end
  //             : CrossAxisAlignment.start,
  //         children: [
  //           Text(data['senderEmail'],style:TextStyle(color:  Color(0xFF435585)),),
  //           const SizedBox(height:5,),
  //           ChatBubble(message: data['message']),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMessageInput() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF7C81AD)
      ),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
                hintText: "Enter your message", controller: _messageController),
          ),
          IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.arrow_upward,
                size: 40,
                color: Colors.white,
              ))
        ],
      ),
    );
  }
}
