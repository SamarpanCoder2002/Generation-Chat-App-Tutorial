import 'dart:io';

import 'package:generation/Global_Uses/enum_generation.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  /// For Important Table
  final String _importantTableData = "__Important_Table_Data__"; // Table Name

  // All Columns
  final String _colUserName = "User_Name";
  final String _colUserMail = "User_Mail";
  final String _colToken = "User_Device_Token";
  final String _colProfileImagePath = "Profile_Image_Path";
  final String _colProfileImageUrl = "Profile_Image_Url";
  final String _colAbout = "About";
  final String _colWallpaper = "Chat_Wallpaper";
  final String _colNotification = "Notification_Status";
  final String _colMobileNumber = "User_Mobile_Number";
  final String _colAccCreationDate = "Account_Creation_Date";
  final String _colAccCreationTime = "Account_Creation_Time";

  /// For Status Management
  /// final String _userStatusData = "__User_Status_Data__";

  // All Columns
  final String _colActivity = "Activity_path";
  final String _colActivityTime = "Activity_time";
  final String _colActivityMediaType = "Activity_media";
  final String _colActivityExtraText = "Activity_Extra_Text";
  final String _colActivityBGInformation = "Activity_BG_Information";

  /// Create Singleton Objects(Only Created once in the whole application)
  static late LocalDatabase _localStorageHelper = LocalDatabase._createInstance();
  static late Database _database;

  /// Instantiate the obj
  LocalDatabase._createInstance(); // Named Constructor

  /// For access Singleton object
  factory LocalDatabase() {
    _localStorageHelper = LocalDatabase._createInstance();
    return _localStorageHelper;
  }

  /// Getter for taking instance of database
  Future<Database> get database async {
    _database = await initializeDatabase();
    return _database;
  }

  /// For make a database
  Future<Database> initializeDatabase() async {
    /// Get the directory path to store the database
    final String desirePath = await getDatabasesPath();

    final Directory newDirectory =
        await Directory(desirePath + '/.Databases/').create();
    final String path = newDirectory.path + '/generation_local_storage.db';

    // create the database
    final Database getDatabase = await openDatabase(path, version: 1);
    return getDatabase;
  }

  /// Table for store important data Table
  Future<void> createTableToStoreImportantData() async {
    try {
      final Database db = await this.database;
      await db.execute(
          "CREATE TABLE ${this._importantTableData}($_colUserName TEXT PRIMARY KEY, $_colUserMail TEXT, $_colToken TEXT, $_colProfileImagePath TEXT, $_colProfileImageUrl TEXT, $_colAbout TEXT, $_colWallpaper TEXT, $_colNotification TEXT, $_colMobileNumber TEXT, $_colAccCreationDate TEXT, $_colAccCreationTime TEXT)");

      print('User Important table creatred');

    } catch (e) {
      print('Error in Create Import Table: ${e.toString()}');
    }
  }

  /// Insert or Update From Important Data Table
  Future<void> insertOrUpdateDataForThisAccount({
    required String userName,
    required String userMail,
    required String userToken,
    required String userAbout,
    required String userAccCreationDate,
    required String userAccCreationTime,
    String chatWallpaper = '',
    String profileImagePath = '',
    String profileImageUrl = '',
    String purpose = 'insert',
  }) async {
    try {
      final Database db = await this.database;

      if (purpose != 'insert') {
        final int updateResult = await db.rawUpdate(
            "UPDATE $_importantTableData SET $_colToken = '$userToken', $_colAbout = '$userAbout', $_colUserMail = '$userMail', $_colAccCreationDate = '$userAccCreationDate', $_colAccCreationTime = '$userAccCreationTime' WHERE $_colUserName = '$userName'");

        print('Update Result is: $updateResult');
      } else {
        final Map<String, dynamic> _accountData = Map<String, dynamic>();

        _accountData[_colUserName] = userName;
        _accountData[_colUserMail] = userMail;
        _accountData[_colToken] = userToken;
        _accountData[_colProfileImagePath] = profileImagePath;
        _accountData[_colProfileImageUrl] = profileImageUrl;
        _accountData[_colAbout] = userAbout;
        _accountData[_colWallpaper] = chatWallpaper;
        _accountData[_colMobileNumber] = '';
        _accountData[_colNotification] = "1";
        _accountData[_colAccCreationDate] = userAccCreationDate;
        _accountData[_colAccCreationTime] = userAccCreationTime;

        await db.insert(this._importantTableData, _accountData);
      }
    } catch (e) {
      print('Error in Insert or Update Important Data Table: ${e.toString()}');
    }
  }

  /// For Make Table for Status
  Future<bool> createTableForUserActivity({required String tableName}) async {
    final Database db = await this.database;
    try {
      await db.execute(
          "CREATE TABLE ${tableName}_status($_colActivity, $_colActivityTime TEXT PRIMARY KEY, $_colActivityMediaType TEXT, $_colActivityExtraText TEXT, $_colActivityBGInformation TEXT)");

      print('User Activity table creatred');

      return true;
    } catch (e) {
      print("Error in Create Table For Status: ${e.toString()}");
      return false;
    }
  }

  /// Insert ActivityData to Activity Table
  Future<bool> insertDataInUserActivityTable(
      {required String tableName,
      required String statusLinkOrString,
      required StatusMediaTypes mediaTypes,
      required String activityTime,
      String extraText = '',
      String bgInformation = ''}) async {
    try {
      final Database db = await this.database;
      final Map<String, dynamic> _activityStoreMap = Map<String, dynamic>();

      _activityStoreMap[_colActivity] = statusLinkOrString;
      _activityStoreMap[_colActivityTime] = activityTime;
      _activityStoreMap[_colActivityMediaType] = mediaTypes.toString();
      _activityStoreMap[_colActivityExtraText] = extraText;
      _activityStoreMap[_colActivityBGInformation] = bgInformation;

      /// Result Insert to DB
      final int result =
          await db.insert('${tableName}_status', _activityStoreMap);

      return result > 0 ? true : false;
    } catch (e) {
      print('Error: Activity Table Data insertion Error: ${e.toString()}');
      return false;
    }
  }
}
