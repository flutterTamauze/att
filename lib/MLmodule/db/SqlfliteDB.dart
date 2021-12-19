import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

import 'package:qr_users/FirebaseCloudMessaging/NotificationMessage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _dbName = "cache.db";
  static Database _database;
  /////////Notifications///////
  static final _notificationTableName = "NotificationTable";
  static final _notificationColTitle = "title";
  static final _notificationColMsgSeen = "seen";
  static final _notificationColMsg = "message";
  static final _notificationColMessageTime = "timeMessage";
  static final _notificationColDate = "date";
  static final _notificationColId = "id";
  static final _notificationColCategory = "category";
  DatabaseHelper() {
    database;
  }
  //Initializting the database opening a path with the directory.
  initializedDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    var myOwnDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return myOwnDb;
  }

  //Creating tables inside the database
  _onCreate(Database db, int newVersion) async {
    await db.execute('''
        CREATE TABLE $_notificationTableName($_notificationColId INTEGER PRIMARY KEY ,$_notificationColTitle TEXT NOT NULL,$_notificationColMsg TEXT NOT NULL ,$_notificationColDate TEXT NOT NULL  ,$_notificationColCategory TEXT ,$_notificationColMsgSeen INTEGER NOT NULL,$_notificationColMessageTime)
        ''');
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializedDatabase();
      return _database;
    }
    return _database;
  } ////////////////////////////RATES////////////

  //////////////////////notifications//////
  Future<int> insertNotification(
      NotificationMessage notificationMessage, BuildContext context) async {
    int id = await _database
        .insert(_notificationTableName, notificationMessage.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .catchError((e) {
      print(e);
    });
    print("Notification added$id");
    return id;
  }

  Future<void> insertOfflineNotification(
    NotificationMessage notificationMessage,
  ) async {
    try {
      await _database
          .insert(_notificationTableName, notificationMessage.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace)
          .then((value) async {
        print("Notification $value");
      }).catchError((e) {
        print(e);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<List<NotificationMessage>> getAllNotifications() async {
    try {
      final List<Map<String, dynamic>> notifis =
          await _database.query(_notificationTableName).catchError((e) {
        print(e);
      });
      return List.generate(notifis.length, (index) {
        return NotificationMessage(
            id: notifis[index]["id"],
            category: notifis[index]["category"],
            dateTime: notifis[index]["date"],
            message: notifis[index]["message"],
            timeOfMessage: notifis[index]["timeMessage"],
            messageSeen: notifis[index]["seen"],
            title: notifis[index]["title"]);
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  clearNotifications() async {
    try {
      bool databaseDeleted = false;

      try {
        Directory documentsDirectory = await getApplicationDocumentsDirectory();
        String path = join(documentsDirectory.path, _dbName);
        _database = null;
        await deleteDatabase(path).whenComplete(() {
          databaseDeleted = true;
          print("db deleted");
        }).catchError((onError) {
          databaseDeleted = false;
        });
      } on DatabaseException catch (error) {
        print(error);
      } catch (error) {
        print(error);
      }

      return databaseDeleted;
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteByID(
    int id,
  ) async {
    try {
      await _database.rawQuery(
          'DELETE FROM $_notificationTableName WHERE $_notificationColId=?',
          [id]).then((value) {
        print("delete $value $id");
      }).catchError((e) {
        print(e);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> checkNotificationStatus() async {
    bool bol;
    await getAllNotifications().then((value) {
      if (value == null || value.isEmpty) {
        bol = false;
      } else {
        bol = true;
      }
    });
    return bol;
  }

  Future<void> readMessage(int value, int id) async {
    try {
      int updateCount = await _database.rawUpdate(
          'UPDATE $_notificationTableName  SET $_notificationColMsgSeen = ? WHERE $_notificationColId=? ',
          [value, id]);

      print(updateCount);
    } catch (e) {
      print(e);
    }
  }
}
