//
//  AuralTests.swift
//  AuralTests
//
//  Created by Oscar Verrico on 11/4/24.
//

import Testing
import XCTest

@testable import Aural

class AuralTests: XCTestCase {
    var audioBox: AudioBox!
    
    override func setUp() {
        super.setUp()
        audioBox = AudioBox()
    }
    
    func testAudioLoad() {
        let url = URL(fileURLWithPath: "/path/to/test/audio.mp3")
        audioBox.loadAudioFile(from: url)
        XCTAssertNotNil(audioBox.audioPlayer)
    }
}
