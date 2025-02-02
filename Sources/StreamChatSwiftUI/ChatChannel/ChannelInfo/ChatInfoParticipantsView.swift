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

    var onItemAppear: (ParticipantInfo) -> Void
    
    public init(viewModel: ChatChannelInfoViewModel, onItemAppear: @escaping (ParticipantInfo) -> Void) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onItemAppear = onItemAppear
    }

    var body: some View {
        LazyVStack {
            ForEach(viewModel.displayedParticipants) { participant in
                    if ((chatClient.currentUserController().currentUser?.userRole == .admin || viewModel.createdByCurrentUser()) && chatClient.currentUserId != participant.id) {
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
                            
                            Button(role: .destructive) {
                                viewModel.removeUserAlertShown = true
                                viewModel.participantToRemove = participant
                            } label: {
                                Label("Remove User", systemImage: "minus.circle.fill")
                            }
                        }
                        .padding(.all, 8)
                        .onAppear {
                            onItemAppear(participant)
                        }
                    } else {
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
