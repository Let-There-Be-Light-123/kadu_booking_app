// // signin_bloc.dart

// import 'package:bloc/bloc.dart';
// import 'package:kadu_booking_app/api/api_repository.dart';

// enum SignInEvent {
//   SignInWithEmail,
//   SignInWithPhone,
// }

// class SignInBloc extends Bloc<SignInEvent, bool> {
//   final ApiRepository apiRepository;

//   SignInBloc({required this.apiRepository}) : super(false);

//   Stream<bool> mapEventToState(SignInEvent event) async* {
//     if (event == SignInEvent.SignInWithEmail) {
//       final result = await apiRepository.signInWithEmail('email', 'password');
//       yield result;
//     } else if (event == SignInEvent.SignInWithPhone) {
//       final result = await apiRepository.signInWithPhone('phoneNumber');
//       yield result;
//     }
//   }
// }
