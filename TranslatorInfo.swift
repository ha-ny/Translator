//
//  TranslatorInfo.swift
//  Translator
//
//  Created by 김하은 on 2023/08/10.
//

import Foundation

struct TranslatorInfo{
    struct language{
        let code: String
        let name: String
    }
    
    static let languageList: [language] = [
        language(code: "ko", name: "한국어"),
        language(code: "en", name: "영어"),
        language(code: "ja", name: "일본어"),
        language(code: "zh-CN", name: "중국어 간체"),
        language(code: "zh-TW", name: "중국어 번체"),
        language(code: "vi", name: "베트남어"),
        language(code: "id", name: "인도네시아어"),
        language(code: "th", name: "태국어"),
        language(code: "de", name: "독일어"),
        language(code: "ru", name: "러시아어"),
        language(code: "es", name: "스페인어"),
        language(code: "it", name: "이탈리아어"),
        language(code: "fr", name: "프랑스어"),
    ]
}
