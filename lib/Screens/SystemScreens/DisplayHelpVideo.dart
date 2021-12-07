// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// class DisplayHelpVideo extends StatefulWidget {
//   @override
//   _DisplayHelpVideoState createState() => _DisplayHelpVideoState();
// }

// class _DisplayHelpVideoState extends State<DisplayHelpVideo> {
//   YoutubePlayerController _controller;
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _controller = YoutubePlayerController(
//         initialVideoId: "2Ld0IfAfqPc",
//         flags: YoutubePlayerFlags(
//           autoPlay: true,
//           mute: false,
//         ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             child: Center(
//               child: Container(
//                   child: YoutubePlayer(
//                 showVideoProgressIndicator: true,
//                 progressIndicatorColor: Colors.yellow[800],
//                 controller: _controller,
//               )),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
