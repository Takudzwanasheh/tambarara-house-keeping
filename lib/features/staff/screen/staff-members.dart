import 'package:flutter/material.dart';

class StaffMembers extends StatelessWidget {
  const StaffMembers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Staff Members")),
      ),
      body: Center(
        child: Container(
          child:
            Text("No Members found",style: TextStyle(color: Colors.grey),)
        ),
      ),
    );
  }
}
