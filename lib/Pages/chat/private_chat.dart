import 'package:bubble/bubble.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:f_app/model/messageModel.dart';
import 'package:f_app/model/user_model.dart';
import 'package:f_app/shared/Cubit/socialCubit/SocialState.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../shared/Cubit/socialCubit/SocialCubit.dart';
import '../../shared/componnetns/components.dart';
import '../../shared/componnetns/constants.dart';
import '../veiw_photo/image_view.dart';

class PrivateChatScreen extends StatelessWidget {
  UserModel userModel;
  PrivateChatScreen(
    this.userModel, {
    Key? key,
  }) : super(key: key);
  var textController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  final ItemScrollController scroll = ItemScrollController();
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      SocialCubit.get(context).getMessage(
        receiverId: userModel.uId!,
      );

      return BlocConsumer<SocialCubit, SocialStates>(
        listener: (context, state) {
          if (state is SendMessageSuccessState) {
            if (SocialCubit.get(context).messageImagePicked != null) {
              SocialCubit.get(context).removemessageimage();
            }
            scroll.scrollTo(
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                index: SocialCubit.get(context).message.length);
            textController.clear();
          }
          if (state is SavedToGallerySuccessState) {
            Fluttertoast.showToast(
                msg: "Downloaded to Gallery!",
                gravity: ToastGravity.BOTTOM,
                backgroundColor: SocialCubit.get(context).isLight
                    ? Colors.white
                    : const Color(0xff063750),
                timeInSecForIosWeb: 5,
                textColor: SocialCubit.get(context).isLight
                    ? Colors.black
                    : Colors.white,
                fontSize: 18);
          }
        },
        builder: (context, state) {
          var cubit = SocialCubit.get(context);

          return Scaffold(
            backgroundColor:
                cubit.isLight ? Colors.white : const Color(0xff063750),
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor:
                    cubit.isLight ? Colors.white : const Color(0xff063750),
                statusBarIconBrightness:
                    cubit.isLight ? Brightness.dark : Brightness.light,
                statusBarBrightness:
                    cubit.isLight ? Brightness.dark : Brightness.light,
              ),
              backgroundColor:
                  cubit.isLight ? Colors.white : const Color(0xff063750),
              leading: IconButton(
                onPressed: () {
                  pop(context);
                },
                icon: Icon(
                  IconlyLight.arrowLeft2,
                  size: 30,
                  color: cubit.isLight ? Colors.black : Colors.white,
                ),
              ),
              titleSpacing: 0,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                      '${userModel.image}',
                    ),
                  ),
                  space(15, 0),
                  Expanded(
                    child: Text(
                      '${userModel.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lobster(
                        color: cubit.isLight ? Colors.blue : Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  space(30, 0),
                ],
              ),
              elevation: 1,
            ),
            body: ConditionalBuilder(
              condition: SocialCubit.get(context).message.isNotEmpty,
              builder: (context) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: ScrollablePositionedList.separated(
                          initialScrollIndex:
                              SocialCubit.get(context).message.length,
                          itemScrollController: scroll,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            var message =
                                SocialCubit.get(context).message[index];
                            if (SocialCubit.get(context).userModel!.uId ==
                                message.senderId) {
                              return buildMyMessageItem(message, context);
                            } else {
                              return buildMessageItem(message, context);
                            }
                          },
                          separatorBuilder: (context, index) => space(0, 15),
                          itemCount: SocialCubit.get(context).message.length,
                        ),
                      ),
                      space(0, 20),
                      if (SocialCubit.get(context).messageImagePicked != null)
                        Stack(
                          alignment: AlignmentDirectional.topEnd,
                          children: [
                            Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                    ),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: FileImage(SocialCubit.get(context)
                                          .messageImagePicked!),
                                    ))),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blue,
                              child: IconButton(
                                  iconSize: 16,
                                  onPressed: () {
                                    SocialCubit.get(context)
                                        .removemessageimage();
                                  },
                                  icon: const Icon(IconlyBroken.closeSquare)),
                            ),
                          ],
                        ),
                      if (state is UploadMessageImageLoadingState)
                        const Center(child: LinearProgressIndicator()),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1.0)),
                              child: SingleChildScrollView(
                                child: TextFormField(
                                  style: GoogleFonts.libreBaskerville(
                                    color: SocialCubit.get(context).isLight
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  textAlignVertical: TextAlignVertical.center,
                                  maxLines: 3,
                                  minLines: 1,
                                  controller: textController,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    counterStyle: const TextStyle(
                                      height: double.minPositive,
                                    ),
                                    isDense: true,
                                    contentPadding:
                                        const EdgeInsetsDirectional.all(12),
                                    hintText: ' \' Type a message \' ',
                                    hintStyle: GoogleFonts.lobster(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    border: InputBorder.none,
                                    prefixIcon: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Octicons.smiley,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            SocialCubit.get(context)
                                                .getMessageImage();
                                          },
                                          icon: Icon(
                                            IconlyLight.camera,
                                            size: 25,
                                            color: cubit.isLight
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  validator: (String? value) {
                                    if (value!.isEmpty) {
                                      return 'Enter your message';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: cubit.isLight ? Colors.blue : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: MaterialButton(
                              minWidth: 1,
                              onPressed: () {
                                if (formKey.currentState!.validate() &&
                                    SocialCubit.get(context)
                                            .messageImagePicked ==
                                        null) {
                                  cubit.sendMessage(
                                    receiverId: userModel.uId!,
                                    dateTime: DateTime.now().toString(),
                                    text: textController.text,
                                  );
                                  textController.clear();
                                  scroll.scrollTo(
                                      duration: const Duration(milliseconds: 1),
                                      curve: Curves.linearToEaseOut,
                                      index: SocialCubit.get(context)
                                          .message
                                          .length);
                                } else {
                                  SocialCubit.get(context).uploadmessageImage(
                                      receiverId: userModel.uId!,
                                      datetime: DateTime.now().toString(),
                                      text: textController.text);
                                  textController.clear();
                                  cubit.removemessageimage();
                                  scroll.scrollTo(
                                      duration: const Duration(milliseconds: 1),
                                      curve: Curves.linearToEaseOut,
                                      index: SocialCubit.get(context)
                                          .message
                                          .length);
                                }
                              },
                              child: Icon(
                                IconlyLight.send,
                                color:
                                    cubit.isLight ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
          );
        },
      );
    });
  }

  Widget buildMyMessageItem(MessageModel messageModel, context) {
    SocialCubit cubit = SocialCubit.get(context);
    if (messageModel.messageImage == '') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 0, right: 8, top: 5, bottom: 5),
              child: Bubble(
                nip: BubbleNip.rightBottom,
                color: Colors.black38,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      messageModel.text!,
                      style: GoogleFonts.libreBaskerville(
                        color: cubit.isLight ? Colors.black : Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    space(0, 5),
                    Text(
                      daysBetween(
                          DateTime.parse(messageModel.dateTime.toString())),
                      style: GoogleFonts.lobster(
                        color: Colors.grey,
                        textStyle: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage(
              '${SocialCubit.get(context).userModel!.image}',
            ),
          ),
        ],
      );
    } else if (messageModel.messageImage != '' && messageModel.text != '') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 300,
            height: 270,
            clipBehavior: Clip.none,
            decoration: const BoxDecoration(
              borderRadius: BorderRadiusDirectional.only(
                bottomStart: Radius.circular(10),
                topEnd: Radius.circular(10),
                topStart: Radius.circular(10),
              ),
            ),
            child: Bubble(
              padding: const BubbleEdges.all(4),
              nip: BubbleNip.rightBottom,
              color: cubit.isLight ? Colors.white : Colors.black38,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadiusDirectional.all(
                        Radius.circular(10),
                      ),
                    ),
                    width: 300,
                    height: 220,
                    child: InkWell(
                      onLongPress: () {
                        cubit.saveToGallery(messageModel.messageImage!);
                      },
                      onTap: () {
                        navigateTo(
                            context,
                            ImageViewScreen(
                                image: messageModel.messageImage, body: ''));
                      },
                      child: Image(
                        image: NetworkImage(
                          '${messageModel.messageImage}',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Column(
                    textBaseline: TextBaseline.alphabetic,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        messageModel.text!,
                        style: GoogleFonts.libreBaskerville(
                          color: cubit.isLight ? Colors.black : Colors.white,
                          fontSize: 16,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        daysBetween(
                            DateTime.parse(messageModel.dateTime.toString())),
                        style: Theme.of(context).textTheme.caption!.copyWith(
                              color: Colors.grey,
                              height: 0.1,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Align(
        alignment: AlignmentDirectional.bottomEnd,
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            InkWell(
              onLongPress: () {
                cubit.saveToGallery(messageModel.messageImage!);
              },
              onTap: () {
                navigateTo(
                    context,
                    ImageViewScreen(
                        image: messageModel.messageImage, body: ''));
              },
              child: Container(
                  width: 300,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadiusDirectional.only(
                      bottomStart: Radius.circular(20),
                      topEnd: Radius.circular(20),
                      topStart: Radius.circular(20),
                    ),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage('${messageModel.messageImage}')),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                daysBetween(DateTime.parse(messageModel.dateTime.toString())),
                style: Theme.of(context).textTheme.caption!.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget buildMessageItem(MessageModel messageModel, context) {
    SocialCubit cubit = SocialCubit.get(context);
    if (messageModel.messageImage == '') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage(
              '${userModel.image}',
            ),
          ),
          Flexible(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
              child: Bubble(
                nip: BubbleNip.leftTop,
                color:
                    cubit.isLight ? Colors.blue : Colors.blue.withOpacity(0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      messageModel.text!,
                      style: GoogleFonts.libreBaskerville(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    space(0, 5),
                    Text(
                      daysBetween(
                          DateTime.parse(messageModel.dateTime.toString())),
                      style: GoogleFonts.lobster(
                        color: Colors.grey,
                        textStyle: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else if (messageModel.messageImage != '' && messageModel.text != '') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 300,
            height: 290,
            clipBehavior: Clip.none,
            decoration: const BoxDecoration(
              borderRadius: BorderRadiusDirectional.only(
                bottomStart: Radius.circular(10),
                topEnd: Radius.circular(10),
                topStart: Radius.circular(10),
              ),
            ),
            child: Bubble(
              padding: const BubbleEdges.all(4),
              nip: BubbleNip.leftTop,
              color: cubit.isLight ? Colors.blue : Colors.blue.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadiusDirectional.all(
                        Radius.circular(10),
                      ),
                    ),
                    width: 300,
                    height: 220,
                    child: InkWell(
                      onLongPress: () {
                        cubit.saveToGallery(messageModel.messageImage!);
                      },
                      onTap: () {
                        navigateTo(
                            context,
                            ImageViewScreen(
                                image: messageModel.messageImage, body: ''));
                      },
                      child: Image(
                        image: NetworkImage(
                          '${messageModel.messageImage}',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.bottomStart,
                    child: Column(
                      textBaseline: TextBaseline.alphabetic,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          messageModel.text!,
                          style: GoogleFonts.libreBaskerville(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.7,
                          ),
                        ),
                        Text(
                          daysBetween(
                              DateTime.parse(messageModel.dateTime.toString())),
                          style: Theme.of(context).textTheme.caption!.copyWith(
                                color: Colors.grey,
                                height: 2.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Align(
        alignment: AlignmentDirectional.bottomStart,
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            InkWell(
              onLongPress: () {
                cubit.saveToGallery(messageModel.messageImage!);
              },
              onTap: () {
                navigateTo(
                    context,
                    ImageViewScreen(
                        image: messageModel.messageImage, body: ''));
              },
              child: Container(
                  width: 300,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadiusDirectional.only(
                      bottomStart: Radius.circular(20),
                      topEnd: Radius.circular(20),
                      topStart: Radius.circular(20),
                    ),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage('${messageModel.messageImage}')),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                daysBetween(DateTime.parse(messageModel.dateTime.toString())),
                style: Theme.of(context).textTheme.caption!.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ],
        ),
      );
    }
  }
}