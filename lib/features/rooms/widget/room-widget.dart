import 'package:flutter/material.dart';
import 'package:tambarara_house_keeping/features/rooms/model/room-model.dart';

class RoomWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 50,
        color: Colors.blue,

        child: Column(children: [
          Text("222"),
          Text("Clean"),
        ]),
      ),
    );
  }
}
