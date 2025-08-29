import 'dart:ffi';

class Deposit {
  String Accountno;
  String AccountName;
  String MovementDate;
  String PersonId;
  String Type;
  String Amount;
  String DocNo;
  Deposit({
    required this.Accountno,
    required this.AccountName,
    required this.PersonId,
    required this.Type,
    required this.MovementDate,
    required this.Amount,
    required this.DocNo,
  });
}
