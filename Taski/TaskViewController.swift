//
//  TaskViewController.swift
//  Taski
//
//  Created by Виталий Гринчик on 18.05.23.
//

import UIKit
// Здесь этого быть не должно: Вьюконтроллер не должен знать о БД. Всё перенести в StorageManager
import CoreData

class TaskViewController: UIViewController {
    
    var delegate: TaskViewControllerDelegate?
    // Создаем свойства для "входа" в контекст БД (Managed ObjectContext), т.е. области ОЗУ, содержащей объекты, подлежащие сохранению
    // as! - временное решение, для примера
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer
        .viewContext
   
    // Lazy позволяет отложить инициализацию до момента первого обращения к этому свойству
    private lazy var taskTextFiled: UITextField = {
        let textFiled = UITextField()
        textFiled.borderStyle = .roundedRect
        textFiled.placeholder = "New task"
        textFiled.clearButtonMode = .whileEditing
        return textFiled
    }()
    
    private lazy var saveButton: UIButton = {
        let buttonColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        let action = UIAction { [unowned self] _ in saveTask() }
        return createButton(withTitle: "Save", andColor: buttonColor, action: action)
    }()
    
    private lazy var cancelButton: UIButton = {
        let buttonColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        let action = UIAction { [unowned self] _ in dismiss(animated: true) }
        return createButton(withTitle: "Cancel", andColor: buttonColor, action: action)
    }()
        
        // 2-й вариант кнопки
//        let saveButton = UIButton(type: .system)
//        saveButton.setTitle("Save", for: .normal)
//        saveButton.backgroundColor = .systemBlue
//        saveButton.setTitleColor(.white, for: .normal)
//        return saveButton
//    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupSubviews(taskTextFiled, saveButton, cancelButton)
        layoutViews()
    }
    // 2-й вариант кнопки
//    override func viewDidLayoutSubviews() {
//        saveButton.layer.cornerRadius = saveButton.frame.height / 2
//    }
    
    private func setupSubviews(_ subviews: UIView...) {
        subviews.forEach { view.addSubview($0)}
    }
    
    private func layoutViews() {
        // отключение сториборд
        taskTextFiled.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            taskTextFiled.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            taskTextFiled.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            taskTextFiled.widthAnchor.constraint(equalToConstant: 250),
            
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.topAnchor.constraint(equalTo: taskTextFiled.bottomAnchor, constant: 40),
            saveButton.widthAnchor.constraint(equalTo: taskTextFiled.widthAnchor),
            
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalTo: taskTextFiled.widthAnchor)
        ])
        
    }
    
    private func createButton(withTitle title: String, andColor color: UIColor, action: UIAction) -> UIButton {
        var attributes = AttributeContainer()
        attributes.font = UIFont.boldSystemFont(ofSize: 18)
        
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.attributedTitle = AttributedString(title, attributes: attributes)
        buttonConfig.baseBackgroundColor = color
        return UIButton(configuration: buttonConfig, primaryAction: action)
    }
    
    private func saveTask() {
        // Создаём экземпляр модели в контексте БД
        let task = Task(context: viewContext)
        // Передаем данные в атрибут объекта модели БД
        task.title = taskTextFiled.text
        // Сохранение если были изменения
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                delegate?.reloadData()
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
        dismiss(animated: true)
    }

}
