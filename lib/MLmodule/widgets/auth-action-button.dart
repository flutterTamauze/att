// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:qr_users/MLmodule/db/database.dart';
// import 'package:qr_users/MLmodule/services/camera.service.dart';
// import 'package:qr_users/MLmodule/services/facenet.service.dart';

// import 'app_text_field.dart';

// class AuthActionButton extends StatefulWidget {
//   AuthActionButton(this._initializeControllerFuture,
//       {Key key, @required this.onPressed, @required this.isLogin, this.reload});
//   final Future _initializeControllerFuture;
//   final Function onPressed;
//   final bool isLogin;
//   final Function reload;
//   @override
//   _AuthActionButtonState createState() => _AuthActionButtonState();
// }

// class _AuthActionButtonState extends State<AuthActionButton> {
//   /// service injection
//   // final FaceNetService _faceNetService = FaceNetService();
//   // final DataBaseService _dataBaseService = DataBaseService();
//   // final CameraService _cameraService = CameraService();

//   final TextEditingController _userTextEditingController =
//       TextEditingController(text: '');
//   final TextEditingController _passwordTextEditingController =
//       TextEditingController(text: '');

//   Future signUp(context) async {
//     /// gets predicted data from facenet service (user face detected)
//     List predictedData = _faceNetService.predictedData;
//     String user = _userTextEditingController.text;
//     String password = _passwordTextEditingController.text;

//     // / creates a new user in the 'database'
//     await _dataBaseService.saveData(user, password, predictedData);

//     // / resets the face stored in the face net sevice
//     this._faceNetService.setPredictedData(null);
//   }

//   String _predictUser() {
//     String userAndPass = _faceNetService.predict();
//     return userAndPass ?? null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () async {
//         try {
//           // Ensure that the camera is initialized.
//           await widget._initializeControllerFuture;
//           // onShot event (takes the image and predict output)
//           bool faceDetected = await widget.onPressed();

//           if (faceDetected) {}
//         } catch (e) {
//           // If an error occurs, log the error to the console.
//          print(e);
//         }
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: Color(0xFF0F0BDB),
//           boxShadow: <BoxShadow>[
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.1),
//               blurRadius: 1,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         alignment: Alignment.center,
//         padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//         width: MediaQuery.of(context).size.width * 0.8,
//         height: 60,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'CAPTURE',
//               style: TextStyle(color: Colors.white),
//             ),
//             SizedBox(
//               width: 10,
//             ),
//             Icon(Icons.camera_alt, color: Colors.white)
//           ],
//         ),
//       ),
//     );
//   }
// }
