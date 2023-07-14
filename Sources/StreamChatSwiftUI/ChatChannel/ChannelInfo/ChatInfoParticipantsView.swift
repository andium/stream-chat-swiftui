//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the chat info participants.
struct ChatInfoParticipantsView: View {
    @Injected(\.chatClient) private var chatClient
    @Injected(\.fonts) private var fonts
    @Injected(\.colors) private var colors
    
    @StateObject var viewModel: ChatChannelInfoViewModel

    var participants: [ParticipantInfo]
    var onItemAppear: (ParticipantInfo) -> Void
    
    public init(viewModel: ChatChannelInfoViewModel, participants: [ParticipantInfo], onItemAppear: @escaping (ParticipantInfo) -> Void) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.participants = participants
        self.onItemAppear = onItemAppear
    }

    var body: some View {
        LazyVStack {
            if (chatClient.currentUserController().currentUser?.userRole == .admin || viewModel.createdByCurrentUser()) {
                ForEach(participants) { participant in
                    HStack {
                        MessageAvatarView(avatarURL: participant.chatUser.imageURL)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(participant.displayName)
                                .lineLimit(1)
                                .font(fonts.bodyBold)
                            Text(participant.onlineInfoText)
                                .font(fonts.footnote)
                                .foregroundColor(Color(colors.textLowEmphasis))
                        }
                        Spacer()
                    }
                    .padding(.all, 8)
                    .onAppear {
                        onItemAppear(participant)
                    }
                    .swipeActions(edge: .leading) {
                        Button(role: .destructive) {
                            viewModel.removeUserFromConversation(id: participant.id) {
                                debugPrint("\(participant.displayName) Removed")
                            }
                        } label: {
                            Label("Remove User", systemImage: "minus.circle.fill")
                        }
                    }
                }
            } else {
                ForEach(participants) { participant in
                    HStack {
                        MessageAvatarView(avatarURL: participant.chatUser.imageURL)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(participant.displayName)
                                .lineLimit(1)
                                .font(fonts.bodyBold)
                            Text(participant.onlineInfoText)
                                .font(fonts.footnote)
                                .foregroundColor(Color(colors.textLowEmphasis))
                        }
                        Spacer()
                    }
                    .padding(.all, 8)
                    .onAppear {
                        onItemAppear(participant)
                    }
                }
            }
        }
        .background(Color(colors.background))
    }
}

public struct ParticipantInfo: Identifiable {
    public var id: String {
        chatUser.id
    }

    public let chatUser: ChatUser
    public let displayName: String
    public let onlineInfoText: String

    public init(chatUser: ChatUser, displayName: String, onlineInfoText: String) {
        self.chatUser = chatUser
        self.displayName = displayName
        self.onlineInfoText = onlineInfoText
    }
}
