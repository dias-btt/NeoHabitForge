//
//  TimePickerViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 28.02.2024.
//
//
//  TimePickerViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 28.02.2024.
//

import UIKit
import SnapKit

protocol TimePickerViewControllerDelegate: AnyObject {
    func nextPageRequested(selectedTime: String)
}

class TimePickerViewController: UIViewController {
    
    var selectedTime: String?
    weak var delegate: TimePickerViewControllerDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let datePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("Далее", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "SecondaryColor")
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(datePicker)
        view.addSubview(nextButton)
        
        if let selectedTime = selectedTime {
            let timeComponents = selectedTime.components(separatedBy: ":")
            if timeComponents.count == 2, let hour = Int(timeComponents[0]), let minute = Int(timeComponents[1]) {
                datePicker.selectRow(hour, inComponent: 0, animated: false)
                datePicker.selectRow(minute, inComponent: 1, animated: false)
            }
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(400)
            make.height.equalTo(50)
        }
        
        datePicker.delegate = self
        datePicker.dataSource = self
    }
    
    @objc func nextButtonTapped() {
        delegate?.nextPageRequested(selectedTime: self.selectedTime ?? "00:00")
    }
}

extension TimePickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // Hour and minute components
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10000
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let value = row % (component == 0 ? 24 : 60)
        return String(format: "%02d", value)
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 80 // Adjust the width of components (hours and minutes)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedHour = pickerView.selectedRow(inComponent: 0)
        let selectedMinute = pickerView.selectedRow(inComponent: 1)
        let hourString = String(format: "%02d", selectedHour)
        let minuteString = String(format: "%02d", selectedMinute)
        self.selectedTime = "\(hourString):\(minuteString)"
    }

}

