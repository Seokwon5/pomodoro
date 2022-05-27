//
//  ViewController.swift
//  pomodoro
//
//  Created by 이석원 on 2022/05/23.
//

import UIKit
import AudioToolbox

enum TimerStatus {
    case Start
    case pause
    case end
}

class ViewController: UIViewController {
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var duration = 60 //1분으로 초기화
    var timerStatus : TimerStatus = .end
    var timer: DispatchSourceTimer?
    var currentSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureToggleButton()
    }
    
    //TimerLabel, ProgressView를 숨기기
    func setTimerInfoVisible(isHidden : Bool) {
        self.timerLabel.isHidden = isHidden
        self.progressView.isHidden = isHidden
    }
     
    func configureToggleButton() {
        self.toggleButton.setTitle("시작", for: .normal)
        self.toggleButton.setTitle("일시정지", for: .selected)
    }
    
    func startTimer() {
        if self.timer == nil {
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            self.timer?.schedule(deadline: .now(), repeating: 1)
            self.timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else {return} //일시적으로 self를 strong레퍼런스로.
                self.currentSeconds -= 1 //1초에 한번씩 currentSeconds 감소
                let hour = self.currentSeconds / 3600
                let minutes = (self.currentSeconds % 3600) / 60
                let seconds = (self.currentSeconds % 3600) % 60
                self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds)
                self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
                UIView.animate(withDuration: 0.5, delay: 0, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi) //view를 180도 회전.
                })
                UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2) //360도 회전.
                })
              
                if self.currentSeconds <= 0 {
                    self.stopTimer()
                    AudioServicesPlaySystemSound(1005)
                }
            })
            self.timer?.resume() //타이머 시작
        }
    }
    
    func stopTimer(){
        if timerStatus == .pause {
            self.timer?.resume()
        }
        self.timer?.cancel() //stop
        self.timer = nil //메모리에서 해제
        self.timerStatus = .end
        self.cancelButton.isEnabled = false
        self.toggleButton.isSelected = false
        UIView.animate(withDuration: 0.5,animations: {
            self.timerLabel.alpha = 0
            self.progressView.alpha = 0
            self.datePicker.alpha  = 1
            self.imageView.transform = .identity
        })
        
    }

    @IBAction func tapcancleButton(_ sender: UIButton) {
        switch self.timerStatus {
        case .Start, .pause:
            self.stopTimer()
        default: break
        }
    }
    
    @IBAction func tapToggleButton(_ sender: UIButton) {
        self.duration = Int(self.datePicker.countDownDuration) //datePicker의 설정시간을 초단위로 변환.
        switch self.timerStatus {
        case .end: //시작할때
            self.currentSeconds = self.duration
            self.timerStatus = .Start //시작 -> 일시정지
            UIView.animate(withDuration: 0.5, animations: {
                self.timerLabel.alpha = 1
                self.progressView.alpha = 1
                self.datePicker.alpha = 0
            })
            self.toggleButton.isSelected = true //시작버튼 -> 일시정지버튼
            self.cancelButton.isEnabled = true //취소버튼 활성화
            self.startTimer()
             
        case .Start: //일시정지 버튼을 눌렀을때
            self.timerStatus = .pause
            self.toggleButton.isSelected = false
            self.timer?.suspend()
            
        case .pause: //다시 재시작할때
            self.timerStatus = .Start
            self.toggleButton.isSelected = true
            self.timer?.resume()
             
        }
        
    }


}

