//
//  SortType.swift
//  AllKindsOfSort
//
//  Created by Mr.LuDashi on 16/11/4.
//  Copyright © 2016年 ZeluLi. All rights reserved.
//

import Foundation

protocol SortType {
    func sort(_ items: Array<Int>) -> Array<Int>
    func setEveryStepClosure(_ everyStepClosure: @escaping SortResultClosure,
                             sortSuccessClosure: @escaping SortSuccessClosure) -> Void
}
