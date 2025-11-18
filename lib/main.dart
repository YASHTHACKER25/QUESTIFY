import 'package:flutter/material.dart';

import 'services/token_service.dart';
import 'ui/activity_page.dart';
import 'ui/admin_page.dart';
import 'ui/answer_edit_page.dart';
import 'ui/answers_given_page.dart';
import 'ui/change_password_page.dart';
import 'ui/forgot_password_email_page.dart';
import 'ui/give_answer_page.dart';
import 'ui/homepage_page.dart';
import 'ui/login_page.dart';
import 'ui/notification_page.dart';
import 'ui/otp_page.dart';
import 'ui/profile_page.dart';
import 'ui/question_create_page.dart';
import 'ui/question_details_page.dart' as detailsPage;
import 'ui/question_edit_page.dart' as editPage;
import 'ui/questions_asked_page.dart';
import 'ui/register_page.dart';
import 'ui/reset_password_page.dart';
import 'ui/splash_screen.dart';
import 'ui/start_page.dart';
import 'ui/success_page.dart';
import 'ui/update_details_page.dart';
import 'ui/update_email_page.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Questify',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      navigatorObservers: [routeObserver],
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>? ?? {};

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => SplashScreen());
          case '/start':
            return MaterialPageRoute(builder: (_) => StartPage());
          case '/register':
            return MaterialPageRoute(builder: (_) => RegisterPage());
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginPage());
          case '/otp':
            return MaterialPageRoute(
              builder: (_) => OTPPage(
                userid: args['userid'],
                email: args['email'],
                isRegistering: args['isRegistering'] ?? false,
                isForPasswordReset: args['isForPasswordReset'] ?? false,
                isEmailUpdate: args['isEmailUpdate'] ?? false,
              ),
            );
          case '/homepage':
            return MaterialPageRoute(builder: (_) => HomepagePage());
          case '/question_create':
            return MaterialPageRoute(builder: (_) => QuestionCreatePage());

          case '/question_details':
            return MaterialPageRoute(
              builder: (_) => detailsPage.QuestionDetailsPage(
                questionid: args['questionid'] ?? args['questionId'] ?? '',
                highlightAnswerId: args['highlightAnswerId'], // 👈 Added
              ),
            );

          case '/give_answer':
            return MaterialPageRoute(
              builder: (_) => GiveAnswerPage(
                questionid: args['questionid'] ?? '',
                questionContent: args['questionContent'] ?? '',
                Username: args['Username'] ?? '',
              ),
            );
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfilePage());
          case '/notification':
            return MaterialPageRoute(builder: (_) => const NotificationPage());
          case '/success':
            return MaterialPageRoute(builder: (_) => SuccessPage());
          case '/forgot_password_email':
            return MaterialPageRoute(builder: (_) => ForgotPasswordEmailPage());
          case '/reset_password':
            return MaterialPageRoute(
              builder: (_) => ResetPasswordPage(
                email: args['email'] ?? '',
                token: args['token'] ?? '',
              ),
            );
          case '/change_password':
            return MaterialPageRoute(
              builder: (_) => const ChangePasswordPage(),
            );
          case '/activity':
            return MaterialPageRoute(builder: (_) => const ActivityPage());
          case '/questions_asked':
            return MaterialPageRoute(
              builder: (_) => const QuestionsAskedPage(),
            );
          case '/answers_given':
            return MaterialPageRoute(builder: (_) => const AnswersGivenPage());
          case '/question_edit':
            final questionData =
                args['question'] as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) =>
                  editPage.QuestionEditPage(questionData: questionData),
            );
          case '/answer_edit':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => FutureBuilder<String?>(
                future: TokenService().getAccessToken(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final token = snapshot.data ?? '';
                  return AnswerEditPage(
                    answerId: args['answerId'] ?? '',
                    questionId: args['questionId'] ?? '',
                    initialContent: args['initialContent'] ?? '',
                    token: token,
                  );
                },
              ),
            );

          case '/edit_personal_info':
            return MaterialPageRoute(builder: (_) => UpdateDetailsPage());
          case '/update_email':
            return MaterialPageRoute(builder: (_) => UpdateEmailPage());
          case '/admin':
            return MaterialPageRoute(builder: (_) => AdminPage());

          default:
            return MaterialPageRoute(builder: (_) => SplashScreen());
        }
      },
    );
  }
}
