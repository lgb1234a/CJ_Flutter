import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import './bloc.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import '../../Base/CJEventBus.dart';

class MineinfoBloc extends Bloc<MineinfoEvent, MineinfoState> {
  String userId;

  @override
  MineinfoState get initialState => InitialMineinfoState();

  @override
  Stream<MineinfoState> mapEventToState(
    MineinfoEvent event,
  ) async* {
    if (event is FetchUserInfo) {
      UserInfo info = await NimSdkUtil.userInfoById();
      userId = info.userId;
      yield UserInfoLoaded(userInfo: info);
    }

    if (event is TappedAvatar) {
      /// 替换头像
      File image;
      if (event.type == 0) {
        /// 拍照
        image = await ImagePicker.pickImage(source: ImageSource.camera);
      } else {
        /// 相册
        image = await ImagePicker.pickImage(source: ImageSource.gallery);
      }

      /// 上传
      bool success = await updateTeamAvatar(image);
      if (success) {
        /// 我 页面接收监听，刷新页面
        eventBus.fire(UpdatedUserInfo());

        /// 刷新头像
        add(FetchUserInfo());
      }
    }

    if (event is UpdateNickName) {
      /// 修改昵称
      bool success = await NimSdkUtil.updateMyInfo(3, event.name);
      if (success) {
        /// 我 页面接收监听，刷新页面
        eventBus.fire(UpdatedUserInfo());

        /// 刷新页面
        add(FetchUserInfo());
      }
    }

    if (event is UpdateEmail) {
      /// 修改邮箱
      bool success = await NimSdkUtil.updateMyInfo(7, event.email);
      if (success) {
        /// 刷新页面
        add(FetchUserInfo());
      }
    }

    if (event is UpdateSign) {
      /// 修改签名
      bool success = await NimSdkUtil.updateMyInfo(5, event.sign);
      if (success) {
        /// 刷新页面
        add(FetchUserInfo());
      }
    }
  }

  /// 更新头像
  Future<bool> updateTeamAvatar(File image) async {
    String imgUrl = await NimSdkUtil.uploadFileToNim(image);
    if (imgUrl == null || imgUrl.isEmpty) {
      return false;
    } else {
      return await NimSdkUtil.updateMyInfo(4, imgUrl);
    }
  }
}
