import 'package:flutter/material.dart';
import 'package:library_management/Circulation/CirculationHomePage.dart';
import 'package:library_management/HomePage/Home.dart';
import 'package:library_management/HomePage/Magazines/MagazineRequestStatus.dart';
import 'package:library_management/HomePage/Magazines/MagazineRequests.dart';
import 'package:library_management/HomePage/profile/userRequests.dart';
import 'package:library_management/Login/Login.dart';
import 'package:library_management/Navbar/BudgetDistributionPage.dart';
import 'package:library_management/Navbar/BudgetRemainingPage.dart';
import 'package:library_management/Navbar/BudgetTotallPage.dart';
import 'package:library_management/Navbar/DeleteHisttory.dart';
import 'package:library_management/Navbar/adminPendingRequestsBooks.dart';
import 'package:library_management/Navbar/adminPendingRequestsMagazines.dart';
import 'package:library_management/Navbar/outStandingBooksPage.dart';
import 'package:library_management/Navbar/userBorrowedBooks.dart';
import 'HomePage/Books/BookRequestStatus.dart';
import 'HomePage/Books/BookRequests.dart';
import 'HomePage/Magazines/MyMagazine.dart';
import 'HomePage/profile/Profile Window.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      '/': (context) => const Login(),
      '/Home': (context) => const Home(),
      '/Profile': (context) => const ProfileWindow(),
      '/MagazineRequests': (context) => const MagazineRequests(),
      '/MagazineRequestStatus': (context) => const MagazineRequestStatus(),
      '/BookRequest': (context) => const BookRequests(),
      '/BookRequestStatus': (context) => const BookRequestStatus(),
      '/MyMagazine': (context) => const MyMagazine(),
      '/Circulation': (context) => const circulationHomePage(),
      '/UserRequests': (context) => userRequestsPage(),
      '/PendingBookRequests':(context)=>adminPendingRequestsPageBooks(),
      '/PendingMagazineRequests' : (context) =>adminPendingRequestsPageMagazines(),
      '/History' : (context) => HistoryPage(),
      '/OutStandingRequests' : (context) =>OutStandingRequests(),
      '/UserBorrowedBooks':(context) =>UserBorrowedBooks(),
      '/BudgetDistributionPage':(context) =>BudgetDistributionPage(),
      '/RemainingBudgetPage':(context) =>BudgetRemainingPage(),
      '/TotalBudgetPage':(context) =>BudgetTotalPage(),
    },
    initialRoute: "/",
  ));
}
