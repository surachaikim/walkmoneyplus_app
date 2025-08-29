import 'package:collection/collection.dart';

class Member {
  String? cusId;
  String? branchId;
  String? personId;
  String? memberType;
  String? dateMember;
  String? title;
  String? firstName;
  String? lastName;
  String? code;
  String? idcard;
  String? birthday;
  String? sex;
  String? phone;
  String? addrNo;
  String? moo;
  String? road;
  String? soi;
  String? locality;
  String? district;
  String? province;
  String? zipCode;
  String? addrNo1;
  String? moo1;
  String? road1;
  String? soi1;
  String? locality1;
  String? district1;
  String? province1;
  String? zipCode1;
  String? barcodeId;
  String? userLineId;

  Member({
    this.cusId,
    this.branchId,
    this.personId,
    this.memberType,
    this.dateMember,
    this.title,
    this.firstName,
    this.lastName,
    this.code,
    this.idcard,
    this.birthday,
    this.sex,
    this.phone,
    this.addrNo,
    this.moo,
    this.road,
    this.soi,
    this.locality,
    this.district,
    this.province,
    this.zipCode,
    this.addrNo1,
    this.moo1,
    this.road1,
    this.soi1,
    this.locality1,
    this.district1,
    this.province1,
    this.zipCode1,
    this.barcodeId,
    this.userLineId,
  });

  @override
  String toString() {
    return 'Member(cusId: $cusId, branchId: $branchId, personId: $personId, memberType: $memberType, dateMember: $dateMember, title: $title, firstName: $firstName, lastName: $lastName, code: $code, idcard: $idcard, birthday: $birthday, sex: $sex, phone: $phone, addrNo: $addrNo, moo: $moo, road: $road, soi: $soi, locality: $locality, district: $district, province: $province, zipCode: $zipCode, addrNo1: $addrNo1, moo1: $moo1, road1: $road1, soi1: $soi1, locality1: $locality1, district1: $district1, province1: $province1, zipCode1: $zipCode1, barcodeId: $barcodeId, userLineId: $userLineId)';
  }

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        cusId: json['cusID'] as String?,
        branchId: json['branchID'] as String?,
        personId: json['personId'] as String?,
        memberType: json['memberType'] as String?,
        dateMember: json['dateMember'] as String?,
        title: json['title'] as String?,
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        code: json['code'] as String?,
        idcard: json['idcard'] as String?,
        birthday: json['birthday'] as String?,
        sex: json['sex'] as String?,
        phone: json['phone'] as String?,
        addrNo: json['addrNo'] as String?,
        moo: json['moo'] as String?,
        road: json['road'] as String?,
        soi: json['soi'] as String?,
        locality: json['locality'] as String?,
        district: json['district'] as String?,
        province: json['province'] as String?,
        zipCode: json['zipCode'] as String?,
        addrNo1: json['addrNo1'] as String?,
        moo1: json['moo1'] as String?,
        road1: json['road1'] as String?,
        soi1: json['soi1'] as String?,
        locality1: json['locality1'] as String?,
        district1: json['district1'] as String?,
        province1: json['province1'] as String?,
        zipCode1: json['zipCode1'] as String?,
        barcodeId: json['barcodeId'] as String?,
        userLineId: json['userLineId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'cusID': cusId,
        'branchID': branchId,
        'personId': personId,
        'memberType': memberType,
        'dateMember': dateMember,
        'title': title,
        'firstName': firstName,
        'lastName': lastName,
        'code': code,
        'idcard': idcard,
        'birthday': birthday,
        'sex': sex,
        'phone': phone,
        'addrNo': addrNo,
        'moo': moo,
        'road': road,
        'soi': soi,
        'locality': locality,
        'district': district,
        'province': province,
        'zipCode': zipCode,
        'addrNo1': addrNo1,
        'moo1': moo1,
        'road1': road1,
        'soi1': soi1,
        'locality1': locality1,
        'district1': district1,
        'province1': province1,
        'zipCode1': zipCode1,
        'barcodeId': barcodeId,
        'userLineId': userLineId,
      };

  Member copyWith({
    String? cusId,
    String? branchId,
    String? personId,
    String? memberType,
    String? dateMember,
    String? title,
    String? firstName,
    String? lastName,
    String? code,
    String? idcard,
    String? birthday,
    String? sex,
    String? phone,
    String? addrNo,
    String? moo,
    String? road,
    String? soi,
    String? locality,
    String? district,
    String? province,
    String? zipCode,
    String? addrNo1,
    String? moo1,
    String? road1,
    String? soi1,
    String? locality1,
    String? district1,
    String? province1,
    String? zipCode1,
    String? barcodeId,
    String? userLineId,
  }) {
    return Member(
      cusId: cusId ?? this.cusId,
      branchId: branchId ?? this.branchId,
      personId: personId ?? this.personId,
      memberType: memberType ?? this.memberType,
      dateMember: dateMember ?? this.dateMember,
      title: title ?? this.title,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      code: code ?? this.code,
      idcard: idcard ?? this.idcard,
      birthday: birthday ?? this.birthday,
      sex: sex ?? this.sex,
      phone: phone ?? this.phone,
      addrNo: addrNo ?? this.addrNo,
      moo: moo ?? this.moo,
      road: road ?? this.road,
      soi: soi ?? this.soi,
      locality: locality ?? this.locality,
      district: district ?? this.district,
      province: province ?? this.province,
      zipCode: zipCode ?? this.zipCode,
      addrNo1: addrNo1 ?? this.addrNo1,
      moo1: moo1 ?? this.moo1,
      road1: road1 ?? this.road1,
      soi1: soi1 ?? this.soi1,
      locality1: locality1 ?? this.locality1,
      district1: district1 ?? this.district1,
      province1: province1 ?? this.province1,
      zipCode1: zipCode1 ?? this.zipCode1,
      barcodeId: barcodeId ?? this.barcodeId,
      userLineId: userLineId ?? this.userLineId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Member) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode =>
      cusId.hashCode ^
      branchId.hashCode ^
      personId.hashCode ^
      memberType.hashCode ^
      dateMember.hashCode ^
      title.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      code.hashCode ^
      idcard.hashCode ^
      birthday.hashCode ^
      sex.hashCode ^
      phone.hashCode ^
      addrNo.hashCode ^
      moo.hashCode ^
      road.hashCode ^
      soi.hashCode ^
      locality.hashCode ^
      district.hashCode ^
      province.hashCode ^
      zipCode.hashCode ^
      addrNo1.hashCode ^
      moo1.hashCode ^
      road1.hashCode ^
      soi1.hashCode ^
      locality1.hashCode ^
      district1.hashCode ^
      province1.hashCode ^
      zipCode1.hashCode ^
      barcodeId.hashCode ^
      userLineId.hashCode;
}
