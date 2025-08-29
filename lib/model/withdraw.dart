import 'dart:ffi';

class Withdraw {
  String Accountno;
  String AccountName;
  String MovementDate;
  String PersonId;
  String Type;
  String Amount;
  Withdraw(
      {required this.Accountno,
      required this.AccountName,
      required this.PersonId,
      required this.Type,
      required this.MovementDate,
      required this.Amount});
}
