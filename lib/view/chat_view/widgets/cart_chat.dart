
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class CartChat extends StatelessWidget {
  const CartChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.maxFinite,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey)
      ),
        child: Row(children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(radius: 30,),
          ),
          SizedBox(width: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            Row(
              children: [
                Text("hiba" , style: TextStyle(fontWeight: FontWeight.bold , fontSize: 18,color: Colors.black),),
                SizedBox(width: MediaQuery.of(context).size.width*0.6,),
                Text("13/05/2025" , style: TextStyle( fontSize: 16,color: Colors.grey),),
              ],
            ),
              Text("hi chiraz" , style: TextStyle(fontSize: 16 , color: Colors.grey),


          )],)
        ],),
      ),
    );
  }
}
