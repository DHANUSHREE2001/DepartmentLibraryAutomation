import 'package:flutter/material.dart';

class Privileges {
  static const int SuperAdmin = 1;
  static const int Admin = 2;
  static const int User = 4;
}

class Avail {
  static const int Online = 1;
  static const int Offline = 2;
}

class RequestStatus {
  static const int processing = 1;
  static const int approved = 2;
  static const int declined = 4;
}
// Template for complex data

class OutstandingListData {
  late String BorrowID;
  late String ISBN;
  late String DueDate;
  late String UserName;
  late String ReturnDate;
  OutstandingListData(
      this.BorrowID, this.ISBN, this.UserName, this.DueDate, this.ReturnDate);
}

class BookData {
  late String ISBN;
  late String BookName;
  late String Author;
  late int Availability;
  late int Type;
  late String Thumbnail;

  BookData(this.ISBN, this.BookName, this.Author, this.Availability, this.Type,
      this.Thumbnail);
}

class BookRequestData {
  late String Request;
  late String BookName;
  late String Author;
  late String RequestedBy;
  late String Status;
  late String Reason;

  BookRequestData(this.Request, this.BookName, this.Author, this.RequestedBy,
      this.Status, this.Reason);
}

class MagazineData {
  late String Name;
  late String Volume;
  late String Issue;
  late String ReleaseDate;
  late String Location;

  MagazineData(
      this.Name, this.Volume, this.Issue, this.ReleaseDate, this.Location);
}

class SubscriptionData {
  late String JournalName;
  late String UserName;
  late String Email;

  SubscriptionData(this.JournalName, this.UserName, this.Email);
}

class SubscriptionRequestData {
  late String JournalName;
  late String UserName;
  late String Email;
  late int Status;

  SubscriptionRequestData(
      this.JournalName, this.UserName, this.Email, this.Status);
}

class SubscriptionRequestDataAdmin {
  late int id;
  late String JournalName;
  late String UserName;
  late String Email;
  late int Status;

  SubscriptionRequestDataAdmin(
      this.id, this.JournalName, this.UserName, this.Email, this.Status);
}

class BookIssue {
  late int IssueID;
  late String ISBN;
  late String Username;
  late String DateIssued;
  late String BookName;

  BookIssue(
      this.IssueID, this.ISBN, this.Username, this.DateIssued, this.BookName);
}

class BookTaken {
  late String ISBN;
  late String DateIssued;
  late String BookName;

  BookTaken(this.ISBN, this.DateIssued, this.BookName);
}

class TotalBudget {
  late String type;
  late String BudgetID, Src, Amount, UsedAmt;
  TotalBudget(this.BudgetID, this.Src, this.Amount, this.UsedAmt, this.type);
}

class remainingBudget{
  late String type;
  late String sum;
  remainingBudget(this.type,this.sum);
}

class BudgetDistribution{
  late String InvestedOn;
  late String Amount;
  BudgetDistribution(this.InvestedOn,this.Amount);
}
// All the class below here are associated with Header class that of handling  API request and response
class Header {
  static const String Split = "||";
  static const String Error = "Error";
  static const String Success = "Success";
  static const String Failed = "Failed";
  static const String Login = "Login";
}

class Error {
  static const String Breach = "Breach";
  static const String Unknown = "Unknown";
  static const String Unavailable = "Unavailable";
}

class Failure {
  static const String Credentials = "Credentials";
  static const String Exist = "Exists";
  static const String Server = "Server";
}

class Handler {
  static const String Handler1 = "Handler1";
}

class Create {
  static const String User = "CreateUser";
  static const String Admin = "CreateAdmin";
}

class Update {
  static const String Password = "UpdatePassword";
  static const String BookRecord = "UpdateRecord";
  static const String BookRequest = "UpdateBookRequestStatus";
  static const String MagazineRequest = "UpdateMagazineRequestStatus";
  static const String MagazineRecord = "UpdateMagazineRecordStatus";
  static const String UserStatus = "UpdateUserStatus";
}

class Remove {
  static const String UserRecord = "RemoveUserRecord";
  static const String DeleteHistory = "RemoveDeleteHistory";
  static const String DeleteBook = "RemoveBook";
}

class Fetch {
  static const String DigitalBooks = "DigitalFetchBooks";
  static const String BookRecord = "FetchBooks";
  static const String News = "FetchNews";
  static const String BookRequest = "FetchBookRequest";
  static const String BookRequestStatus = "FetchBookRequestStatus";
  static const String MyMagazineRequest = "FetchMySubscriptionRequest";
  static const String MySubscription = "FetchMySubscription";
  static const String MagazineRequest = "FetchSubscriptionRequest";
  static const String CurrentSubscription = "FetchCurrentSubscription";
  static const String DueUsers = "FetchDueUsers";
  static const String TotalBudget = "FetchTotalBudget";
  static const String RemainingBudget = "FetchRemainingBudget";
  static const String BudgetDistribution = "FetchBudgetDistribution";
  static const String BookSuggestion = "FetchBookSuggestion";
  static const String BooksIssuedToUser = "FetchBooksIssuedToUser";
  static const String UserIssuedBook = "FetchUserIssuedBook";
  static const String DeleteHistory = "FetchDeleteHistory";
}

class Search {
  static const String Books = "SearchBooks";
  static const String Magazines = "SearchMagazine";
}

class BookParams {
  static const String ISBN = "ISBN";
  static const String Name = "Name";
  static const String Author = "Author";
  static const String Type = "Type";
}

class MagazineParams {
  static const String Name = "MagazineName";
  static const String Author = "Author";
}

class Categories {
  static const String Business = "business";
  static const String Entertainment = "entertainment";
  static const String General = "general";
  static const String Health = "health";
  static const String Science = "science";
  static const String Sports = "sports";
  static const String Technology = "technology";
}

class Add {
  static const String BookRecord = "AddBookRecord";
  static const String BookRequest = "AddBookRequest";
  static const String MagazineRecord = "AddMagazineRecord";
  static const String MagazineSubscriptionRequest = "AddSubscriptionRequest";
  static const String BookIssue = "AddBookIssue";
  static const String BookReserve = "AddBookReserve";
  static const String BookRenewal = "AddBookRenewal";
  static const String BookReturn = "AddBookReturn";
  static const String FinePayment = "AddFinePayment";
  static const String BudgetRecord = "AddBudgetRecord";
  static const String ExpenditureRecord = "AddExpenditureRecord";
}

class UserStat {
  static const String User = "User";
  static const String Admin = "Librarian";
  static const String SuperAdmin = "HOD";
}

class Upload {
  static const String DigitalBook = "UploadDigitalBook";
}

const String ip = "127.0.0.1";
// const String ip = "52.172.252.176";
const int TCPPort = 24680;
const int WebPort = 13579;

void showSnackbar(BuildContext context, String message) {
  var snackBar = SnackBar(
    content: Text(message),
    action: SnackBarAction(
      label: 'Ok',
      onPressed: () {
        print('undo pressed');
      },
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
