//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

// View for the channel info screen.
public struct ChatChannelInfoView: View, KeyboardReadable {
    
    @Injected(\.images) private var images
    @Injected(\.colors) private var colors
    @Injected(\.fonts) private var fonts
    
    @ObservedObject private var viewModel: ChatChannelInfoViewModel
    private var shownFromMessageList: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    public init(
        viewModel: ChatChannelInfoViewModel,
        shownFromMessageList: Bool = false
    ) {
        self.viewModel = viewModel
        self.shownFromMessageList = shownFromMessageList
    }
    
    init(viewModel: ChatChannelInfoViewModel) {
        self.viewModel = viewModel
        shownFromMessageList = false
    }
    
    public var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    if viewModel.channel.isDirectMessageChannel {
                        ChatInfoDirectChannelView(
                            participant: viewModel.displayedParticipants.first
                        )
                    } else {
                        ChatInfoParticipantsView(
                            viewModel: viewModel,
                            onItemAppear: viewModel.onParticipantAppear(_:)
                        )
                        .alert(isPresented: $viewModel.removeUserAlertShown) {
                            let title = "Are you sure you want to remove this user?"
                            let message = "They will no longer have access to this channel"
                            let buttonTitle = "Remove user"
                            return Alert(title: Text(title),
                                         message: Text(message),
                                         primaryButton: .destructive(Text(buttonTitle), action: { viewModel.removeUserFromConversation(id: viewModel.participantToRemove!.id) { debugPrint("\(viewModel.participantToRemove!.id) Removed")} }),
                                         secondaryButton: .cancel()
                            )
                        }
                    }
                    
                    if viewModel.showMoreUsersButton {
                        ChatChannelInfoButton(
                            title: L10n.ChatInfo.Users.loadMore(viewModel.notDisplayedParticipantsCount),
                            iconName: "chevron.down",
                            foregroundColor: Color(colors.textLowEmphasis)
                        ) {
                            viewModel.memberListCollapsed = false
                        }
                    }
                    
                    ChannelInfoDivider()
                    
                    ChatInfoOptionsView(viewModel: viewModel)
                    
                    ChannelInfoDivider()
                        .alert(isPresented: $viewModel.errorShown) {
                            Alert.defaultErrorAlert
                        }
                    
                    if viewModel.shouldShowLeaveConversationButton {
                        ChatChannelInfoButton(
                            title: viewModel.leaveButtonTitle,
                            iconName: "person.fill.xmark",
                            foregroundColor: Color(colors.alert)
                        ) {
                            viewModel.leaveGroupAlertShown = true
                        }
                        .alert(isPresented: $viewModel.leaveGroupAlertShown) {
                            let title = viewModel.leaveButtonTitle
                            let message = viewModel.leaveConversationDescription
                            let buttonTitle = viewModel.leaveButtonTitle
                            
                            return Alert(
                                title: Text(title),
                                message: Text(message),
                                primaryButton: .destructive(Text(buttonTitle)) {
                                    viewModel.leaveConversationTapped {
                                        if shownFromMessageList {
                                            notifyChannelDismiss()
                                        } else {
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
            }
            .overlay(
                viewModel.addUsersShown ?
                Color.black.opacity(0.3).edgesIgnoringSafeArea(.all) : nil
            )
            .blur(radius: viewModel.addUsersShown ? 6 : 0)
            .allowsHitTesting(!viewModel.addUsersShown)
            
            if viewModel.addUsersShown {
                VStack {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .layoutPriority(-1)
                        .onTapGesture {
                            viewModel.addUsersShown = false
                        }
                    AddUsersView(
                        loadedUserIds: viewModel.participants.map(\.id),
                        onUserTap: viewModel.addUserTapped(_:)
                    )
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Group {
                    if viewModel.channel.isDirectMessageChannel {
                        Text(viewModel.displayedParticipants.first?.chatUser.name ?? "")
                            .font(fonts.bodyBold)
                            .foregroundColor(Color(colors.text))
                    } else {
                        ChannelTitleView(
                            channel: $viewModel.channel,
                            shouldShowTypingIndicator: false
                        )
                        .id(viewModel.channelId)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                viewModel.channel.isDirectMessageChannel ? nil :
                Button {
                    viewModel.addUsersShown = true
                } label: {
                    Image(systemName: "person.badge.plus")
                        .customizable()
                        .foregroundColor(Color.white)
                        .padding(.all, 8)
                        .background(colors.tintColor)
                        .clipShape(Circle())
                }
            }
        }
        .onReceive(keyboardWillChangePublisher) { visible in
            viewModel.keyboardShown = visible
        }
        .modifier(
            HideKeyboardOnTapGesture(shouldAdd: viewModel.keyboardShown)
        )
        .background(Color(colors.background).edgesIgnoringSafeArea(.bottom))
    }
}
