import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = "contactTable";
final String idColumn    = "idColumn";
final String nameColumn  = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imageColumn = "imageColumn";

class ContactHelper{

  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async{
    if(db!= null)
      return _db;
    return _db = await initDB() ;
  }

  Future<Contact> saveContact(Contact contact) async{
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async{
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(
        contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imageColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);

    if(maps.length >0)
      return Contact.fromMap(maps.first);
    return null;
  }

  Future<int> deleteContact(int id) async{
    Database dbContact = await db;
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async{
    Database dbContact = await db;
    return await dbContact.update(
        contactTable,
        contact.toMap(),
        where: "$idColumn = ?",
        whereArgs: [contact.id]);
  }

  Future<Database> initDB() async {
    final dataBasePath = await getDatabasesPath();
    final path = join(dataBasePath, "contacts.db");
    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async{
      await db.execute(
        "CREATE TABLE $contactTable("
            "$idColumn INTEGER PRIMARY KEY, "
            "$nameColumn TEXT, "
            "$emailColumn TEXT, "
            "$phoneColumn TEXT, "
            "$imageColumn TEXT)"
      );

    });
  }
}

class Contact{
  int id;
  String name;
  String email;
  String phone;
  String image;

  Contact.fromMap(Map map){
    id = map[idColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    image = map[imageColumn];
    name = map[nameColumn];
  }

  Map toMap(){
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imageColumn: image
    };
    if(id != null)
      map[idColumn] = id;
    return map;
  }

  @override
  String toString() {
    return "Contact( nome:$name email:$email phone:$phone image:$image)";
  }


}