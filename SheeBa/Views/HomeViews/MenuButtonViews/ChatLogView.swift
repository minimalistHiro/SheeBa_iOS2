//
//  ChatLogView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/16.
//

import SwiftUI
import FirebaseFirestore

struct ChatLogView: View {
    
    @Environment(\.dismiss) var dismiss
    @FocusState var focus: Bool
    @ObservedObject var vm = ViewModel()
    static let emptyScrollTToString = "Empty"
    @State private var isShowSendPayScreen = false      // SendPayViewの表示有無
//    @State private var sendPayText = "0"                // 送金テキスト
    @State private var chatText = ""                    // ユーザーの入力テキスト
    @State private var lastText = ""                    // 一時保存用最新メッセージ
    @State private var isSendPay = false                // 送金処理をしたか否か
//    @State private var textFieldRowCount: CGFloat = 1   // テキストフィールドの行数
    var chatUserUID: String
    
    init(chatUserUID: String) {
        self.chatUserUID = chatUserUID
        vm.fetchCurrentUser()
        vm.fetchUser(uid: chatUserUID)
        vm.fetchMessages(toId: chatUserUID)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    messagesView
                }
                chatButtonBar
            }
            .background(Color.chatLogBar)
            .fullScreenCover(isPresented: $isShowSendPayScreen) {
                SendPayView(didCompleteSendPayProcess: { sendPayText in
                    isShowSendPayScreen.toggle()
                    vm.handleSend(toId: chatUserUID, chatText: "", lastText: sendPayText, isSendPay: true)
                }, chatUser: vm.chatUser)
            }
            .navigationTitle(vm.chatUser?.username.prefix(20) ?? "")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            if let uid = FirebaseManager.shared.auth.currentUser?.uid {
                vm.fetchFriend(document1: chatUserUID, document2: uid)
                vm.updateRecentMessage(document1: uid, document2: chatUserUID, data: [
                    FirebaseConstants.isRead: true,
                ])
            }
        }
        .asBackButton()
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: {
            vm.isShowError = false
            dismiss()
        })
    }
    
    // MARK: - messagesView
    private var messagesView: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                LazyVStack {
                    ForEach(vm.chatMessages) { message in
                        LazyVStack {
                            // 送金メッセージの場合
                            if message.isSendPay {
                                // 送信者が自身の場合
                                if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                                    MessageView.SelfSendPayMessage(message: message)
                                } else {
                                    MessageView.ChatUserSendPayMessage(message: message, chatUser: vm.chatUser)
                                }
                            } else {
                                // 送信者が自身の場合
                                if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                                    MessageView.SelfMessage(message: message)
                                } else {
                                    MessageView.ChatUserMessage(message: message, chatUser: vm.chatUser)
                                }
                            }
                        }
                        .rotationEffect(.degrees(180))
                        .padding(.horizontal)
                        .padding(.top, 5)
                    }
                    HStack { Spacer() }
                        .id(ChatLogView.emptyScrollTToString)
                }
//                .onAppear {
//                    // 開くと同時に最下部を表示する
//                    scrollViewProxy.scrollTo(ChatLogView.emptyScrollTToString, anchor: .bottom)
//                }
//                .onChange(of: vm.isScroll) { _ in
//                    // メッセージが追加されるたびに最下部にスクロール
//                    withAnimation(.easeOut(duration: 0.5)) { scrollViewProxy.scrollTo(ChatLogView.emptyScrollTToString, anchor: .top) }
//                }
            }
        }
        .rotationEffect(.degrees(180))
        .onTapGesture {
            focus = false
        }
    }
    
    // MARK: - chatButtonBar
    private var chatButtonBar: some View {
        HStack(spacing: 10) {
            if !focus {
                Button {
                    isShowSendPayScreen.toggle()
                } label: {
                    Capsule()
                        .foregroundStyle(.blue)
                        .frame(width: 60, height: 35)
                        .overlay {
                            HStack(spacing: 0) {
                                Image(systemName: "dollarsign")
                                    .foregroundStyle(.white)
                                Text("送る")
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(.white)
                            }
                        }
                }
            }
            
//            Rectangle()
//                .foregroundStyle(.white)
//                .frame(height: 32 * textFieldRowCount)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .overlay {
                    TextField(focus ? "メッセージを入力" : "Aa",
                              text: $chatText,
                              axis: .vertical
                    )
                    .padding(10)
                    .background(Color.white)
                    .focused($focus)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                    .onChange(of: chatText, perform: { value in
//                        textFieldRowCount = 1
                        // 最大文字数に達したら、それ以上書き込めないようにする
                        if value.count > Setting.maxChatTextCount {
                            chatText.removeLast(chatText.count - Setting.maxChatTextCount)
                        }
                        // 改行の数をカウントして、その分テキストフィールドを大きくする（5行まで）。
//                        for val in value {
//                            if val == "\n" && textFieldRowCount < 5 {
//                                textFieldRowCount += 1
//                            }
//                        }
                    })
//                }
            
            Button {
                focus = false
                vm.handleSend(toId: chatUserUID, chatText: chatText, lastText: lastText, isSendPay: false)
                // 送金処理以外（通常テキスト送信）の場合のみ実行
                if !isSendPay {
                    self.lastText = chatText
                    self.chatText = ""
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .foregroundColor(chatText.isEmpty ? .gray : .blue)
            }
            .disabled(chatText.isEmpty)
            .padding(.vertical, 6)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.chatLogBackground)
    }
}

#Preview {
    ChatLogView(chatUserUID: "")
}
