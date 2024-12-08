import 'package:path/path.dart';
import 'package:socket_io_client/socket_io_client.dart'
    as IO; // Ensure you import this
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Singleton pattern for DatabaseHelper
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;
  late IO.Socket _socketClient; // Define socket client variable

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(); // Initialize database if not present
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create users table if it doesn't exist
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            email TEXT UNIQUE
          )
        ''');
      },
    );
  }

  Future<void> insertUser(String email) async {
    final db = await database;

    await db.insert(
      'users',
      {'email': email},
      conflictAlgorithm: ConflictAlgorithm.ignore, // Ignore if user exists
    );

    // Debug print for tracking user insertion
    print('User inserted: $email');

    // Initialize Socket.IO client and emit create_user event
    _socketClient = IO.io('YOUR_SOCKET_SERVER_URL', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    try {
      _socketClient.connect(); // Connect to Socket.IO server
      _socketClient.onConnect((_) {
        print('Socket connected'); // Debug print for connection confirmation
      });

      // Emit the create_user event through Socket.IO
      _socketClient.emit('create_user', {'email': email});
      print(
          'Emitted create_user event for: $email'); // Debug print for emitted event
    } catch (e) {
      print(
          'Error connecting to Socket.IO: $e'); // Debug print for any connection error
    }
  }

  Future<Map<String, dynamic>?> getUser(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    // Debug print for user retrieval
    print('Fetching user with email: $email');
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> userExists(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    // Debug print for user existence check
    print('Checking if user exists with email: $email');
    return result.isNotEmpty; // Return true if email exists
  }
}
