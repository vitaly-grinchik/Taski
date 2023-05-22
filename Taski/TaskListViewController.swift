//
//  TaskListViewController.swift
//  Taski
//
//  Created by Виталий Гринчик on 18.05.23.
//

import UIKit

class TaskListViewController: UITableViewController {

    // Варианты Alert Controller
    private enum AlertType: String {
        case addTask = "Add task"
        case editTask = "Edit task"
        case deleteTask = "Delete task"
        case nameErrorMessage = "Task name already exists"
    }
    
    // Доступ к зоне ОЗУ с объектами БД
    private let viewContext = StorageManager.shared.persistentContainer.viewContext
    
    private let cellID = "taskCell"
    
    private var taskList = [Task]()
    
    lazy private var addButton = UIBarButtonItem(
        barButtonSystemItem: .add,
        target: self,
        action: #selector(addTask)
    )
    
    private let appColor = UIColor(
        red: 21/255,
        green: 101/255,
        blue: 192/255,
        alpha: 194/255
    )
    
    // Handlers контекстного свайпа
    private let editRowHandler: (() -> Void) = { print("Edit row finished") }
    
    private let deleteRowHandler: (() -> Void) = { print("Deletion finished") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Регистрация ячеки таблицы
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNaviBar()
        fetchData()
    }
    
    // Настройка navigation bar
    private func setupNaviBar() {
        let naviBarAppearance = UINavigationBarAppearance()
        
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true // Крупный шрифт названия
        
        // Цвета
        navigationController?.navigationBar.tintColor = .white
        naviBarAppearance.backgroundColor = appColor
        naviBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // для рекомендованного Apple крупного размера текста
        naviBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white] // для обычного размера текста
        
        // Стиль текста (аттрибуты)
        navigationController?.navigationBar.standardAppearance = naviBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = naviBarAppearance
        
        // Добавляем системные кнопки "Addz"
        navigationItem.rightBarButtonItem = addButton
    
    }
    
    // MARK: - Add, edit, delete task records
    @objc private func addTask() {
        showAlert(ofType: .addTask,
                         withTitle: "New task",
                         andMessage: "Add task title"
        )
        
    }
    
    private func deleteTask(_ task: Task) {
        guard let index = taskList.firstIndex(of: task) else { return }
        taskList.remove(at: index)
    }
    
    private func editTask(_ task: Task) {
        
    }
    
    private func checkForTitleUnique(_ taskTitle: String) -> Bool {
        for task in taskList {
            if task.title == taskTitle {
                return true
            }
        }
        return false
    }
    // MARK: - Fetch and save data
    private func fetchData() {
        // Указываем, какой тип данных нужно извлечь из БД -> тип Task
        let fetchRequest = Task.fetchRequest()
        // Пробуем извлечь данные
        do {
            taskList = try viewContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func saveData() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Alert controller configuration
    private func showAlert(ofType alertType: AlertType, withTitle title: String, andMessage message: String) {
        // Инициализация контроллера
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // Определение действий
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            dismiss(animated: true)
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
//            saveTask(task)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] _ in
            dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { [unowned self] _ in
            dismiss(animated: true)
        }
        
        // Привязка действий к контроллеру в зависимости от действия с задачей
        switch alertType {
        case .addTask:
            // Добавление текстового поля
            // Пустое текстовое поле (с placeholder)
            alert.addTextField { textField in
                textField.clearButtonMode = .whileEditing
                textField.placeholder = "Task name"
            }
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
        case .editTask:
            // Текстовое поле с повторением названия задачи
            alert.addTextField { textField in
                textField.clearButtonMode = .whileEditing
                //                textField.text = title
            }
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
        case .deleteTask:
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
        case .nameErrorMessage:
            alert.addAction(cancelAction)
        }
        present(alert, animated: true)
    }

    
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editRowAction = UIContextualAction(style: .normal, title: nil) { [unowned self] _, _, _ in
            
            showAlert(ofType: .editTask,
                      withTitle: "Edit task",
                      andMessage: "Change task name?"
            )
        }
        editRowAction.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        editRowAction.image = UIImage(systemName: "pencil.line")
        
        let deleteRowAction = UIContextualAction(style: .destructive, title: nil) { [unowned self] _, _, _ in
            print("Deleting...")
            deleteRowHandler()
        }
        deleteRowAction.image = UIImage(systemName: "trash")
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteRowAction, editRowAction])
        // Не выполнять первое действия при полном свайпе
//        swipeConfig.performsFirstActionWithFullSwipe = false
        
        return swipeConfig
    }
    
}
