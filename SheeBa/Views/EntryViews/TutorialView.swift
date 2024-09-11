//
//  TutorialView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/18.
//

import SwiftUI

struct TutorialText: Hashable {
    let title: String
    let text: String
}

struct TutorialView: View {
    
    let didCompleteTutorialProcess: () -> ()
    @State private var selectedTab: Int = 1         // 選択されたページ
    let pages: [Int] = [1, 2, 3, 4, 5]              // ページ
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.sheebaYellow.ignoresSafeArea(edges: .all)
                
                TabView(selection: $selectedTab) {
                    ForEach(pages, id: \.self) { page in
                        Tutorial(text: String.tutorialText(page: page),
                                 image: String.tutorialImage(page: page),
                                 lastPage: pages.count,
                                 selectedTab: $selectedTab,
                                 didAction: didCompleteTutorialProcess)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .animation(.easeInOut, value: selectedTab)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack {
                            Spacer()
                            if selectedTab != pages.endIndex {
                                Button {
//                                    didCompleteTutorialProcess()
                                    selectedTab = pages.endIndex
                                } label: {
                                    Text("スキップ")
                                        .dynamicTypeSize(.medium)
                                }
                            }
                        }
                        .foregroundStyle(.black)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct Tutorial: View {
    
    let text: String
    let image: String
    let lastPage: Int
    @Binding var selectedTab: Int
    let didAction: () -> ()
    @State private var isAgree = false          // ユーザーの同意の有無
    var disabled: Bool {
        if (selectedTab == lastPage) && !isAgree {
            return true
        }
        return false
    }                                           // ボタンの有効性
    let tutorialText: [TutorialText] = [
        TutorialText(
            title: String.termsOfServiceTitle1,
            text: String.termsOfServiceArticle1),
        TutorialText(
            title: String.termsOfServiceTitle2,
            text: String.termsOfServiceArticle2),
        TutorialText(
            title: String.termsOfServiceTitle3,
            text: String.termsOfServiceArticle3),
        TutorialText(
            title: String.termsOfServiceTitle4,
            text: String.termsOfServiceArticle4),
        TutorialText(
            title: String.termsOfServiceTitle5,
            text: String.termsOfServiceArticle5),
        TutorialText(
            title: String.termsOfServiceTitle6,
            text: String.termsOfServiceArticle6),
        TutorialText(
            title: String.termsOfServiceTitle7,
            text: String.termsOfServiceArticle7),
        TutorialText(
            title: String.termsOfServiceTitle8,
            text: String.termsOfServiceArticle8),
        TutorialText(
            title: String.termsOfServiceTitle9,
            text: String.termsOfServiceArticle9),
        TutorialText(
            title: String.termsOfServiceTitle10,
            text: String.termsOfServiceArticle10),
    ]

    var body: some View {
        ZStack {
            // ボタン周辺
            VStack {
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                
                if selectedTab == lastPage {
                    agreeButton
                }
                
                Button {
                    if selectedTab != lastPage {
                        selectedTab += 1
                    } else {
                        didAction()
                    }
                } label: {
                    CustomCapsule(text: selectedTab != lastPage ? "次へ" : "始める", imageSystemName: nil, foregroundColor: disabled ? .gray : .black, textColor: .white, isStroke: false)
                }
                .disabled(disabled)
                
                Spacer()
            }
            
            // テキスト周辺
            VStack {
                if selectedTab != lastPage {
                    Spacer()
                }
                
                if selectedTab != lastPage {
                    Image(image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                }
                
                if selectedTab != lastPage {
                    Text(text)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .font(.title2)
                        .bold()
                        .frame(height: 100)
                        .dynamicTypeSize(.medium)
                } else {
                    Text(String.termsOfServiceTitle)
                        .fontWeight(.bold)
                        .font(.title2)
                        .dynamicTypeSize(.medium)
                    privacyPolicy
                }
                
                Spacer()
                Spacer()
            }
        }
    }
    
    // 同意ボタン
    private var agreeButton: some View {
        HStack {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                isAgree.toggle()
            } label: {
                if isAgree {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                } else {
                    Image(systemName: "circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                }
            }
            .foregroundStyle(Color.blue)
            .padding(.trailing, 5)
            
            Text("同意します")
                .font(.title3)
                .bold()
                .dynamicTypeSize(.medium)
        }
        .padding(.bottom)
    }
    
    // 利用規約
    private var privacyPolicy: some View {
        ScrollView {
            Text(String.termsOfServiceExplanation)
                .font(.subheadline)
                .frame(alignment: .leading)
                .dynamicTypeSize(.medium)
            ForEach(tutorialText, id: \.self) { tutorialText in
                Text(tutorialText.title)
                    .fontWeight(.bold)
                    .font(.title3)
                    .padding(.vertical)
                    .dynamicTypeSize(.medium)
                Text(tutorialText.text)
                    .font(.subheadline)
                    .frame(alignment: .leading)
                    .dynamicTypeSize(.medium)
            }
        }
        .frame(height: CGFloat(UIScreen.main.bounds.height / 2))
        .padding()
        .background(Color.chatLogBackground)
    }
}

#Preview {
    TutorialView(didCompleteTutorialProcess: {})
}
