import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class SessioninfoBloc extends Bloc<SessioninfoEvent, SessioninfoState> {
  @override
  SessioninfoState get initialState => InitialSessioninfoState();

  @override
  Stream<SessioninfoState> mapEventToState(
    SessioninfoEvent event,
  ) async* {
    // TODO: Add Logic
  }

  // Future<>

}
