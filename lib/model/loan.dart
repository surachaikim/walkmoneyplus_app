import 'dart:ffi';

class Loan {
  String Accountno;
  String AccountName;
  String DatePay;
  String PersonId;
  String DocId;
  String UserId;
  String Amount;
  Loan(
      {required this.Accountno,
      required this.AccountName,
      required this.DatePay,
      required this.PersonId,
      required this.DocId,
      required this.UserId,
      required this.Amount});
}
