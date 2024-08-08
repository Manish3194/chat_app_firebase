import 'package:chatting_app_demo/api/api.dart';
import 'package:chatting_app_demo/model/message.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatelessWidget {
  final Message message;

  const MessageCard({Key? key, required this.message, required String formattedTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Align(
        alignment: message.fromId == APIs.user?.uid ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: message.fromId == APIs.user?.uid ? Colors.blueAccent : Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.msg,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 5),
              Text(
                _formatTimestamp(message.sent),
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    return "${dateTime.hour}:${dateTime.minute}";
  }
}



/*
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app_demo/api/api.dart';
import 'package:chatting_app_demo/helper/my_date_util.dart';
import 'package:chatting_app_demo/model/message.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }

  Widget _blueMessage() {

    //update last read message if sender and receiver are diffrent
    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(Checkbox.width),
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.lightBlue),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                )),
            child: widget.message.type == Type.text ?

            Text(

              MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ):ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                  height: 30,
                  width: 30,
                  imageUrl: widget.message.msg,
                  errorWidget: (context, url, error) =>
                      CircleAvatar(
                        child: Icon(Icons.image,size: 70,),
                      )),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            widget.message.sent,
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
        ),

      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Row(
          children: [
            SizedBox(width: 10,),

            if(widget.message.read.isNotEmpty)
            Icon(Icons.done_all_rounded,color: Colors.blue,),
            Text(
              MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(Checkbox.width),
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            decoration: BoxDecoration(
                color: Colors.green[200],
                border: Border.all(color: Colors.lightGreen),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )),
            child: widget.message.type == Type.text ?

            Text(

              MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ):ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                  //height: 30,
                  //width: 30,
                  imageUrl: widget.message.msg,
                  placeholder: (context,url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      CircleAvatar(
                        child: Icon(Icons.image,size: 70,),
                      )),
            ),
          ),
        ),

      ],
    );
  }
}
*/
