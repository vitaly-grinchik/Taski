//
//  TaskListViewController.swift
//  Taski
//
//  Created by Виталий Гринчик on 18.05.23.
//

import UIKit

class TaskListViewController: UITableViewController {

    private enum TaskAction: String {
        case addTask = "Add task"
        case editTask = "Edit task"
        case deleteTask = "Delete task"
    }
    
    // Доступ к зоне ОЗУ с объектами БД
    private let viewContext = StorageManager.shared.persistentContainer.viewContext
    
    private let cellID = "taskCell"
    
    private var taskList = [Task]() {
        didSet {
//            updateData()
        }
    }
    
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
    
    private let editRowHandler: (() -> Void) = {}
    
    private let deleteRowHandler: (() -> Void) = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Регистрация ячеки таблицы
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        setupNaviBar()
        fetchData()
    }
    
    private func setupNaviBar() {
        // Настройка представления navigation bar
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
    
    @objc private func addTask() {
        showDefaultAlert(forAction: .addTask, withTitle: "New task",
                  andMessage: "Add task name"
        )
    }
            
    private func deleteTask(_ task: Task) {
        
    }
    
    private func editTask(_ task: Task) {
        
    }
    
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
    
    private func showDefaultAlert(forAction action: TaskAction, withTitle title: String, andMessage message: String) {
        // Инициализация контроллера
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // Определение действий
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            save(task)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        // Привязка действий к контроллеру в зависимости от действия с задачей
        switch action {
        case .addTask:
            // Добавление текстового поля
            alert.addTextField { textField in
                textField.clearButtonMode = .whileEditing
                textField.placeholder = "Task name"
            }
            alert.addAction(saveAction)
        case .editTask:
            alert.addTextField { textField in
                textField.clearButtonMode = .whileEditing
                textField.text = title
            }
            alert.addAction(saveAction)
        case .deleteTask:
            alert.addAction(deleteAction)
        }
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        // Создаём экземпляр модели в контексте БД
        let task = Task(context: viewContext)
        // Передаем данные в атрибут объекта модели БД
        task.title = taskName
        taskList.append(task)
        // Определяем индекс последнего элемента для добавления в конец списка
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        // Сохранение если были изменения
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
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
        let editRowAction = UIContextualAction(style: .normal, title: "Edit") { action, _, _ in
            print("Editing...")
        }
        editRowAction.backgroundColor = appColor
        
        let deleteRowAction = UIContextualAction(style: .destructive, title: "Delete") { action, _, _ in
            print("Deleting...")
        }
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [editRowAction, deleteRowAction])
        // Не выполнять первое действия при полном свайпе
        swipeConfig.performsFirstActionWithFullSwipe = false
        
        return swipeConfig
    }
    
}
