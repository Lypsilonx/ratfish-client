import 'dart:async';
import 'dart:convert';

import 'package:ratfish/src/elements/character_card.dart';
import 'package:ratfish/src/elements/chat_group_card.dart';
import 'package:ratfish/src/server/character.dart';
import 'package:ratfish/src/server/chat_group.dart';
import 'package:ratfish/src/server/client.dart';
import 'package:flutter/material.dart';

import 'package:chatview/chatview.dart' as chatview;
import 'package:ratfish/src/server/message.dart';
import 'package:ratfish/src/views/edit_view.dart';
import 'package:ratfish/src/views/inspect_view.dart';

class ChatView extends StatefulWidget {
  final String chatGroupId;
  final String chatId;
  final bool isGroup;

  const ChatView(this.chatGroupId, this.chatId, this.isGroup, {super.key});

  static const routeName = '/chat';

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  ScrollController scrollController = ScrollController();
  final List<chatview.Message> _messages = [];
  late Timer updateTimer;

  chatview.ChatController? chatController;

  @override
  void initState() {
    super.initState();

    //call updateChat every 20 seconds
    updateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      updateChat();
    });
  }

  @override
  void dispose() {
    updateTimer.cancel();
    super.dispose();
  }

  Future<void> updateChat() async {
    var messages = await Client.getChatMessagesFull(widget.chatId);

    for (var message in messages) {
      if (message.editTimestamp != "") {
        var editTimestamp = int.parse(message.editTimestamp);
        if (_messages.any((element) =>
            element.id == message.id &&
            element.createdAt.millisecondsSinceEpoch != editTimestamp)) {
          _messages.removeWhere((element) => element.id == message.id);
          _messages.add(await buildMessage(message, edit: true));
        } else {
          if (_messages.any((element) => element.id == message.id)) {
            continue;
          }
          _messages.add(await buildMessage(message, edit: true));
        }
      } else {
        if (_messages.any((element) => element.id == message.id)) {
          continue;
        }
        _messages.add(
          await buildMessage(message),
        );
      }
    }

    // sort messages by date
    _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (chatController != null) {
      chatController!.loadMoreData([]);
    }
  }

  Future<chatview.Message> buildMessage(Message message,
      {bool edit = false}) async {
    return chatview.Message(
      id: message.id,
      sentBy: message.senderId,
      createdAt: message.editTimestamp != ""
          ? DateTime.fromMillisecondsSinceEpoch(
              int.parse(message.editTimestamp))
          : DateTime.fromMillisecondsSinceEpoch(int.parse(message.timestamp)),
      status: chatview.MessageStatus.delivered,
      replyMessage:
          chatview.ReplyMessage.fromJson(jsonDecode(message.replyMessage)),
      message: message.content + (edit ? " (edited)" : ""),
    );
  }

  Future<chatview.ChatUser> buildUser(String characterId) async {
    var character = await Client.getServerObject<Character>(characterId);
    return chatview.ChatUser(
      id: character.id,
      name: character.name +
          (character.pronouns != "" ? " (${character.pronouns})" : ""),
      profilePhoto: character.image,
      imageType: chatview.ImageType.base64,
    );
  }

  Future<void> updateChatController(
      String characterId, List<chatview.ChatUser> users) async {
    await updateChat().then((value) {
      chatController = chatview.ChatController(
        initialMessageList: _messages,
        scrollController: ScrollController(),
        currentUser: users.firstWhere((element) => element.id == characterId),
        otherUsers:
            users.where((element) => element.id != characterId).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<List<String>> futureChatMemberIds =
        Client.getChatMembers(widget.chatId);
    Future<ChatGroup> futureChatGroup =
        Client.getServerObject<ChatGroup>(widget.chatGroupId);
    Future<String> futureCharacterId =
        Client.getCharacterId(widget.chatGroupId, Client.instance.self.id);
    Future<List<chatview.ChatUser>> futureUsers = futureChatMemberIds.then(
      (chatMemberIds) async {
        return Future.wait(chatMemberIds.map((e) => buildUser(e)).toList());
      },
    );
    var chatControllerReady = Completer();
    // create never completing future
    if (chatController == null) {
      Future.wait([futureUsers, futureCharacterId]).then((values) {
        List<chatview.ChatUser> users = values[0] as List<chatview.ChatUser>;
        String characterId = values[1] as String;

        updateChatController(characterId, users).then((value) {
          chatControllerReady.complete();
        });
      });
    }

    return FutureBuilder(
      future: Future.wait([
        futureChatMemberIds,
        futureChatGroup,
        futureCharacterId,
        futureUsers,
        chatControllerReady.future,
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: ListTile(
              leading: const Icon(Icons.error),
              title: Text(
                  "Error loading chat: ${widget.chatId},${widget.chatGroupId} (${snapshot.error})"),
            ),
          );
        }

        if (snapshot.hasData) {
          List<String> chatMemberIds = snapshot.data![0] as List<String>;
          ChatGroup chatGroup = snapshot.data![1] as ChatGroup;
          String characterId = snapshot.data![2] as String;

          String id = widget.isGroup
              ? chatGroup.id
              : chatMemberIds.firstWhere((element) => element != characterId);

          return Scaffold(
            body: chatview.ChatView(
              chatController: chatController!,
              onSendTap: (message, replyMessage, messageType) {
                _onSendTap(
                  message,
                  replyMessage,
                  messageType,
                  characterId,
                );
              },
              profileCircleConfig: chatview.ProfileCircleConfiguration(
                onAvatarTap: (user) {
                  Navigator.of(context).pushNamed(
                    InspectView.routeName,
                    arguments: {
                      "type": (Character).toString(),
                      "id": user.id,
                    },
                  );
                },
              ),
              featureActiveConfig: const chatview.FeatureActiveConfig(
                enableSwipeToSeeTime: false,
                lastSeenAgoBuilderVisibility: false,
                receiptsBuilderVisibility: false,
                enableScrollToBottomButton: true,
                enableReactionPopup: false,
                enableDoubleTapToLike: false,
              ),
              scrollToBottomButtonConfig: chatview.ScrollToBottomButtonConfig(
                backgroundColor: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.transparent
                      : Colors.grey,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                  weight: 10,
                  size: 30,
                ),
              ),
              chatViewState: chatview.ChatViewState.hasMessages,
              chatViewStateConfig: chatview.ChatViewStateConfiguration(
                loadingWidgetConfig: chatview.ChatViewStateWidgetConfiguration(
                  loadingIndicatorColor:
                      Theme.of(context).colorScheme.secondary,
                ),
                onReloadButtonTap: () {},
              ),
              appBar: AppBar(
                title: widget.isGroup
                    ? ChatGroupCard(id, goto: "info")
                    : CharacterCard(chatMemberIds.firstWhere(
                        (element) => element != characterId,
                      )),
              ),
              chatBackgroundConfig: chatview.ChatBackgroundConfiguration(
                messageTimeIconColor: Theme.of(context).colorScheme.secondary,
                messageTimeTextStyle:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                defaultGroupSeparatorConfig:
                    chatview.DefaultGroupSeparatorConfiguration(
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 17,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              sendMessageConfig: chatview.SendMessageConfiguration(
                imagePickerIconsConfig: chatview.ImagePickerIconsConfiguration(
                  cameraIconColor: Theme.of(context).colorScheme.onPrimary,
                  galleryIconColor: Theme.of(context).colorScheme.onPrimary,
                ),
                replyMessageColor: Theme.of(context).colorScheme.onPrimary,
                defaultSendButtonColor: Theme.of(context).colorScheme.onPrimary,
                replyDialogColor: Theme.of(context).colorScheme.tertiary,
                replyTitleColor: Theme.of(context).colorScheme.onTertiary,
                textFieldBackgroundColor: Theme.of(context).colorScheme.primary,
                closeIconColor: Theme.of(context).colorScheme.onTertiary,
                textFieldConfig: chatview.TextFieldConfiguration(
                  textStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withAlpha(100)),
                ),
                micIconColor: Theme.of(context).colorScheme.onPrimary,
                voiceRecordingConfiguration:
                    chatview.VoiceRecordingConfiguration(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  recorderIconColor: Theme.of(context).colorScheme.onPrimary,
                  waveStyle: chatview.WaveStyle(
                    showMiddleLine: false,
                    waveColor: Theme.of(context).colorScheme.onPrimary,
                    extendWaveform: true,
                  ),
                ),
              ),
              chatBubbleConfig: chatview.ChatBubbleConfiguration(
                outgoingChatBubbleConfig: chatview.ChatBubble(
                  linkPreviewConfig: chatview.LinkPreviewConfiguration(
                    linkStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      decoration: TextDecoration.underline,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    bodyStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                    titleStyle:
                        Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                  ),
                  textStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  senderNameTextStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  receiptsWidgetConfig: const chatview.ReceiptsWidgetConfig(
                      showReceiptsIn: chatview.ShowReceiptsIn.all),
                  color: Theme.of(context).colorScheme.primary,
                ),
                inComingChatBubbleConfig: chatview.ChatBubble(
                  linkPreviewConfig: chatview.LinkPreviewConfiguration(
                    linkStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          decoration: TextDecoration.underline,
                        ),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    bodyStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                    titleStyle:
                        Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                  ),
                  textStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  senderNameTextStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              replyPopupConfig: chatview.ReplyPopupConfiguration(
                backgroundColor: Theme.of(context).colorScheme.surface,
                buttonTextStyle:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
                topBorderColor: Theme.of(context).colorScheme.primary,
                onUnsendTap: (message) {
                  Client.deleteMessage(characterId, message.id).then((value) {
                    _messages
                        .removeWhere((element) => element.id == message.id);
                    setState(() {});
                  });
                },
                onMoreTap: (message, value) {
                  Navigator.of(context).pushNamed(
                    EditView.routeName,
                    arguments: {
                      "type": (Message).toString(),
                      "id": message.id,
                    },
                  );
                },
              ),
              reactionPopupConfig: chatview.ReactionPopupConfiguration(
                overrideUserReactionCallback: true,
                userReactionCallback: (message, reaction) {
                  debugPrint("User reacted with $reaction");
                },
                shadow: BoxShadow(
                  color: Theme.of(context).colorScheme.shadow,
                  blurRadius: 0,
                ),
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              messageConfig: chatview.MessageConfiguration(
                messageReactionConfig: chatview.MessageReactionConfiguration(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  borderColor: Theme.of(context).colorScheme.tertiary,
                  reactedUserCountTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary),
                  reactionCountTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary),
                  reactionsBottomSheetConfig:
                      chatview.ReactionsBottomSheetConfiguration(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    reactedUserTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    reactionWidgetDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                imageMessageConfig: chatview.ImageMessageConfiguration(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  shareIconConfig: chatview.ShareIconConfiguration(
                    defaultIconBackgroundColor:
                        Theme.of(context).colorScheme.primary,
                    defaultIconColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              // profileCircleConfig:
              //     const chatview.ProfileCircleConfiguration(
              //   profileImageUrl: Data.profileImage,
              // ),
              repliedMessageConfig: chatview.RepliedMessageConfiguration(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                verticalBarColor: Theme.of(context).colorScheme.onSurface,
                repliedMsgAutoScrollConfig: chatview.RepliedMsgAutoScrollConfig(
                  enableHighlightRepliedMsg: true,
                  highlightColor: Theme.of(context).colorScheme.onSurface,
                  highlightScale: 1.1,
                ),
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.25,
                ),
                replyTitleTextStyle:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              swipeToReplyConfig: chatview.SwipeToReplyConfiguration(
                replyIconColor: Theme.of(context).colorScheme.onTertiary,
                replyIconProgressRingColor:
                    Theme.of(context).colorScheme.tertiary,
                replyIconBackgroundColor:
                    Theme.of(context).colorScheme.tertiary,
              ),
              replySuggestionsConfig: chatview.ReplySuggestionsConfig(
                itemConfig: chatview.SuggestionItemConfig(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: (item) => _onSendTap(
                  item.text,
                  const chatview.ReplyMessage(),
                  chatview.MessageType.text,
                  characterId,
                ),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Loading..."),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  void _onSendTap(
    String message,
    chatview.ReplyMessage replyMessage,
    chatview.MessageType messageType,
    String characterId,
  ) async {
    var messageObject = Message(
      id: "",
      chatId: widget.chatId,
      senderId: characterId,
      content: message,
      editTimestamp: "",
      replyMessage: jsonEncode(replyMessage),
      timestamp: "",
    );
    await Client.addMessage(
      messageObject,
    );
    updateChat();
  }
}
