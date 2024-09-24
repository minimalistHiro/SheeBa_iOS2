//
//  StringExtension.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/08.
//

import Foundation

extension String {
    
    // Colors
//    static let highlight = "Highlight"
//    static let caution = "Caution"
//    static let chatLogBackground = "ChatLogBackground"
//    static let yellow = "Yellow"
//    static let green = "Green"
//    static let darkGreen = "DarkGreen"
//    static let brown = "Brown"
    
    // Image
    static let title = "Title"
    static let clearTitle = "ClearTitle"
    
    // Tutorial
    static func tutorialText(page: Int) -> String {
        switch page {
        case 1:
            return "SheeBaを\nダウンロードしていただき\nありがとうございます"
        case 2:
            return "各店舗にあるQRコードを読み取って\nポイントを貯めることができます"
        case 3:
            return "貯まったポイントは\n景品と交換することができます"
        case 4:
            return "QRコードをたくさんスキャンして\n欲しい商品をゲットしよう！"
        default :
            return ""
        }
    }
    static func tutorialImage(page: Int) -> String {
        switch page {
        case 1:
            return "Greeting"
        case 2:
            return ""
        case 3:
            return ""
        case 4:
            return ""
        default :
            return ""
        }
    }
    
    // UserDefault
    static let authVerificationID = "authVerificationID"
    
    // ErrorCode
    static let emptyEmailOrPassword = "メールアドレス、パスワードを入力してください。"
    static let invalidEmail = "メールアドレスの形式が正しくありません。"
    static let weakPassword = "パスワードは6文字以上で設定してください。"
    static let mismatchPassword = "パスワードとパスワード（確認用）が一致しません。"
    static let emailAlreadyInUse = "このメールアドレスはすでに登録されています。"
    static let userNotFound = "メールアドレス、またはパスワードが違います。"
    static let wrongEmail = "メールアドレスが違います。"
    static let userDisabled = "このユーザーアカウントは無効化されています。"
    static let networkError = "通信エラーが発生しました。"
    static let notFoundData = "データが見つかりませんでした。"
    static let failureFetchUID = "UIDの取得に失敗しました。"
    static let failureFetchUser = "ユーザー情報の取得に失敗しました。"
    static let failureFetchAllUser = "全ユーザーの取得に失敗しました。"
    static let failureFetchStorePoint = "店舗ポイント情報の取得に失敗しました。"
    static let failureFetchStores = "全店舗の取得に失敗しました。"
    static let failureDeleteData = "データ削除に失敗しました。"
    static let failureDeleteUser = "ユーザー情報の削除に失敗しました。"
    static let failureDeleteMessage = "メッセージの削除に失敗しました。"
    static let failureDeleteRecentMessage = "最新メッセージの削除に失敗しました。"
    static let failureDeleteFriend = "友達情報の削除に失敗しました。"
    static let failureDeleteStorePoint = "店舗ポイント情報の削除に失敗しました。"
    static let failureDeleteNotification = "お知らせの削除に失敗しました。"
    static let failureDeleteAdvertisement = "広告の削除に失敗しました。"
    static let failureDeleteStore = "店舗の削除に失敗しました。"
    static let failureDeleteImage = "画像の削除に失敗しました。"
    static let failureDeleteAuth = "認証情報の削除に失敗しました。"
    static let jumpToExternalLink = "外部リンクに飛びます。よろしいですか？"
    static let failureSendEmail = "メール送信に失敗しました。\nしばらく経ってから再度お試しください。"
    
    // Preview
    static let previewUsername = "test"
    static let previewAge = ages.first ?? ""
    static let previewAddress = addresses.first ?? ""
    static let previewEmail = "test@gmail.com"
    static let previewPhoneNumber = "0120123456"
    static let previewPassword = "12345678"
    
    // PrivacyPolicy
    static let termsOfServiceTitle = "利用規約"
    static let termsOfServiceExplanation = "本規約は、芝銀座通り商店会（以下「当会」といいます。）が提供する芝銀座通り商店会デジタルポイントアプリSheeBa（シーバ）（以下「本サービス」といいます。）を利用される際に適用されます。ご利用にあたっては、本規約をお読みいただき、内容をご承諾の上でご利用ください。"
    static let termsOfServiceTitle1 = "第1条（規約の適用）"
    static let termsOfServiceArticle1 = "　1.本規約は、当会が本サービスを提供する上で、利用者が本サービスの提供を受けるにあたっての諸条件を定めたものです。\n　2.当会は、本サービスの提供に関して、本規約のほか、本サービスの利用に関する個別規約その他のガイドライン等を定めることがあります。この場合、当該個別規約その他のガイドライン等は、本規約の一部として利用者による本サービスの利用に優先して適用されるものとします。\n　3.利用者が本サービスを利用された場合、利用者が本規約に同意したものとみなします。\n　4.利用者が、未成年の場合、利用者は、本サービスの利用について、親権者等法定代理人の同意を得なければなりません。当会は、未成年者の利用者による本サービスの利用については、親権者等法定代理人の同意を得て行為されたものとみなします。"
    static let termsOfServiceTitle2 = "第2条（パスワードの管理）"
    static let termsOfServiceArticle2 = "　1.利用者は、パスワードを厳重に管理し、保管するものとし、これを第三者に貸与、譲渡、売買その他の方法をもって利用させてはならないものとします。パスワードの管理が不十分なことにより、利用者が損害又は不利益を被ったとしても、当会は責任を負わないものとします。\n　2.パスワードを紛失又は忘失した場合、又はこれらが第三者に使用されていることが判明した場合、利用者は、直ちにその旨を当会に通知するものとします。\n　3.当会は、利用者に発行したパスワードによる本サービスの利用の一切につき、利用者による真正な利用か否かにかかわらず、利用者本人の行為とみなすものとし、利用者は当該行為の結果生じる一切の責任を負担するものとします。"
    static let termsOfServiceTitle3 = "第3条（景品交換やポイント利用）"
    static let termsOfServiceArticle3 = "　1.当会サービスは1ヶ月間の運用（2024年2月1日〜2024年2月29日）となり、期間外のポイント付与は不可となります。ポイントは2024年3月14日までの景品交換猶予期間以降、すべて消失します。\n　2.景品交換は商店街にある酒店「大門先屋」の１か所のみとし、「大門先屋」の営業時間にのみ交換できるものとします。\n　3.ポイントを不正入手したものと判断した場合、不正利用とみなし、そのユーザーのアカウントに紐づけられているポイントでの景品交換は一切禁止とします。\n　4.景品は、在庫がなくなり次第終了となります。"
    static let termsOfServiceTitle4 = "第4条（景品等の返品・交換）"
    static let termsOfServiceArticle4 = "本サービスに関し、景品等の返品及び交換は、一切受け付けておりません。未成年の利用者についても、親権者等法定代理人の同意のもと利用したものとみなされますので、景品の返品及び交換は受け付けておりません。"
    static let termsOfServiceTitle5 = "第5条（景品等に関する免責）"
    static let termsOfServiceArticle5 = "　1.本サービスを通じて交換される景品等の品質、機能、性能、他の物品との適合性その他の欠陥に関する当会の責任は、当会の故意又は重過失による場合に限られるものとします。\n　2.当会は、本サービスのウェブサイト上の表示及び利用者が投稿した商品等に関する写真及びコメント並びにTwitter、Instagramその他のSNSサービスに投稿したコメントについて、適法性、有用性、完全性、正確性、最新性、信頼性、特定目的への適合性を含め何らの保証をしません。"
    static let termsOfServiceTitle6 = "第6条（利用者へのお知らせ）"
    static let termsOfServiceArticle6 = "当会は、利用者に、当会が提供するサービスの最新情報やおすすめのお知らせのために定期的又は不定期に公式サイトにお知らせいたします。"
    static let termsOfServiceTitle7 = "第7条（サービスの内容の変更、追加、停止）"
    static let termsOfServiceArticle7 = "当会は、利用者に事前の通知をすることなく、本サービスの内容の全部又は一部を変更、追加又は停止する場合があり、利用者はこれをあらかじめ承諾するものとします。"
    static let termsOfServiceTitle8 = "第8条（個人情報）"
    static let termsOfServiceArticle8 = "当会は、利用者による本サービスの利用によって取得する個人情報を、当会のプライバシーポリシーに従い、適切に取り扱います。"
    static let termsOfServiceTitle9 = "第9条（禁止事項）"
    static let termsOfServiceArticle9 = "　1.利用者は、次の行為を行うことはできません。\n　　1.本サービスの運営を妨げ、又はそのおそれのある行為\n　　2.他の利用者による本サービスの利用を妨害する行為\n　　3.本サービスにかかる著作権その他の権利を侵害する行為\n　　4.当会、他の利用者又は第三者の権利又は利益（名誉権、プライバシー権及び著作権を含みますが、これらに限られません。）を侵害する行為\n　　5.公序良俗その他法令に違反する行為及びこれに違反する恐れのある行為\n　　6.本規約に違反する行為\n　　7.前各号の他、本サービスの趣旨に鑑みて当会が不適切と判断する行為\n　2.利用者が前項に定める行為を行ったと当会が判断した場合、当会は、利用者に事前に通知することなく、本サービスの全部又は一部の利用停止その他当会が必要かつ適切と判断する措置を講じることができます。本項の措置により利用者に生じる損害又は不利益について、当会は、一切の責任を負わないものとします。"
    static let termsOfServiceTitle10 = "第10条（お問い合わせ窓口）"
    static let termsOfServiceArticle10 = "本規約に関するお問い合わせは、下記の窓口までお願いいたします。\n住所：川口市芝3871-2\n会名：芝銀座通り商店会\n会長：平田輝久\n担当部署：事業部\nEメールアドレス：sheeba.point.project@gmail.com\n\n　　　　　　　　　　　　　　　　　　　　　以上"
}
