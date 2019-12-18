import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';

class MineinfoBloc extends Bloc<MineinfoEvent, MineinfoState> {

  String userId;

  @override
  MineinfoState get initialState => InitialMineinfoState();

  @override
  Stream<MineinfoState> mapEventToState(
    MineinfoEvent event,
  ) async* {
    if(event is FetchUserInfo) {
      UserInfo info = await NimSdkUtil.userInfoById();
      userId = info.userId;
      yield UserInfoLoaded(userInfo: info);
    }
  }
}
