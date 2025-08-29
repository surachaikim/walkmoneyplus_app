// กำหนดชื่อตารางไว้ในตัวแปร
final String tableMember = 'member';

// กำหนดฟิลด์ข้อมูลของตาราง
class MemberFields {
  // สร้างเป็นลิสรายการสำหรับคอลัมน์ฟิลด์
  static final List<String> values = [
    id,
    personid,
    title,
    firstName,
    lastName,
    idcard,
    address
  ];

  // กำหนดแต่ละฟิลด์ของตาราง ต้องเป็น String ทั้งหมด
  static final String id = '_id'; // ตัวแรกต้องเป็น _id ส่วนอื่นใช้ชื่อะไรก็ได้
  static final String personid = 'personid';
  static final String title = 'title';
  static final String firstName = 'firstName';
  static final String lastName = 'lastName';
  static final String idcard = 'idcard';
  static final String address = 'address';
  static final String phone = 'phone';
  static final String email = 'email';
}

// ส่วนของ Data Model ของหนังสือ
class Mermbers {
  final int? id; // จะใช้ค่าจากที่ gen ในฐานข้อมูล
  final String personid;
  final String title;
  final String firstName;
  final String lastName;
  final String idcard;
  final String address;
  final String phone;
  final String email;

  // constructor
  const Mermbers({
    this.id,
    required this.personid,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.idcard,
    required this.address,
    required this.phone,
    required this.email,
  });

  // ฟังก์ชั่นสำหรับ สร้างข้อมูลใหม่ โดยรองรับแก้ไขเฉพาะฟิลด์ที่ต้องการ
  Mermbers copy({
    int? id,
    String? personid,
    String? title,
    String? firstName,
    String? lastName,
    String? idcard,
    String? address,
    String? phone,
    String? email,
  }) =>
      Mermbers(
        id: id ?? this.id,
        personid: personid ?? this.personid,
        title: title ?? this.title,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        idcard: idcard ?? this.idcard,
        address: address ?? this.address,
        phone: phone ?? this.phone,
        email: email ?? this.email,
      );

  // สำหรับแปลงข้อมูลจาก Json เป็น Book object
  static Mermbers fromJson(Map<String, Object?> json) => Mermbers(
        id: json[MemberFields.id] as int?,
        personid: json[MemberFields.personid] as String,
        title: json[MemberFields.title] as String,
        firstName: json[MemberFields.firstName] as String,
        lastName: json[MemberFields.lastName] as String,
        idcard: json[MemberFields.idcard] as String,
        address: json[MemberFields.address] as String,
        phone: json[MemberFields.phone] as String,
        email: json[MemberFields.email] as String,
      );

  // สำหรับแปลง Book object เป็น Json บันทึกลงฐานข้อมูล
  Map<String, Object?> toJson() => {
        MemberFields.id: id,
        MemberFields.personid: personid,
        MemberFields.title: title,
        MemberFields.firstName: firstName,
        MemberFields.lastName: lastName,
        MemberFields.idcard: idcard,
        MemberFields.address: address,
        MemberFields.phone: phone,
        MemberFields.email: email,
      };
}
