//
//  User.swift
//  Pace Maker
//
//  Created by 성준오 on 2021/04/15.
//

import Foundation

struct User {
    var name: String
    var id: String
    var info: String
}

var users: [User] = [
    User(name: "ohsungjoon", id: "joon2387", info: """
국가는 균형있는 국민경제의 성장 및 안정과 적정한 소득의 분배를 유지하고, 시장의 지배와 경제력의 남용을 방지하며, 경제주체간의 조화를 통한 경제의 민주화를 위하여 경제에 관한 규제와 조정을 할 수 있다.
"""),
    User(name: "sungjoonoh", id: "osj2387", info: """
대법원은 법률에 저촉되지 아니하는 범위안에서 소송에 관한 절차, 법원의 내부규율과 사무처리에 관한 규칙을 제정할 수 있다. 국회는 헌법 또는 법률에 특별한 규정이 없는 한 재적의원 과반수의 출석과 출석의원 과반수의 찬성으로 의결한다. 가부동수인 때에는 부결된 것으로 본다
"""),
    User(name: "joonohsung", id: "keeve0317", info: """
국가원로자문회의의 의장은 직전대통령이 된다. 다만, 직전대통령이 없을 때에는 대통령이 지명한다. 대통령의 임기는 5년으로 하며, 중임할 수 없다. 국회의원이 회기전에 체포 또는 구금된 때에는 현행범인이 아닌 한 국회의 요구가 있으면 회기중 석방된다.
""")
]
